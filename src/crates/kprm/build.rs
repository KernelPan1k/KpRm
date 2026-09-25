//! Embeds `assets/icon.ico` as the .exe's PE resource icon (the icon shown
//! by Explorer, the taskbar, and Alt+Tab before the window even exists —
//! without this, Windows falls back to a generic default), plus the
//! `requestedExecutionLevel`/`dpiAwareness` manifest (`assets/app.manifest`,
//! or `assets/app.noadmin.manifest` when the `dev-noadmin` feature is
//! enabled — see that file's own doc comment).
fn main() {
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("windows") {
        let manifest_dir = env!("CARGO_MANIFEST_DIR");
        let manifest_file = if std::env::var("CARGO_FEATURE_DEV_NOADMIN").is_ok() {
            "app.noadmin.manifest"
        } else {
            "app.manifest"
        };
        println!("cargo:rerun-if-changed=assets/{manifest_file}");

        // embed_resource::compile takes one fixed .rc file, but which
        // manifest it embeds depends on the feature above — so the .rc
        // itself is generated into OUT_DIR rather than kept as a static
        // asset, referencing the chosen manifest by absolute path.
        let out_dir = std::env::var("OUT_DIR").unwrap();
        // windres resolves the bare filenames below relative to the .rc
        // file's own directory — copying the chosen manifest (and the
        // icon, for consistency) next to a generated icon.rc in OUT_DIR
        // sidesteps any absolute-path/escaping quoting issues entirely,
        // matching the exact scheme (relative filename next to the .rc)
        // the original static assets/icon.rc always used.
        std::fs::copy(
            format!("{manifest_dir}/assets/{manifest_file}"),
            format!("{out_dir}/embedded.manifest"),
        )
        .expect("failed to copy the chosen manifest into OUT_DIR");
        std::fs::copy(
            format!("{manifest_dir}/assets/icon.ico"),
            format!("{out_dir}/icon.ico"),
        )
        .expect("failed to copy icon.ico into OUT_DIR");

        let rc_path = format!("{out_dir}/icon.rc");
        std::fs::write(&rc_path, "IDI_ICON1 ICON \"icon.ico\"\n1 24 \"embedded.manifest\"\n")
            .expect("failed to write generated icon.rc");

        match embed_resource::compile(&rc_path, embed_resource::NONE) {
            embed_resource::CompilationResult::Ok => {}
            other => panic!(
                "failed to embed assets/icon.ico as the .exe resource icon: {other:?} \
                 (windres from a MinGW toolchain must be on PATH)"
            ),
        }

        // MinGW's gcc spec unconditionally links an `asInvoker` default
        // manifest (`default-manifest.o`, found via its `-B` search
        // path) into every non-shared link, which collides with the
        // `requireAdministrator` manifest embedded above (linker warning:
        // "multiple non-default manifests") and silently wins, leaving
        // the .exe running unelevated. `nodefaultmanifest/` shadows it
        // with an empty object (no `.rsrc` section) by coming first on
        // the search path, so ours is the only manifest left.
        println!(
            "cargo:rustc-link-arg-bins=-B{}/nodefaultmanifest",
            env!("CARGO_MANIFEST_DIR")
        );
    }
}
