# Sideforge · Disk Lens

> **A fast, portable WPF tool for Windows to analyze, visualize, and clean up disk space.**  
> Single-file PowerShell — no installation, no dependencies.

![Version](https://img.shields.io/badge/version-1.3.0-E8600A?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Windows-0078D4?style=flat-square)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-012456?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-639922?style=flat-square)
![Sideforge](https://img.shields.io/badge/Sideforge-Design%20System-E8600A?style=flat-square)

🇩🇪 [Deutsche Version](README.de.md)

Part of the **[Sideforge](https://github.com/C129H223N3O54/SideForge)** tool suite.

---

## Screenshot

> *(Add a screenshot here — e.g. `![Screenshot](docs/screenshot-dark.png)`)*

---

## Features

### Analysis
- **Parallel folder scan** with live updates while running
- **Progress bar** with percentage and current folder
- **Size class badges** — Very Large / Large / Medium / Small / Very Small
- **Share bar** showing each folder's proportion visually
- **Cancel** at any time — partial results stay visible

### File Browser
- Side-panel browser with double-click navigation
- **Breadcrumb navigation** with clickable path segments
- Asynchronous size calculation — UI stays responsive
- **Size cache** — visited folders are not re-scanned
- Sort by column click (Name, Type, Size, Date) — **default: size descending**
- Back and Up navigation
- Context menu: Open, Show in Explorer, Rename, Copy, Cut, Paste, New folder, Delete, Copy path

### Duplicate Finder
- Three-stage hash algorithm: size pre-filter → quick hash → full MD5
- Results grouped by duplicate set with wasted space summary
- Delete to Recycle Bin or permanently
- Runs as a **separate process** — does not block the main window

### Empty Folder Finder
- Recursive search for truly empty folders (no files, no subfolders)
- Delete individually or all at once
- Deepest paths deleted first (correct order)
- Runs as a **separate process**

### Status Bar
- **Drive usage** for all connected drives in real time
- **Recycle Bin size** with one-click empty button
- **Temp folder size** with details and clean button

### Convenience
- **Language switch** — English / German, toggle live via header button
- **Dark / Light mode** — toggle via header button, system theme on first launch
- **Path history** — last 10 paths, stored persistently
- **Window position and size** saved and restored
- **Admin check** at startup with option to restart as Administrator
- **Drive selection** dialog at startup

---

## Requirements

| Requirement | Details |
|---|---|
| **OS** | Windows 10 / 11 |
| **PowerShell** | 5.1 or newer (pre-installed on Windows 10+) |
| **Permissions** | Standard user — Administrator recommended for full system folder access |
| **Framework** | .NET / WPF (built into Windows, no installation needed) |

---

## Getting Started

```powershell
powershell -ExecutionPolicy Bypass -File DiskLens.ps1
```

Or right-click → **"Run with PowerShell"**.

> **Tip:** Run as Administrator for full access to all system folders.  
> Disk Lens will prompt you at startup.

---

## Startup Flow

1. **Admin check** — run as Administrator or continue with standard rights
2. **Drive selection** — choose which drive to analyze

Language and theme are switched live via buttons in the top-right corner. Preferences are saved automatically in `%APPDATA%\DiskLens\config.xml`.

---

## Design

Disk Lens uses the **[Sideforge](https://github.com/C129H223N3O54/SideForge)** design system:

- **Ember** orange as the primary accent (`#E8600A` Light / `#F07E2D` Dark)
- **Anvil** warm grays as neutrals (replaces the old cool blue-gray)
- **Moss** green reserved for success states
- SF logo tile in every window — black tile, "S" in Ember, "F" in white, Georgia italic bold
- Full Light and Dark mode support

---

## Project Structure

```
DiskLens/
├── DiskLens.ps1     # Entire application — single file
├── README.md        # English
├── README.de.md     # Deutsch
├── LICENSE
└── .gitignore
```

Configuration is stored at `%APPDATA%\DiskLens\config.xml` (window position, path history, language, theme).

---

## How It Works

| Component | Technology |
|---|---|
| GUI | WPF (Windows Presentation Foundation) via PowerShell `Add-Type` |
| Parallel scan | `System.Threading.Tasks.Task` + `ConcurrentBag` |
| Thread → UI bridge | `ConcurrentDictionary` + `DispatcherTimer` polling |
| File enumeration | `System.IO.Directory.GetFiles/GetDirectories` |
| Duplicate detection | Size pre-filter → quick hash (first+last 64 KB) → full MD5 |
| Sub-tools | Spawned as separate `powershell.exe` processes with token-injected scripts |
| Persistence | `Export-Clixml` / `Import-Clixml` |

---

## Changelog

### v1.3.0 — 2026-04-24
- **Sideforge design system** introduced (Ember / Moss / Anvil palette)
- Accent color changed from purple to Sideforge orange
- SF logo tile in all windows — main, admin check, drive selection, sub-tools
- Window title: `Sideforge - DiskLens` throughout
- Light mode: warm Anvil gray instead of cool blue-gray
- Dark mode: warm anthracite with subtle orange accent
- Duplicate Finder rebranded with orange accent

### v1.2.6 — 2026-04-22
- Unified button colors across all windows
- Browser: size-descending sort as default with live sorting
- DataGrid column widths evenly distributed
- Size class badges: correct colors in light mode (bug fix)
- Code cleanup: removed dead code

### v1.2.5 — 2026-04-03
- Live Dark / Light toggle via header button — no restart needed
- Live language switch via header button — no restart needed
- No more startup dialogs for language / theme — loaded from config automatically
- First launch: system theme detected automatically

### v1.2.4 — 2026-04-03
- Dark / Light mode with complete color palette

### v1.2.3 — 2026-03-13
- Language selection — English or German, fully bilingual UI
- Renamed to **Disk Lens**

### v1.2.0 — 2026-03-12
- Breadcrumb navigation in file browser
- Empty Folder Finder as separate process

### v1.1.5 — 2026-03-12
- Asynchronous folder size calculation in browser
- Duplicate Finder with MD5 hash, grouping, wasted space

### v1.1.3 — 2026-02-25
- Real-time drive usage status bar
- Recycle Bin and Temp display with empty buttons
- Changelog window

### v1.0.0 — 2026-02-24
- Initial release

---

## Credits

Idea, requirements, and direction by **Jan Erik Mueller** ([@kampfmade](https://github.com/kampfmade)).  
Code written by **[Claude](https://claude.ai)** (Anthropic).  
Design system: **[Sideforge](https://github.com/C129H223N3O54/SideForge)**.

---

## License

MIT — see [LICENSE](LICENSE)
