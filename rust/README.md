# KpRm — réécriture Rust

Implémentation en cours de la réécriture Rust de KpRm décrite dans
[`../docs/RUST-REWRITE-SPEC.md`](../docs/RUST-REWRITE-SPEC.md). Ce dossier est
un workspace Cargo autonome, indépendant du code AutoIt historique (`../src`).

## État d'avancement

Correspond au début des phases 1 et 2 de la feuille de route (§11 de la
spec) :

| Crate | Statut | Contenu |
|---|---|---|
| `kprm-catalog` | ✅ | Modèle de données + chargement/validation du catalogue (202 outils migrés depuis `tools.xml`, embarqués dans le binaire). 7 tests. |
| `kprm-engine` | ✅ (noyau pur) | Liste blanche, résolution des macros de chemin, formatage des clés 32/64 bits, décision de quarantaine, moteur de correspondance règle/élément. 23 tests. Pas encore d'accès disque/registre réel (`kprm-windows` à venir). |
| `kprm-i18n` | ✅ | 8 langues (FR/EN/DE/IT/PT/RU/ES/NL) portées en Fluent, avec test de parité des clés entre langues. 8 tests. |
| `kprm-cli` | ✅ (utilitaire) | Binaire headless : `catalog stats/list/validate`, `translate <locale> <clé>`, `locales`. Pas encore de suppression réelle. |
| `kprm-windows` | ❌ à faire | Adaptateurs Windows réels (ACL, registre, VSS, Task Scheduler, process) — §3 de la spec. |
| `kprm-gui` | ❌ à faire | Interface egui reprenant la maquette (voir le canvas de design partagé plus tôt dans la conversation). |

**38 tests unitaires, tous verts** (`cargo test --workspace`). Aucune
fonctionnalité de suppression réelle n'est encore branchée : ce qui existe
aujourd'hui est le socle métier testable indépendamment de Windows, condition
posée dans la spec (§9.0) avant d'écrire les adaptateurs Windows eux-mêmes.

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
