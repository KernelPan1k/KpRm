//! `KprmApp`: the GUI's screens, built on `kprm-win32gui`'s owner-drawn
//! `AppWindow` (see `../../kprm-win32gui/src/window.rs`) rather than
//! `egui`/`eframe` — see `../../BUILDING.md` and the project's rewrite plan
//! for why. Real actions run on a background thread (see [`crate::worker`])
//! so the UI never freezes during a scan/removal.
//!
//! **Porting status**: the title bar, startup disclaimer, tab bar, footer,
//! all four tabs (Automatic/Custom/Extra Tools/Donate), and both modal
//! dialogs (restart-required, registry-restore confirmation) are fully
//! ported. Remaining work is the polish pass (DPI edge cases, manifest,
//! reference-screenshot comparison) — see the rewrite plan.

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
use crate::worker::{self, MaintenanceTask, WorkerRequest, WorkerResponse};

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

const BTC_ADDRESS: &str = "bc1qeuy23256g05v80ggcy6ezwrlhxttrhm827hf2u";
const ETH_ADDRESS: &str = "0x02AF1772AADaE8abf1d522aF5E87115E1Ed0dea5";
const LTC_ADDRESS: &str = "Lh3p9yoDzJrYKHDm3TaW55B49q2uMVZaj5";
const XMR_ADDRESS: &str = "BUsMZ3KoHcPvUAKCuFL8dsgUQAuWBJbaRxda6sQ8ND53";
/// Single place to fill in once a PayPal.me link exists — the row stays
/// hidden (and the GitHub Sponsors row skipped entirely, at the user's
/// request) until this is non-empty.
const PAYPAL_URL: &str = "";
const QR_SIZE: f32 = 76.0;
const DONATE_CARD_PAD: f32 = 14.0;
const DONATE_CARD_HEIGHT: f32 = 104.0;
const DONATE_CARD_GAP: f32 = 10.0;

const EXTRA_SECTION_GAP: f32 = 27.0;
const MAINT_ROW_HEIGHT: f32 = 46.0;
const MAINT_ROW_GAP: f32 = 8.0;
const MAINT_RUN_BTN_SIZE: (f32, f32) = (90.0, 28.0);
const BACKUP_LIST_HEIGHT: f32 = 140.0;
const BACKUP_ROW_HEIGHT: f32 = 26.0;
/// Wheel step for the Automatic/Donate/Extra Tools tabs' whole-tab
/// scrolls — unlike the Custom tab's list (uniform `RESULT_ROW_HEIGHT`
/// rows) their content isn't rows of one height, so this is just a
/// reasonable "one text line" step.
const TAB_SCROLL_LINE_HEIGHT: f32 = 40.0;

// Modal dialogs (restart-required, registry-restore confirmation) — drawn
// as an overlay pass at the end of `paint`, matching `docs/design/
// Restart.dc.html`'s vertically-stacked layout (a badge, centered title/
// body, then a full-width primary button and a plain "later/cancel" link)
// rather than the pre-rewrite egui version's side-by-side buttons.
const DIALOG_PANEL_WIDTH: f32 = 340.0;
const DIALOG_PAD: f32 = 24.0;
const DIALOG_BADGE_SIZE: f32 = 52.0;
const DIALOG_BADGE_GAP: f32 = 16.0;
const DIALOG_TITLE_HEIGHT: f32 = 20.0;
const DIALOG_TITLE_GAP: f32 = 8.0;
const DIALOG_BODY_HEIGHT: f32 = 92.0;
const DIALOG_BODY_GAP: f32 = 18.0;
const DIALOG_PRIMARY_BTN_HEIGHT: f32 = 40.0;
const DIALOG_PRIMARY_GAP: f32 = 12.0;
const DIALOG_LINK_HEIGHT: f32 = 20.0;
const LOCK_LIST_ROW_HEIGHT: f32 = 26.0;
const LOCK_LIST_MAX_ROWS: usize = 4;
const LOCK_LIST_PAD: f32 = 4.0;

#[derive(PartialEq, Eq, Clone, Copy, Debug)]
enum Tab {
    Automatic,
    Custom,
    ExtraTools,
    Donate,
}

/// Which wording the restart dialog shows — the same dialog is reused for
/// a locked-file cleanup pass and for a registry restore, and the two
/// deserve different phrasing (`restart-dialog-body` vs
/// `restore-restart-dialog-body`).
#[derive(PartialEq, Eq, Clone, Copy, Debug)]
enum RestartReason {
    LockedFiles,
    RegistryRestore,
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
    /// 0=BTC, 1=ETH, 2=LTC, 3=XMR — indexes `DONATE_ADDRESSES`.
    CopyAddress(usize),
    OpenPayPal,
    RefreshBackups,
    BackupRadio(usize),
    RestoreButton,
    RunMaintenance(MaintenanceTask),
    RestartNow,
    RestartLater,
    ConfirmRestore,
    CancelRestore,
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
    /// Which wording `draw_restart_dialog` shows — only meaningful while
    /// `show_restart_dialog` is `true`.
    restart_reason: RestartReason,
    /// Paths of whatever got scheduled for on-reboot deletion by the run
    /// that triggered `show_restart_dialog` (mockup parity —
    /// `docs/design/Restart.dc.html`'s locked-files list; the original app
    /// never showed this).
    restart_locked_files: Vec<String>,
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
    /// The Automatic tab's whole-tab scroll — see `draw_ui_automatic`; a
    /// small enough window (or a resize down to `min_size`, now that the
    /// window is resizable) can make the card grid + sidebar taller than
    /// the available space.
    automatic_scroll: ScrollState,

    /// The Custom tab's result-list scroll area — see
    /// `kprm_win32gui::scroll` (the rewrite plan's highest-risk primitive).
    scroll: ScrollState,
    toolbar_button_rects: Vec<(UiButton, RectF)>,
    search_button_rect: RectF,
    remove_selected_button_rect: RectF,

    copy_button_rects: [RectF; 4],
    paypal_button_rect: RectF,
    /// The Donate tab's whole-tab scroll — 4 address cards plus PayPal can
    /// outgrow a small window just like the Automatic tab's content.
    donate_scroll: ScrollState,

    /// The Extra Tools tab's whole-tab scroll, and the backup list's own
    /// nested scroll inside it — see `draw_ui_extra_tools` for how their
    /// coordinate spaces compose (the rewrite plan's nested-scroll risk).
    outer_scroll: ScrollState,
    backup_scroll: ScrollState,
    refresh_backups_rect: RectF,
    restore_button_rect: RectF,
    maintenance_row_rects: Vec<(MaintenanceTask, RectF)>,

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
            restart_reason: RestartReason::LockedFiles,
            restart_locked_files: Vec::new(),
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
            automatic_scroll: ScrollState::default(),
            scroll: ScrollState::default(),
            toolbar_button_rects: Vec::new(),
            search_button_rect: RectF::default(),
            remove_selected_button_rect: RectF::default(),
            copy_button_rects: [RectF::default(); 4],
            paypal_button_rect: RectF::default(),
            donate_scroll: ScrollState::default(),
            outer_scroll: ScrollState::default(),
            backup_scroll: ScrollState::default(),
            refresh_backups_rect: RectF::default(),
            restore_button_rect: RectF::default(),
            maintenance_row_rects: Vec::new(),
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
                self.restart_reason = if report.events.iter().any(|e| e.action_type == "registry_restore") {
                    RestartReason::RegistryRestore
                } else {
                    RestartReason::LockedFiles
                };
                self.restart_locked_files = report
                    .events
                    .iter()
                    .filter(|e| e.result == EventResult::ScheduledOnReboot)
                    .map(|e| e.target.clone())
                    .collect();
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

    /// Geometry for `draw_restart_dialog`/`button_at`, shared so hit-testing
    /// (no `Graphics`, can't measure text) matches what got painted exactly
    /// — everything here is fixed-size, so plain arithmetic on
    /// `self.restart_locked_files.len()` is enough, no cached rects needed.
    /// Returns `(panel, primary_button, later_link, locked_files_list)`.
    fn restart_dialog_layout(&self, width: f32, height: f32) -> (RectF, RectF, RectF, Option<RectF>) {
        let lock_list = if self.restart_locked_files.is_empty() {
            None
        } else {
            let rows = self.restart_locked_files.len().min(LOCK_LIST_MAX_ROWS) as f32;
            Some(LOCK_LIST_PAD * 2.0 + rows * LOCK_LIST_ROW_HEIGHT)
        };
        let content_h = DIALOG_PAD * 2.0
            + DIALOG_BADGE_SIZE
            + DIALOG_BADGE_GAP
            + DIALOG_TITLE_HEIGHT
            + DIALOG_TITLE_GAP
            + DIALOG_BODY_HEIGHT
            + DIALOG_BODY_GAP
            + lock_list.map(|h| h + DIALOG_BODY_GAP).unwrap_or(0.0)
            + DIALOG_PRIMARY_BTN_HEIGHT
            + DIALOG_PRIMARY_GAP
            + DIALOG_LINK_HEIGHT;
        let panel = RectF {
            X: (width - DIALOG_PANEL_WIDTH) / 2.0,
            Y: (height - content_h) / 2.0,
            Width: DIALOG_PANEL_WIDTH,
            Height: content_h,
        };
        let mut y = panel.Y + DIALOG_PAD + DIALOG_BADGE_SIZE + DIALOG_BADGE_GAP + DIALOG_TITLE_HEIGHT
            + DIALOG_TITLE_GAP
            + DIALOG_BODY_HEIGHT
            + DIALOG_BODY_GAP;
        let lock_list_rect = lock_list.map(|h| {
            let rect = RectF { X: panel.X + DIALOG_PAD, Y: y, Width: panel.Width - DIALOG_PAD * 2.0, Height: h };
            y += h + DIALOG_BODY_GAP;
            rect
        });
        let primary = RectF {
            X: panel.X + DIALOG_PAD,
            Y: y,
            Width: panel.Width - DIALOG_PAD * 2.0,
            Height: DIALOG_PRIMARY_BTN_HEIGHT,
        };
        y += DIALOG_PRIMARY_BTN_HEIGHT + DIALOG_PRIMARY_GAP;
        let link = RectF { X: panel.X + DIALOG_PAD, Y: y, Width: panel.Width - DIALOG_PAD * 2.0, Height: DIALOG_LINK_HEIGHT };
        (panel, primary, link, lock_list_rect)
    }

    /// Same idea as [`Self::restart_dialog_layout`] but for the (fixed-
    /// height, no locked-files list) registry-restore confirmation.
    /// Returns `(panel, confirm_button, cancel_link)`.
    fn confirm_dialog_layout(&self, width: f32, height: f32) -> (RectF, RectF, RectF) {
        let content_h = DIALOG_PAD * 2.0
            + DIALOG_BADGE_SIZE
            + DIALOG_BADGE_GAP
            + DIALOG_TITLE_HEIGHT
            + DIALOG_TITLE_GAP
            + DIALOG_BODY_HEIGHT
            + DIALOG_BODY_GAP
            + DIALOG_PRIMARY_BTN_HEIGHT
            + DIALOG_PRIMARY_GAP
            + DIALOG_LINK_HEIGHT;
        let panel = RectF {
            X: (width - DIALOG_PANEL_WIDTH) / 2.0,
            Y: (height - content_h) / 2.0,
            Width: DIALOG_PANEL_WIDTH,
            Height: content_h,
        };
        let y = panel.Y + DIALOG_PAD + DIALOG_BADGE_SIZE + DIALOG_BADGE_GAP + DIALOG_TITLE_HEIGHT
            + DIALOG_TITLE_GAP
            + DIALOG_BODY_HEIGHT
            + DIALOG_BODY_GAP;
        let confirm = RectF { X: panel.X + DIALOG_PAD, Y: y, Width: panel.Width - DIALOG_PAD * 2.0, Height: DIALOG_PRIMARY_BTN_HEIGHT };
        let link = RectF {
            X: panel.X + DIALOG_PAD,
            Y: y + DIALOG_PRIMARY_BTN_HEIGHT + DIALOG_PRIMARY_GAP,
            Width: panel.Width - DIALOG_PAD * 2.0,
            Height: DIALOG_LINK_HEIGHT,
        };
        (panel, confirm, link)
    }

    fn button_at(&self, width: f32, height: f32, x: f32, y: f32) -> Option<UiButton> {
        for btn in [UiButton::Minimize, UiButton::Close] {
            if rect_contains(self.title_bar_button_rect(width, btn), x, y) {
                return Some(btn);
            }
        }
        if self.show_restart_dialog {
            let (_, primary, link, _) = self.restart_dialog_layout(width, height);
            if rect_contains(primary, x, y) {
                return Some(UiButton::RestartNow);
            }
            if rect_contains(link, x, y) {
                return Some(UiButton::RestartLater);
            }
        } else if self.confirm_restore.is_some() {
            let (_, confirm, link) = self.confirm_dialog_layout(width, height);
            if rect_contains(confirm, x, y) {
                return Some(UiButton::ConfirmRestore);
            }
            if rect_contains(link, x, y) {
                return Some(UiButton::CancelRestore);
            }
        } else if !self.disclaimer_accepted {
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
                // Cached in content space (drawn as if `automatic_scroll`'s
                // viewport were unscrolled — see `draw_ui_automatic`), same
                // convention as the Extra Tools tab below.
                if self.automatic_scroll.contains(x, y) {
                    let y_content = y + self.automatic_scroll.offset;
                    for (i, rect) in self.action_rects.iter().enumerate() {
                        if rect_contains(*rect, x, y_content) {
                            return Some(UiButton::ActionCard(i));
                        }
                    }
                    for (choice, rect) in &self.quarantine_rects {
                        if rect_contains(*rect, x, y_content) {
                            return Some(UiButton::QuarantineSeg(*choice));
                        }
                    }
                    if rect_contains(self.run_button_rect, x, y_content) && self.can_run() {
                        return Some(UiButton::RunButton);
                    }
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
            } else if self.tab == Tab::Donate {
                if self.donate_scroll.contains(x, y) {
                    let y_content = y + self.donate_scroll.offset;
                    for (i, rect) in self.copy_button_rects.iter().enumerate() {
                        if rect_contains(*rect, x, y_content) {
                            return Some(UiButton::CopyAddress(i));
                        }
                    }
                    if !PAYPAL_URL.is_empty() && rect_contains(self.paypal_button_rect, x, y_content) {
                        return Some(UiButton::OpenPayPal);
                    }
                }
            } else if self.tab == Tab::ExtraTools {
                // All of this tab's interactive rects were cached in
                // "outer-content space" (drawn as if `outer_scroll`'s
                // viewport were unscrolled — see `draw_ui_extra_tools`),
                // so the real cursor `y` needs converting back into that
                // space before comparing against them; the reverse of what
                // `ScrollState::show` does to draw them on screen.
                if self.outer_scroll.contains(x, y) {
                    let y_content = y + self.outer_scroll.offset;
                    if rect_contains(self.backup_scroll.last_viewport, x, y_content) {
                        let y_inner = y_content + self.backup_scroll.offset;
                        let relative_y = y_inner - self.backup_scroll.last_viewport.Y;
                        if relative_y >= 0.0 {
                            let index = (relative_y / BACKUP_ROW_HEIGHT) as usize;
                            if index < self.available_backups.len() {
                                return Some(UiButton::BackupRadio(index));
                            }
                        }
                    }
                    if rect_contains(self.refresh_backups_rect, x, y_content) {
                        return Some(UiButton::RefreshBackups);
                    }
                    if !self.busy
                        && self.selected_backup.is_some()
                        && rect_contains(self.restore_button_rect, x, y_content)
                    {
                        return Some(UiButton::RestoreButton);
                    }
                    if !self.busy {
                        for (task, rect) in &self.maintenance_row_rects {
                            if rect_contains(*rect, x, y_content) {
                                return Some(UiButton::RunMaintenance(*task));
                            }
                        }
                    }
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
        near.set_line_align(StringAlignmentCenter).unwrap();
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
        center.set_line_align(StringAlignmentCenter).unwrap();
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
        center.set_line_align(StringAlignmentCenter).unwrap();

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

    /// The "Automatique" tab: a 2-column grid of action-checkbox cards, the
    /// 3-way quarantine choice, a run button, and (mockup parity — the
    /// original egui app never had this) a right-hand sidebar with the
    /// live catalog size and the last run's timestamp. Scrolls as one
    /// block (see `kprm_win32gui::scroll`) for whenever the window is
    /// resized smaller than all of this needs.
    fn draw_ui_automatic(&mut self, g: &Graphics, width: f32, height: f32) {
        let top = TITLE_BAR_HEIGHT + TAB_BAR_HEIGHT;
        let bottom = height - FOOTER_HEIGHT;
        let viewport = RectF { X: 0.0, Y: top, Width: width, Height: (bottom - top).max(40.0) };
        let content_x = CONTENT_PAD_X;
        let content_y = top + CONTENT_PAD_TOP;
        let left_col_width = width - CONTENT_PAD_X * 2.0 - SIDEBAR_WIDTH - COLUMN_GAP;

        let mut content_bottom = viewport.Y;
        let mut scroll = self.automatic_scroll;
        scroll.show(g, viewport, |g| {
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
            let left_bottom =
                self.run_button_rect.Y + self.run_button_rect.Height + if !self.can_run() { 22.0 } else { 0.0 };

            let sidebar_bottom = self.draw_sidebar(g, width, top);
            content_bottom = left_bottom.max(sidebar_bottom) + 20.0;
        });
        let content_height = content_bottom - viewport.Y;
        scroll.finish(g, content_height);
        self.automatic_scroll = scroll;
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
        center.set_line_align(StringAlignmentCenter).unwrap();
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
    /// between runs. Returns the sidebar's own bottom Y so the caller can
    /// compare it against the left column's when sizing the tab's scroll
    /// content.
    fn draw_sidebar(&self, g: &Graphics, width: f32, top: f32) -> f32 {
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

        stats_y + STATS_H
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
        center.set_line_align(StringAlignmentCenter).unwrap();
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
        center.set_line_align(StringAlignmentCenter).unwrap();
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
        center.set_line_align(StringAlignmentCenter).unwrap();
        g.draw_string(label, &self.fonts.proportional(12.5), self.remove_selected_button_rect, &center, &brush)
            .unwrap();
    }

    /// The "Dons" tab: a primary Bitcoin card with a real QR code (mockup
    /// parity — the original app never rendered one) plus a copy button,
    /// then compact rows for the other addresses and, once
    /// [`PAYPAL_URL`] is filled in, a PayPal link (GitHub Sponsors is
    /// intentionally not implemented, per the user's request).
    fn draw_ui_donate(&mut self, g: &Graphics, width: f32, height: f32) {
        let top = TITLE_BAR_HEIGHT + TAB_BAR_HEIGHT;
        let bottom = height - FOOTER_HEIGHT;
        let viewport = RectF { X: 0.0, Y: top, Width: width, Height: (bottom - top).max(40.0) };
        let content_x = CONTENT_PAD_X;
        let content_w = width - CONTENT_PAD_X * 2.0;

        let mut content_bottom = viewport.Y;
        let mut scroll = self.donate_scroll;
        scroll.show(g, viewport, |g| {
            let mut y = top + CONTENT_PAD_TOP;

            let near = StringFormat::new().unwrap();
            near.set_align(StringAlignmentNear).unwrap();

            let header_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
            g.draw_string(
                &self.t("tab-donate").to_uppercase(),
                &self.fonts.proportional(11.0),
                RectF { X: content_x, Y: y, Width: content_w, Height: 16.0 },
                &near,
                &header_brush,
            )
            .unwrap();
            y += 24.0;

            let body_brush = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
            g.draw_string(
                &self.t("donate-body"),
                &self.fonts.proportional(12.0),
                RectF { X: content_x, Y: y, Width: content_w, Height: 20.0 },
                &near,
                &body_brush,
            )
            .unwrap();
            y += 32.0;

            // Every address gets the same treatment: label + address + copy
            // button + its own scannable QR code.
            let copy_label = self.t("copy-button");
            let cryptos = [
                (0usize, "Bitcoin (BTC)", BTC_ADDRESS),
                (1, "Ethereum (ETH)", ETH_ADDRESS),
                (2, "Litecoin (LTC)", LTC_ADDRESS),
                (3, "Monero (XMR)", XMR_ADDRESS),
            ];
            for (i, label, address) in cryptos {
                let card_rect = RectF { X: content_x, Y: y, Width: content_w, Height: DONATE_CARD_HEIGHT };
                self.draw_donate_card(g, card_rect, i, label, address, &copy_label);
                y += DONATE_CARD_HEIGHT + DONATE_CARD_GAP;
            }

            if !PAYPAL_URL.is_empty() {
                self.paypal_button_rect = RectF { X: content_x, Y: y, Width: 160.0, Height: 32.0 };
                self.draw_paypal_button(g, self.paypal_button_rect);
                y += 32.0;
            }
            content_bottom = y + 20.0;
        });
        let content_height = content_bottom - viewport.Y;
        scroll.finish(g, content_height);
        self.donate_scroll = scroll;
    }

    #[allow(clippy::too_many_arguments)]
    fn draw_donate_card(&mut self, g: &Graphics, card_rect: RectF, index: usize, label: &str, address: &str, copy_label: &str) {
        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();

        let panel = SolidBrush::new(theme::BG_PANEL.to_argb()).unwrap();
        g.fill_rounded_rect(card_rect, 12.0, &panel).unwrap();
        let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
        g.draw_rounded_rect(card_rect, 12.0, &border).unwrap();

        let text_1 = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        let label_x = card_rect.X + DONATE_CARD_PAD;
        let text_area_w = card_rect.Width - DONATE_CARD_PAD * 3.0 - QR_SIZE;
        g.draw_string(
            label,
            &self.fonts.proportional(13.5),
            RectF { X: label_x, Y: card_rect.Y + DONATE_CARD_PAD, Width: text_area_w, Height: 18.0 },
            &near,
            &text_1,
        )
        .unwrap();

        let copy_w = g.measure_line_width(copy_label, &self.fonts.proportional(11.0)).unwrap_or(50.0) + 24.0;
        let addr_y = card_rect.Y + DONATE_CARD_PAD + 26.0;
        let addr_box_w = (text_area_w - copy_w - 8.0).max(40.0);
        let addr_box = RectF { X: label_x, Y: addr_y, Width: addr_box_w, Height: 32.0 };
        let elevated = SolidBrush::new(theme::BG_ELEVATED.to_argb()).unwrap();
        g.fill_rounded_rect(addr_box, 8.0, &elevated).unwrap();
        g.draw_rounded_rect(addr_box, 8.0, &border).unwrap();
        let addr_text = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
        g.draw_string(
            address,
            &self.fonts.monospace(10.5),
            RectF { X: addr_box.X + 10.0, Y: addr_box.Y + 8.0, Width: addr_box.Width - 20.0, Height: 18.0 },
            &near,
            &addr_text,
        )
        .unwrap();

        self.copy_button_rects[index] =
            RectF { X: addr_box.X + addr_box.Width + 8.0, Y: addr_y, Width: copy_w, Height: 32.0 };
        self.draw_copy_button(g, self.copy_button_rects[index], index, copy_label);

        let qr_rect = RectF {
            X: card_rect.X + card_rect.Width - DONATE_CARD_PAD - QR_SIZE,
            Y: card_rect.Y + (DONATE_CARD_HEIGHT - QR_SIZE) / 2.0,
            Width: QR_SIZE,
            Height: QR_SIZE,
        };
        self.draw_qr(g, qr_rect, address);
    }

    fn draw_copy_button(&self, g: &Graphics, rect: RectF, index: usize, label: &str) {
        let hovered = self.hover == Some(UiButton::CopyAddress(index));
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
        center.set_line_align(StringAlignmentCenter).unwrap();
        g.draw_string(label, &self.fonts.proportional(11.0), rect, &center, &brush).unwrap();
    }

    #[allow(clippy::too_many_arguments)]
    fn draw_paypal_button(&self, g: &Graphics, rect: RectF) {
        let hovered = self.hover == Some(UiButton::OpenPayPal);
        let border_color = if hovered { theme::BORDER } else { theme::BORDER_SOFT };
        let pen = Pen::new(border_color.to_argb(), 1.5).unwrap();
        g.draw_rounded_rect(rect, theme::RADIUS, &pen).unwrap();
        let text_color = if hovered { theme::TEXT_1 } else { theme::TEXT_2 };
        let brush = SolidBrush::new(text_color.to_argb()).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        center.set_line_align(StringAlignmentCenter).unwrap();
        g.draw_string("PayPal", &self.fonts.proportional(12.5), rect, &center, &brush).unwrap();
    }

    /// Encodes `data` (the BTC address) into a QR code and draws it as
    /// plain filled squares, one per module — genuinely new functionality,
    /// not a port (the original app never had one).
    fn draw_qr(&self, g: &Graphics, rect: RectF, data: &str) {
        let bg = SolidBrush::new(Color::rgb(0xff, 0xff, 0xff).to_argb()).unwrap();
        g.fill_rounded_rect(rect, 6.0, &bg).ok();

        let Ok(code) = qrcode::QrCode::new(data.as_bytes()) else {
            return;
        };
        let modules_per_side = code.width();
        let colors = code.to_colors();
        const QUIET_ZONE: f32 = 1.0;
        let module_size = rect.Width / (modules_per_side as f32 + QUIET_ZONE * 2.0);
        let offset = module_size * QUIET_ZONE;
        let dark = SolidBrush::new(Color::rgb(0x14, 0x16, 0x1b).to_argb()).unwrap();
        for row in 0..modules_per_side {
            for col in 0..modules_per_side {
                if colors[row * modules_per_side + col] == qrcode::Color::Dark {
                    let module_rect = RectF {
                        X: rect.X + offset + col as f32 * module_size,
                        Y: rect.Y + offset + row as f32 * module_size,
                        Width: module_size + 0.5,
                        Height: module_size + 0.5,
                    };
                    g.fill_rect(module_rect, &dark).ok();
                }
            }
        }
    }

    /// The "Outils +" tab: a registry-restore section (its own nested
    /// scroll for the backup list, inside the whole-tab scroll) followed
    /// by 12 maintenance actions across 5 sections — the rewrite's other
    /// scroll-primitive risk, this time nested. See
    /// `kprm_win32gui::scroll::ScrollState::show`'s doc comment for how the
    /// two scrolls' coordinate spaces compose, and `button_at`/
    /// `on_mouse_wheel` for how hit-testing and wheel routing undo it.
    fn draw_ui_extra_tools(&mut self, g: &Graphics, width: f32, height: f32) {
        let top = TITLE_BAR_HEIGHT + TAB_BAR_HEIGHT;
        let bottom = height - FOOTER_HEIGHT;
        let content_x = CONTENT_PAD_X;
        let content_w = width - CONTENT_PAD_X * 2.0;
        let viewport =
            RectF { X: content_x, Y: top, Width: content_w, Height: (bottom - top).max(40.0) };

        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        center.set_line_align(StringAlignmentCenter).unwrap();
        let header_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
        let title_brush = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        let desc_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
        let amber_brush = SolidBrush::new(theme::AMBER.to_argb()).unwrap();
        let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();

        let sections: [(&str, &[(&str, &str, MaintenanceTask, bool)]); 5] = [
            (
                "quick-actions-title",
                &[
                    ("quick-actions-flush-dns", "quick-actions-flush-dns-desc", MaintenanceTask::FlushDns, false),
                    ("quick-actions-clean-temp", "quick-actions-clean-temp-desc", MaintenanceTask::CleanTempDirs, false),
                    ("quick-actions-empty-recycle", "quick-actions-empty-recycle-desc", MaintenanceTask::EmptyRecycleBin, false),
                ],
            ),
            (
                "network-section-title",
                &[
                    ("network-winsock-reset", "network-winsock-reset-desc", MaintenanceTask::ResetWinsock, true),
                    ("network-hosts-reset", "network-hosts-reset-desc", MaintenanceTask::ResetHostsFile, false),
                    ("network-proxy-remove", "network-proxy-remove-desc", MaintenanceTask::RemoveProxy, false),
                ],
            ),
            (
                "browsers-section-title",
                &[
                    ("browsers-policies-reset", "browsers-policies-reset-desc", MaintenanceTask::ResetBrowserPolicies, false),
                    ("browsers-file-assoc", "browsers-file-assoc-desc", MaintenanceTask::RestoreFileAssociations, false),
                ],
            ),
            (
                "windows-repair-title",
                &[
                    ("windows-repair-firewall", "windows-repair-firewall-desc", MaintenanceTask::ResetFirewall, false),
                    ("windows-repair-sfc", "windows-repair-sfc-desc", MaintenanceTask::RunSfc, false),
                    ("windows-repair-dism", "windows-repair-dism-desc", MaintenanceTask::RunDism, true),
                ],
            ),
            (
                "diag-section-title",
                &[("diag-button", "diag-button-desc", MaintenanceTask::GenerateDiagnosticReport, false)],
            ),
        ];

        let mut maint_rects: Vec<(MaintenanceTask, RectF)> = Vec::new();
        let mut refresh_rect = RectF::default();
        let mut restore_rect = RectF::default();
        let mut content_bottom = viewport.Y;

        // `outer_scroll`/`backup_scroll` are copied out for the duration of
        // the closures, and `backup_local` is shown from *inside* the outer
        // closure — see the borrow-checker pattern note on `draw_ui_custom`
        // and the coordinate-space note on `ScrollState::show`.
        let mut backup_local = self.backup_scroll;
        let mut outer = self.outer_scroll;
        outer.show(g, viewport, |g| {
            let x = viewport.X;
            let w = viewport.Width;
            let mut y = viewport.Y + CONTENT_PAD_TOP;

            g.draw_string(
                &self.t("tab-extra-tools").to_uppercase(),
                &self.fonts.proportional(11.0),
                RectF { X: x, Y: y, Width: w, Height: 16.0 },
                &near,
                &header_brush,
            )
            .ok();
            y += 24.0;

            g.draw_string(
                &self.t("restore-registry-title"),
                &self.fonts.proportional(13.0),
                RectF { X: x, Y: y, Width: w, Height: 18.0 },
                &near,
                &title_brush,
            )
            .ok();
            y += 22.0;

            g.draw_string(
                &self.t("restore-registry-intro"),
                &self.fonts.proportional(11.0),
                RectF { X: x, Y: y, Width: w, Height: 30.0 },
                &near,
                &desc_brush,
            )
            .ok();
            y += 34.0;

            g.draw_string(
                &self.t("restore-registry-warning"),
                &self.fonts.proportional(11.0),
                RectF { X: x, Y: y, Width: w, Height: 30.0 },
                &near,
                &amber_brush,
            )
            .ok();
            y += 40.0;

            let refresh_label = self.t("restore-registry-refresh");
            let refresh_w =
                g.measure_line_width(&refresh_label, &self.fonts.proportional(12.0)).unwrap_or(80.0) + 24.0;
            refresh_rect = RectF { X: x, Y: y, Width: refresh_w, Height: 30.0 };
            let refresh_hovered = self.hover == Some(UiButton::RefreshBackups);
            let refresh_border_color = if refresh_hovered { theme::BORDER } else { theme::BORDER_SOFT };
            let refresh_pen = Pen::new(refresh_border_color.to_argb(), 1.5).unwrap();
            g.draw_rounded_rect(refresh_rect, theme::RADIUS, &refresh_pen).ok();
            let refresh_text_color = if refresh_hovered { theme::TEXT_1 } else { theme::TEXT_2 };
            let refresh_brush = SolidBrush::new(refresh_text_color.to_argb()).unwrap();
            g.draw_string(&refresh_label, &self.fonts.proportional(12.0), refresh_rect, &center, &refresh_brush)
                .ok();
            y += 30.0 + 12.0;

            let panel_rect = RectF { X: x, Y: y, Width: w, Height: BACKUP_LIST_HEIGHT };
            let panel_fill = SolidBrush::new(theme::BG_PANEL.to_argb()).unwrap();
            g.fill_rounded_rect(panel_rect, 12.0, &panel_fill).ok();
            g.draw_rounded_rect(panel_rect, 12.0, &border).ok();

            let backup_viewport = RectF {
                X: panel_rect.X + 6.0,
                Y: panel_rect.Y + 6.0,
                Width: panel_rect.Width - 12.0,
                Height: panel_rect.Height - 12.0,
            };
            let backups_empty = self.available_backups.is_empty();
            let backup_content_h = if backups_empty {
                backup_viewport.Height
            } else {
                self.available_backups.len() as f32 * BACKUP_ROW_HEIGHT
            };

            backup_local.show(g, backup_viewport, |g| {
                if backups_empty {
                    let hint_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
                    g.draw_string(
                        &self.t("restore-registry-empty"),
                        &self.fonts.proportional(11.5),
                        RectF {
                            X: backup_viewport.X,
                            Y: backup_viewport.Y + backup_viewport.Height / 2.0 - 16.0,
                            Width: backup_viewport.Width,
                            Height: 32.0,
                        },
                        &center,
                        &hint_brush,
                    )
                    .ok();
                    return;
                }
                for i in 0..self.available_backups.len() {
                    let backup = &self.available_backups[i];
                    let is_selected = self.selected_backup.as_ref() == Some(backup);
                    let row_rect = RectF {
                        X: backup_viewport.X,
                        Y: backup_viewport.Y + i as f32 * BACKUP_ROW_HEIGHT,
                        Width: backup_viewport.Width,
                        Height: BACKUP_ROW_HEIGHT,
                    };
                    self.draw_backup_row(g, row_rect, i, backup, is_selected);
                }
            });
            backup_local.finish(g, backup_content_h);
            y += BACKUP_LIST_HEIGHT + 14.0;

            let restore_label = self.t("restore-registry-button");
            restore_rect = RectF { X: x, Y: y, Width: 140.0, Height: 32.0 };
            let can_restore = !self.busy && self.selected_backup.is_some();
            let restore_fill_color = if can_restore { theme::RED } else { theme::BG_PANEL };
            let restore_fill = SolidBrush::new(restore_fill_color.to_argb()).unwrap();
            g.fill_rounded_rect(restore_rect, theme::RADIUS, &restore_fill).ok();
            if !can_restore {
                g.draw_rounded_rect(restore_rect, theme::RADIUS, &border).ok();
            }
            let restore_text_color = if can_restore { Color::rgb(0xff, 0xff, 0xff) } else { theme::TEXT_3 };
            let restore_text_brush = SolidBrush::new(restore_text_color.to_argb()).unwrap();
            g.draw_string(&restore_label, &self.fonts.proportional(12.5), restore_rect, &center, &restore_text_brush)
                .ok();
            y += 32.0 + EXTRA_SECTION_GAP;

            for (section_key, rows) in sections {
                g.draw_line(x, y, x + w, y, &border).ok();
                y += 16.0;
                g.draw_string(
                    &self.t(section_key).to_uppercase(),
                    &self.fonts.proportional(11.0),
                    RectF { X: x, Y: y, Width: w, Height: 16.0 },
                    &near,
                    &header_brush,
                )
                .ok();
                y += 24.0;
                for (title_key, desc_key, task, amber) in rows.iter().copied() {
                    let row_rect = RectF { X: x, Y: y, Width: w, Height: MAINT_ROW_HEIGHT };
                    let title = self.t(title_key);
                    let desc = self.t(desc_key);
                    let btn_rect = self.draw_maintenance_row(g, row_rect, &title, &desc, amber);
                    maint_rects.push((task, btn_rect));
                    y += MAINT_ROW_HEIGHT + MAINT_ROW_GAP;
                }
                y += EXTRA_SECTION_GAP - MAINT_ROW_GAP;
            }

            content_bottom = y + 8.0;
        });

        let content_height = content_bottom - viewport.Y;
        outer.finish(g, content_height);
        self.outer_scroll = outer;
        self.backup_scroll = backup_local;
        self.refresh_backups_rect = refresh_rect;
        self.restore_button_rect = restore_rect;
        self.maintenance_row_rects = maint_rects;
    }

    fn draw_backup_row(
        &self,
        g: &Graphics,
        rect: RectF,
        index: usize,
        backup: &kprm_engine::backup::AvailableBackup,
        selected: bool,
    ) {
        let hovered = self.hover == Some(UiButton::BackupRadio(index));
        if hovered {
            let fill = SolidBrush::new(theme::BG_HOVER.to_argb()).unwrap();
            g.fill_rounded_rect(rect, 6.0, &fill).ok();
        }

        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();

        const RADIO_SIZE: f32 = 14.0;
        let radio_rect = RectF {
            X: rect.X + 6.0,
            Y: rect.Y + rect.Height / 2.0 - RADIO_SIZE / 2.0,
            Width: RADIO_SIZE,
            Height: RADIO_SIZE,
        };
        let ring_color = if selected { theme::BLUE } else { theme::BORDER };
        let ring_pen = Pen::new(ring_color.to_argb(), 1.5).unwrap();
        g.draw_rounded_rect(radio_rect, RADIO_SIZE / 2.0, &ring_pen).ok();
        if selected {
            const DOT: f32 = RADIO_SIZE - 7.0;
            let dot_rect = RectF { X: radio_rect.X + 3.5, Y: radio_rect.Y + 3.5, Width: DOT, Height: DOT };
            let dot_fill = SolidBrush::new(theme::BLUE.to_argb()).unwrap();
            g.fill_rounded_rect(dot_rect, DOT / 2.0, &dot_fill).ok();
        }

        let tag_font = self.fonts.proportional(9.5);
        let tag_brush = SolidBrush::new(theme::TEXT_3.to_argb()).unwrap();
        let mut tag_x = rect.X + rect.Width - 8.0;
        for tag in [("NTUSER.DAT", backup.has_ntuser), ("SOFTWARE", backup.has_software)] {
            if !tag.1 {
                continue;
            }
            let tag_w = g.measure_line_width(tag.0, &tag_font).unwrap_or(50.0);
            tag_x -= tag_w;
            g.draw_string(
                tag.0,
                &tag_font,
                RectF { X: tag_x, Y: rect.Y + rect.Height / 2.0 - 7.0, Width: tag_w, Height: 14.0 },
                &near,
                &tag_brush,
            )
            .ok();
            tag_x -= 10.0;
        }

        let text_color = if selected { theme::TEXT_1 } else { theme::TEXT_2 };
        let text_brush = SolidBrush::new(text_color.to_argb()).unwrap();
        let label_x = radio_rect.X + RADIO_SIZE + 8.0;
        g.draw_string(
            &format_backup_timestamp(&backup.timestamp),
            &self.fonts.monospace(11.5),
            RectF { X: label_x, Y: rect.Y, Width: (tag_x - label_x - 8.0).max(20.0), Height: rect.Height },
            &near,
            &text_brush,
        )
        .ok();
    }

    /// One maintenance action row: title + wrapped description on the
    /// left, a blue "Exécuter" button on the right — returns the button's
    /// rect so the caller can cache it (in the same outer-content
    /// coordinate space as the row itself) for `button_at`.
    fn draw_maintenance_row(&self, g: &Graphics, rect: RectF, title: &str, desc: &str, amber: bool) -> RectF {
        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        center.set_line_align(StringAlignmentCenter).unwrap();

        let btn_rect = RectF {
            X: rect.X + rect.Width - MAINT_RUN_BTN_SIZE.0,
            Y: rect.Y + (rect.Height - MAINT_RUN_BTN_SIZE.1) / 2.0,
            Width: MAINT_RUN_BTN_SIZE.0,
            Height: MAINT_RUN_BTN_SIZE.1,
        };
        let text_w = (btn_rect.X - rect.X - 16.0).max(20.0);

        let title_brush = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        g.draw_string(
            title,
            &self.fonts.proportional(12.0),
            RectF { X: rect.X, Y: rect.Y, Width: text_w, Height: 18.0 },
            &near,
            &title_brush,
        )
        .ok();

        let desc_color = if amber { theme::AMBER } else { theme::TEXT_3 };
        let desc_brush = SolidBrush::new(desc_color.to_argb()).unwrap();
        g.draw_string(
            desc,
            &self.fonts.proportional(10.5),
            RectF { X: rect.X, Y: rect.Y + 20.0, Width: text_w, Height: rect.Height - 20.0 },
            &near,
            &desc_brush,
        )
        .ok();

        let enabled = !self.busy;
        let fill_color = if enabled { theme::BLUE } else { theme::BG_PANEL };
        let fill = SolidBrush::new(fill_color.to_argb()).unwrap();
        g.fill_rounded_rect(btn_rect, theme::RADIUS, &fill).ok();
        if !enabled {
            let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
            g.draw_rounded_rect(btn_rect, theme::RADIUS, &border).ok();
        }
        let text_color = if enabled { Color::rgb(0xff, 0xff, 0xff) } else { theme::TEXT_3 };
        let text_brush = SolidBrush::new(text_color.to_argb()).unwrap();
        g.draw_string(&self.t("run"), &self.fonts.proportional(12.0), btn_rect, &center, &text_brush).ok();

        btn_rect
    }

    fn draw_dialog_overlay(&self, g: &Graphics, width: f32, height: f32) {
        let overlay = SolidBrush::new(Color::rgba(0x0c, 0x0d, 0x10, 140).to_argb()).unwrap();
        g.fill_rect(RectF { X: 0.0, Y: 0.0, Width: width, Height: height }, &overlay).ok();
    }

    /// A panel with a centered icon badge, title and wrapped body — shared
    /// layout for both dialogs, at whatever rect the caller already worked
    /// out (see `restart_dialog_layout`/`confirm_dialog_layout`).
    fn draw_dialog_frame(&self, g: &Graphics, panel: RectF, badge_bg: Color, icon: &Icon, icon_color: Color, title: &str, body: &str) {
        let panel_fill = SolidBrush::new(theme::BG_PANEL.to_argb()).unwrap();
        g.fill_rounded_rect(panel, 14.0, &panel_fill).unwrap();
        let border = Pen::new(theme::BORDER.to_argb(), 1.0).unwrap();
        g.draw_rounded_rect(panel, 14.0, &border).unwrap();

        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();

        let badge_rect = RectF {
            X: panel.X + (panel.Width - DIALOG_BADGE_SIZE) / 2.0,
            Y: panel.Y + DIALOG_PAD,
            Width: DIALOG_BADGE_SIZE,
            Height: DIALOG_BADGE_SIZE,
        };
        let badge_fill = SolidBrush::new(badge_bg.to_argb()).unwrap();
        g.fill_rounded_rect(badge_rect, 999.0, &badge_fill).unwrap();
        let icon_rect = RectF {
            X: badge_rect.X + (DIALOG_BADGE_SIZE - 26.0) / 2.0,
            Y: badge_rect.Y + (DIALOG_BADGE_SIZE - 26.0) / 2.0,
            Width: 26.0,
            Height: 26.0,
        };
        icon.draw(g, icon_rect, icon_color, 1.8).ok();

        let title_y = badge_rect.Y + DIALOG_BADGE_SIZE + DIALOG_BADGE_GAP;
        let text_1 = SolidBrush::new(theme::TEXT_1.to_argb()).unwrap();
        g.draw_string(
            title,
            &self.fonts.proportional(15.0),
            RectF { X: panel.X + DIALOG_PAD, Y: title_y, Width: panel.Width - DIALOG_PAD * 2.0, Height: DIALOG_TITLE_HEIGHT },
            &center,
            &text_1,
        )
        .unwrap();

        let body_y = title_y + DIALOG_TITLE_HEIGHT + DIALOG_TITLE_GAP;
        let text_2 = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
        g.draw_string(
            body,
            &self.fonts.proportional(12.5),
            RectF { X: panel.X + DIALOG_PAD, Y: body_y, Width: panel.Width - DIALOG_PAD * 2.0, Height: DIALOG_BODY_HEIGHT },
            &center,
            &text_2,
        )
        .unwrap();
    }

    /// A full-width colored primary button plus a plain underlined "link"
    /// below it — `docs/design/Restart.dc.html`'s button stack, reused for
    /// both dialogs instead of the pre-rewrite egui version's side-by-side
    /// buttons.
    fn draw_dialog_buttons(&self, g: &Graphics, primary: RectF, link: RectF, primary_fill: Color, primary_text: Color, primary_label: &str, link_label: &str, link_hovered: bool) {
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        center.set_line_align(StringAlignmentCenter).unwrap();

        let fill = SolidBrush::new(primary_fill.to_argb()).unwrap();
        g.fill_rounded_rect(primary, theme::RADIUS, &fill).unwrap();
        let text_brush = SolidBrush::new(primary_text.to_argb()).unwrap();
        g.draw_string(primary_label, &self.fonts.proportional(13.5), primary, &center, &text_brush).unwrap();

        let link_color = if link_hovered { theme::TEXT_1 } else { theme::TEXT_2 };
        let link_brush = SolidBrush::new(link_color.to_argb()).unwrap();
        g.draw_string(link_label, &self.fonts.proportional(12.0), link, &center, &link_brush).unwrap();
        let text_w = g.measure_line_width(link_label, &self.fonts.proportional(12.0)).unwrap_or(60.0);
        let underline_y = link.Y + link.Height - 4.0;
        let underline_x = link.X + (link.Width - text_w) / 2.0;
        let underline_pen = Pen::new(link_color.to_argb(), 1.0).unwrap();
        g.draw_line(underline_x, underline_y, underline_x + text_w, underline_y, &underline_pen).ok();
    }

    /// The "Redémarrage nécessaire" prompt — shown after a real run left
    /// something scheduled for deletion (or a registry restore scheduled)
    /// on next boot (see `Report::needs_restart`). Restarting is always an
    /// explicit choice here, never automatic, unlike the original AutoIt
    /// tool.
    fn draw_restart_dialog(&self, g: &Graphics, width: f32, height: f32) {
        self.draw_dialog_overlay(g, width, height);
        let (panel, primary, link, lock_list) = self.restart_dialog_layout(width, height);

        let title = self.t("restart-dialog-title");
        let body = match self.restart_reason {
            RestartReason::LockedFiles => self.t("restart-dialog-body"),
            RestartReason::RegistryRestore => self.t("restore-restart-dialog-body"),
        };
        self.draw_dialog_frame(g, panel, theme::AMBER_BG, &app_icons::UNDO, theme::AMBER, &title, &body);

        if let Some(list_rect) = lock_list {
            let elevated = SolidBrush::new(theme::BG_ELEVATED.to_argb()).unwrap();
            g.fill_rounded_rect(list_rect, theme::RADIUS, &elevated).unwrap();
            let border = Pen::new(theme::BORDER_SOFT.to_argb(), 1.0).unwrap();
            g.draw_rounded_rect(list_rect, theme::RADIUS, &border).unwrap();

            let near = StringFormat::new().unwrap();
            near.set_align(StringAlignmentNear).unwrap();
            let path_brush = SolidBrush::new(theme::TEXT_2.to_argb()).unwrap();
            let shown = self.restart_locked_files.len().min(LOCK_LIST_MAX_ROWS);
            for (i, path) in self.restart_locked_files.iter().take(shown).enumerate() {
                let row_rect = RectF {
                    X: list_rect.X + LOCK_LIST_PAD,
                    Y: list_rect.Y + LOCK_LIST_PAD + i as f32 * LOCK_LIST_ROW_HEIGHT,
                    Width: list_rect.Width - LOCK_LIST_PAD * 2.0,
                    Height: LOCK_LIST_ROW_HEIGHT,
                };
                let icon_rect = RectF { X: row_rect.X, Y: row_rect.Y + row_rect.Height / 2.0 - 7.0, Width: 14.0, Height: 14.0 };
                app_icons::LOCK.draw(g, icon_rect, theme::TEXT_3, 1.8).ok();
                g.draw_string(
                    path,
                    &self.fonts.monospace(10.5),
                    RectF { X: row_rect.X + 22.0, Y: row_rect.Y, Width: row_rect.Width - 22.0, Height: row_rect.Height },
                    &near,
                    &path_brush,
                )
                .ok();
            }
        }

        let hovered = self.hover == Some(UiButton::RestartLater);
        self.draw_dialog_buttons(
            g,
            primary,
            link,
            theme::AMBER,
            Color::rgb(0x2a, 0x1a, 0x08),
            &self.t("restart-now-button"),
            &self.t("restart-later-button"),
            hovered,
        );
    }

    /// The "are you sure?" gate in front of a registry restore — the one
    /// action in the whole app that overwrites live system state wholesale
    /// and can't be undone, so it gets an explicit confirmation on top of
    /// the button click, unlike every other action here.
    fn draw_confirm_restore_dialog(&self, g: &Graphics, width: f32, height: f32) {
        let Some(backup) = self.confirm_restore.clone() else {
            return;
        };
        self.draw_dialog_overlay(g, width, height);
        let (panel, confirm, link) = self.confirm_dialog_layout(width, height);

        let title = self.t("restore-registry-confirm-title");
        let body = self.tf("restore-registry-confirm-body", &[("date", &format_backup_timestamp(&backup.timestamp))]);
        self.draw_dialog_frame(g, panel, theme::RED_BG, &app_icons::ALERT, theme::RED, &title, &body);

        let hovered = self.hover == Some(UiButton::CancelRestore);
        self.draw_dialog_buttons(
            g,
            confirm,
            link,
            theme::RED,
            Color::rgb(0xff, 0xff, 0xff),
            &self.t("restore-registry-confirm-button"),
            &self.t("restore-registry-cancel-button"),
            hovered,
        );
    }
}

fn rect_contains(r: RectF, x: f32, y: f32) -> bool {
    x >= r.X && x <= r.X + r.Width && y >= r.Y && y <= r.Y + r.Height
}

/// `20260905113716` -> `2026-09-05 11:37:16` (a backup folder's timestamp
/// name, as `AvailableBackup::timestamp` stores it).
fn format_backup_timestamp(timestamp: &str) -> String {
    if timestamp.len() != 14 || !timestamp.bytes().all(|b| b.is_ascii_digit()) {
        return timestamp.to_string();
    }
    format!(
        "{}-{}-{} {}:{}:{}",
        &timestamp[0..4],
        &timestamp[4..6],
        &timestamp[6..8],
        &timestamp[8..10],
        &timestamp[10..12],
        &timestamp[12..14],
    )
}

/// The status text shown while each maintenance task runs — SFC/DISM/the
/// diagnostic report get their own longer-running wording, everything else
/// shares the generic "running" status.
fn maintenance_status_key(task: MaintenanceTask) -> &'static str {
    match task {
        MaintenanceTask::RunSfc => "status-sfc",
        MaintenanceTask::RunDism => "status-dism",
        MaintenanceTask::GenerateDiagnosticReport => "diag-status-running",
        _ => "status-running",
    }
}

fn wide(s: &str) -> Vec<u16> {
    s.encode_utf16().chain(std::iter::once(0)).collect()
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
                Tab::ExtraTools => self.draw_ui_extra_tools(g, width, height),
                Tab::Donate => self.draw_ui_donate(g, width, height),
            }
        }

        // Overlay passes, on top of everything above — not real modal
        // windows (see the rewrite plan's architecture section), just a
        // darkened backdrop plus a centered panel, exactly like the
        // pre-rewrite egui version's `egui::Window` dialogs. `button_at`
        // gates all other hit-testing out while either is showing.
        if self.show_restart_dialog {
            self.draw_restart_dialog(g, width, height);
        } else if self.confirm_restore.is_some() {
            self.draw_confirm_restore_dialog(g, width, height);
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
                Some(UiButton::CopyAddress(i)) => {
                    let address = [BTC_ADDRESS, ETH_ADDRESS, LTC_ADDRESS, XMR_ADDRESS].get(i).copied();
                    if let Some(address) = address {
                        if let Ok(mut clipboard) = arboard::Clipboard::new() {
                            let _ = clipboard.set_text(address);
                        }
                    }
                }
                Some(UiButton::OpenPayPal) => {
                    if !PAYPAL_URL.is_empty() {
                        unsafe {
                            let operation = wide("open");
                            let url = wide(PAYPAL_URL);
                            let _ = windows::Win32::UI::Shell::ShellExecuteW(
                                None,
                                windows::core::PCWSTR(operation.as_ptr()),
                                windows::core::PCWSTR(url.as_ptr()),
                                None,
                                None,
                                windows::Win32::UI::WindowsAndMessaging::SW_SHOWNORMAL,
                            );
                        }
                    }
                }
                Some(UiButton::RefreshBackups) => {
                    self.available_backups =
                        kprm_windows::list_registry_backups(&kprm_windows::EnvKnownDirs::detect());
                }
                Some(UiButton::BackupRadio(i)) => {
                    self.selected_backup = self.available_backups.get(i).cloned();
                }
                Some(UiButton::RestoreButton) => {
                    self.confirm_restore.clone_from(&self.selected_backup);
                }
                Some(UiButton::RunMaintenance(task)) => {
                    self.busy = true;
                    self.status = self.t(maintenance_status_key(task));
                    let _ = self.request_tx.send(WorkerRequest::RunMaintenanceTask(task));
                }
                Some(UiButton::RestartNow) => {
                    self.show_restart_dialog = false;
                    if let Err(err) = kprm_windows::reboot_machine() {
                        self.status = format!("{} : {err}", self.t("fail"));
                    }
                }
                Some(UiButton::RestartLater) => {
                    self.show_restart_dialog = false;
                }
                Some(UiButton::ConfirmRestore) => {
                    if let Some(backup) = self.confirm_restore.take() {
                        self.busy = true;
                        self.status = self.t("status-restoring");
                        let _ = self.request_tx.send(WorkerRequest::RestoreRegistryBackup(backup));
                    }
                }
                Some(UiButton::CancelRestore) => {
                    self.confirm_restore = None;
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
        if self.tab == Tab::Automatic && self.automatic_scroll.contains(x, y) {
            self.automatic_scroll.scroll_by_notches(notches, TAB_SCROLL_LINE_HEIGHT);
            true
        } else if self.tab == Tab::Custom && self.scroll.contains(x, y) {
            self.scroll.scroll_by_notches(notches, RESULT_ROW_HEIGHT);
            true
        } else if self.tab == Tab::Donate && self.donate_scroll.contains(x, y) {
            self.donate_scroll.scroll_by_notches(notches, TAB_SCROLL_LINE_HEIGHT);
            true
        } else if self.tab == Tab::ExtraTools {
            // Innermost scroll under the cursor wins: `backup_scroll`'s
            // viewport is cached in outer-content space (see `button_at`),
            // so convert it back to real/screen space before testing
            // containment against the real cursor position.
            let backup_real_viewport = RectF {
                X: self.backup_scroll.last_viewport.X,
                Y: self.backup_scroll.last_viewport.Y - self.outer_scroll.offset,
                Width: self.backup_scroll.last_viewport.Width,
                Height: self.backup_scroll.last_viewport.Height,
            };
            if rect_contains(backup_real_viewport, x, y) {
                self.backup_scroll.scroll_by_notches(notches, BACKUP_ROW_HEIGHT);
                true
            } else if self.outer_scroll.contains(x, y) {
                self.outer_scroll.scroll_by_notches(notches, TAB_SCROLL_LINE_HEIGHT);
                true
            } else {
                false
            }
        } else {
            false
        }
    }
}
