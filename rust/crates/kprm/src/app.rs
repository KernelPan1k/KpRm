//! The two functional tabs (Automatique / Analyse personnalisée) plus two
//! static placeholder tabs (Outils + / Dons), matching the design mockup
//! shared earlier in the project. Real actions run on a background thread
//! (see [`crate::worker`]) so the UI never freezes during a scan/removal.

use std::collections::HashSet;
use std::sync::mpsc::{Receiver, Sender};

use eframe::egui::{self, Align2, Color32, FontId, Frame, Margin, Sense, Stroke, Vec2};
use kprm_engine::quarantine::QuarantineMode;
use kprm_engine::report::{Event, EventResult, Report};

use crate::theme;
use crate::worker::{self, WorkerRequest, WorkerResponse};

#[derive(PartialEq, Eq, Clone, Copy)]
enum Tab {
    Automatic,
    Custom,
    ExtraTools,
    Donate,
}

#[derive(PartialEq, Clone, Copy)]
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

pub struct KprmApp {
    tab: Tab,

    opt_remove_tools: bool,
    opt_backup_registry: bool,
    opt_remove_restore_points: bool,
    opt_create_restore_point: bool,
    opt_restore_uac: bool,
    opt_restore_settings: bool,
    quarantine_choice: QuarantineChoice,

    status: String,
    busy: bool,
    /// `(processed, total)` tools, updated during a scan or a real
    /// "Supprimer les outils" pass — `None` while busy with a step that
    /// doesn't report fine-grained progress (backup, restore points, UAC,
    /// settings), or while idle.
    progress: Option<(usize, usize)>,

    scan_results: Vec<(Event, bool)>,

    /// Set when the last real run left something scheduled for deletion
    /// on next boot — prompts the "Redémarrage nécessaire" dialog instead
    /// of restarting unconditionally like the original did.
    show_restart_dialog: bool,

    /// Gates the whole app behind the startup disclaimer (see
    /// [`KprmApp::ui_disclaimer`]) until accepted, matching the original.
    disclaimer_accepted: bool,

    /// Loaded once at startup from the detected OS locale (see
    /// `main.rs`) — every UI string except the "KpRm"/"by kernel-panik"
    /// brand text and the crypto addresses goes through [`KprmApp::t`]/
    /// [`KprmApp::tf`] instead of a hardcoded literal.
    t: kprm_i18n::Translations,

    request_tx: Sender<WorkerRequest>,
    response_rx: Receiver<WorkerResponse>,
}

impl KprmApp {
    pub fn new(translations: kprm_i18n::Translations) -> Self {
        let (response_tx, response_rx) = std::sync::mpsc::channel();
        let request_tx = worker::spawn(response_tx);
        let status = translations
            .get("status-ready")
            .unwrap_or_else(|_| "Ready".to_string());
        Self {
            tab: Tab::Automatic,
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
            disclaimer_accepted: false,
            t: translations,
            request_tx,
            response_rx,
        }
    }

    /// Looks up `key` in the current locale, falling back to the raw key
    /// itself if somehow missing — this must never panic, even if a key
    /// was mistyped somewhere, since it runs on every frame.
    fn t(&self, key: &str) -> String {
        self.t.get(key).unwrap_or_else(|_| key.to_string())
    }

    /// Like [`KprmApp::t`], with `{ $name }` placeables filled in from
    /// `args`.
    fn tf(&self, key: &str, args: &[(&str, &str)]) -> String {
        self.t
            .get_fmt(key, args)
            .unwrap_or_else(|_| key.to_string())
    }
}

/// A small square glyph button (minimize/close), used only in the title bar.
fn icon_button(ui: &mut egui::Ui, glyph: &str, hover_bg: Color32) -> egui::Response {
    let (rect, response) = ui.allocate_exact_size(Vec2::splat(26.0), Sense::click());
    if response.hovered() {
        ui.painter().rect_filled(rect, 6.0, hover_bg);
    }
    ui.painter().text(
        rect.center(),
        Align2::CENTER_CENTER,
        glyph,
        FontId::proportional(14.0),
        theme::TEXT_2,
    );
    response
}

/// One "card" row in the Actions section: checkbox + colored icon badge +
/// bold title + muted one-line description, matching the mockup's row
/// pattern (docs/design/Main.dc.html).
///
/// `width` is computed once by the caller and threaded straight down,
/// rather than re-derived from `ui.available_width()` inside nested
/// closures — simpler to reason about, and confirmed correct by measuring
/// the actual laid-out rects (see rust/README.md: this session's
/// screenshot tooling turned out to be unreliable and was giving false
/// negatives during development — the layout itself was fine).
#[allow(clippy::too_many_arguments)]
fn action_row(
    ui: &mut egui::Ui,
    checked: &mut bool,
    badge_bg: Color32,
    badge_fg: Color32,
    glyph: &str,
    title: &str,
    description: &str,
    width: f32,
) {
    const CHECKBOX_W: f32 = 22.0;
    const BADGE_W: f32 = 26.0;
    const MARGIN: f32 = 12.0 * 2.0;
    const GAPS: f32 = 8.0 * 2.0;
    let text_width = (width - CHECKBOX_W - BADGE_W - MARGIN - GAPS).max(60.0);

    Frame::none()
        .fill(theme::BG_PANEL)
        .stroke(Stroke::new(1.0_f32, theme::BORDER_SOFT))
        .rounding(theme::RADIUS)
        .inner_margin(Margin::symmetric(12.0, 10.0))
        .show(ui, |ui| {
            ui.set_width(width - MARGIN);
            // Fixed content height regardless of description length, so
            // every card in the grid lines up with its neighbors — without
            // this, a card whose description happens to wrap to a second
            // line ends up taller than the others in its row/column,
            // producing the slight misalignment reported after the last
            // round (short descriptions are also kept short on purpose so
            // none of them actually need to wrap at the current column
            // width; this is the safety net for if that ever changes).
            ui.set_min_height(34.0);
            ui.horizontal(|ui| {
                ui.checkbox(checked, "");
                let (badge_rect, _) = ui.allocate_exact_size(Vec2::splat(BADGE_W), Sense::hover());
                ui.painter().rect_filled(badge_rect, 7.0, badge_bg);
                ui.painter().text(
                    badge_rect.center(),
                    Align2::CENTER_CENTER,
                    glyph,
                    FontId::proportional(13.0),
                    badge_fg,
                );
                ui.vertical(|ui| {
                    ui.set_width(text_width);
                    ui.add(
                        egui::Label::new(
                            egui::RichText::new(title)
                                .size(13.0)
                                .strong()
                                .color(theme::TEXT_1),
                        )
                        .wrap(),
                    );
                    ui.add(
                        egui::Label::new(
                            egui::RichText::new(description)
                                .size(10.5)
                                .color(theme::TEXT_2),
                        )
                        .wrap(),
                    );
                });
            });
        });
}

/// One segment of the 3-way quarantine choice (Conserver / Maintenant /
/// Dans 7 jours). Uses `ui.add_sized` for the button's footprint; the
/// description is a hover tooltip instead of a second line, keeping this a
/// plain `Button`.
/// Returns `true` when this click just changed `choice` to `value` — the
/// caller uses this to auto-check "Supprimer les outils" when a quarantine
/// mode other than "Conserver" is picked (original spec §2.2: each of
/// "Supprimer maintenant"/"Dans 7 jours" auto-selects it, since quarantine
/// only has any effect inside tool removal in the first place — picking
/// one without it silently did nothing before this).
fn quarantine_segment(
    ui: &mut egui::Ui,
    choice: &mut QuarantineChoice,
    value: QuarantineChoice,
    title: &str,
    subtitle: &str,
    width: f32,
) -> bool {
    let selected = *choice == value;
    let (bg, border, text_color) = if selected {
        (theme::BLUE_BG, theme::BLUE, theme::TEXT_1)
    } else {
        (theme::BG_PANEL, theme::BORDER_SOFT, theme::TEXT_2)
    };

    let button = egui::Button::new(
        egui::RichText::new(title)
            .size(12.5)
            .strong()
            .color(text_color),
    )
    .fill(bg)
    .stroke(Stroke::new(1.5_f32, border))
    .rounding(theme::RADIUS);
    let response = ui
        .add_sized(Vec2::new(width, 36.0), button)
        .on_hover_text(subtitle);
    if response.clicked() {
        *choice = value;
        true
    } else {
        false
    }
}

impl KprmApp {
    fn poll_worker(&mut self) {
        // Drained in a loop rather than once: progress messages can arrive
        // faster than this is polled, and the final Done/Failed must never
        // be missed behind a backlog of Progress ones.
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
                WorkerResponse::Failed(message) => {
                    self.busy = false;
                    self.progress = None;
                    self.status = format!("{} : {message}", self.t("fail"));
                }
            }
        }
    }

    /// A scan's report is "all Found" — becomes the checkable list.
    /// Any other report (an automatic run, or a "remove selected" pass)
    /// instead prunes whatever it successfully touched out of that list.
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

    /// The startup "AS IS, no warranty, no commercial use" disclaimer —
    /// see [`KprmApp::disclaimer_accepted`]. Declining closes the window
    /// immediately, matching the original's `Exit` on "No".
    fn ui_disclaimer(&mut self, ui: &mut egui::Ui, ctx: &egui::Context) {
        let title = self.t("eula-title");
        let body = self.t("eula-body");
        let accept_label = self.t("eula-accept");
        let decline_label = self.t("eula-decline");
        ui.vertical_centered(|ui| {
            ui.add_space(20.0);
            ui.label(
                egui::RichText::new(title)
                    .size(17.0)
                    .strong()
                    .color(theme::TEXT_1),
            );
            ui.add_space(16.0);
            ui.add(
                egui::Label::new(egui::RichText::new(body).size(13.0).color(theme::TEXT_2)).wrap(),
            );
            ui.add_space(24.0);
            ui.horizontal(|ui| {
                let accept = egui::Button::new(
                    egui::RichText::new(accept_label)
                        .strong()
                        .color(Color32::from_rgb(0x10, 0x2a, 0x1c)),
                )
                .fill(theme::GREEN)
                .min_size(Vec2::new(90.0, 32.0));
                if ui.add(accept).clicked() {
                    self.disclaimer_accepted = true;
                }
                ui.add_space(8.0);
                let decline =
                    egui::Button::new(egui::RichText::new(decline_label).color(Color32::WHITE))
                        .fill(theme::RED)
                        .min_size(Vec2::new(90.0, 32.0));
                if ui.add(decline).clicked() {
                    ctx.send_viewport_cmd(egui::ViewportCommand::Close);
                }
            });
        });
    }

    /// The "Redémarrage nécessaire" prompt — shown after a real run left
    /// something scheduled for deletion on next boot (see
    /// [`Report::needs_restart`]). Mirrors `docs/design/Restart.dc.html`;
    /// unlike the original AutoIt tool, restarting is an explicit choice,
    /// never automatic.
    fn restart_dialog(&mut self, ctx: &egui::Context) {
        if !self.show_restart_dialog {
            return;
        }

        let title = self.t("restart-dialog-title");
        let body = self.t("restart-dialog-body");
        let restart_label = self.t("restart-now-button");
        let later_label = self.t("restart-later-button");
        let fail_label = self.t("fail");

        egui::Window::new("restart_dialog")
            .title_bar(false)
            .collapsible(false)
            .resizable(false)
            .anchor(egui::Align2::CENTER_CENTER, Vec2::ZERO)
            .frame(
                Frame::none()
                    .fill(theme::BG_ELEVATED)
                    .stroke(Stroke::new(1.0_f32, theme::BORDER_SOFT))
                    .rounding(theme::RADIUS)
                    .inner_margin(Margin::same(20.0)),
            )
            .show(ctx, |ui| {
                ui.set_width(340.0);
                ui.label(
                    egui::RichText::new(title)
                        .size(15.0)
                        .strong()
                        .color(theme::TEXT_1),
                );
                ui.add_space(8.0);
                ui.add(
                    egui::Label::new(egui::RichText::new(body).size(12.0).color(theme::TEXT_2))
                        .wrap(),
                );
                ui.add_space(16.0);
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    let restart_button = egui::Button::new(
                        egui::RichText::new(restart_label)
                            .strong()
                            .color(Color32::from_rgb(0x2a, 0x1a, 0x08)),
                    )
                    .fill(theme::AMBER)
                    .min_size(Vec2::new(170.0, 32.0));
                    if ui.add(restart_button).clicked() {
                        self.show_restart_dialog = false;
                        if let Err(err) = kprm_windows::reboot_machine() {
                            self.status = format!("{fail_label} : {err}");
                        }
                    }
                    ui.add_space(8.0);
                    let later_button =
                        egui::Button::new(egui::RichText::new(later_label).color(theme::TEXT_2))
                            .fill(theme::BG_PANEL)
                            .stroke(Stroke::new(1.0_f32, theme::BORDER_SOFT))
                            .min_size(Vec2::new(90.0, 32.0));
                    if ui.add(later_button).clicked() {
                        self.show_restart_dialog = false;
                    }
                });
            });
    }

    fn title_bar(&mut self, ctx: &egui::Context) {
        egui::TopBottomPanel::top("titlebar")
            .frame(
                Frame::none()
                    .fill(theme::BG_ELEVATED)
                    .inner_margin(Margin::symmetric(12.0, 8.0)),
            )
            .exact_height(46.0)
            .show(ctx, |ui| {
                ui.horizontal(|ui| {
                    let (badge_rect, _) = ui.allocate_exact_size(Vec2::splat(26.0), Sense::hover());
                    ui.painter().rect_filled(badge_rect, 8.0, theme::BLUE_BG);
                    let c = badge_rect.center();
                    let stroke = Stroke::new(1.8_f32, theme::BLUE);
                    ui.painter()
                        .line_segment([c + Vec2::new(-6.0, 0.0), c + Vec2::new(-2.0, 4.0)], stroke);
                    ui.painter()
                        .line_segment([c + Vec2::new(-2.0, 4.0), c + Vec2::new(6.0, -5.0)], stroke);

                    ui.add_space(8.0);
                    ui.label(
                        egui::RichText::new("KpRm")
                            .strong()
                            .size(15.0)
                            .color(theme::TEXT_1),
                    );
                    ui.add_space(6.0);
                    Frame::none()
                        .fill(theme::BG_PANEL)
                        .stroke(Stroke::new(1.0_f32, theme::BORDER_SOFT))
                        .rounding(999.0)
                        .inner_margin(Margin::symmetric(7.0, 2.0))
                        .show(ui, |ui| {
                            ui.label(
                                egui::RichText::new(concat!("v", env!("CARGO_PKG_VERSION")))
                                    .monospace()
                                    .size(10.5)
                                    .color(theme::TEXT_2),
                            );
                        });
                    ui.add_space(10.0);
                    ui.label(
                        egui::RichText::new("by kernel-panik")
                            .size(10.5)
                            .color(theme::TEXT_3),
                    );

                    let remaining = ui.available_width() - 60.0;
                    let (drag_rect, drag_response) = ui.allocate_exact_size(
                        Vec2::new(remaining.max(0.0), 26.0),
                        Sense::click_and_drag(),
                    );
                    if drag_response.drag_started() {
                        ctx.send_viewport_cmd(egui::ViewportCommand::StartDrag);
                    }
                    let _ = drag_rect;

                    if icon_button(ui, "—", theme::BG_HOVER).clicked() {
                        ctx.send_viewport_cmd(egui::ViewportCommand::Minimized(true));
                    }
                    if icon_button(ui, "×", theme::RED_BG).clicked() {
                        ctx.send_viewport_cmd(egui::ViewportCommand::Close);
                    }
                });
            });
    }

    fn tab_bar(&mut self, ctx: &egui::Context) {
        egui::TopBottomPanel::top("tabs")
            .frame(
                Frame::none()
                    .fill(theme::BG)
                    .inner_margin(Margin::symmetric(16.0, 10.0)),
            )
            .show(ctx, |ui| {
                let tabs = [
                    (Tab::Automatic, self.t("auto")),
                    (Tab::Custom, self.t("custom")),
                    (Tab::ExtraTools, self.t("tab-extra-tools")),
                    (Tab::Donate, self.t("tab-donate")),
                ];
                let mut selected_rect = None;
                ui.horizontal(|ui| {
                    for (tab, label) in tabs {
                        let selected = self.tab == tab;
                        let color = if selected {
                            theme::TEXT_1
                        } else {
                            theme::TEXT_2
                        };
                        let resp = ui.add(
                            egui::Button::new(egui::RichText::new(label).size(13.0).color(color))
                                .frame(false),
                        );
                        if resp.clicked() {
                            self.tab = tab;
                        }
                        if selected {
                            selected_rect = Some(resp.rect);
                        }
                        ui.add_space(10.0);
                    }
                });
                let bottom = ui.min_rect().bottom() + 8.0;
                ui.painter().hline(
                    ui.max_rect().x_range(),
                    bottom,
                    Stroke::new(1.0_f32, theme::BORDER_SOFT),
                );
                if let Some(rect) = selected_rect {
                    ui.painter()
                        .hline(rect.x_range(), bottom, Stroke::new(2.0_f32, theme::BLUE));
                }
            });
    }

    fn footer(&mut self, ctx: &egui::Context) {
        egui::TopBottomPanel::bottom("status")
            .frame(
                Frame::none()
                    .fill(theme::BG_ELEVATED)
                    .inner_margin(Margin::symmetric(20.0, 12.0)),
            )
            .show(ctx, |ui| {
                ui.horizontal(|ui| {
                    let dot_color = if self.busy {
                        theme::BLUE
                    } else {
                        theme::TEXT_3
                    };
                    let (rect, _) = ui.allocate_exact_size(Vec2::splat(8.0), Sense::hover());
                    ui.painter().circle_filled(rect.center(), 4.0, dot_color);
                    ui.add_space(4.0);
                    if self.busy && self.progress.is_none() {
                        ui.spinner();
                    }
                    ui.monospace(
                        egui::RichText::new(&self.status)
                            .size(12.0)
                            .color(theme::TEXT_2),
                    );

                    if let Some((current, total)) = self.progress {
                        ui.add_space(10.0);
                        let fraction = if total == 0 {
                            0.0
                        } else {
                            current as f32 / total as f32
                        };
                        ui.add(
                            egui::ProgressBar::new(fraction)
                                .desired_width(160.0)
                                .text(format!("{current}/{total}")),
                        );
                    }
                });
            });
    }

    fn ui_automatic(&mut self, ui: &mut egui::Ui) {
        ui.add_space(4.0);
        ui.label(
            egui::RichText::new(self.t("actions").to_uppercase())
                .size(11.0)
                .strong()
                .color(theme::TEXT_3),
        );
        ui.add_space(8.0);

        // Every row's title/description is resolved to an owned String up
        // front: the `with_layout` closures below need `&mut self.opt_*`
        // (a field borrow), so nothing inside them can also call
        // `self.t(...)` (a whole-`self` borrow) without conflicting.
        let remove_tools_title = self.t("delete-tools");
        let remove_tools_desc = self.t("action-remove-tools-desc");
        let backup_registry_title = self.t("save-registry");
        let backup_registry_desc = self.t("action-backup-registry-desc");
        let remove_restore_points_title = self.t("delete-system-restore-points");
        let remove_restore_points_desc = self.t("action-remove-restore-points-desc");
        let create_restore_point_title = self.t("create-restore-point");
        let create_restore_point_desc = self.t("action-create-restore-point-desc");
        let restore_uac_title = self.t("restore-uac");
        let restore_uac_desc = self.t("action-restore-uac-desc");
        let restore_settings_title = self.t("restore-settings");
        let restore_settings_desc = self.t("action-restore-settings-desc");

        // 2-column layout, `half` computed once here (the one place that
        // legitimately knows the real available width) and threaded
        // explicitly into every `action_row` call.
        // Use egui's real inter-item spacing (not a guessed constant) so the
        // two cards exactly fill the row with no left-over slack on the
        // right — a small contributor to the reported misalignment.
        let gap = ui.spacing().item_spacing.x;
        let half = (ui.available_width() - gap) / 2.0;

        // `with_layout(..., Align::Min)` instead of plain `ui.horizontal`
        // (which centers cross-axis by default): two `Frame`s of the same
        // reported height still ended up offset by a few pixels under
        // center alignment — forcing top alignment removes that ambiguity
        // entirely instead of chasing egui's exact centering computation.
        ui.with_layout(egui::Layout::left_to_right(egui::Align::Min), |ui| {
            action_row(
                ui,
                &mut self.opt_remove_tools,
                theme::BLUE_BG,
                theme::BLUE,
                "T",
                &remove_tools_title,
                &remove_tools_desc,
                half,
            );
            action_row(
                ui,
                &mut self.opt_backup_registry,
                theme::GREEN_BG,
                theme::GREEN,
                "R",
                &backup_registry_title,
                &backup_registry_desc,
                half,
            );
        });
        ui.add_space(8.0);
        ui.with_layout(egui::Layout::left_to_right(egui::Align::Min), |ui| {
            action_row(
                ui,
                &mut self.opt_remove_restore_points,
                theme::BLUE_BG,
                theme::BLUE,
                "P",
                &remove_restore_points_title,
                &remove_restore_points_desc,
                half,
            );
            action_row(
                ui,
                &mut self.opt_create_restore_point,
                theme::GREEN_BG,
                theme::GREEN,
                "+",
                &create_restore_point_title,
                &create_restore_point_desc,
                half,
            );
        });
        ui.add_space(8.0);
        ui.with_layout(egui::Layout::left_to_right(egui::Align::Min), |ui| {
            action_row(
                ui,
                &mut self.opt_restore_uac,
                theme::BLUE_BG,
                theme::BLUE,
                "U",
                &restore_uac_title,
                &restore_uac_desc,
                half,
            );
            action_row(
                ui,
                &mut self.opt_restore_settings,
                theme::BLUE_BG,
                theme::BLUE,
                "S",
                &restore_settings_title,
                &restore_settings_desc,
                half,
            );
        });

        ui.add_space(14.0);
        ui.label(
            egui::RichText::new(self.t("quarantine-section-title"))
                .size(11.0)
                .strong()
                .color(theme::TEXT_3),
        );
        ui.add_space(8.0);
        let keep_title = self.t("quarantine-keep");
        let keep_desc = self.t("quarantine-keep-desc");
        let now_title = self.t("remove-now");
        let now_desc = self.t("quarantine-now-desc");
        let seven_days_title = self.t("quarantine-7-days");
        let seven_days_desc = self.t("quarantine-7-days-desc");
        let seg_gap = ui.spacing().item_spacing.x;
        let seg_width = (ui.available_width() - seg_gap * 2.0) / 3.0;
        ui.horizontal(|ui| {
            quarantine_segment(
                ui,
                &mut self.quarantine_choice,
                QuarantineChoice::Keep,
                &keep_title,
                &keep_desc,
                seg_width,
            );
            if quarantine_segment(
                ui,
                &mut self.quarantine_choice,
                QuarantineChoice::Now,
                &now_title,
                &now_desc,
                seg_width,
            ) {
                self.opt_remove_tools = true;
            }
            if quarantine_segment(
                ui,
                &mut self.quarantine_choice,
                QuarantineChoice::In7Days,
                &seven_days_title,
                &seven_days_desc,
                seg_width,
            ) {
                self.opt_remove_tools = true;
            }
        });

        ui.add_space(16.0);
        let can_run = !self.busy
            && (self.opt_remove_tools
                || self.opt_restore_uac
                || self.opt_restore_settings
                || self.opt_remove_restore_points
                || self.opt_create_restore_point
                || self.opt_backup_registry);
        let run_button = egui::Button::new(
            egui::RichText::new(self.t("run"))
                .strong()
                .color(Color32::from_rgb(0x10, 0x2a, 0x1c)),
        )
        .fill(theme::GREEN)
        .min_size(Vec2::new(120.0, 34.0));
        if ui.add_enabled(can_run, run_button).clicked() {
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
        if !can_run {
            ui.add_space(4.0);
            ui.label(
                egui::RichText::new(self.t("no-option-selected"))
                    .size(10.5)
                    .color(theme::TEXT_3),
            );
        }
    }

    fn ui_custom(&mut self, ui: &mut egui::Ui) {
        ui.add_space(4.0);
        let found = self.scan_results.len();
        let selected_count = self
            .scan_results
            .iter()
            .filter(|(_, checked)| *checked)
            .count();
        let counts_label = self.tf(
            "custom-counts",
            &[
                ("found", &found.to_string()),
                ("selected", &selected_count.to_string()),
            ],
        );
        let select_all_label = self.t("all");
        let select_none_label = self.t("no-element");
        let clear_label = self.t("empty");
        ui.horizontal(|ui| {
            ui.label(
                egui::RichText::new(counts_label)
                    .size(13.0)
                    .color(theme::TEXT_1),
            );
            ui.add_space(8.0);
            if ui.button(select_all_label).clicked() {
                for (_, checked) in &mut self.scan_results {
                    *checked = true;
                }
            }
            if ui.button(select_none_label).clicked() {
                for (_, checked) in &mut self.scan_results {
                    *checked = false;
                }
            }
            if ui.button(clear_label).clicked() {
                self.scan_results.clear();
            }
        });

        ui.add_space(8.0);
        let empty_hint = self.t("custom-empty-hint");
        Frame::none()
            .fill(theme::BG_PANEL)
            .stroke(Stroke::new(1.0_f32, theme::BORDER_SOFT))
            .rounding(theme::RADIUS)
            .inner_margin(Margin::same(6.0))
            .show(ui, |ui| {
                let w = ui.available_width();
                ui.set_min_width(w);
                ui.set_max_width(w);
                egui::ScrollArea::vertical()
                    .max_height(280.0)
                    .show(ui, |ui| {
                        if self.scan_results.is_empty() {
                            ui.add_space(20.0);
                            ui.vertical_centered(|ui| {
                                ui.label(egui::RichText::new(empty_hint).color(theme::TEXT_3));
                            });
                            ui.add_space(20.0);
                        }
                        for (event, checked) in &mut self.scan_results {
                            ui.horizontal(|ui| {
                                ui.checkbox(checked, "");
                                ui.label(
                                    egui::RichText::new(&event.target)
                                        .monospace()
                                        .size(12.0)
                                        .color(theme::TEXT_1),
                                );
                                ui.with_layout(
                                    egui::Layout::right_to_left(egui::Align::Center),
                                    |ui| {
                                        ui.label(
                                            egui::RichText::new(format!(
                                                "{} · {}",
                                                event.tool, event.action_type
                                            ))
                                            .size(10.0)
                                            .color(theme::TEXT_3),
                                        );
                                    },
                                );
                            });
                        }
                    });
            });

        ui.add_space(10.0);
        let search_label = self.t("search");
        let selected: Vec<(String, String)> = self
            .scan_results
            .iter()
            .filter(|(_, checked)| *checked)
            .map(|(e, _)| (e.tool.clone(), e.target.clone()))
            .collect();
        let remove_selection_label = self.tf(
            "remove-selection-button",
            &[("count", &selected.len().to_string())],
        );
        let scanning_status = self.t("status-scanning");
        let removing_status = self.t("status-removing");
        ui.horizontal(|ui| {
            if ui
                .add_enabled(
                    !self.busy,
                    egui::Button::new(search_label).min_size(Vec2::new(0.0, 32.0)),
                )
                .clicked()
            {
                self.busy = true;
                self.status = scanning_status;
                let _ = self.request_tx.send(WorkerRequest::Scan);
            }

            let can_remove = !self.busy && !selected.is_empty();
            let remove_button = egui::Button::new(
                egui::RichText::new(remove_selection_label).color(Color32::WHITE),
            )
            .fill(theme::RED)
            .min_size(Vec2::new(0.0, 32.0));
            if ui.add_enabled(can_remove, remove_button).clicked() {
                self.busy = true;
                self.status = removing_status;
                let _ = self
                    .request_tx
                    .send(WorkerRequest::RemoveSelected(selected));
            }
        });
    }

    fn ui_extra_tools(&mut self, ui: &mut egui::Ui) {
        ui.add_space(4.0);
        ui.label(
            egui::RichText::new(self.t("tab-extra-tools").to_uppercase())
                .size(11.0)
                .strong()
                .color(theme::TEXT_3),
        );
        ui.add_space(10.0);
        ui.label(
            egui::RichText::new(self.t("extra-tools-empty"))
                .size(12.0)
                .color(theme::TEXT_2),
        );
    }

    fn ui_donate(&mut self, ui: &mut egui::Ui) {
        ui.add_space(4.0);
        ui.label(
            egui::RichText::new(self.t("tab-donate").to_uppercase())
                .size(11.0)
                .strong()
                .color(theme::TEXT_3),
        );
        ui.add_space(10.0);
        ui.label(
            egui::RichText::new(self.t("donate-body"))
                .size(12.0)
                .color(theme::TEXT_2),
        );
        ui.add_space(8.0);
        let copy_label = self.t("copy-button");
        donation_address_row(ui, "Bitcoin (BTC)", BTC_ADDRESS, &copy_label);
        ui.add_space(10.0);
        donation_address_row(ui, "Ethereum (ETH)", ETH_ADDRESS, &copy_label);
    }
}

/// One "label + monospace address + copy button" row in the Donate tab.
fn donation_address_row(ui: &mut egui::Ui, label: &str, address: &'static str, copy_label: &str) {
    ui.label(
        egui::RichText::new(label)
            .size(11.0)
            .strong()
            .color(theme::TEXT_3),
    );
    ui.add_space(4.0);
    ui.horizontal(|ui| {
        ui.monospace(egui::RichText::new(address).color(theme::TEXT_1));
        if ui.small_button(copy_label).clicked() {
            if let Ok(mut clipboard) = arboard::Clipboard::new() {
                let _ = clipboard.set_text(address);
            }
        }
    });
}

const BTC_ADDRESS: &str = "bc1qeuy23256g05v80ggcy6ezwrlhxttrhm827hf2u";
const ETH_ADDRESS: &str = "0x02AF1772AADaE8abf1d522aF5E87115E1Ed0dea5";

impl eframe::App for KprmApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        self.poll_worker();
        if self.busy {
            ctx.request_repaint();
        }

        self.title_bar(ctx);

        // Gates everything else — the original shows this "AS IS, no
        // commercial use" disclaimer before any UI, exiting immediately on
        // "No" (spec §2.1.5); this is the one screen it never localized
        // even in the original (English-only regardless of @OSLang), so
        // it's translated properly here instead.
        if !self.disclaimer_accepted {
            egui::CentralPanel::default()
                .frame(
                    Frame::none()
                        .fill(theme::BG)
                        .inner_margin(Margin::symmetric(30.0, 24.0)),
                )
                .show(ctx, |ui| self.ui_disclaimer(ui, ctx));
            return;
        }

        self.tab_bar(ctx);
        self.footer(ctx);

        egui::CentralPanel::default()
            .frame(
                Frame::none()
                    .fill(theme::BG)
                    .inner_margin(Margin::symmetric(20.0, 4.0)),
            )
            .show(ctx, |ui| match self.tab {
                Tab::Automatic => self.ui_automatic(ui),
                Tab::Custom => self.ui_custom(ui),
                Tab::ExtraTools => self.ui_extra_tools(ui),
                Tab::Donate => self.ui_donate(ui),
            });

        self.restart_dialog(ctx);
    }
}
