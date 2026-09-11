//! The KpRm tools catalog: parsing, validation, and loading of `tools.d/*.toml`.
//!
//! See `docs/RUST-REWRITE-SPEC.md` §4 for the rationale (one TOML file per tool
//! instead of the historical monolithic `tools.xml`) and §12 Annex B for the
//! attribute schema each action type is validated against.

use std::collections::HashMap;
use std::path::Path;

use include_dir::{include_dir, Dir};
use serde::Deserialize;

/// The catalog embedded into the binary at compile time, so the tool works
/// standalone with no installation and no external files to ship alongside
/// the executable (see docs/RUST-REWRITE-SPEC.md, "outil fonctionne sans
/// installation").
static EMBEDDED_TOOLS_DIR: Dir<'_> = include_dir!("$CARGO_MANIFEST_DIR/../../tools.d");

#[derive(Debug, Clone, Deserialize)]
pub struct Tool {
    pub name: String,
    #[serde(default)]
    pub actions: Vec<Action>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum EntryKind {
    File,
    Folder,
}

impl Default for EntryKind {
    /// The original AutoIt engine defaults the `type` attribute to `"file"`
    /// when a file-like action omits it (`GetSwapOrder`,
    /// `functions/functions.au3`). No entry in the migrated catalog actually
    /// relies on this default (every XML action specified `type` explicitly),
    /// but a hand-written `tools.d/*.toml` contribution might.
    fn default() -> Self {
        EntryKind::File
    }
}

#[derive(Debug, Clone, Deserialize)]
pub struct FileLikeAction {
    pub pattern: String,
    #[serde(default)]
    pub company_name: String,
    #[serde(default)]
    pub kind: EntryKind,
    #[serde(default)]
    pub quarantine: bool,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ProcessAction {
    pub pattern: String,
    #[serde(default)]
    pub company_name: String,
    #[serde(default)]
    pub force: bool,
}

#[derive(Debug, Clone, Deserialize)]
pub struct UninstallAction {
    pub folder: String,
    pub uninstaller: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct TaskAction {
    pub name: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SoftwareKeyAction {
    pub pattern: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct RegistryKeyAction {
    pub key: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SearchRegistryKeyAction {
    pub key: String,
    pub pattern: String,
    pub value: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct CleanDirectoryAction {
    pub path: String,
    #[serde(default)]
    pub company_name: String,
    #[serde(default)]
    pub quarantine: bool,
}

#[derive(Debug, Clone, Deserialize)]
pub struct FileAction {
    pub path: String,
    #[serde(default)]
    pub company_name: String,
}

#[derive(Debug, Clone, Deserialize)]
pub struct FolderAction {
    pub path: String,
    #[serde(default)]
    pub quarantine: bool,
}

/// One removal rule for one tool. The `type` tag matches the snake_case
/// names in docs/RUST-REWRITE-SPEC.md §12 Annex B.
#[derive(Debug, Clone, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Action {
    Desktop(FileLikeAction),
    DesktopCommon(FileLikeAction),
    Download(FileLikeAction),
    ProgramFiles(FileLikeAction),
    HomeDrive(FileLikeAction),
    AppData(FileLikeAction),
    AppDataCommon(FileLikeAction),
    AppDataLocal(FileLikeAction),
    WindowsFolder(FileLikeAction),
    StartMenu(FileLikeAction),
    UserStartMenu(FileLikeAction),
    Process(ProcessAction),
    Uninstall(UninstallAction),
    Task(TaskAction),
    SoftwareKey(SoftwareKeyAction),
    RegistryKey(RegistryKeyAction),
    SearchRegistryKey(SearchRegistryKeyAction),
    CleanDirectory(CleanDirectoryAction),
    File(FileAction),
    Folder(FolderAction),
}

impl Action {
    /// Short machine-readable name of this action's type, for logging/reports.
    pub fn type_name(&self) -> &'static str {
        match self {
            Action::Desktop(_) => "desktop",
            Action::DesktopCommon(_) => "desktop_common",
            Action::Download(_) => "download",
            Action::ProgramFiles(_) => "program_files",
            Action::HomeDrive(_) => "home_drive",
            Action::AppData(_) => "app_data",
            Action::AppDataCommon(_) => "app_data_common",
            Action::AppDataLocal(_) => "app_data_local",
            Action::WindowsFolder(_) => "windows_folder",
            Action::StartMenu(_) => "start_menu",
            Action::UserStartMenu(_) => "user_start_menu",
            Action::Process(_) => "process",
            Action::Uninstall(_) => "uninstall",
            Action::Task(_) => "task",
            Action::SoftwareKey(_) => "software_key",
            Action::RegistryKey(_) => "registry_key",
            Action::SearchRegistryKey(_) => "search_registry_key",
            Action::CleanDirectory(_) => "clean_directory",
            Action::File(_) => "file",
            Action::Folder(_) => "folder",
        }
    }

    /// Every string field of this action that is a regular expression
    /// (as opposed to a literal path, registry key, or value name), paired
    /// with a label identifying which field it is (for error messages).
    pub fn regex_fields(&self) -> Vec<(&'static str, &str)> {
        match self {
            Action::Desktop(a)
            | Action::DesktopCommon(a)
            | Action::Download(a)
            | Action::ProgramFiles(a)
            | Action::HomeDrive(a)
            | Action::AppData(a)
            | Action::AppDataCommon(a)
            | Action::AppDataLocal(a)
            | Action::WindowsFolder(a)
            | Action::StartMenu(a)
            | Action::UserStartMenu(a) => {
                let mut fields = vec![("pattern", a.pattern.as_str())];
                if !a.company_name.is_empty() {
                    fields.push(("company_name", a.company_name.as_str()));
                }
                fields
            }
            Action::Process(a) => {
                let mut fields = vec![("pattern", a.pattern.as_str())];
                if !a.company_name.is_empty() {
                    fields.push(("company_name", a.company_name.as_str()));
                }
                fields
            }
            Action::Uninstall(a) => vec![
                ("folder", a.folder.as_str()),
                ("uninstaller", a.uninstaller.as_str()),
            ],
            Action::SoftwareKey(a) => vec![("pattern", a.pattern.as_str())],
            Action::SearchRegistryKey(a) => vec![("pattern", a.pattern.as_str())],
            Action::CleanDirectory(a) => {
                let mut fields = vec![];
                if !a.company_name.is_empty() {
                    fields.push(("company_name", a.company_name.as_str()));
                }
                fields
            }
            Action::File(a) => {
                let mut fields = vec![];
                if !a.company_name.is_empty() {
                    fields.push(("company_name", a.company_name.as_str()));
                }
                fields
            }
            Action::Task(_) | Action::RegistryKey(_) | Action::Folder(_) => vec![],
        }
    }
}

#[derive(Debug, thiserror::Error)]
pub enum CatalogError {
    #[error("failed to read {file}: {message}")]
    Io { file: String, message: String },
    #[error("failed to parse {file}: {source}")]
    Parse {
        file: String,
        #[source]
        source: toml::de::Error,
    },
    #[error("duplicate tool name '{0}' (found in {1} and {2})")]
    DuplicateName(String, String, String),
    #[error("tool '{tool}': invalid regex in field `{field}` ('{pattern}'): {source}")]
    InvalidRegex {
        tool: String,
        field: &'static str,
        pattern: String,
        #[source]
        source: regex::Error,
    },
    #[error("tool '{tool}' has no actions")]
    EmptyTool { tool: String },
    #[error("tool '{0}' has an empty name")]
    EmptyName(String),
}

/// A tool, tagged with the source file it was loaded from (for error messages).
#[derive(Debug, Clone)]
struct LoadedTool {
    tool: Tool,
    source: String,
}

#[derive(Debug)]
pub struct Catalog {
    tools: Vec<Tool>,
}

impl Catalog {
    /// Loads the catalog embedded in the binary at compile time.
    pub fn embedded() -> Result<Self, Vec<CatalogError>> {
        let mut loaded = Vec::new();
        let mut errors = Vec::new();

        for file in EMBEDDED_TOOLS_DIR.files() {
            let path = file.path().display().to_string();
            let Some(contents) = file.contents_utf8() else {
                errors.push(CatalogError::Io {
                    file: path.clone(),
                    message: "file is not valid UTF-8".to_string(),
                });
                continue;
            };
            match toml::from_str::<Tool>(contents) {
                Ok(tool) => loaded.push(LoadedTool { tool, source: path }),
                Err(source) => errors.push(CatalogError::Parse { file: path, source }),
            }
        }

        if !errors.is_empty() {
            return Err(errors);
        }

        Self::from_loaded(loaded)
    }

    /// Loads every `*.toml` file directly under `dir` (non-recursive).
    /// Used by tests and by anyone wanting to override the embedded catalog
    /// with a local `tools.d/` directory during development.
    pub fn from_dir(dir: &Path) -> Result<Self, Vec<CatalogError>> {
        let mut entries: Vec<_> = std::fs::read_dir(dir)
            .map_err(|e| {
                vec![CatalogError::Io {
                    file: dir.display().to_string(),
                    message: e.to_string(),
                }]
            })?
            .filter_map(|e| e.ok())
            .filter(|e| e.path().extension().and_then(|s| s.to_str()) == Some("toml"))
            .collect();
        entries.sort_by_key(|e| e.path());

        let mut loaded = Vec::new();
        let mut errors = Vec::new();

        for entry in entries {
            let path = entry.path();
            let display = path.display().to_string();
            let contents = match std::fs::read_to_string(&path) {
                Ok(c) => c,
                Err(e) => {
                    errors.push(CatalogError::Io {
                        file: display,
                        message: e.to_string(),
                    });
                    continue;
                }
            };
            match toml::from_str::<Tool>(&contents) {
                Ok(tool) => loaded.push(LoadedTool {
                    tool,
                    source: display,
                }),
                Err(source) => errors.push(CatalogError::Parse {
                    file: display,
                    source,
                }),
            }
        }

        if !errors.is_empty() {
            return Err(errors);
        }

        Self::from_loaded(loaded)
    }

    fn from_loaded(loaded: Vec<LoadedTool>) -> Result<Self, Vec<CatalogError>> {
        let mut errors = Vec::new();
        let mut seen: HashMap<String, String> = HashMap::new();

        for lt in &loaded {
            if lt.tool.name.trim().is_empty() {
                errors.push(CatalogError::EmptyName(lt.source.clone()));
                continue;
            }
            if let Some(first_source) = seen.get(&lt.tool.name) {
                errors.push(CatalogError::DuplicateName(
                    lt.tool.name.clone(),
                    first_source.clone(),
                    lt.source.clone(),
                ));
            } else {
                seen.insert(lt.tool.name.clone(), lt.source.clone());
            }
        }

        if !errors.is_empty() {
            return Err(errors);
        }

        let tools: Vec<Tool> = loaded.into_iter().map(|lt| lt.tool).collect();
        let catalog = Catalog { tools };

        let validation_errors = catalog.validate();
        if !validation_errors.is_empty() {
            return Err(validation_errors);
        }

        Ok(catalog)
    }

    /// Structural + regex validation. Called automatically by the loaders
    /// above; exposed separately so a CI check (or `kprm-cli catalog
    /// validate`) can run it without re-parsing.
    pub fn validate(&self) -> Vec<CatalogError> {
        let mut errors = Vec::new();

        for tool in &self.tools {
            if tool.actions.is_empty() {
                errors.push(CatalogError::EmptyTool {
                    tool: tool.name.clone(),
                });
            }

            for action in &tool.actions {
                for (field, pattern) in action.regex_fields() {
                    if let Err(source) = regex::Regex::new(pattern) {
                        errors.push(CatalogError::InvalidRegex {
                            tool: tool.name.clone(),
                            field,
                            pattern: pattern.to_string(),
                            source,
                        });
                    }
                }
            }
        }

        errors
    }

    pub fn tools(&self) -> &[Tool] {
        &self.tools
    }

    pub fn tool_count(&self) -> usize {
        self.tools.len()
    }

    pub fn action_count(&self) -> usize {
        self.tools.iter().map(|t| t.actions.len()).sum()
    }

    pub fn find(&self, name: &str) -> Option<&Tool> {
        self.tools.iter().find(|t| t.name == name)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_catalog_loads_and_has_267_tools() {
        let catalog = Catalog::embedded().expect("embedded catalog must be valid");
        assert_eq!(catalog.tool_count(), 267);
        assert!(catalog.action_count() > 800);
    }

    #[test]
    fn embedded_catalog_has_no_duplicate_names() {
        let catalog = Catalog::embedded().expect("embedded catalog must be valid");
        let mut names: Vec<&str> = catalog.tools().iter().map(|t| t.name.as_str()).collect();
        let before = names.len();
        names.sort_unstable();
        names.dedup();
        assert_eq!(names.len(), before, "duplicate tool name found");
    }

    #[test]
    fn embedded_catalog_has_a_known_tool_with_expected_shape() {
        let catalog = Catalog::embedded().expect("embedded catalog must be valid");
        let adw = catalog
            .find("AdwCleaner")
            .expect("AdwCleaner must be present");
        assert_eq!(adw.actions.len(), 4);
        let has_quarantined_home_drive = adw
            .actions
            .iter()
            .any(|a| matches!(a, Action::HomeDrive(f) if f.quarantine));
        assert!(
            has_quarantined_home_drive,
            "AdwCleaner's home_drive folder should be quarantined"
        );
    }

    #[test]
    fn rejects_duplicate_tool_names() {
        let dir = tempdir();
        std::fs::write(
            dir.join("a.toml"),
            "name = 'Dup'\n[[actions]]\ntype = 'task'\nname = 'x'\n",
        )
        .unwrap();
        std::fs::write(
            dir.join("b.toml"),
            "name = 'Dup'\n[[actions]]\ntype = 'task'\nname = 'y'\n",
        )
        .unwrap();

        let result = Catalog::from_dir(&dir);
        assert!(result.is_err());
        let errors = result.unwrap_err();
        assert!(errors
            .iter()
            .any(|e| matches!(e, CatalogError::DuplicateName(name, _, _) if name == "Dup")));

        std::fs::remove_dir_all(&dir).ok();
    }

    #[test]
    fn rejects_invalid_regex() {
        let dir = tempdir();
        std::fs::write(
            dir.join("bad.toml"),
            "name = 'Bad'\n[[actions]]\ntype = 'process'\npattern = '(unclosed'\n",
        )
        .unwrap();

        let result = Catalog::from_dir(&dir);
        assert!(result.is_err());
        let errors = result.unwrap_err();
        assert!(errors
            .iter()
            .any(|e| matches!(e, CatalogError::InvalidRegex { tool, .. } if tool == "Bad")));

        std::fs::remove_dir_all(&dir).ok();
    }

    #[test]
    fn rejects_tool_with_no_actions() {
        let dir = tempdir();
        std::fs::write(dir.join("empty.toml"), "name = 'Empty'\n").unwrap();

        let result = Catalog::from_dir(&dir);
        assert!(result.is_err());
        let errors = result.unwrap_err();
        assert!(errors
            .iter()
            .any(|e| matches!(e, CatalogError::EmptyTool { tool } if tool == "Empty")));

        std::fs::remove_dir_all(&dir).ok();
    }

    #[test]
    fn file_like_action_kind_defaults_to_file() {
        let tool: Tool =
            toml::from_str("name = 'X'\n[[actions]]\ntype = 'desktop'\npattern = 'foo'\n").unwrap();
        match &tool.actions[0] {
            Action::Desktop(a) => assert_eq!(a.kind, EntryKind::File),
            _ => panic!("expected a Desktop action"),
        }
    }

    fn tempdir() -> std::path::PathBuf {
        let dir = std::env::temp_dir().join(format!(
            "kprm-catalog-test-{}-{}",
            std::process::id(),
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        std::fs::create_dir_all(&dir).unwrap();
        dir
    }
}
