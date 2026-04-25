# Sideforge · Disk Lens

> **Ein schnelles, portables WPF-Tool für Windows zum Analysieren, Visualisieren und Aufräumen von Festplattenplatz.**  
> Einzelne PowerShell-Datei — keine Installation, keine Abhängigkeiten.

![Version](https://img.shields.io/badge/version-1.3.0-E8600A?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Windows-0078D4?style=flat-square)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-012456?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-639922?style=flat-square)
![Sideforge](https://img.shields.io/badge/Sideforge-Design%20System-E8600A?style=flat-square)

🇬🇧 [English version](README.md)

Teil der **[Sideforge](https://github.com/C129H223N3O54/SideForge)** Tool-Suite.

---

## Screenshot

> *(Screenshot hier einfügen — z. B. `![Screenshot](docs/screenshot-dark.png)`)*

---

## Features

### Analyse
- **Paralleler Ordner-Scan** mit Live-Updates während die Analyse läuft
- **Fortschrittsanzeige** mit Prozent und aktuellem Ordner
- **Größenklassen-Badges** — Sehr groß / Groß / Mittel / Klein / Sehr klein
- **Anteilsbalken** zeigt visuell, welcher Ordner wie viel Platz belegt
- **Abbruch** jederzeit möglich — Teilergebnisse bleiben sichtbar

### Datei-Browser
- Seitenbereich-Browser mit Doppelklick-Navigation
- **Breadcrumb-Navigation** mit klickbaren Pfadsegmenten
- Asynchrone Größenberechnung — UI bleibt flüssig
- **Größen-Cache** — bereits besuchte Ordner werden nicht neu gescannt
- Sortierung per Spaltenklick (Name, Typ, Größe, Datum) — **Standard: Größe absteigend**
- Zurück- und Hoch-Navigation
- Kontextmenü: Öffnen, Im Explorer anzeigen, Umbenennen, Kopieren, Ausschneiden, Einfügen, Neuer Ordner, Löschen, Pfad kopieren

### Duplikat-Finder
- Dreistufiger Hash-Algorithmus: Größen-Vorfilter → Schnell-Hash → vollständiger MD5
- Ergebnisse gruppiert nach Duplikat-Gruppe mit Anzeige der verschwendeten Kapazität
- Löschen in Papierkorb oder endgültig
- Läuft als **eigener Prozess** — blockiert das Hauptfenster nicht

### Leere-Ordner-Finder
- Rekursive Suche nach wirklich leeren Ordnern (keine Dateien, keine Unterordner)
- Einzeln oder alle auf einmal löschen
- Tiefste Pfade werden zuerst gelöscht (korrekte Reihenfolge)
- Läuft als **eigener Prozess**

### Statusleiste
- **Laufwerksauslastung** aller angeschlossenen Laufwerke in Echtzeit
- **Papierkorb-Größe** mit Ein-Klick-Leeren-Button
- **Temp-Ordner-Größe** mit Detailansicht und Leeren-Button

### Komfort
- **Sprachwechsel** — Englisch / Deutsch, live per Button im Header umschaltbar
- **Dark / Light Mode** — per Button im Header, System-Theme beim ersten Start
- **Pfad-History** — letzten 10 Pfade, persistent gespeichert
- **Fensterposition und -größe** werden gespeichert und wiederhergestellt
- **Admin-Check** beim Start mit Option zum Neustart als Administrator
- **Laufwerks-Auswahldialog** beim Start

---

## Voraussetzungen

| Anforderung | Details |
|---|---|
| **Betriebssystem** | Windows 10 / 11 |
| **PowerShell** | 5.1 oder neuer (vorinstalliert auf Windows 10+) |
| **Rechte** | Normale Benutzerrechte reichen — Administrator empfohlen für vollen Zugriff |
| **Framework** | .NET / WPF (in Windows integriert, keine Installation nötig) |

---

## Start

```powershell
powershell -ExecutionPolicy Bypass -File DiskLens.ps1
```

Oder per Rechtsklick → **„Mit PowerShell ausführen"**.

> **Tipp:** Für vollen Zugriff auf alle Systemordner als Administrator starten.  
> Disk Lens fragt beim Start automatisch danach.

---

## Startablauf

1. **Admin-Check** — als Administrator starten oder mit normalen Rechten weitermachen
2. **Laufwerksauswahl** — zu analysierendes Laufwerk wählen

Sprache und Theme werden live per Button oben rechts umgeschaltet. Einstellungen werden automatisch in `%APPDATA%\DiskLens\config.xml` gespeichert.

---

## Design

Disk Lens verwendet das **[Sideforge](https://github.com/C129H223N3O54/SideForge)** Design-System:

- **Ember** Orange als Primärakzent (`#E8600A` Light / `#F07E2D` Dark)
- **Anvil** warme Grautöne als Neutrals (löst das frühere kühle Blaugrau ab)
- **Moss** Grün reserviert für Erfolgsmeldungen
- SF-Logo-Kachel in allen Fenstern — schwarze Kachel, „S" in Ember, „F" in Weiß, Georgia italic bold
- Vollständige Light- und Dark-Mode-Unterstützung

---

## Projektstruktur

```
DiskLens/
├── DiskLens.ps1     # Gesamte Anwendung — eine Datei
├── README.md        # English
├── README.de.md     # Deutsch
├── LICENSE
└── .gitignore
```

Konfiguration liegt unter `%APPDATA%\DiskLens\config.xml` (Fensterposition, Pfad-History, Sprache, Theme).

---

## Technische Details

| Komponente | Technologie |
|---|---|
| GUI | WPF (Windows Presentation Foundation) via PowerShell `Add-Type` |
| Paralleler Scan | `System.Threading.Tasks.Task` + `ConcurrentBag` |
| Thread → UI-Bridge | `ConcurrentDictionary` + `DispatcherTimer`-Polling |
| Datei-Enumeration | `System.IO.Directory.GetFiles/GetDirectories` |
| Duplikat-Erkennung | Größen-Vorfilter → Schnell-Hash (Anfang+Ende 64 KB) → vollständiger MD5 |
| Sub-Tools | Als eigene `powershell.exe`-Prozesse mit token-injizierten Skripten |
| Persistenz | `Export-Clixml` / `Import-Clixml` |

---

## Changelog

### v1.3.0 — 24.04.2026
- **Sideforge Design-System** eingeführt (Ember / Moss / Anvil Palette)
- Akzentfarbe von Lila auf Sideforge-Orange umgestellt
- SF-Logo-Kachel in allen Fenstern — Hauptfenster, Admin-Check, Laufwerksauswahl, Sub-Tools
- Fenstertitel: `Sideforge - DiskLens` überall
- Light Mode: warmes Anvil-Grau statt kühlem Blaugrau
- Dark Mode: warmes Anthrazit mit dezenten Orange-Akzent
- Duplikat-Finder mit orangener Akzentfarbe

### v1.2.6 — 22.04.2026
- Einheitliche Button-Farben in allen Fenstern
- Browser: Größe absteigend als Standard-Sortierung mit Live-Sorting
- DataGrid-Spaltenbreiten ausgewogen verteilt
- Größenklassen-Badges: korrekte Farben im Light Mode (Bugfix)
- Code-Bereinigung: toter Code entfernt

### v1.2.5 — 03.04.2026
- Live Dark/Light-Umschaltung per Header-Button — kein Neustart nötig
- Live Sprachwechsel per Header-Button — kein Neustart nötig
- Keine Startup-Dialoge mehr für Sprache/Theme — aus Config geladen
- Erster Start: System-Theme wird automatisch erkannt

### v1.2.4 — 03.04.2026
- Dark / Light Mode mit vollständiger Farbpalette

### v1.2.3 — 13.03.2026
- Sprachauswahl — Englisch oder Deutsch, vollständig zweisprachige UI
- Umbenennung zu **Disk Lens**

### v1.2.0 — 12.03.2026
- Breadcrumb-Navigation im Datei-Browser
- Leere-Ordner-Finder als eigener Prozess

### v1.1.5 — 12.03.2026
- Asynchrone Ordnergrößen-Berechnung im Browser
- Duplikat-Finder mit MD5-Hash, Gruppierung, Verschwendungsanzeige

### v1.1.3 — 25.02.2026
- Laufwerksauslastung in Echtzeit-Statusleiste
- Papierkorb- und Temp-Anzeige mit Leeren-Button
- Changelog-Fenster

### v1.0.0 — 24.02.2026
- Initiale Version

---

## Credits

Idee, Anforderungen und Richtung von **Jan Erik Mueller** ([@kampfmade](https://github.com/kampfmade)).  
Code geschrieben von **[Claude](https://claude.ai)** (Anthropic).  
Design-System: **[Sideforge](https://github.com/C129H223N3O54/SideForge)**.

---

## Lizenz

MIT — siehe [LICENSE](LICENSE)
