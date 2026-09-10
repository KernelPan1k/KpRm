#!/usr/bin/env node
// One-off migration: src/config/tools.xml -> rust/tools.d/<slug>.toml
//
// Throwaway script (see docs/RUST-REWRITE-SPEC.md §4.2): tools.xml stays the
// historical source of truth for this migration, but is not read by the Rust
// code afterwards. Not meant to be run again except to regenerate the catalog
// from scratch or to audit the migration.
//
// Usage: node migrate_tools_xml.mjs <path-to-tools.xml> <output-dir>

import { readFileSync, writeFileSync, mkdirSync, readdirSync, unlinkSync } from "node:fs";
import { join } from "node:path";

const [, , xmlPathArg, outDirArg] = process.argv;
const xmlPath = xmlPathArg ?? "../../src/config/tools.xml";
const outDir = outDirArg ?? "../tools.d";

const xml = readFileSync(xmlPath, "utf8");

// XML -> internal action type (snake_case, matches docs/RUST-REWRITE-SPEC.md §12 Annex B)
const TAG_TO_TYPE = {
  process: "process",
  uninstall: "uninstall",
  task: "task",
  desktop: "desktop",
  desktopCommon: "desktop_common",
  download: "download",
  programFiles: "program_files",
  homeDrive: "home_drive",
  appData: "app_data",
  appDataCommon: "app_data_common",
  appDataLocal: "app_data_local",
  windowsFolder: "windows_folder",
  softwareKey: "software_key",
  registryKey: "registry_key",
  searchRegistryKey: "search_registry_key",
  startMenu: "start_menu",
  userStartMenu: "user_start_menu",
  cleanDirectory: "clean_directory",
  file: "file",
  folder: "folder",
};

// Action types whose original XML carries pattern/companyName/type/quarantine,
// i.e. AutoIt's $aActionsFile list (functions/functions.au3, GetSwapOrder).
const FILE_LIKE = new Set([
  "desktop", "desktop_common", "download", "home_drive",
  "app_data", "app_data_common", "app_data_local", "windows_folder",
  "start_menu", "user_start_menu", "program_files",
]);

function slugify(name) {
  return name
    .toLowerCase()
    .normalize("NFD").replace(/[̀-ͯ]/g, "") // strip accents
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .replace(/-{2,}/g, "-");
}

function parseAttrs(attrString) {
  const attrs = {};
  const re = /([a-zA-Z]+)="([^"]*)"/g;
  let m;
  while ((m = re.exec(attrString)) !== null) {
    attrs[m[1]] = m[2];
  }
  return attrs;
}

// TOML literal string: no escaping needed/possible, safe for every regex
// pattern in this catalog (verified: no single-quote characters in tools.xml).
function tomlLiteral(value) {
  if (value.includes("'")) {
    throw new Error(`Value contains a single quote, cannot use a TOML literal string: ${value}`);
  }
  return `'${value}'`;
}

function tomlBool(value) {
  return value === "1" ? "true" : "false";
}

// Strip XML comments before parsing.
const xmlNoComments = xml.replace(/<!--[\s\S]*?-->/g, "");

const toolRe = /<tool name="([^"]*)">([\s\S]*?)<\/tool>/g;
const selfClosingRe = /<([a-zA-Z]+)((?:\s+[a-zA-Z]+="[^"]*")*)\s*\/>/g;

const usedSlugs = new Map(); // slug -> count, to disambiguate collisions
const droppedAttrsLog = [];
let toolCount = 0;
let actionCount = 0;

let toolMatch;
while ((toolMatch = toolRe.exec(xmlNoComments)) !== null) {
  const toolName = toolMatch[1];
  const body = toolMatch[2];
  toolCount++;

  let baseSlug = slugify(toolName) || `tool-${toolCount}`;
  const n = (usedSlugs.get(baseSlug) ?? 0) + 1;
  usedSlugs.set(baseSlug, n);
  const slug = n > 1 ? `${baseSlug}-${n}` : baseSlug;

  const lines = [];
  lines.push(`name = ${tomlLiteral(toolName)}`);
  lines.push("");

  let actionMatch;
  selfClosingRe.lastIndex = 0;
  while ((actionMatch = selfClosingRe.exec(body)) !== null) {
    const tag = actionMatch[1];
    const type = TAG_TO_TYPE[tag];
    if (!type) {
      throw new Error(`Unknown action tag <${tag}> in tool "${toolName}"`);
    }
    const attrs = parseAttrs(actionMatch[2]);
    actionCount++;

    lines.push("[[actions]]");
    lines.push(`type = ${tomlLiteral(type)}`);

    if (FILE_LIKE.has(type)) {
      if (attrs.pattern !== undefined) lines.push(`pattern = ${tomlLiteral(attrs.pattern)}`);
      if (attrs.companyName) lines.push(`company_name = ${tomlLiteral(attrs.companyName)}`);
      if (attrs.type) lines.push(`kind = ${tomlLiteral(attrs.type)}`);
      if (attrs.quarantine !== undefined) lines.push(`quarantine = ${tomlBool(attrs.quarantine)}`);
      for (const k of Object.keys(attrs)) {
        if (!["pattern", "companyName", "type", "quarantine"].includes(k)) {
          droppedAttrsLog.push(`${toolName} <${tag}> unexpected attr ${k}="${attrs[k]}" (ignored by original engine)`);
        }
      }
    } else if (type === "process") {
      if (attrs.process !== undefined) lines.push(`pattern = ${tomlLiteral(attrs.process)}`);
      if (attrs.companyName) lines.push(`company_name = ${tomlLiteral(attrs.companyName)}`);
      if (attrs.force !== undefined) lines.push(`force = ${tomlBool(attrs.force)}`);
    } else if (type === "uninstall") {
      if (attrs.folder !== undefined) lines.push(`folder = ${tomlLiteral(attrs.folder)}`);
      if (attrs.uninstaller !== undefined) lines.push(`uninstaller = ${tomlLiteral(attrs.uninstaller)}`);
    } else if (type === "task") {
      if (attrs.name !== undefined) lines.push(`name = ${tomlLiteral(attrs.name)}`);
    } else if (type === "software_key") {
      if (attrs.pattern !== undefined) lines.push(`pattern = ${tomlLiteral(attrs.pattern)}`);
    } else if (type === "registry_key") {
      if (attrs.key !== undefined) lines.push(`key = ${tomlLiteral(attrs.key)}`);
    } else if (type === "search_registry_key") {
      if (attrs.key !== undefined) lines.push(`key = ${tomlLiteral(attrs.key)}`);
      if (attrs.pattern !== undefined) lines.push(`pattern = ${tomlLiteral(attrs.pattern)}`);
      if (attrs.value !== undefined) lines.push(`value = ${tomlLiteral(attrs.value)}`);
    } else if (type === "clean_directory") {
      if (attrs.path !== undefined) lines.push(`path = ${tomlLiteral(attrs.path)}`);
      if (attrs.companyName) lines.push(`company_name = ${tomlLiteral(attrs.companyName)}`);
      if (attrs.quarantine !== undefined) lines.push(`quarantine = ${tomlBool(attrs.quarantine)}`);
    } else if (type === "file") {
      if (attrs.path !== undefined) lines.push(`path = ${tomlLiteral(attrs.path)}`);
      if (attrs.companyName) lines.push(`company_name = ${tomlLiteral(attrs.companyName)}`);
    } else if (type === "folder") {
      if (attrs.path !== undefined) lines.push(`path = ${tomlLiteral(attrs.path)}`);
      if (attrs.quarantine !== undefined) lines.push(`quarantine = ${tomlBool(attrs.quarantine)}`);
      for (const k of Object.keys(attrs)) {
        if (!["path", "quarantine"].includes(k)) {
          droppedAttrsLog.push(`${toolName} <${tag}> unexpected attr ${k}="${attrs[k]}" (ignored by original engine)`);
        }
      }
    }

    lines.push("");
  }

  writeFileSync(join(outDir, `${slug}.toml`), lines.join("\n").trimEnd() + "\n", "utf8");
}

console.log(`Migrated ${toolCount} tools, ${actionCount} actions -> ${outDir}`);
if (droppedAttrsLog.length) {
  console.log(`\n${droppedAttrsLog.length} attribute(s) dropped as dead/ignored in the original engine:`);
  for (const line of droppedAttrsLog) console.log(`  - ${line}`);
}
