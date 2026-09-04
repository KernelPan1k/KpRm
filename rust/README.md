# KpRm — réécriture Rust

Implémentation en cours de la réécriture Rust de KpRm décrite dans
[`../docs/RUST-REWRITE-SPEC.md`](../docs/RUST-REWRITE-SPEC.md). Ce dossier est
un workspace Cargo autonome, indépendant du code AutoIt historique (`../src`).

## État d'avancement

Correspond aux phases 1 à 3 de la feuille de route (§11 de la spec), plus
une partie de la 4 :

| Crate | Statut | Contenu |
|---|---|---|
| `kprm-catalog` | ✅ | Modèle de données + chargement/validation du catalogue (202 outils migrés depuis `tools.xml`, embarqués dans le binaire). 7 tests. |
| `kprm-engine` | ✅ (noyau + orchestrateur) | Liste blanche, macros de chemin, clés 32/64 bits, décision de quarantaine, moteur de correspondance, **orchestrateur des 20 types d'action** (`orchestrator::run_tool_actions`, le pendant de `RunRemoveTools`), restauration UAC et paramètres système — tout exprimé sur des traits (`ports`) et testé avec des fakes en mémoire (`fakes`), zéro dépendance Windows. 41 tests. |
| `kprm-i18n` | ✅ | 8 langues (FR/EN/DE/IT/PT/RU/ES/NL) portées en Fluent, avec test de parité des clés entre langues. 8 tests. |
| `kprm-windows` | ✅ | Implémentations réelles des `ports` de `kprm-engine` : fichiers/dossiers (attributs, `icacls`, suppression différée au redémarrage), registre (`winreg`, vue 32/64 bits), process (Toolhelp32 natif), commandes externes, dossiers connus (variables d'environnement), lecture du `CompanyName` d'un PE (`pelite`). 19 tests, **tous exécutés pour de vrai** (fichiers temporaires jetables, sous-arbre de registre `HKCU\Software\KpRmRustTests` dédié et auto-nettoyé, process que le test lance lui-même — jamais le vrai Bureau/Program Files/HKLM de la machine). |
| `kprm-cli` | ✅ | Binaire headless : `catalog stats/list/validate`, `translate`, `locales`, **`scan`** (lecture seule, réellement exécuté sur cette machine : ~13s, 202 outils, rien trouvé — poste de dev propre) et **`remove --confirm`** (suppression réelle, jamais lancé sur cette machine de dev pour ne rien casser). |
| `kprm-gui` | ❌ à faire | Interface egui reprenant la maquette (voir le canvas de design partagé plus tôt dans la conversation). |

**75 tests unitaires, tous verts** (`cargo test --workspace`), dont 19 qui
touchent réellement le système (fichiers, registre, processus) mais toujours
dans un bac à sable jetable — jamais contre les vraies données de
l'utilisateur. `kprm-cli scan` a été exécuté pour de vrai sur cette machine
(lecture seule) ; `kprm-cli remove` ne l'a volontairement pas été, pour ne
provoquer aucune suppression réelle pendant le développement.

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

Toolchain : Rust stable, cible `x86_64-pc-windows-gnu` (ou `-msvc`).

> **Note d'environnement** : si le compte Windows a un nom d'utilisateur
> contenant un caractère accentué (`C:\Users\Prénom...`), installez la
> toolchain Rust (`RUSTUP_HOME`/`CARGO_HOME`) sur un chemin sans accent —
> le linker GNU embarqué par rustup échoue silencieusement à résoudre les
> chemins accentués (`ld: cannot find ...: No such file or directory` sur des
> fichiers qui existent pourtant). Rencontré et contourné pendant cette
> session en installant la toolchain sous `C:\rust-toolchain`.

```bash
cargo build --workspace
cargo test --workspace
cargo build --release -p kprm-cli
```

Le binaire `target/release/kprm-cli.exe` (~1.7 Mo) est un exécutable
autonome : testé avec un `PATH` réduit à `C:\Windows\System32` seul, sans
aucune DLL tierce à installer — conforme à l'exigence « fonctionne sans
installation ».

## Pourquoi pas `dlltool`/MinGW complet

Le poste de build n'a qu'une toolchain GNU minimale (fournie par `rustup`,
sans binutils complet). Certaines crates (`clap` avec ses fonctionnalités de
couleur terminal par défaut) déclenchent un besoin de `dlltool.exe` absent de
cet environnement. Plutôt que d'installer une chaîne MinGW complète (ou de
basculer sur `cargo-xwin`/MSVC, cf. spec §5.3), `clap` est utilisé avec
`default-features = false` + un sous-ensemble de fonctionnalités qui évite
cette dépendance. À revisiter si une future dépendance impose réellement
`dlltool` (alors ce sera le moment de suivre la piste `cargo-xwin` décrite
dans la spec).
