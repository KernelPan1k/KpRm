//! The specific Lucide-style icons `kprm`'s screens use, as
//! [`kprm_win32gui::icons::Icon`] definitions transcribed from
//! `docs/design/*.dc.html`'s inline SVGs — see that crate's `icons.rs` for
//! how a `d`/`points`/`cx,cy,r` element gets drawn.

use kprm_win32gui::icons::{Element, Icon};

/// The checkbox check glyph (every `kp-option`'s checked state).
pub const CHECK: Icon = Icon(&[Element::Polyline(&[(5.0, 12.0), (10.0, 17.0), (19.0, 6.0)])]);

/// "Supprimer les outils".
pub const TRASH: Icon = Icon(&[
    Element::Path("M6 7h12"),
    Element::Path("M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"),
    Element::Path("M7 7l1 12a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2l1-12"),
]);

/// "Sauvegarder le registre".
pub const SAVE: Icon = Icon(&[
    Element::Path("M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"),
    Element::Polyline(&[(17.0, 21.0), (17.0, 13.0), (7.0, 13.0), (7.0, 21.0)]),
    Element::Polyline(&[(7.0, 3.0), (7.0, 8.0), (15.0, 8.0)]),
]);

/// "Supprimer les points de restauration".
pub const UNDO: Icon = Icon(&[
    Element::Path("M3 12a9 9 0 1 0 3-6.7L3 8"),
    Element::Polyline(&[(3.0, 3.0), (3.0, 8.0), (8.0, 8.0)]),
]);

/// "Créer un point de restauration".
pub const CIRCLE_PLUS: Icon = Icon(&[
    Element::Circle { cx: 12.0, cy: 12.0, r: 9.0 },
    Element::Line(12.0, 8.0, 12.0, 16.0),
    Element::Line(8.0, 12.0, 16.0, 12.0),
]);

/// "Restaurer UAC".
pub const LOCK: Icon = Icon(&[
    Element::Rect { x: 4.0, y: 11.0, w: 16.0, h: 10.0, rx: 2.0 },
    Element::Path("M7.5 11V7.5a4.5 4.5 0 0 1 9 0V11"),
]);

/// "Restaurer les paramètres système".
pub const SLIDERS: Icon = Icon(&[
    Element::Line(5.0, 21.0, 5.0, 14.0),
    Element::Line(5.0, 10.0, 5.0, 3.0),
    Element::Circle { cx: 5.0, cy: 12.0, r: 2.0 },
    Element::Line(12.0, 21.0, 12.0, 12.0),
    Element::Line(12.0, 8.0, 12.0, 3.0),
    Element::Circle { cx: 12.0, cy: 10.0, r: 2.0 },
    Element::Line(19.0, 21.0, 19.0, 16.0),
    Element::Line(19.0, 12.0, 19.0, 3.0),
    Element::Circle { cx: 19.0, cy: 14.0, r: 2.0 },
]);

/// Quarantine segment icons.
pub const BOX: Icon = Icon(&[Element::Path("M3 6a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6z")]);
pub const CLOCK: Icon = Icon(&[Element::Circle { cx: 12.0, cy: 12.0, r: 9.0 }, Element::Polyline(&[(12.0, 7.0), (12.0, 12.0), (16.0, 14.0)])]);

/// The shield/logo glyph (title bar + sidebar brand card + tab icon).
pub const SHIELD: Icon = Icon(&[
    Element::Path("M12 2 4 5v6c0 5 3.5 9 8 11 4.5-2 8-6 8-11V5l-8-3z"),
    Element::Polyline(&[(8.5, 12.0), (11.0, 14.5), (15.5, 9.5)]),
]);
