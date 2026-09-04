# KpRm — réécriture Rust

Implémentation en cours de la réécriture Rust de KpRm décrite dans
[`../docs/RUST-REWRITE-SPEC.md`](../docs/RUST-REWRITE-SPEC.md). Ce dossier est
un workspace Cargo autonome, indépendant du code AutoIt historique (`../src`).

## État d'avancement

Correspond aux phases 1 à 5 de la feuille de route (§11 de la spec) :

| Crate | Statut | Contenu |
|---|---|---|
| `kprm-catalog` | ✅ | Modèle de données + chargement/validation du catalogue (202 outils migrés depuis `tools.xml`, embarqués dans le binaire). 7 tests. |
| `kprm-engine` | ✅ (noyau + orchestrateur) | Liste blanche, macros de chemin, clés 32/64 bits, décision de quarantaine, moteur de correspondance, **orchestrateur des 20 types d'action** (`orchestrator::run_tool_actions`, le pendant de `RunRemoveTools`), restauration UAC et paramètres système — tout exprimé sur des traits (`ports`) et testé avec des fakes en mémoire (`fakes`), zéro dépendance Windows. 45 tests. |
| `kprm-i18n` | ✅ | 8 langues (FR/EN/DE/IT/PT/RU/ES/NL) portées en Fluent, avec test de parité des clés entre langues. 8 tests. |
| `kprm-windows` | ✅ | Implémentations réelles des `ports` de `kprm-engine` : fichiers/dossiers (attributs, `icacls`, suppression différée au redémarrage), registre (`winreg`, vue 32/64 bits), process (Toolhelp32 natif), commandes externes, dossiers connus (variables d'environnement), lecture du `CompanyName` d'un PE (`pelite`). 19 tests, **tous exécutés pour de vrai** (fichiers temporaires jetables, sous-arbre de registre `HKCU\Software\KpRmRustTests` dédié et auto-nettoyé, process que le test lance lui-même — jamais le vrai Bureau/Program Files/HKLM de la machine). |
| `kprm-cli` | ✅ | Binaire headless : `catalog stats/list/validate`, `translate`, `locales`, **`scan`** (lecture seule, réellement exécuté sur cette machine : ~13s, 202 outils, rien trouvé — poste de dev propre) et **`remove --confirm`** (suppression réelle, jamais lancé sur cette machine de dev pour ne rien casser). |
| `kprm-gui` | ✅ | Interface egui/eframe : onglets Automatique / Analyse personnalisée / Outils + / Dons, actions lancées sur un thread de fond pour ne jamais geler l'UI. Barre de titre custom dessinée à la main (icône, pastille de version, glisser-déplacer, réduire/fermer), polices réelles embarquées (Space Grotesk + IBM Plex Mono), palette sombre reprenant les tokens de la maquette, cartes d'actions à 2 colonnes avec badge coloré, quarantaine en 3 boutons. Disposition **vérifiée par instrumentation des coordonnées réelles** plutôt que par capture d'écran (voir plus bas — la capture d'écran s'est révélée peu fiable dans cet environnement). Le rapport texte est écrit dans `%HOMEDRIVE%\KPRM` + le Bureau et ouvert dans le Bloc-notes après "Exécuter"/"Supprimer la sélection" (jamais après un simple scan). Aucun bouton destructif n'a été cliqué pendant le développement. |

**80 tests unitaires, tous verts** (`cargo test --workspace`), dont 20 qui
touchent réellement le système (fichiers, registre, processus) mais toujours
dans un bac à sable jetable — jamais contre les vraies données de
l'utilisateur. `kprm-cli scan` a été exécuté pour de vrai sur cette machine
(lecture seule) ; `kprm-cli remove` et le bouton "Exécuter"/"Supprimer la
sélection" de la GUI n'ont volontairement pas été déclenchés, pour ne
provoquer aucune suppression réelle pendant le développement.

### ⚠️ `PrintWindow` n'est pas fiable dans cet environnement

Une capture d'écran classique (`CopyFromScreen`) ne montre pas la fenêtre
dans cette session (pas de bureau interactif composé normalement affiché).
`PrintWindow(hwnd, hdc, PW_RENDERFULLCONTENT)` + un `MoveWindow` forcé juste
avant (pour déclencher un vrai repaint) semblait fonctionner et a été utilisé
pour "vérifier" plusieurs correctifs visuels de suite — **à tort** : après
un mauvais diagnostic de mise en page (voir point 2 ci-dessous), le code a
été instrumenté pour imprimer les rectangles réellement calculés par egui
(coordonnées exactes de chaque carte), et ces coordonnées se sont révélées
parfaitement correctes alors que la capture `PrintWindow` continuait
d'afficher une disposition visiblement fausse — même après un rebuild propre
et plusieurs cycles de redimensionnement. Conclusion : `PrintWindow` renvoie
ici un contenu qui ne correspond pas au rendu réel de la fenêtre, pour une
raison non identifiée (probablement liée à l'absence de compositeur DWM actif
dans cette session). **Ne pas se fier aux captures d'écran prises depuis
cette session pour juger du rendu de `kprm-gui`** — seule une vérification
sur une vraie session Windows interactive, ou une instrumentation directe
des coordonnées (`ui.cursor()`/`response.rect` imprimés via `eprintln!`,
comme ça a été fait ici) sont fiables.

### Corrections apportées suite à des retours utilisateur

1. **« Le rapport ne s'ouvre pas à la fin »** — vrai manque : rien n'écrivait
   ni n'ouvrait de rapport après "Exécuter". Corrigé : `kprm-windows::
   write_and_open_report` (nouveau, partagé par `kprm-cli` et `kprm-gui`)
   écrit le texte du rapport (`Report::to_text`, nouveau dans `kprm-engine`)
   dans `%HOMEDRIVE%\KPRM\kprm-<horodatage>.txt` + une copie sur le Bureau,
   puis lance `notepad.exe` dessus — après "Exécuter" et "Supprimer la
   sélection" uniquement, jamais après un simple scan (comme l'original).
2. **« Il ne ressemble pas à la maquette »** — refonte visuelle : polices
   Space Grotesk/IBM Plex Mono embarquées (`assets/fonts/`), palette sombre
   reprenant les couleurs de la maquette, fenêtre sans bordure avec barre de
   titre custom (icône, pastille de version, glisser-déplacer, boutons
   réduire/fermer), soulignement d'onglet, cartes d'action à 2 colonnes avec
   badge coloré. La disposition en 2 colonnes a d'abord semblé ne pas
   fonctionner (`egui::Grid`, `ui.columns`, `ui.scope`+`set_width` ont tous
   été essayés, chacun donnant — à l'écran — une première carte débordant
   sur toute la largeur), au point de passer temporairement en liste à une
   seule colonne. En creusant via une largeur explicite passée en paramètre
   plutôt que déduite de `ui.available_width()` imbriqué, puis en imprimant
   les coordonnées réelles calculées par egui, il s'est avéré que **la mise
   en page était correcte depuis le début** (deux rectangles de 385px
   parfaitement côte à côte, sans chevauchement) — c'est `PrintWindow` qui
   mentait (voir l'avertissement ci-dessus). La disposition à 2 colonnes a
   donc été restaurée.
3. **« Léger décalage entre les boutons/colonnes »** — vérifié par la même
   technique d'instrumentation (impression des `Response.rect` réels plutôt
   que capture d'écran) : deux causes trouvées. D'abord, une description
   trop longue sur une carte forçait un retour à la ligne, rendant cette
   carte plus haute que sa voisine — raccourcie. Ensuite, `ui.horizontal`
   aligne ses enfants avec `Align::Center` par défaut, ce qui produisait un
   décalage vertical de quelques pixels entre deux cartes pourtant de même
   hauteur. Corrigé par : hauteur minimale explicite (`ui.set_min_height`)
   dans `action_row` pour une hauteur de carte uniforme, calcul des largeurs
   à partir de l'espacement réel (`ui.spacing().item_spacing.x`) plutôt que
   de constantes devinées, et remplacement des trois `ui.horizontal` de
   paires de cartes par `ui.with_layout(egui::Layout::left_to_right(egui::
   Align::Min), ...)` pour forcer un alignement en haut. Revérifié : les
   trois rangées affichent désormais des coordonnées identiques (même y,
   même hauteur) pour les deux cartes de chaque paire.

## Migration du catalogue

`tools.d/*.toml` (202 fichiers, un par outil) a été généré une fois depuis
`../src/config/tools.xml` par `scripts/migrate_tools_xml.mjs` (Node.js, aucune
dépendance). Ce script est jetable — `tools.xml` reste la source historique,
mais n'est plus lu par le code Rust après cette migration. Pour le
ré-exécuter (ex. après une correction sur `tools.xml`) :

```bash
node scripts/migrate_tools_xml.mjs ../src/config/tools.xml tools.d
```

## Construire

Toolchain : Rust stable, cible `x86_64-pc-windows-gnu`, **plus une vraie
distribution MinGW-w64 complète** (voir ci-dessous — indispensable dès que
`kprm-gui` entre en jeu).

> **Note d'environnement n°1 — chemins accentués.** Si le compte Windows a un
> nom d'utilisateur contenant un caractère accentué (`C:\Users\Prénom...`),
> installez la toolchain Rust (`RUSTUP_HOME`/`CARGO_HOME`) **et** `%TEMP%`/
> `%TMP%` sur un chemin sans accent — le linker GNU (et `cargo install`, qui
> construit dans `%TEMP%`) échoue silencieusement à résoudre les chemins
> accentués (`ld: cannot find ...: No such file or directory` /
> `cannot find ...rlib` sur des fichiers qui existent pourtant). Rencontré et
> contourné pendant cette session en installant la toolchain sous
> `C:\rust-toolchain` et en forçant `TEMP=TMP=C:\rust-toolchain\tmp`.

> **Note d'environnement n°2 — `dlltool`/MinGW complet requis pour
> `kprm-gui`.** `kprm-catalog`/`kprm-engine`/`kprm-i18n`/`kprm-windows`/
> `kprm-cli` compilent avec la toolchain GNU minimale fournie par `rustup`
> seule. Dès que `winit`/`egui-winit` (donc `kprm-gui`) entrent en jeu,
> plusieurs dépendances (`parking_lot_core`, `libloading`, `arboard`/
> `clipboard-win` récent...) utilisent le mécanisme `raw-dylib` de Rust, qui
> réclame un vrai `dlltool.exe` + `as.exe` — absents de la toolchain minimale
> de `rustup` (qui ne fournit qu'un `dlltool.exe`/`gcc.exe` "self-contained"
> incomplets, sans assembleur). Pire : même avec un `dlltool`/`as`
> fonctionnels, le linker `ld.exe` fourni par `rustup` génère une erreur de
> lien propre à `raw-dylib` sur la cible GNU
> (`undefined reference to _head_..._kernel32_dll_imports_lib`) — un bug
> connu du support `raw-dylib`/GNU de rustc, indépendant de `dlltool`.
> La solution qui a fonctionné : installer une **distribution MinGW-w64
> complète** (ex. [WinLibs](https://winlibs.com/), UCRT, ~270 Mo) sous
> `C:\mingw64`, l'ajouter au `PATH`, **et** forcer rustc à utiliser son
> `gcc.exe` comme linker (au lieu du sien) via `.cargo/config.toml` :
> ```toml
> [target.x86_64-pc-windows-gnu]
> linker = "C:/mingw64/bin/gcc.exe"
> ar = "C:/mingw64/bin/ar.exe"
> ```
> (déjà présent dans `rust/.cargo/config.toml`). C'est ce changement de
> linker — pas seulement la présence de `dlltool` — qui a résolu l'erreur
> `raw-dylib`. `cargo-xwin`/la cible MSVC (alternative documentée en spec
> §5.3) a aussi été tentée mais nécessite en plus `clang-cl`, absent lui
> aussi de cet environnement — non poursuivie une fois la piste GNU+MinGW
> complet validée.
>
> **Compromis accepté** : la distribution WinLibs utilisée est basée sur
> l'UCRT (`api-ms-win-crt-*.dll`), disponible nativement à partir de
> Windows 10 (1607+) — contrairement au `msvcrt.dll` historique (présent
> depuis Windows XP) que ciblait la toolchain GNU minimale d'origine. Les
> exécutables produits (`kprm-cli.exe`, `kprm-gui.exe`) restent 100%
> autonomes (vérifié via `objdump -p` : uniquement des DLL système), mais
> supposent désormais Windows 10+ — cohérent avec le public visé par une
> réécriture en 2026, mais à noter si un support Windows 7/8.1 était
> requis (auquel cas viser une distribution MinGW basée sur `msvcrt`
> plutôt qu'UCRT).

```bash
cargo build --workspace
cargo test --workspace
cargo build --release -p kprm-cli
cargo build --release -p kprm-gui
```

Les binaires `target/release/kprm-cli.exe` (~1.7 Mo) et `kprm-gui.exe`
(~4.4 Mo) sont des exécutables autonomes : `kprm-cli.exe` a été testé avec un
`PATH` réduit à `C:\Windows\System32` seul, et `objdump -p` confirme que les
deux ne dépendent que de DLL système (`kernel32`, `user32`, `gdi32`,
`opengl32`, les forwarders `api-ms-win-crt-*`, ...) — aucune DLL tierce à
installer, conforme à l'exigence « fonctionne sans installation ».

## Pourquoi pas `dlltool`/MinGW complet dès le départ

Pour les crates sans GUI, `clap` (avec ses fonctionnalités de couleur
terminal par défaut) déclenchait déjà un besoin de `dlltool.exe` ; comme la
toolchain minimale de `rustup` suffisait sinon, `clap` a d'abord été utilisé
avec `default-features = false` pour l'éviter, retardant l'installation
d'un MinGW complet jusqu'à ce que `kprm-gui` la rende inévitable (voir
ci-dessus).
