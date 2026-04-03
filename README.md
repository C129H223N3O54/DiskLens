# Disk Lens

> **A fast, portable WPF tool for Windows to analyze, visualize, and clean up disk space.**  
> Written entirely in PowerShell — no installation, no dependencies, single file.

![Version](https://img.shields.io/badge/version-1.2.4-7C3AED?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Windows-0078D4?style=flat-square)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-012456?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-22C55E?style=flat-square)

🇩🇪 [Deutsche Version](README.de.md)

---

## Screenshot

> *(Add a screenshot here — e.g. `![Screenshot](docs/screenshot.png)`)*

---

## Features

### Analysis
- **Parallel folder scan** with live updates while the scan is running
- **Progress bar** showing percentage and current folder
- **Size class badges** (Very large / Large / Medium / Small / Very small)
- **Share bar** visually showing how much space each folder uses
- **Tree view** as an alternative to the flat list
- **Cancel** at any time — partial results remain visible

### File Browser
- Built-in side-panel browser with double-click navigation
- **Breadcrumb navigation** with clickable path segments
- Asynchronous size calculation (UI stays responsive)
- **Size cache** — already calculated folders are not re-scanned on revisit
- Sort by column click (Name, Type, Size, Date)
- Back and Up navigation
- Context menu: Open, Show in Explorer, Rename, Copy, Cut, Paste, New folder, Delete, Copy path

### Duplicate Finder
- Three-stage hash algorithm: size pre-filter → quick hash → full MD5
- Results grouped by duplicate group with wasted space summary
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
- **Language selection** — English / German, asked at every startup with last choice pre-selected
- **Dark / Light mode** — asked at every startup with last choice pre-selected, automatic system detection as option
- **Path history** — last 10 paths, stored persistently
- **Window position and size** saved and restored
- **Admin check** at startup with option to restart as Administrator
- **Drive selection dialog** at startup

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

Or right-click the file → **"Run with PowerShell"**.

> **Tip:** Run as Administrator for full access to all system folders.  
> Disk Lens will prompt you at startup.

---

## Startup Flow

Each time Disk Lens starts, it asks three quick questions — all with your last choice pre-selected:

1. **Language** — English or German
2. **Display mode** — Dark, Light, or use system setting
3. **Admin check** — run as Administrator or continue with standard rights

Then the **drive selection** dialog opens and you're ready to scan.

---

## Project Structure

```
DiskLens/
├── DiskLens.ps1     # Entire application — GUI, logic, tools (single file)
├── README.md        # English
├── README.de.md     # Deutsch
├── LICENSE
└── .gitignore
```

The entire application — GUI, scan engine, duplicate finder, empty folder finder, all dialogs — lives in a single `.ps1` file. No installation, no registry entries, no setup required.

Configuration (window position, path history, language, theme) is stored at `%APPDATA%\DiskLens\config.xml`.

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

### v1.2.4 — 2026-04-03
- **Dark / Light mode** with complete color palette
- Theme dialog at startup: Dark / Light / System setting
- Selected theme and language saved and pre-selected on next launch
- High-contrast light mode palette
- Code cleanup: unnecessary constructs and duplicate imports removed

### v1.2.3 — 2026-03-13
- **Language selection** at startup — English or German
- **In-app language switch** button — switch at any time without restarting
- Fully bilingual UI: all buttons, labels, dialogs, status messages, context menus
- Renamed to **Disk Lens** (`DiskLens.ps1`)

### v1.2.2 — 2026-03-13
- Browser: `IO.Directory` methods replace `Get-ChildItem` (faster, no pipeline overhead)
- Browser runspace: fixed silent `Dispatcher.Invoke` scoping bug
- Duplicate finder: replaced COM `Shell.Application` with `VisualBasic.FileIO.FileSystem`
- Dead code removed

### v1.2.1 — 2026-03-13
- Browser size cache — no re-scan when navigating back
- Stack-based `IO.Directory` scan replaces `Get-ChildItem -Recurse`

### v1.2.0 — 2026-03-12
- Breadcrumb navigation in file browser
- Empty folder finder as separate process with progress bar

### v1.1.5 — 2026-03-12
- Asynchronous folder size calculation in browser
- Sort by column click with direction arrow
- Duplicate finder with MD5 hash, grouping, wasted space display

### v1.1.3 — 2026-02-25
- Real-time drive usage in status bar
- Recycle Bin and Temp display with empty buttons
- Changelog window

### v1.0.0 — 2026-02-24
- Initial release

---

## Credits

The idea, requirements and direction for this project came from **Jan Erik Mueller**.  
The entire codebase — every line of PowerShell, the WPF GUI, the scan engine, all dialogs and tools — was written by **[Claude](https://claude.ai)**, an AI assistant made by [Anthropic](https://www.anthropic.com).

This project is an example of human–AI collaboration: a person with a vision, and an AI that implements it.

---

## License

MIT — see [LICENSE](LICENSE)
