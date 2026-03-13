# Disk Lens

> **A fast, portable WPF tool for Windows to analyze, visualize, and clean up disk space.**  
> Written entirely in PowerShell — no installation, no dependencies, single file.

![Version](https://img.shields.io/badge/version-1.2.3-7C3AED?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Windows-0078D4?style=flat-square)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-012456?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-22C55E?style=flat-square)

🇩🇪 [Deutsche Version](README.de.md)

---

## Screenshot

https://github.com/C129H223N3O54/DiskLens/blob/main/screenshot.png

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
- **Language switch** — English / German, selectable at startup and switchable at any time via button
- **Path history** — last 10 paths, stored persistently
- **Window position and size** saved and restored
- **Admin check** at startup with option to restart as Administrator
- **Drive selection dialog** at startup
- Dark theme throughout

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

Configuration (window position, path history) is stored at `%APPDATA%\DiskLens\config.xml`.

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

### v1.2.3 — 2026-03-13
- **Language selection at startup** — English or German (Windows Forms dialog)
- **In-app language switch** button — switch at any time without restarting
- Fully bilingual UI: all buttons, labels, dialogs, status messages, context menus
- Duplicate finder and empty folder finder fully translated via token injection
- Renamed to **Disk Lens** (`DiskLens.ps1`)
- Fixed: PowerShell built-in `$Lang` variable conflict → renamed to `$StartLang`

### v1.2.2 — 2026-03-13
- Browser: `IO.Directory` methods replace `Get-ChildItem` (faster, no pipeline overhead)
- Browser runspace: fixed silent `Dispatcher.Invoke` scoping bug
- Duplicate finder: replaced COM `Shell.Application` with `VisualBasic.FileIO.FileSystem`
- Empty folder runspace: eliminated mass `DirectoryInfo` allocations
- Dead code removed: `$maxDepth`, `$dupeGroups`, duplicate formatting logic

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

## License

MIT — see [LICENSE](LICENSE)
