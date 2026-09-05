# KpRm — réécriture Rust

Implémentation en cours de la réécriture Rust de KpRm décrite dans
[`../docs/RUST-REWRITE-SPEC.md`](../docs/RUST-REWRITE-SPEC.md). Ce dossier est
un workspace Cargo autonome, indépendant du code AutoIt historique (`../src`).

## État d'avancement

Correspond aux phases 1 à 5 de la feuille de route (§11 de la spec) :

| Crate | Statut | Contenu |
|---|---|---|
| `kprm-catalog` | ✅ | Modèle de données + chargement/validation du catalogue (202 outils migrés depuis `tools.xml`, embarqués dans le binaire). 7 tests. |
| `kprm-engine` | ✅ (noyau + orchestrateur) | Liste blanche, macros de chemin, clés 32/64 bits, décision de quarantaine, moteur de correspondance, **orchestrateur des 20 types d'action** (`orchestrator::run_tool_actions`, le pendant de `RunRemoveTools`), restauration UAC et paramètres système, infos système pour l'en-tête du rapport (`system_info::SystemInfo`, formatage pur), détection du besoin de redémarrage (`Report::needs_restart`), création/suppression/liste des points de restauration système (`restore_point`, via `CommandRunner`), sauvegarde du registre (`backup`, via la nouvelle méthode `Registry::save_key_to_file`) — tout exprimé sur des traits (`ports`) et testé avec des fakes en mémoire (`fakes`), zéro dépendance Windows. 58 tests. |
| `kprm-i18n` | ✅ | 8 langues (FR/EN/DE/IT/PT/RU/ES/NL) portées en Fluent, avec test de parité des clés entre langues. 8 tests. |
| `kprm-windows` | ✅ | Implémentations réelles des `ports` de `kprm-engine` : fichiers/dossiers (attributs, `icacls`, suppression différée au redémarrage), registre (`winreg`, vue 32/64 bits), process (Toolhelp32 natif), commandes externes, dossiers connus (variables d'environnement), lecture du `CompanyName` d'un PE (`pelite`), infos système réelles pour le rapport (utilisateur/machine/OS via variables d'environnement + registre, nombre de passages via `%HOMEDRIVE%\KPRM`), redémarrage réel de la machine (`reboot::reboot_machine`, `SeShutdownPrivilege` + `ExitWindowsEx` — non testé unitairement pour une raison évidente : l'appeler redémarre la machine), détection d'élévation (`elevation::is_elevated`, `GetTokenInformation(TokenElevation)`, utilisé par `kprm-cli`), `run_capture` sur `RealCommandRunner` (capture réelle de stdout), export d'une ruche vers un fichier (`registry::WinRegistry::save_key_to_file`, `RegSaveKeyExW`), activation de privilège factorisée (`privilege::enable_privilege`, partagée par `reboot` et `registry`). 26 tests, **tous exécutés pour de vrai** (fichiers temporaires jetables, sous-arbre de registre `HKCU\Software\KpRmRustTests` dédié et auto-nettoyé, process que le test lance lui-même — jamais le vrai Bureau/Program Files/HKLM de la machine). |
| `kprm-cli` | ✅ | Binaire headless : `catalog stats/list/validate`, `translate`, `locales`, **`scan`** (lecture seule, réellement exécuté sur cette machine : ~13s, 202 outils, rien trouvé — poste de dev propre) et **`remove --confirm`** (suppression réelle, jamais lancé sur cette machine de dev pour ne rien casser). |
| `kprm-gui` | ✅ | Interface egui/eframe : onglets Automatique / Analyse personnalisée / Outils + / Dons, actions lancées sur un thread de fond pour ne jamais geler l'UI. Barre de titre custom dessinée à la main (icône, pastille de version, glisser-déplacer, réduire/fermer), polices réelles embarquées (Space Grotesk + IBM Plex Mono), palette sombre reprenant les tokens de la maquette, cartes d'actions à 2 colonnes avec badge coloré, quarantaine en 3 boutons. Disposition **vérifiée par instrumentation des coordonnées réelles** plutôt que par capture d'écran (voir plus bas — la capture d'écran s'est révélée peu fiable dans cet environnement). Le rapport texte est écrit dans `%HOMEDRIVE%\KPRM` + le Bureau et ouvert dans le Bloc-notes après "Exécuter"/"Supprimer la sélection" (jamais après un simple scan). Aucun bouton destructif n'a été cliqué pendant le développement. |

**99 tests unitaires, tous verts** (`cargo test --workspace`), dont 26 qui
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
3. **« Je veux des infos comme avant (nom utilisateur, machine, OS...) et le
   nombre de passages »** — le rapport en manquait, contrairement à
   l'original (`functions.au3` lignes 17-23 : `@UserName`, `@ComputerName`,
   `GetHumanVersion()`, `CountKpRmPass()`). Ajouté : `kprm_engine::
   system_info::SystemInfo` (données pures, formatées et testées sans
   Windows) rempli par `kprm_windows::system_info::collect` — nom
   d'utilisateur/ordinateur via les variables d'environnement `USERNAME`/
   `COMPUTERNAME`, nom et build de l'OS via le registre
   `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion` (avec correction du
   nom pour les machines Windows 11 dont `ProductName` dit encore
   « Windows 10 »), et le nombre de passages en comptant les
   `kprm-*.txt` déjà présents dans `%HOMEDRIVE%\KPRM`. Affiché dans le
   bandeau du rapport, sous les lignes de titre. La version de l'app
   (`v3.0.0`, `[workspace.package].version` dans `Cargo.toml`, lue via
   `env!("CARGO_PKG_VERSION")`) est maintenant elle aussi dans ce bandeau
   ET dans la pastille de la barre de titre — une seule source de vérité
   au lieu d'un `"v3.0.0"` codé en dur dans `app.rs`.
4. **« Léger décalage entre les boutons/colonnes »** — vérifié par la même
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

5. **« FRST supprimé au reboot mais pas de reboot »** — vrai manque, pas un
   bug d'affichage : contrairement à l'original (`RestartIfNeeded` dans
   `functions.au3`, qui force un `Shutdown(6)`/`Shutdown(2)` dès qu'un
   élément a été programmé via `MOVEFILE_DELAY_UNTIL_REBOOT`), la
   réécriture Rust ne faisait jamais rien de ce cas — le rapport disait
   « sera supprimé au redémarrage » et s'arrêtait là. Ajouté :
   `Report::needs_restart()` (vrai si au moins un événement est
   `ScheduledOnReboot`) et `kprm_windows::reboot_machine()` (active
   `SeShutdownPrivilege` sur le token du process puis appelle
   `ExitWindowsEx(EWX_REBOOT | EWX_FORCEIFHUNG, ...)` — un token de
   processus normal n'a pas ce privilège par défaut, même administrateur).
   Contrairement à l'original qui redémarre **sans poser de vraie
   question** (juste un message d'information), la GUI affiche maintenant
   une boîte de dialogue « Redémarrage nécessaire » (Redémarrer
   maintenant / Plus tard) et le CLI pose la question en ligne de
   commande (`[o/N]`) — un choix explicite plutôt qu'un redémarrage
   forcé. `reboot_machine()` n'a, pour des raisons évidentes, jamais été
   appelé pendant le développement/les tests sur cette machine.
6. **« Un 'e' comme logo dans la barre des tâches »** — le binaire n'avait
   jamais eu d'icône : ni ressource PE embarquée, ni icône de fenêtre
   fournie à `eframe`, donc Windows retombait sur une icône par défaut.
   Ajouté : `assets/icon.ico` (multi-résolutions 16 à 256px, généré à
   partir du même symbole que le badge de la barre de titre — coche
   blanche sur fond bleu arrondi) embarqué comme icône de l'exécutable via
   `build.rs` + `embed-resource` (qui invoque `windres` du toolchain
   MinGW), et `assets/icon.png` chargé au runtime via
   `eframe::icon_data::from_png_bytes` + `ViewportBuilder::with_icon` pour
   l'icône de fenêtre/barre des tâches/Alt+Tab pendant que l'appli tourne.
   Vérifié en extrayant l'icône réelle du `.exe` compilé
   (`System.Drawing.Icon::ExtractAssociatedIcon`) plutôt qu'en supposant
   que l'embarquement a marché.
7. **« Je ne vois pas le point de restauration, ni dans les points de
   restauration ni dans le rapport »** — comme les points 3/5, un vrai
   manque : les cases « Supprimer/Créer un point de restauration »
   existaient dans la GUI mais n'étaient jamais lues par le worker (case
   cochée = aucun effet, silencieusement). Ajouté
   `kprm_engine::restore_point` : `create_restore_point` (active la
   protection système puis `Checkpoint-Computer`) et
   `remove_all_restore_points` (`Disable-ComputerRestore` puis
   `Enable-ComputerRestore` sur le disque système — contrairement à
   l'original qui appelle `SRRemoveRestorePoint` de `SrClient.dll` en
   boucle sur chaque point énuméré via WMI, il n'existe pas de cmdlet
   PowerShell pour supprimer un point précis ; couper puis rallumer la
   protection système les efface tous d'un coup sans appel DLL). Les deux
   passent par le port `CommandRunner` (donc testables avec le fake, sans
   toucher Windows) et poussent chaque étape dans le rapport
   (`EventResult::Ran`/`Failed`) sous l'outil « Points de restauration »
   — visible dans le rapport même en cas d'échec, contrairement à avant
   où rien n'apparaissait dans un cas comme dans l'autre. Windows peut
   toujours refuser la création (limite d'un point automatique par 24h,
   protection système désactivée par stratégie de groupe) : dans ce cas
   le rapport affiche `[X]` au lieu de rester silencieux.
8. **Suite du point 7 : les trois actions échouaient systématiquement**
   (`[X] supprimer les points de restauration`, `[X] activer la
   protection du système`, `[X] créer le point de restauration`) — « ça
   marchait à tous les coups avec l'ancien outil ». Cause racine : l'exe
   Rust ne s'exécutait jamais élevé, contrairement à l'original qui a
   `#RequireAdmin` en toute première ligne de `kpRm.au3` (élévation UAC
   systématique au lancement) — sans droits admin, `Enable-
   ComputerRestore`/`Checkpoint-Computer`/`Disable-ComputerRestore`
   échouent tous, comme d'ailleurs la suppression de fichiers sous
   Program Files, l'écriture dans HKLM ou l'arrêt de processus d'autres
   utilisateurs. Corrigé en embarquant un vrai manifeste Win32
   (`assets/app.manifest`, `requestedExecutionLevel=
   "requireAdministrator"`) dans `kprm-gui.exe` via `build.rs` +
   `embed-resource` — Windows demande maintenant l'élévation UAC au
   lancement, comme l'original. Piège rencontré en cours de route : le
   spec `gcc` de MinGW lie *toujours* un `default-manifest.o`
   (`asInvoker`) à tout exécutable, ce qui entrait en conflit avec notre
   manifeste (`ld: .rsrc merge failure: multiple non-default manifests`)
   et le nôtre perdait silencieusement — vérifié en extrayant la
   vraie ressource `RT_MANIFEST` lue par Windows (`FindResource`/
   `LoadResource`), pas en supposant que l'avertissement du linker était
   sans conséquence. Contourné en pointant `-B` vers un
   `default-manifest.o` vide (`nodefaultmanifest/`, aucune section
   `.rsrc`) qui prend le pas sur celui de MinGW dans la recherche de
   `gcc`, laissant notre manifeste seul survivant — reconfirmé après
   coup sur le binaire debug et le binaire release. `kprm-cli` n'a
   volontairement pas ce manifeste (forcer l'UAC sur `catalog stats`
   serait pire que l'ancien comportement) ; à la place,
   `kprm_windows::is_elevated()` (jeton du process,
   `GetTokenInformation(TokenElevation)`) fait refuser `remove --confirm`
   avec un message clair si le terminal n'est pas déjà lancé en
   administrateur. Effet de bord découvert et corrigé au passage : le
   manifeste s'appliquant à tous les binaires du crate, le harnais de
   test généré par `cargo test` pour `kprm-gui` refusait lui aussi de
   démarrer (erreur Windows 740, élévation requise) — réglé en mettant
   `test = false` sur son `[[bin]]` (ce crate n'a de toute façon aucun
   `#[cfg(test)]`, toute la logique testée vit dans `kprm-engine`/
   `kprm-windows`).
9. **« Il faut que ça liste les points de restauration existants dans le
   rapport »** — équivalent de `ShowCurrentRestorePoint` dans l'original.
   Le port `CommandRunner` ne renvoyait qu'un booléen succès/échec, sans
   moyen de récupérer la sortie d'une commande ; ajouté `run_capture`
   (capture le stdout réel, `None` en cas d'échec) à côté de `run`,
   implémenté sur `RealCommandRunner` et `FakeCommandRunner`.
   `restore_point::list_restore_points` l'utilise pour appeler
   `Get-ComputerRestorePoint` (même cmdlet que la version PowerShell de
   secours de l'original) et parse chaque point (numéro de séquence,
   description, date) depuis une sortie `sequence|description|date`
   générée côté PowerShell. Chaque point trouvé est poussé dans le
   rapport (`EventResult::Found`, outil « Points de restauration ») après
   « Supprimer » et/ou « Créer », qu'il y en ait ou non (une ligne « Aucun
   point de restauration trouvé » sinon) — visible dans le rapport
   qu'importe si l'action a réussi ou échoué.
10. **« Il n'a pas créé un nouveau point de restauration lorsque je l'ai
    lancé »** — malgré l'élévation corrigée au point 8, `Checkpoint-
    Computer` ne fait *rien* silencieusement (ni erreur, ni nouveau point)
    s'il en existe déjà un créé il y a moins de ~24h (`SystemRestore
    PointCreationFrequency`, en minutes, sous `HKLM\SOFTWARE\Microsoft\
    Windows NT\CurrentVersion\SystemRestore`, 1440 par défaut) — que ce
    point vienne de Windows Update, d'un pilote, ou d'un essai précédent
    de l'outil. L'original contournait ça en supprimant les points du
    jour avant de réessayer (`ClearDailyRestorePoint`) ; plus simple ici :
    `create_restore_point` écrit `SystemRestorePointCreationFrequency = 0`
    (via le port `Registry`, déjà utilisé ailleurs) juste avant d'appeler
    `Checkpoint-Computer`, donc un point est créé à chaque exécution quel
    que soit l'historique du jour, sans jamais toucher (encore moins
    supprimer) les points déjà présents.
11. **« Sauvegarder le registre » implémenté** — comme les points de
    restauration, la case existait mais n'était branchée nulle part
    (« Pas encore implémenté »). L'original crée une copie shadow VSS du
    disque système, lui assigne une lettre de lecteur via un `dosdev.exe`
    embarqué en hexadécimal dans le script, copie les hives `SOFTWARE` et
    `NTUSER.dat` depuis cette copie, et retombe sur `HoboCopy.exe`
    (binaire tiers embarqué) si la copie VSS échoue — exactement le genre
    de hack que la spec de réécriture (`docs/RUST-REWRITE-SPEC.md`)
    proposait de remplacer. Remplacé par `RegSaveKeyExW`, l'API Win32
    native conçue précisément pour exporter une ruche vivante vers un
    fichier — aucune copie shadow, aucun binaire tiers. Ajouté au passage
    `Registry::save_key_to_file` (nouvelle méthode du port),
    `kprm_engine::backup` (calcule quoi sauvegarder et où : `HKLM\
    SOFTWARE` → `SOFTWARE`, `HKCU` → `NTUSER.DAT`, sous
    `%HOMEDRIVE%\KPRM\backup\<horodatage>`, mêmes noms de fichiers que
    l'original pour rester restaurable de la même façon) et
    `kprm-windows::privilege` (factorisé depuis `reboot.rs` : activer un
    privilège du token du process — ici `SeBackupPrivilege`, nécessaire
    pour lire `HKLM\SOFTWARE` en entier). Le test réel de
    `save_key_to_file` (vérifie l'en-tête magique `regf` d'un vrai
    fichier de ruche) se saute proprement au lieu d'échouer quand il
    tourne sans élévation : `RegSaveKeyExW` a besoin que
    `SeBackupPrivilege` soit réellement *présent* dans le token, pas
    seulement d'un compte administrateur — un token standard (non élevé)
    ne l'a pas du tout, donc `AdjustTokenPrivileges` réussit sans rien
    activer, découvert en instrumentant le code réel plutôt qu'en
    devinant la cause d'un premier échec silencieux.

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
