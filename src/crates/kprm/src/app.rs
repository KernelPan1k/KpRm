//! `KprmApp`: the GUI's screens, built on `kprm-win32gui`'s owner-drawn
//! `AppWindow` (see `../../kprm-win32gui/src/window.rs`) rather than
//! `egui`/`eframe` — see `../../BUILDING.md` and the project's rewrite plan
//! for why. Real actions run on a background thread (see [`crate::worker`])
//! so the UI never freezes during a scan/removal.
//!
//! **Porting status**: the title bar, startup disclaimer, tab bar, and
//! footer are fully ported. Each tab's own content and the two modal
//! dialogs are still placeholders — being filled in phase by phase; see
//! the rewrite plan.

use std::collections::HashSet;
use std::sync::mpsc::{Receiver, Sender};

use kprm_engine::quarantine::QuarantineMode;
use kprm_engine::report::{Event, EventResult, Report};
use kprm_win32gui::color::Color;
use kprm_win32gui::gdiplus::{Graphics, Pen, SolidBrush, StringFormat};
use kprm_win32gui::icons::Icon;
use kprm_win32gui::image::Bitmap;
use kprm_win32gui::scroll::ScrollState;
use kprm_win32gui::window::{AppWindow, HitZone};
use windows::Win32::Foundation::HWND;
use windows::Win32::Graphics::GdiPlus::{RectF, StringAlignmentCenter, StringAlignmentNear};

use crate::app_icons;
use crate::theme::{self, Fonts};
use crate::worker::{self, WorkerRequest, WorkerResponse};

const TITLE_BAR_HEIGHT: f32 = 46.0;
const TAB_BAR_HEIGHT: f32 = 44.0;
const FOOTER_HEIGHT: f32 = 44.0;
const BTN_SIZE: f32 = 26.0;
const BTN_MARGIN_TOP: f32 = 10.0;
const BTN_RIGHT_MARGIN: f32 = 8.0;
const BTN_GAP: f32 = 4.0;
const DISCLAIMER_BTN_SIZE: (f32, f32) = (90.0, 32.0);
const DISCLAIMER_TITLE_Y: f32 = 100.0;
const DISCLAIMER_BODY_Y: f32 = 150.0;
const DISCLAIMER_BODY_HEIGHT: f32 = 260.0;
const DISCLAIMER_BUTTONS_Y: f32 = DISCLAIMER_BODY_Y + DISCLAIMER_BODY_HEIGHT + 20.0;

const CONTENT_PAD_X: f32 = 24.0;
const CONTENT_PAD_TOP: f32 = 20.0;
const SIDEBAR_WIDTH: f32 = 168.0;
const COLUMN_GAP: f32 = 20.0;
const CARD_GAP: f32 = 10.0;
const CARD_HEIGHT: f32 = 78.0;
const SEGMENT_GAP: f32 = 10.0;
const SEGMENT_HEIGHT: f32 = 52.0;
const RUN_BUTTON_SIZE: (f32, f32) = (120.0, 34.0);

const TOOLBAR_HEIGHT: f32 = 32.0;
const LIST_GAP: f32 = 10.0;
const RESULT_ROW_HEIGHT: f32 = 34.0;
const BUTTONS_ROW_HEIGHT: f32 = 34.0;

#[derive(PartialEq, Eq, Clone, Copy, Debug)]
enum Tab {
    Automatic,
    Custom,
    ExtraTools,
    Donate,
}

#[derive(PartialEq, Clone, Copy, Debug)]
enum QuarantineChoice {
    Keep,
    Now,
    In7Days,
}

impl From<QuarantineChoice> for QuarantineMode {
    fn from(choice: QuarantineChoice) -> Self {
        match choice {
            QuarantineChoice::Keep => QuarantineMode::Keep,
            QuarantineChoice::Now => QuarantineMode::Now,
            QuarantineChoice::In7Days => QuarantineMode::In7Days,
        }
    }
}

#[derive(PartialEq, Clone, Copy, Debug)]
enum UiButton {
    Minimize,
    Close,
    DisclaimerAccept,
    DisclaimerDecline,
    Tab(Tab),
    ActionCard(usize),
    QuarantineSeg(QuarantineChoice),
    RunButton,
    SelectAll,
    SelectNone,
    Clear,
    ResultRow(usize),
    SearchButton,
    RemoveSelectedButton,
}

#[allow(dead_code)] // wired up again once each tab is ported
pub struct KprmApp {
    tab: Tab,
    fonts: Fonts,
    logo: Bitmap,

    opt_remove_tools: bool,
    opt_backup_registry: bool,
    opt_remove_restore_points: bool,
    opt_create_restore_point: bool,
    opt_restore_uac: bool,
    opt_restore_settings: bool,
    quarantine_choice: QuarantineChoice,

    status: String,
    busy: bool,
    progress: Option<(usize, usize)>,

    scan_results: Vec<(kprm_engine::report::Event, bool)>,

    show_restart_dialog: bool,
    available_backups: Vec<kprm_engine::backup::AvailableBackup>,
    selected_backup: Option<kprm_engine::backup::AvailableBackup>,
    confirm_restore: Option<kprm_engine::backup::AvailableBackup>,

    /// Gates the whole app behind the startup disclaimer until accepted,
    /// matching the original — see `ui_disclaimer`.
    disclaimer_accepted: bool,

    t: kprm_i18n::Translations,

    request_tx: Sender<WorkerRequest>,
    response_rx: Receiver<WorkerResponse>,

    hover: Option<UiButton>,
    pressed: Option<UiButton>,
    close_requested: bool,
    minimize_requested: bool,

    /// The tab labels' rects from the *last* paint — text-width-dependent,
    /// so recomputed every `draw_tab_bar` call rather than hardcoded; mouse
    /// hit-testing (which has no `Graphics` to measure text with) reads
    /// this cache instead of re-measuring.
    tab_rects: Vec<(Tab, RectF)>,
    /// The 6 action-row checkbox cards' rects from the last paint, indexed
    /// the same as the `opt_*` fields are checked in `action_card_specs`.
    action_rects: Vec<RectF>,
    quarantine_rects: Vec<(QuarantineChoice, RectF)>,
    run_button_rect: RectF,

    /// The Custom tab's result-list scroll area — see
    /// `kprm_win32gui::scroll` (the rewrite plan's highest-risk primitive).
    scroll: ScrollState,
    toolbar_button_rects: Vec<(UiButton, RectF)>,
    search_button_rect: RectF,
    remove_selected_button_rect: RectF,

    /// Read once at startup; the number of tools the embedded catalog
    /// knows about, shown in the Automatic tab's sidebar stat card.
    catalog_tool_count: usize,
    /// The last recorded successful run's timestamp (see
    /// `kprm_engine::last_run`), shown in the same sidebar — `None` until
    /// the first run completes.
    last_run: Option<String>,
}

impl KprmApp {
    pub fn new(translations: kprm_i18n::Translations, hwnd: HWND) -> Self {
        let (response_tx, response_rx) = std::sync::mpsc::channel();
        let request_tx = worker::spawn(response_tx, hwnd);
        let status = translations
            .get("status-ready")
            .unwrap_or_else(|_| "Ready".to_string());

        let logo = Bitmap::from_png_bytes(include_bytes!("../assets/bug.png"))
            .expect("embedded bug.png must decode");
        logo.recolor_white().expect("bug.png recolor must succeed");

        let catalog_tool_count = kprm_catalog::Catalog::embedded().map(|c| c.tools().len()).unwrap_or(0);
        let last_run = kprm_engine::last_run::read(&kprm_windows::WinRegistry);

        Self {
            tab: Tab::Automatic,
            fonts: Fonts::load().expect("embedded fonts must load"),
            logo,
            opt_remove_tools: true,
            opt_backup_registry: false,
            opt_remove_restore_points: false,
            opt_create_restore_point: false,
            opt_restore_uac: false,
            opt_restore_settings: false,
            quarantine_choice: QuarantineChoice::Keep,
            status,
            busy: false,
            progress: None,
            scan_results: Vec::new(),
            show_restart_dialog: false,
            available_backups: kprm_windows::list_registry_backups(
                &kprm_windows::EnvKnownDirs::detect(),
            ),
            selected_backup: None,
            confirm_restore: None,
            disclaimer_accepted: false,
            t: translations,
            request_tx,
            response_rx,
            hover: None,
            pressed: None,
            close_requested: false,
            minimize_requested: false,
            tab_rects: Vec::new(),
            action_rects: Vec::new(),
            quarantine_rects: Vec::new(),
            run_button_rect: RectF::default(),
            scroll: ScrollState::default(),
            toolbar_button_rects: Vec::new(),
            search_button_rect: RectF::default(),
            remove_selected_button_rect: RectF::default(),
            catalog_tool_count,
            last_run,
        }
    }

    fn t(&self, key: &str) -> String {
        self.t.get(key).unwrap_or_else(|_| key.to_string())
    }

    #[allow(dead_code)]
    fn tf(&self, key: &str, args: &[(&str, &str)]) -> String {
        self.t
            .get_fmt(key, args)
            .unwrap_or_else(|_| key.to_string())
    }

    fn poll_worker(&mut self) {
        while let Ok(response) = self.response_rx.try_recv() {
            match response {
                WorkerResponse::Progress { current, total } => {
                    self.progress = Some((current, total));
                }
                WorkerResponse::Done(report) => {
                    self.busy = false;
                    self.progress = None;
                    self.status = self.tf(
                        "status-done",
                        &[("count", &report.events.len().to_string())],
                    );
                    self.handle_report(report);
                }
                WorkerResponse::DiagnosticDone(path) => {
                    self.busy = false;
                    self.progress = None;
                    self.status = self.tf("diag-status-done", &[("path", &path)]);
                }
                WorkerResponse::Failed(message) => {
                    self.busy = false;
                    self.progress = None;
                    self.status = format!("{} : {message}", self.t("fail"));
                }
            }
        }
    }

    fn handle_report(&mut self, report: Report) {
        let is_scan_result = !report.events.is_empty()
            && report.events.iter().all(|e| e.result == EventResult::Found);

        if is_scan_result {
            self.scan_results = report.events.into_iter().map(|e| (e, true)).collect();
        } else {
            if report.needs_restart() {
                self.show_restart_dialog = true;
            }
            let handled: HashSet<String> = report
                .events
                .iter()
                .filter(|e| {
                    matches!(
                        e.result,
                        EventResult::Removed | EventResult::ScheduledOnReboot
                    )
                })
                .map(|e| e.target.clone())
                .collect();
            self.scan_results
                .retain(|(e, _)| !handled.contains(&e.target));
        }
    }

    fn title_bar_button_rect(&self, width: f32, btn: UiButton) -> RectF {
        let close_x = width - BTN_RIGHT_MARGIN - BTN_SIZE;
        let minimize_x = close_x - BTN_GAP - BTN_SIZE;
        let x = match btn {
            UiButton::Close => close_x,
            _ => minimize_x,
        };
        RectF { X: x, Y: BTN_MARGIN_TOP, Width: BTN_SIZE, Height: BTN_SIZE }
    }

    fn disclaimer_button_rect(&self, width: f32, _height: f32, btn: UiButton) -> RectF {
        let (w, h) = DISCLAIMER_BTN_SIZE;
        let total_w = w * 2.0 + 8.0;
        let left = (width - total_w) / 2.0;
        let x = match btn {
            UiButton::DisclaimerAccept => left,
            _ => left + w + 8.0,
        };
        RectF { X: x, Y: DISCLAIMER_BUTTONS_Y, Width: w, Height: h }
    }

    fn button_at(&self, width: f32, height: f32, x: f32, y: f32) -> Option<UiButton> {
        for btn in [UiButton::Minimize, UiButton::Close] {
            if rect_contains(self.title_bar_button_rect(width, btn), x, y) {
                return Some(btn);
            }
        }
        if !self.disclaimer_accepted {
            for btn in [UiButton::DisclaimerAccept, UiButton::DisclaimerDecline] {
                if rect_contains(self.disclaimer_button_rect(width, height, btn), x, y) {
                    return Some(btn);
                }
            }
        } else {
            for (tab, rect) in &self.tab_rects {
                if rect_contains(*rect, x, y) {
                    return Some(UiButton::Tab(*tab));
                }
            }
            if self.tab == Tab::Automatic {
                for (i, rect) in self.action_rects.iter().enumerate() {
                    if rect_contains(*rect, x, y) {
                        return Some(UiButton::ActionCard(i));
                    }
                }
                for (choice, rect) in &self.quarantine_rects {
                    if rect_contains(*rect, x, y) {
                        return Some(UiButton::QuarantineSeg(*choice));
                    }
                }
                if rect_contains(self.run_button_rect, x, y) && self.can_run() {
                    return Some(UiButton::RunButton);
                }
            } else if self.tab == Tab::Custom {
                for (btn, rect) in &self.toolbar_button_rects {
                    if rect_contains(*rect, x, y) {
                        return Some(*btn);
                    }
                }
                if self.scroll.contains(x, y) {
                    let relative_y = (y - self.scroll.last_viewport.Y) + self.scroll.offset;
                    if relative_y >= 0.0 {
                        let index = (relative_y / RESULT_ROW_HEIGHT) as usize;
                        if index < self.scan_results.len() {
                            return Some(UiButton::ResultRow(index));
                        }
                    }
                }
                if rect_contains(self.search_button_rect, x, y) && !self.busy {
                    return Some(UiButton::SearchButton);
                }
                if rect_contains(self.remove_selected_button_rect, x, y) && self.can_remove_selected() {
                    return Some(UiButton::RemoveSelectedButton);
                }
            }
        }
        None
    }

    /// At least one action must be checked, and nothing may already be
    /// running — mirrors the original's `can_run` gate on the run button.
    fn can_run(&self) -> bool {
        !self.busy
            && (self.opt_remove_tools
                || self.opt_backup_registry
                || self.opt_remove_restore_points
                || self.opt_create_restore_point
                || self.opt_restore_uac
                || self.opt_restore_settings)
    }

    fn can_remove_selected(&self) -> bool {
        !self.busy && self.scan_results.iter().any(|(_, checked)| *checked)
    }

    fn draw_title_bar(&self, g: &Graphics, width: f32) {
        let titlebar_bg = SolidBrush::new(theme::BG_ELEVATED.to_argb()).unwrap();
        g.fill_rect(RectF { X: 0.0, Y: 0.0, Width: width, Height: TITLE_BAR_HEIGHT }, &titlebar_bg)
            .unwrap();
        let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
        g.draw_line(0.0, TITLE_BAR_HEIGHT, width, TITLE_BAR_HEIGHT, &border).ok();

        self.logo
            .draw(g, RectF { X: 16.0, Y: 8.0, Width: 30.0, Height: 30.0 })
            .ok();

        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let text_1 = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        g.draw_string(
            "KpRm",
            &self.fonts.proportional(15.0),
            RectF { X: 54.0, Y: 14.0, Width: 100.0, Height: 20.0 },
            &near,
            &text_1,
        )
        .unwrap();

        let pill_rect = RectF { X: 106.0, Y: 12.0, Width: 60.0, Height: 20.0 };
        let pill_bg = SolidBrush::new(theme::BG_PANEL.to_argb()).unwrap();
        g.fill_rounded_rect(pill_rect, 999.0, &pill_bg).unwrap();
        g.draw_rounded_rect(pill_rect, 999.0, &border).unwrap();
        let text_2 = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        g.draw_string(
            concat!("v", env!("CARGO_PKG_VERSION")),
            &self.fonts.monospace(10.5),
            pill_rect,
            &center,
            &text_2,
        )
        .unwrap();

        let text_3 = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
        g.draw_string(
            "by kernel-panik",
            &self.fonts.proportional(10.5),
            RectF { X: 176.0, Y: 15.0, Width: 100.0, Height: 18.0 },
            &near,
            &text_3,
        )
        .unwrap();

        for btn in [UiButton::Minimize, UiButton::Close] {
            let r = self.title_bar_button_rect(width, btn);
            let is_hover = self.hover == Some(btn);
            if is_hover {
                let fill_color = if btn == UiButton::Close { theme::RED_BG } else { theme::BG_HOVER };
                let fill = SolidBrush::new(fill_color.to_argb()).unwrap();
                g.fill_rounded_rect(r, 6.0, &fill).unwrap();
            }
            let glyph_color = if is_hover && btn == UiButton::Close { theme::RED } else { theme::TEXT_2 };
            let glyph_brush = SolidBrush::new(glyph_color.to_argb()).unwrap();
            let glyph = if btn == UiButton::Minimize { "\u{2014}" } else { "\u{00D7}" };
            g.draw_string(glyph, &self.fonts.proportional(14.0), r, &center, &glyph_brush)
                .unwrap();
        }
    }

    /// The startup "AS IS, no warranty, no commercial use" disclaimer —
    /// shown unconditionally on every launch (not persisted), matching the
    /// original. Declining closes the window immediately.
    fn draw_disclaimer(&self, g: &Graphics, width: f32, height: f32) {
        let title = self.t("eula-title");
        let body = self.t("eula-body");
        let accept_label = self.t("eula-accept");
        let decline_label = self.t("eula-decline");

        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();

        let title_brush = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        g.draw_string(
            &title,
            &self.fonts.proportional(17.0),
            RectF { X: 0.0, Y: DISCLAIMER_TITLE_Y, Width: width, Height: 26.0 },
            &center,
            &title_brush,
        )
        .unwrap();

        // GDI+'s `DrawString` wraps to the rect's *width* but does not
        // clip to its *height* by default — it just keeps drawing wrapped
        // lines past the bottom if the text doesn't fit, so this height
        // needs real headroom (`DISCLAIMER_BODY_HEIGHT`) rather than being
        // tight around the expected text, unlike a clipped/scrollable
        // widget.
        let body_brush = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
        g.draw_string(
            &body,
            &self.fonts.proportional(13.0),
            RectF {
                X: 80.0,
                Y: DISCLAIMER_BODY_Y,
                Width: width - 160.0,
                Height: DISCLAIMER_BODY_HEIGHT,
            },
            &center,
            &body_brush,
        )
        .unwrap();

        let accept_rect = self.disclaimer_button_rect(width, height, UiButton::DisclaimerAccept);
        let accept_fill = SolidBrush::new(theme::GREEN.to_argb()).unwrap();
        g.fill_rounded_rect(accept_rect, theme::RADIUS, &accept_fill).unwrap();
        let accept_text = SolidBrush::new(Color::rgb(0x10, 0x2a, 0x1c).to_argb()).unwrap();
        g.draw_string(&accept_label, &self.fonts.proportional(13.0), accept_rect, &center, &accept_text)
            .unwrap();

        let decline_rect = self.disclaimer_button_rect(width, height, UiButton::DisclaimerDecline);
        let decline_fill = SolidBrush::new(theme::RED.to_argb()).unwrap();
        g.fill_rounded_rect(decline_rect, theme::RADIUS, &decline_fill).unwrap();
        let decline_text = SolidBrush::new(Color::rgb(0xff, 0xff, 0xff).to_argb()).unwrap();
        g.draw_string(&decline_label, &self.fonts.proportional(13.0), decline_rect, &center, &decline_text)
            .unwrap();
    }

    /// Frameless text tabs with a blue underline beneath the selected one —
    /// mechanical port of `tab_bar`. Tab rects depend on each label's
    /// measured width, so they're computed here (the only place a
    /// `Graphics` is available) and cached in `self.tab_rects` for mouse
    /// hit-testing to read back.
    fn draw_tab_bar(&mut self, g: &Graphics, width: f32) {
        let y0 = TITLE_BAR_HEIGHT;
        let tabs = [
            (Tab::Automatic, self.t("auto")),
            (Tab::Custom, self.t("custom")),
            (Tab::ExtraTools, self.t("tab-extra-tools")),
            (Tab::Donate, self.t("tab-donate")),
        ];
        let font = self.fonts.proportional(13.0);
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();

        self.tab_rects.clear();
        let mut x = 16.0;
        let mut selected_rect: Option<RectF> = None;
        for (tab, label) in &tabs {
            const H_PADDING: f32 = 14.0;
            let text_w = g.measure_line_width(label, &font).unwrap_or(60.0);
            let rect = RectF { X: x, Y: y0, Width: text_w + H_PADDING * 2.0, Height: TAB_BAR_HEIGHT };

            let color = if self.tab == *tab { theme::TEXT_1 } else { theme::TEXT_2 };
            let brush = SolidBrush::new(color.to_argb()).unwrap();
            g.draw_string(label, &font, rect, &center, &brush).unwrap();

            if self.tab == *tab {
                selected_rect = Some(rect);
            }
            self.tab_rects.push((*tab, rect));
            x += rect.Width;
        }

        let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
        g.draw_line(0.0, y0 + TAB_BAR_HEIGHT, width, y0 + TAB_BAR_HEIGHT, &border)
            .ok();
        if let Some(r) = selected_rect {
            let blue = Pen::new(theme::BLUE.to_argb(), 2.0).unwrap();
            g.draw_line(r.X + 4.0, y0 + TAB_BAR_HEIGHT, r.X + r.Width - 4.0, y0 + TAB_BAR_HEIGHT, &blue)
                .ok();
        }
    }

    /// Status dot + text + (while a fine-grained pass is running) a
    /// progress bar. The busy-with-no-progress spinner is deferred (see the
    /// rewrite plan's compromises: it needs its own repaint timer, and
    /// nothing yet sets `busy = true` since no tab triggers a worker
    /// request until the Automatic tab is ported).
    fn draw_footer(&self, g: &Graphics, width: f32, height: f32) {
        let y0 = height - FOOTER_HEIGHT;
        let bg = SolidBrush::new(theme::BG_ELEVATED.to_argb()).unwrap();
        g.fill_rect(RectF { X: 0.0, Y: y0, Width: width, Height: FOOTER_HEIGHT }, &bg)
            .unwrap();
        let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
        g.draw_line(0.0, y0, width, y0, &border).ok();

        let dot_color = if self.busy { theme::BLUE } else { theme::TEXT_3 };
        let dot_brush = SolidBrush::new(dot_color.to_argb()).unwrap();
        g.fill_rounded_rect(
            RectF { X: 24.0, Y: y0 + FOOTER_HEIGHT / 2.0 - 4.0, Width: 8.0, Height: 8.0 },
            4.0,
            &dot_brush,
        )
        .unwrap();

        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let text_brush = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
        g.draw_string(
            &self.status,
            &self.fonts.monospace(12.0),
            RectF { X: 40.0, Y: y0 + FOOTER_HEIGHT / 2.0 - 9.0, Width: width - 260.0, Height: 18.0 },
            &near,
            &text_brush,
        )
        .unwrap();

        if let Some((current, total)) = self.progress {
            const BAR_W: f32 = 160.0;
            let bar_rect = RectF {
                X: width - BAR_W - 100.0,
                Y: y0 + FOOTER_HEIGHT / 2.0 - 3.0,
                Width: BAR_W,
                Height: 6.0,
            };
            let track = SolidBrush::new(theme::BG_PANEL.to_argb()).unwrap();
            g.fill_rounded_rect(bar_rect, 3.0, &track).unwrap();
            let fraction = if total > 0 { current as f32 / total as f32 } else { 0.0 };
            let fill_rect = RectF { Width: bar_rect.Width * fraction.clamp(0.0, 1.0), ..bar_rect };
            let fill = SolidBrush::new(theme::BLUE.to_argb()).unwrap();
            g.fill_rounded_rect(fill_rect, 3.0, &fill).ok();

            let label = format!("{current}/{total}");
            let label_brush = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
            g.draw_string(
                &label,
                &self.fonts.monospace(11.0),
                RectF { X: width - 96.0, Y: y0 + FOOTER_HEIGHT / 2.0 - 9.0, Width: 80.0, Height: 18.0 },
                &near,
                &label_brush,
            )
            .ok();
        }
    }

    /// Placeholder for the tabs not yet ported (see the rewrite plan's
    /// phases 5-6).
    fn draw_tab_body_placeholder(&self, g: &Graphics, width: f32, height: f32) {
        let top = TITLE_BAR_HEIGHT + TAB_BAR_HEIGHT;
        let bottom = height - FOOTER_HEIGHT;
        let bg = SolidBrush::new(theme::BG.to_argb()).unwrap();
        g.fill_rect(RectF { X: 0.0, Y: top, Width: width, Height: bottom - top }, &bg)
            .unwrap();
        let text = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        g.draw_string(
            "Contenu de cet onglet : phases suivantes",
            &self.fonts.proportional(13.0),
            RectF { X: 0.0, Y: (top + bottom) / 2.0, Width: width, Height: 24.0 },
            &center,
            &text,
        )
        .unwrap();
    }

    /// The "Automatique" tab: a 2-column grid of action-checkbox cards, the
    /// 3-way quarantine choice, a run button, and (mockup parity — the
    /// original egui app never had this) a right-hand sidebar with the
    /// live catalog size and the last run's timestamp.
    fn draw_ui_automatic(&mut self, g: &Graphics, width: f32, _height: f32) {
        let top = TITLE_BAR_HEIGHT + TAB_BAR_HEIGHT;
        let content_x = CONTENT_PAD_X;
        let content_y = top + CONTENT_PAD_TOP;
        let left_col_width = width - CONTENT_PAD_X * 2.0 - SIDEBAR_WIDTH - COLUMN_GAP;

        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let header_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
        g.draw_string(
            &self.t("actions").to_uppercase(),
            &self.fonts.proportional(11.0),
            RectF { X: content_x, Y: content_y, Width: left_col_width, Height: 16.0 },
            &near,
            &header_brush,
        )
        .unwrap();

        let grid_y = content_y + 24.0;
        let card_w = (left_col_width - CARD_GAP) / 2.0;

        let specs: [(bool, &Icon, kprm_win32gui::color::Color, kprm_win32gui::color::Color, String, String); 6] = [
            (
                self.opt_remove_tools,
                &app_icons::TRASH,
                theme::BLUE_BG,
                theme::BLUE,
                self.t("delete-tools"),
                self.t("action-remove-tools-desc"),
            ),
            (
                self.opt_backup_registry,
                &app_icons::SAVE,
                theme::GREEN_BG,
                theme::GREEN,
                self.t("save-registry"),
                self.t("action-backup-registry-desc"),
            ),
            (
                self.opt_remove_restore_points,
                &app_icons::UNDO,
                theme::BLUE_BG,
                theme::BLUE,
                self.t("delete-system-restore-points"),
                self.t("action-remove-restore-points-desc"),
            ),
            (
                self.opt_create_restore_point,
                &app_icons::CIRCLE_PLUS,
                theme::GREEN_BG,
                theme::GREEN,
                self.t("create-restore-point"),
                self.t("action-create-restore-point-desc"),
            ),
            (
                self.opt_restore_uac,
                &app_icons::LOCK,
                theme::BLUE_BG,
                theme::BLUE,
                self.t("restore-uac"),
                self.t("action-restore-uac-desc"),
            ),
            (
                self.opt_restore_settings,
                &app_icons::SLIDERS,
                theme::BLUE_BG,
                theme::BLUE,
                self.t("restore-settings"),
                self.t("action-restore-settings-desc"),
            ),
        ];

        self.action_rects.clear();
        for (i, (checked, icon, badge_bg, icon_color, title, desc)) in specs.iter().enumerate() {
            let row = (i / 2) as f32;
            let col = (i % 2) as f32;
            let rect = RectF {
                X: content_x + col * (card_w + CARD_GAP),
                Y: grid_y + row * (CARD_HEIGHT + CARD_GAP),
                Width: card_w,
                Height: CARD_HEIGHT,
            };
            self.action_rects.push(rect);
            self.draw_action_card(g, rect, i, *checked, icon, *badge_bg, *icon_color, title, desc);
        }

        let quarantine_y = grid_y + 3.0 * CARD_HEIGHT + 2.0 * CARD_GAP + 18.0;
        g.draw_string(
            &self.t("quarantine-section-title"),
            &self.fonts.proportional(11.0),
            RectF { X: content_x, Y: quarantine_y, Width: left_col_width, Height: 16.0 },
            &near,
            &header_brush,
        )
        .unwrap();

        let seg_y = quarantine_y + 24.0;
        let seg_w = (left_col_width - SEGMENT_GAP * 2.0) / 3.0;
        let segs = [
            (QuarantineChoice::Keep, &app_icons::BOX, theme::TEXT_2, self.t("quarantine-keep"), self.t("quarantine-keep-desc")),
            (QuarantineChoice::Now, &app_icons::TRASH, theme::RED, self.t("remove-now"), self.t("quarantine-now-desc")),
            (QuarantineChoice::In7Days, &app_icons::CLOCK, theme::BLUE, self.t("quarantine-7-days"), self.t("quarantine-7-days-desc")),
        ];
        self.quarantine_rects.clear();
        for (i, (choice, icon, icon_color, title, desc)) in segs.iter().enumerate() {
            let rect = RectF {
                X: content_x + i as f32 * (seg_w + SEGMENT_GAP),
                Y: seg_y,
                Width: seg_w,
                Height: SEGMENT_HEIGHT,
            };
            self.quarantine_rects.push((*choice, rect));
            self.draw_quarantine_segment(g, rect, *choice, icon, *icon_color, title, desc);
        }

        self.run_button_rect = RectF {
            X: content_x,
            Y: seg_y + SEGMENT_HEIGHT + 20.0,
            Width: RUN_BUTTON_SIZE.0,
            Height: RUN_BUTTON_SIZE.1,
        };
        self.draw_run_button(g);

        self.draw_sidebar(g, width, top);
    }

    #[allow(clippy::too_many_arguments)]
    fn draw_action_card(
        &self,
        g: &Graphics,
        rect: RectF,
        index: usize,
        checked: bool,
        icon: &Icon,
        badge_bg: Color,
        icon_color: Color,
        title: &str,
        desc: &str,
    ) {
        let hovered = self.hover == Some(UiButton::ActionCard(index));
        let panel_bg = if hovered { theme::BG_HOVER } else { theme::BG_PANEL };
        let panel = SolidBrush::new(panel_bg.to_argb()).unwrap();
        g.fill_rounded_rect(rect, 10.0, &panel).unwrap();
        let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
        g.draw_rounded_rect(rect, 10.0, &border).unwrap();

        const PAD: f32 = 12.0;
        let cb_rect = RectF { X: rect.X + PAD, Y: rect.Y + PAD, Width: 18.0, Height: 18.0 };
        if checked {
            let fill = SolidBrush::new(theme::GREEN.to_argb()).unwrap();
            g.fill_rounded_rect(cb_rect, 5.0, &fill).unwrap();
            let check_rect = RectF { X: cb_rect.X + 2.0, Y: cb_rect.Y + 2.0, Width: 14.0, Height: 14.0 };
            app_icons::CHECK.draw(g, check_rect, Color::rgb(0x10, 0x2a, 0x1c), 2.4).ok();
        } else {
            let empty_border = Pen::new(theme::BORDER.to_argb(), 1.5).unwrap();
            g.draw_rounded_rect(cb_rect, 5.0, &empty_border).ok();
        }

        let badge_rect = RectF { X: cb_rect.X + 18.0 + 8.0, Y: rect.Y + PAD - 4.0, Width: 26.0, Height: 26.0 };
        let badge_fill = SolidBrush::new(badge_bg.to_argb()).unwrap();
        g.fill_rounded_rect(badge_rect, 7.0, &badge_fill).unwrap();
        let icon_rect = RectF { X: badge_rect.X + 6.0, Y: badge_rect.Y + 6.0, Width: 14.0, Height: 14.0 };
        icon.draw(g, icon_rect, icon_color, 1.8).ok();

        let text_x = badge_rect.X + 26.0 + 10.0;
        let text_w = (rect.X + rect.Width - text_x - PAD).max(20.0);
        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let title_brush = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        g.draw_string(
            title,
            &self.fonts.proportional(12.5),
            RectF { X: text_x, Y: rect.Y + PAD - 4.0, Width: text_w, Height: 32.0 },
            &near,
            &title_brush,
        )
        .unwrap();
        let desc_brush = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
        g.draw_string(
            desc,
            &self.fonts.proportional(10.5),
            RectF { X: text_x, Y: rect.Y + PAD - 4.0 + 30.0, Width: text_w, Height: 30.0 },
            &near,
            &desc_brush,
        )
        .unwrap();
    }

    #[allow(clippy::too_many_arguments)]
    fn draw_quarantine_segment(
        &self,
        g: &Graphics,
        rect: RectF,
        choice: QuarantineChoice,
        icon: &Icon,
        icon_color: Color,
        title: &str,
        desc: &str,
    ) {
        let selected = self.quarantine_choice == choice;
        let (bg, border_color, text_color) = if selected {
            (theme::BLUE_BG, theme::BLUE, theme::TEXT_1)
        } else {
            (theme::BG_PANEL, theme::BORDER_SOFT, theme::TEXT_2)
        };
        let fill = SolidBrush::new(bg.to_argb()).unwrap();
        g.fill_rounded_rect(rect, 9.0, &fill).unwrap();
        let pen = Pen::new(border_color.to_argb(), 1.5).unwrap();
        g.draw_rounded_rect(rect, 9.0, &pen).unwrap();

        let icon_rect = RectF { X: rect.X + 11.0, Y: rect.Y + 10.0, Width: 14.0, Height: 14.0 };
        let icon_draw_color = if selected { theme::BLUE } else { icon_color };
        icon.draw(g, icon_rect, icon_draw_color, 1.8).ok();

        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let title_brush = SolidBrush::new(text_color.to_argb()).unwrap();
        g.draw_string(
            title,
            &self.fonts.proportional(12.5),
            RectF { X: rect.X + 29.0, Y: rect.Y + 9.0, Width: rect.Width - 40.0, Height: 18.0 },
            &near,
            &title_brush,
        )
        .unwrap();
        let desc_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
        g.draw_string(
            desc,
            &self.fonts.proportional(10.5),
            RectF { X: rect.X + 11.0, Y: rect.Y + 29.0, Width: rect.Width - 22.0, Height: 16.0 },
            &near,
            &desc_brush,
        )
        .unwrap();
    }

    fn draw_run_button(&self, g: &Graphics) {
        let enabled = self.can_run();
        let fill = SolidBrush::new(if enabled { theme::GREEN } else { theme::BG_PANEL }.to_argb()).unwrap();
        g.fill_rounded_rect(self.run_button_rect, theme::RADIUS, &fill).unwrap();
        if !enabled {
            let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
            g.draw_rounded_rect(self.run_button_rect, theme::RADIUS, &border).ok();
        }
        let text_color = if enabled { Color::rgb(0x10, 0x2a, 0x1c) } else { theme::TEXT_3 };
        let text_brush = SolidBrush::new(text_color.to_argb()).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        g.draw_string(&self.t("run"), &self.fonts.proportional(13.5), self.run_button_rect, &center, &text_brush)
            .unwrap();

        if !enabled {
            let hint_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
            let near = StringFormat::new().unwrap();
            near.set_align(StringAlignmentNear).unwrap();
            g.draw_string(
                &self.t("no-option-selected"),
                &self.fonts.proportional(10.5),
                RectF {
                    X: self.run_button_rect.X,
                    Y: self.run_button_rect.Y + self.run_button_rect.Height + 6.0,
                    Width: 300.0,
                    Height: 16.0,
                },
                &near,
                &hint_brush,
            )
            .ok();
        }
    }

    /// Mockup parity (`docs/design/Main.dc.html`'s right column) — new
    /// functionality, not a port: the original app persisted nothing
    /// between runs.
    fn draw_sidebar(&self, g: &Graphics, width: f32, top: f32) {
        let x = width - CONTENT_PAD_X - SIDEBAR_WIDTH;
        let y = top + CONTENT_PAD_TOP;
        let panel = SolidBrush::new(theme::BG_PANEL.to_argb()).unwrap();
        let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();

        const BRAND_H: f32 = 130.0;
        let brand_rect = RectF { X: x, Y: y, Width: SIDEBAR_WIDTH, Height: BRAND_H };
        g.fill_rounded_rect(brand_rect, 12.0, &panel).unwrap();
        g.draw_rounded_rect(brand_rect, 12.0, &border).unwrap();
        const BADGE_SIZE: f32 = 56.0;
        let badge_rect =
            RectF { X: x + (SIDEBAR_WIDTH - BADGE_SIZE) / 2.0, Y: y + 18.0, Width: BADGE_SIZE, Height: BADGE_SIZE };
        let badge_bg = SolidBrush::new(theme::BLUE_BG.to_argb()).unwrap();
        g.fill_rounded_rect(badge_rect, 999.0, &badge_bg).unwrap();
        let icon_rect = RectF { X: badge_rect.X + 14.0, Y: badge_rect.Y + 14.0, Width: 28.0, Height: 28.0 };
        app_icons::SHIELD.draw(g, icon_rect, theme::BLUE, 1.7).ok();
        let text_1 = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        g.draw_string(
            "KpRm",
            &self.fonts.proportional(13.5),
            RectF { X: x, Y: y + 82.0, Width: SIDEBAR_WIDTH, Height: 18.0 },
            &center,
            &text_1,
        )
        .unwrap();
        let text_2 = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
        g.draw_string(
            &self.t("sidebar-tagline"),
            &self.fonts.proportional(11.0),
            RectF { X: x + 10.0, Y: y + 100.0, Width: SIDEBAR_WIDTH - 20.0, Height: 28.0 },
            &center,
            &text_2,
        )
        .unwrap();

        const STATS_H: f32 = 110.0;
        let stats_y = y + BRAND_H + 14.0;
        let stats_rect = RectF { X: x, Y: stats_y, Width: SIDEBAR_WIDTH, Height: STATS_H };
        g.fill_rounded_rect(stats_rect, 12.0, &panel).unwrap();
        g.draw_rounded_rect(stats_rect, 12.0, &border).unwrap();
        let label_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
        let value_brush = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        g.draw_string(
            &self.t("sidebar-catalog-label"),
            &self.fonts.proportional(10.0),
            RectF { X: x + 14.0, Y: stats_y + 12.0, Width: SIDEBAR_WIDTH - 28.0, Height: 14.0 },
            &near,
            &label_brush,
        )
        .unwrap();
        g.draw_string(
            &self.tf("sidebar-catalog-value", &[("count", &self.catalog_tool_count.to_string())]),
            &self.fonts.monospace(13.0),
            RectF { X: x + 14.0, Y: stats_y + 28.0, Width: SIDEBAR_WIDTH - 28.0, Height: 18.0 },
            &near,
            &value_brush,
        )
        .unwrap();
        g.draw_line(x + 14.0, stats_y + 54.0, x + SIDEBAR_WIDTH - 14.0, stats_y + 54.0, &border).ok();
        g.draw_string(
            &self.t("sidebar-last-run-label"),
            &self.fonts.proportional(10.0),
            RectF { X: x + 14.0, Y: stats_y + 62.0, Width: SIDEBAR_WIDTH - 28.0, Height: 14.0 },
            &near,
            &label_brush,
        )
        .unwrap();
        let text_2b = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
        g.draw_string(
            self.last_run.as_deref().unwrap_or("\u{2014}"),
            &self.fonts.monospace(11.0),
            RectF { X: x + 14.0, Y: stats_y + 78.0, Width: SIDEBAR_WIDTH - 28.0, Height: 18.0 },
            &near,
            &text_2b,
        )
        .unwrap();
    }

    /// The "Personnalisé" tab: a scrollable list of everything the last
    /// scan found, each independently checkable, plus select-all/none/
    /// clear shortcuts and the scan/remove actions. The list is this
    /// tab's — and the whole rewrite's — first scrollable region; see
    /// `kprm_win32gui::scroll` for how clipping/translation/the thumb
    /// work.
    fn draw_ui_custom(&mut self, g: &Graphics, width: f32, height: f32) {
        let top = TITLE_BAR_HEIGHT + TAB_BAR_HEIGHT;
        let bottom = height - FOOTER_HEIGHT;
        let content_x = CONTENT_PAD_X;
        let content_w = width - CONTENT_PAD_X * 2.0;
        let y = top + CONTENT_PAD_TOP;

        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();

        let found = self.scan_results.len();
        let selected_count = self.scan_results.iter().filter(|(_, checked)| *checked).count();
        let counts = self.tf(
            "custom-counts",
            &[("found", &found.to_string()), ("selected", &selected_count.to_string())],
        );
        let text_1 = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        g.draw_string(
            &counts,
            &self.fonts.proportional(13.0),
            RectF { X: content_x, Y: y + TOOLBAR_HEIGHT / 2.0 - 9.0, Width: 320.0, Height: 18.0 },
            &near,
            &text_1,
        )
        .unwrap();

        let toolbar_specs = [
            (UiButton::SelectAll, self.t("all")),
            (UiButton::SelectNone, self.t("no-element")),
            (UiButton::Clear, self.t("empty")),
        ];
        let font_toolbar = self.fonts.proportional(11.5);
        let mut bx = content_x + content_w;
        let mut computed: Vec<(UiButton, String, RectF)> = Vec::new();
        for (btn, label) in toolbar_specs.iter().rev() {
            let w = g.measure_line_width(label, &font_toolbar).unwrap_or(30.0) + 24.0;
            bx -= w;
            computed.push((*btn, label.clone(), RectF { X: bx, Y: y, Width: w, Height: TOOLBAR_HEIGHT }));
            bx -= 8.0;
        }
        computed.reverse();
        self.toolbar_button_rects = computed.iter().map(|(btn, _, rect)| (*btn, *rect)).collect();
        for (btn, label, rect) in &computed {
            self.draw_toolbar_button(g, *rect, *btn, label);
        }

        let list_y = y + TOOLBAR_HEIGHT + LIST_GAP;
        let list_bottom = bottom - CONTENT_PAD_TOP - BUTTONS_ROW_HEIGHT - LIST_GAP;
        let panel_rect = RectF { X: content_x, Y: list_y, Width: content_w, Height: (list_bottom - list_y).max(40.0) };
        let panel_fill = SolidBrush::new(theme::BG_PANEL.to_argb()).unwrap();
        g.fill_rounded_rect(panel_rect, 12.0, &panel_fill).unwrap();
        let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
        g.draw_rounded_rect(panel_rect, 12.0, &border).unwrap();

        let viewport = RectF {
            X: panel_rect.X + 6.0,
            Y: panel_rect.Y + 6.0,
            Width: panel_rect.Width - 12.0,
            Height: panel_rect.Height - 12.0,
        };
        let content_height = (self.scan_results.len() as f32 * RESULT_ROW_HEIGHT).max(1.0);

        // `self.scroll` is copied out for the duration of the closure so
        // the closure can freely read `self` (fonts, scan_results, hover
        // state, ...) without conflicting with `ScrollState::show`'s
        // `&mut` receiver — see `kprm_win32gui::scroll::ScrollState`.
        let mut scroll = self.scroll;
        scroll.show(g, viewport, |g| {
            if self.scan_results.is_empty() {
                let hint_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
                g.draw_string(
                    &self.t("custom-empty-hint"),
                    &self.fonts.proportional(12.0),
                    RectF { X: viewport.X, Y: viewport.Y + viewport.Height / 2.0 - 10.0, Width: viewport.Width, Height: 20.0 },
                    &center,
                    &hint_brush,
                )
                .ok();
            }
            for (i, (event, checked)) in self.scan_results.iter().enumerate() {
                let row_rect = RectF {
                    X: viewport.X,
                    Y: viewport.Y + i as f32 * RESULT_ROW_HEIGHT,
                    Width: viewport.Width,
                    Height: RESULT_ROW_HEIGHT,
                };
                self.draw_result_row(g, row_rect, i, event, *checked);
            }
        });
        scroll.finish(g, content_height);
        self.scroll = scroll;

        let buttons_y = list_bottom + LIST_GAP;
        let search_label = self.t("search");
        let search_w = g.measure_line_width(&search_label, &self.fonts.proportional(12.5)).unwrap_or(60.0) + 32.0;
        self.search_button_rect = RectF { X: content_x, Y: buttons_y, Width: search_w, Height: BUTTONS_ROW_HEIGHT };
        self.draw_search_button(g, &search_label);

        let remove_label = self.tf("remove-selection-button", &[("count", &selected_count.to_string())]);
        let remove_w = g.measure_line_width(&remove_label, &self.fonts.proportional(12.5)).unwrap_or(100.0) + 32.0;
        self.remove_selected_button_rect = RectF {
            X: content_x + search_w + 10.0,
            Y: buttons_y,
            Width: remove_w,
            Height: BUTTONS_ROW_HEIGHT,
        };
        self.draw_remove_selected_button(g, &remove_label);
    }

    fn draw_toolbar_button(&self, g: &Graphics, rect: RectF, btn: UiButton, label: &str) {
        let hovered = self.hover == Some(btn);
        if hovered {
            let fill = SolidBrush::new(theme::BG_HOVER.to_argb()).unwrap();
            g.fill_rounded_rect(rect, 7.0, &fill).unwrap();
        }
        let border_color = if hovered { theme::BORDER } else { theme::BORDER_SOFT };
        let pen = Pen::new(border_color.to_argb(), 1.5).unwrap();
        g.draw_rounded_rect(rect, 7.0, &pen).unwrap();
        let text_color = if hovered { theme::TEXT_1 } else { theme::TEXT_2 };
        let brush = SolidBrush::new(text_color.to_argb()).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        g.draw_string(label, &self.fonts.proportional(11.5), rect, &center, &brush).unwrap();
    }

    fn draw_result_row(&self, g: &Graphics, rect: RectF, index: usize, event: &Event, checked: bool) {
        let hovered = self.hover == Some(UiButton::ResultRow(index));
        if hovered {
            let fill = SolidBrush::new(theme::BG_HOVER.to_argb()).unwrap();
            g.fill_rounded_rect(rect, 8.0, &fill).ok();
        }

        let cb_rect = RectF { X: rect.X + 10.0, Y: rect.Y + rect.Height / 2.0 - 9.0, Width: 18.0, Height: 18.0 };
        if checked {
            let fill = SolidBrush::new(theme::GREEN.to_argb()).unwrap();
            g.fill_rounded_rect(cb_rect, 5.0, &fill).unwrap();
            let check_rect = RectF { X: cb_rect.X + 2.0, Y: cb_rect.Y + 2.0, Width: 14.0, Height: 14.0 };
            app_icons::CHECK.draw(g, check_rect, Color::rgb(0x10, 0x2a, 0x1c), 2.4).ok();
        } else {
            let empty_border = Pen::new(theme::BORDER.to_argb(), 1.5).unwrap();
            g.draw_rounded_rect(cb_rect, 5.0, &empty_border).ok();
        }

        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();

        let tag_font = self.fonts.proportional(10.0);
        let tag = format!("{} \u{b7} {}", event.tool, event.action_type);
        let tag_w = g.measure_line_width(&tag, &tag_font).unwrap_or(60.0) + 16.0;
        let tag_rect = RectF { X: rect.X + rect.Width - tag_w - 10.0, Y: rect.Y + rect.Height / 2.0 - 9.0, Width: tag_w, Height: 18.0 };
        let tag_bg = SolidBrush::new(theme::BG_ELEVATED.to_argb()).unwrap();
        g.fill_rounded_rect(tag_rect, 999.0, &tag_bg).ok();
        let tag_border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
        g.draw_rounded_rect(tag_rect, 999.0, &tag_border).ok();
        let tag_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
        g.draw_string(&tag, &tag_font, tag_rect, &center, &tag_brush).ok();

        let path_x = cb_rect.X + 18.0 + 10.0;
        let path_w = (tag_rect.X - path_x - 10.0).max(20.0);
        let path_brush = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        g.draw_string(
            &event.target,
            &self.fonts.monospace(12.0),
            RectF { X: path_x, Y: rect.Y + rect.Height / 2.0 - 8.0, Width: path_w, Height: 16.0 },
            &near,
            &path_brush,
        )
        .ok();
    }

    fn draw_search_button(&self, g: &Graphics, label: &str) {
        let enabled = !self.busy;
        let border_color = if enabled { theme::BORDER } else { theme::BORDER_SOFT };
        let pen = Pen::new(border_color.to_argb(), 1.5).unwrap();
        g.draw_rounded_rect(self.search_button_rect, theme::RADIUS, &pen).unwrap();
        let text_color = if enabled { theme::TEXT_2 } else { theme::TEXT_3 };
        let brush = SolidBrush::new(text_color.to_argb()).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        g.draw_string(label, &self.fonts.proportional(12.5), self.search_button_rect, &center, &brush).unwrap();
    }

    fn draw_remove_selected_button(&self, g: &Graphics, label: &str) {
        let enabled = self.can_remove_selected();
        let fill_color = if enabled { theme::RED } else { theme::BG_PANEL };
        let fill = SolidBrush::new(fill_color.to_argb()).unwrap();
        g.fill_rounded_rect(self.remove_selected_button_rect, theme::RADIUS, &fill).unwrap();
        if !enabled {
            let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
            g.draw_rounded_rect(self.remove_selected_button_rect, theme::RADIUS, &border).ok();
        }
        let text_color = if enabled { Color::rgb(0xff, 0xff, 0xff) } else { theme::TEXT_3 };
        let brush = SolidBrush::new(text_color.to_argb()).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        g.draw_string(label, &self.fonts.proportional(12.5), self.remove_selected_button_rect, &center, &brush)
            .unwrap();
    }
}

fn rect_contains(r: RectF, x: f32, y: f32) -> bool {
    x >= r.X && x <= r.X + r.Width && y >= r.Y && y <= r.Y + r.Height
}

impl AppWindow for KprmApp {
    fn paint(&mut self, g: &Graphics, width: f32, height: f32) {
        self.poll_worker();

        let bg = SolidBrush::new(theme::BG.to_argb()).unwrap();
        g.fill_rect(RectF { X: 0.0, Y: 0.0, Width: width, Height: height }, &bg)
            .unwrap();

        self.draw_title_bar(g, width);
        if !self.disclaimer_accepted {
            self.draw_disclaimer(g, width, height);
        } else {
            self.draw_tab_bar(g, width);
            self.draw_footer(g, width, height);
            match self.tab {
                Tab::Automatic => self.draw_ui_automatic(g, width, height),
                Tab::Custom => self.draw_ui_custom(g, width, height),
                _ => self.draw_tab_body_placeholder(g, width, height),
            }
        }
    }

    fn hit_zone(&self, x: f32, y: f32, width: f32, height: f32) -> HitZone {
        if y < TITLE_BAR_HEIGHT && self.button_at(width, height, x, y).is_none() {
            HitZone::Caption
        } else {
            HitZone::Client
        }
    }

    fn on_mouse_move(&mut self, x: f32, y: f32, width: f32, height: f32) -> bool {
        let new_hover = self.button_at(width, height, x, y);
        if new_hover != self.hover {
            self.hover = new_hover;
            true
        } else {
            false
        }
    }

    fn on_mouse_down(&mut self, _x: f32, _y: f32, _width: f32, _height: f32) -> bool {
        self.pressed = self.hover;
        false
    }

    fn on_mouse_up(&mut self, _x: f32, _y: f32, _width: f32, _height: f32) -> bool {
        if self.pressed.is_some() && self.pressed == self.hover {
            match self.pressed {
                Some(UiButton::Close) => self.close_requested = true,
                Some(UiButton::Minimize) => self.minimize_requested = true,
                Some(UiButton::DisclaimerAccept) => self.disclaimer_accepted = true,
                Some(UiButton::DisclaimerDecline) => self.close_requested = true,
                Some(UiButton::Tab(tab)) => self.tab = tab,
                Some(UiButton::ActionCard(i)) => match i {
                    0 => self.opt_remove_tools = !self.opt_remove_tools,
                    1 => self.opt_backup_registry = !self.opt_backup_registry,
                    2 => self.opt_remove_restore_points = !self.opt_remove_restore_points,
                    3 => self.opt_create_restore_point = !self.opt_create_restore_point,
                    4 => self.opt_restore_uac = !self.opt_restore_uac,
                    5 => self.opt_restore_settings = !self.opt_restore_settings,
                    _ => {}
                },
                Some(UiButton::QuarantineSeg(choice)) => {
                    self.quarantine_choice = choice;
                    if choice != QuarantineChoice::Keep {
                        self.opt_remove_tools = true;
                    }
                }
                Some(UiButton::RunButton) => {
                    self.busy = true;
                    self.status = self.t("status-running");
                    let _ = self.request_tx.send(WorkerRequest::RunAutomatic {
                        backup_registry: self.opt_backup_registry,
                        remove_tools: self.opt_remove_tools,
                        restore_uac: self.opt_restore_uac,
                        restore_settings: self.opt_restore_settings,
                        remove_restore_points: self.opt_remove_restore_points,
                        create_restore_point: self.opt_create_restore_point,
                        quarantine_mode: self.quarantine_choice.into(),
                    });
                }
                Some(UiButton::SelectAll) => {
                    for (_, checked) in &mut self.scan_results {
                        *checked = true;
                    }
                }
                Some(UiButton::SelectNone) => {
                    for (_, checked) in &mut self.scan_results {
                        *checked = false;
                    }
                }
                Some(UiButton::Clear) => self.scan_results.clear(),
                Some(UiButton::ResultRow(i)) => {
                    if let Some((_, checked)) = self.scan_results.get_mut(i) {
                        *checked = !*checked;
                    }
                }
                Some(UiButton::SearchButton) => {
                    self.busy = true;
                    self.status = self.t("status-scanning");
                    let _ = self.request_tx.send(WorkerRequest::Scan);
                }
                Some(UiButton::RemoveSelectedButton) => {
                    let selected: Vec<(String, String)> = self
                        .scan_results
                        .iter()
                        .filter(|(_, checked)| *checked)
                        .map(|(e, _)| (e.tool.clone(), e.target.clone()))
                        .collect();
                    if !selected.is_empty() {
                        self.busy = true;
                        self.status = self.t("status-removing");
                        let _ = self.request_tx.send(WorkerRequest::RemoveSelected(selected));
                    }
                }
                None => {}
            }
        }
        self.pressed = None;
        true
    }

    fn should_close(&mut self) -> bool {
        std::mem::take(&mut self.close_requested)
    }

    fn should_minimize(&mut self) -> bool {
        std::mem::take(&mut self.minimize_requested)
    }

    fn on_mouse_wheel(&mut self, x: f32, y: f32, notches: f32, _width: f32, _height: f32) -> bool {
        if self.tab == Tab::Custom && self.scroll.contains(x, y) {
            self.scroll.scroll_by_notches(notches, RESULT_ROW_HEIGHT);
            true
        } else {
            false
        }
    }
}
