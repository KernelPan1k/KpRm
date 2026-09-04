//! The two functional tabs (Automatique / Analyse personnalisée) plus two
//! static placeholder tabs (Outils + / Dons), matching the design mockup
//! shared earlier in the project. Real actions run on a background thread
//! (see [`crate::worker`]) so the UI never freezes during a scan/removal.

use std::collections::HashSet;
use std::sync::mpsc::{Receiver, Sender};

use eframe::egui;
use kprm_engine::quarantine::QuarantineMode;
use kprm_engine::report::{Event, EventResult, Report};

use crate::worker::{self, WorkerRequest, WorkerResponse};

#[derive(PartialEq, Clone, Copy)]
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

    scan_results: Vec<(Event, bool)>,

    request_tx: Sender<WorkerRequest>,
    response_rx: Receiver<WorkerResponse>,
}

impl Default for KprmApp {
    fn default() -> Self {
        let (response_tx, response_rx) = std::sync::mpsc::channel();
        let request_tx = worker::spawn(response_tx);
        Self {
            tab: Tab::Automatic,
            opt_remove_tools: true,
            opt_backup_registry: false,
            opt_remove_restore_points: false,
            opt_create_restore_point: false,
            opt_restore_uac: false,
            opt_restore_settings: false,
            quarantine_choice: QuarantineChoice::Keep,
            status: "Prêt".to_string(),
            busy: false,
            scan_results: Vec::new(),
            request_tx,
            response_rx,
        }
    }
}

impl KprmApp {
    fn poll_worker(&mut self) {
        if let Ok(response) = self.response_rx.try_recv() {
            self.busy = false;
            match response {
                WorkerResponse::Done(report) => {
                    self.status = format!("Terminé — {} événement(s)", report.events.len());
                    self.handle_report(report);
                }
                WorkerResponse::Failed(message) => {
                    self.status = format!("Échec : {message}");
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

    fn ui_automatic(&mut self, ui: &mut egui::Ui) {
        ui.add_space(4.0);
        ui.heading("Actions");
        ui.checkbox(&mut self.opt_remove_tools, "Supprimer les outils");
        ui.checkbox(
            &mut self.opt_backup_registry,
            "Sauvegarder le registre (pas encore implémenté)",
        );
        ui.checkbox(
            &mut self.opt_remove_restore_points,
            "Supprimer les points de restauration (pas encore implémenté)",
        );
        ui.checkbox(
            &mut self.opt_create_restore_point,
            "Créer un point de restauration (pas encore implémenté)",
        );
        ui.checkbox(&mut self.opt_restore_uac, "Restaurer UAC");
        ui.checkbox(
            &mut self.opt_restore_settings,
            "Restaurer les paramètres système",
        );

        ui.add_space(8.0);
        ui.heading("Quarantaine");
        ui.horizontal(|ui| {
            ui.selectable_value(
                &mut self.quarantine_choice,
                QuarantineChoice::Keep,
                "Conserver",
            );
            ui.selectable_value(
                &mut self.quarantine_choice,
                QuarantineChoice::Now,
                "Maintenant",
            );
            ui.selectable_value(
                &mut self.quarantine_choice,
                QuarantineChoice::In7Days,
                "Dans 7 jours",
            );
        });

        ui.add_space(12.0);
        let can_run = !self.busy
            && (self.opt_remove_tools || self.opt_restore_uac || self.opt_restore_settings);
        let run_button = egui::Button::new(egui::RichText::new("Exécuter").strong())
            .fill(egui::Color32::from_rgb(0x5c, 0xc7, 0x6a));
        if ui.add_enabled(can_run, run_button).clicked() {
            self.busy = true;
            self.status = "Exécution en cours...".to_string();
            let _ = self.request_tx.send(WorkerRequest::RunAutomatic {
                remove_tools: self.opt_remove_tools,
                restore_uac: self.opt_restore_uac,
                restore_settings: self.opt_restore_settings,
                quarantine_mode: self.quarantine_choice.into(),
            });
        }
        if !can_run {
            ui.weak("Cochez au moins une action implémentée pour activer ce bouton.");
        }
    }

    fn ui_custom(&mut self, ui: &mut egui::Ui) {
        ui.add_space(4.0);
        ui.horizontal(|ui| {
            let found = self.scan_results.len();
            let selected = self
                .scan_results
                .iter()
                .filter(|(_, checked)| *checked)
                .count();
            ui.label(format!("{found} détecté(s) · {selected} sélectionné(s)"));
            ui.separator();
            if ui.button("Tout").clicked() {
                for (_, checked) in &mut self.scan_results {
                    *checked = true;
                }
            }
            if ui.button("Aucun").clicked() {
                for (_, checked) in &mut self.scan_results {
                    *checked = false;
                }
            }
            if ui.button("Vider").clicked() {
                self.scan_results.clear();
            }
        });

        ui.add_space(6.0);
        egui::ScrollArea::vertical().show(ui, |ui| {
            for (event, checked) in &mut self.scan_results {
                ui.horizontal(|ui| {
                    ui.checkbox(checked, "");
                    ui.monospace(&event.target);
                    ui.weak(format!("[{}] {}", event.tool, event.action_type));
                });
            }
        });

        ui.add_space(8.0);
        ui.horizontal(|ui| {
            if ui
                .add_enabled(!self.busy, egui::Button::new("Analyser"))
                .clicked()
            {
                self.busy = true;
                self.status = "Analyse en cours...".to_string();
                let _ = self.request_tx.send(WorkerRequest::Scan);
            }

            let selected: Vec<(String, String)> = self
                .scan_results
                .iter()
                .filter(|(_, checked)| *checked)
                .map(|(e, _)| (e.tool.clone(), e.target.clone()))
                .collect();
            let can_remove = !self.busy && !selected.is_empty();
            let remove_button =
                egui::Button::new(format!("Supprimer la sélection ({})", selected.len()))
                    .fill(egui::Color32::from_rgb(0xd9, 0x4f, 0x4f));
            if ui.add_enabled(can_remove, remove_button).clicked() {
                self.busy = true;
                self.status = "Suppression en cours...".to_string();
                let _ = self
                    .request_tx
                    .send(WorkerRequest::RemoveSelected(selected));
            }
        });
    }

    fn ui_extra_tools(&mut self, ui: &mut egui::Ui) {
        ui.add_space(4.0);
        ui.heading("Outils supplémentaires");
        ui.label("Aucun outil configuré pour le moment — liste à définir.");
    }

    fn ui_donate(&mut self, ui: &mut egui::Ui) {
        ui.add_space(4.0);
        ui.heading("Soutenir le projet");
        ui.label("KpRm est gratuit, open-source, et le restera.");
        ui.add_space(6.0);
        ui.monospace("Bitcoin (BTC) : [ adresse à renseigner ]");
    }
}

impl eframe::App for KprmApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        self.poll_worker();
        if self.busy {
            ctx.request_repaint();
        }

        egui::TopBottomPanel::top("tabs").show(ctx, |ui| {
            ui.add_space(4.0);
            ui.horizontal(|ui| {
                ui.selectable_value(&mut self.tab, Tab::Automatic, "Automatique");
                ui.selectable_value(&mut self.tab, Tab::Custom, "Analyse personnalisée");
                ui.selectable_value(&mut self.tab, Tab::ExtraTools, "Outils +");
                ui.selectable_value(&mut self.tab, Tab::Donate, "Dons");
            });
            ui.add_space(4.0);
        });

        egui::TopBottomPanel::bottom("status").show(ctx, |ui| {
            ui.horizontal(|ui| {
                if self.busy {
                    ui.spinner();
                }
                ui.label(&self.status);
            });
        });

        egui::CentralPanel::default().show(ctx, |ui| match self.tab {
            Tab::Automatic => self.ui_automatic(ui),
            Tab::Custom => self.ui_custom(ui),
            Tab::ExtraTools => self.ui_extra_tools(ui),
            Tab::Donate => self.ui_donate(ui),
        });
    }
}
