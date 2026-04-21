# Disk Lens

> **Ein schnelles, portables WPF-Tool für Windows zum Analysieren, Visualisieren und Aufräumen von Festplattenplatz.**  
> Vollständig in PowerShell geschrieben – keine Installation, keine Abhängigkeiten, eine einzige Datei.

![Version](https://img.shields.io/badge/version-1.2.6-7C3AED?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Windows-0078D4?style=flat-square)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-012456?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-22C55E?style=flat-square)

🇬🇧 [English version](README.md)

---

## Screenshot

> *(Screenshot hier einfügen – z. B. mit `![Screenshot](docs/screenshot.png)`)*

---

## Features

### Analyse
- **Paralleler Ordner-Scan** mit Live-Updates während die Analyse läuft
- **Fortschrittsanzeige** mit Prozent und aktuellem Ordner
- **Größenklassen-Badges** (Sehr groß / Groß / Mittel / Klein / Sehr klein)
- **Anteilsbalken** zeigt visuell, welcher Ordner wie viel Platz belegt
- **Baumansicht** optional zur flachen Liste
- **Abbruch** jederzeit möglich – Teilergebnisse bleiben sichtbar

### Datei-Browser
- Integrierter Seitenbereich-Browser mit Doppelklick-Navigation
- **Breadcrumb-Navigation** mit klickbaren Pfadsegmenten
- Asynchrone Größenberechnung (UI bleibt flüssig)
- **Größen-Cache** – bereits berechnete Ordner werden nicht neu gescannt
- Sortierung per Spaltenklick (Name, Typ, Größe, Datum)
- Zurück- und Hoch-Navigation
- Kontextmenü: Öffnen, Im Explorer anzeigen, Umbenennen, Kopieren, Ausschneiden, Einfügen, Neuer Ordner, Löschen, Pfad kopieren

### Duplikat-Finder
- Dreistufiger Hash-Algorithmus: Größen-Vorfilter → Schnell-Hash → vollständiger MD5
- Ergebnisse gruppiert nach Duplikat-Gruppe mit Anzeige der verschwendeten Kapazität
- Löschen in Papierkorb oder endgültig
- Läuft als **eigener Prozess** – blockiert das Hauptfenster nicht

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
- **Sprachwechsel** – Englisch / Deutsch, live per Button im Header umschaltbar
- **Dark / Light Mode** – live per Button im Header umschaltbar, System-Theme wird beim ersten Start automatisch erkannt
- **Pfad-History** – letzten 10 Pfade, persistent gespeichert
- **Fensterposition und -größe** werden gespeichert und wiederhergestellt
- **Admin-Check** beim Start mit Option zum Neustart als Administrator
- **Laufwerks-Auswahldialog** beim Start

---

## Voraussetzungen

| Anforderung | Details |
|---|---|
| **Betriebssystem** | Windows 10 / 11 |
| **PowerShell** | 5.1 oder neuer (vorinstalliert auf Windows 10+) |
| **Rechte** | Normale Benutzerrechte reichen – Administratorrechte empfohlen für vollständigen Zugriff |
| **Framework** | .NET / WPF (in Windows integriert, keine Installation nötig) |

---

## Start

```powershell
powershell -ExecutionPolicy Bypass -File DiskLens.ps1
```

Oder per Rechtsklick auf die Datei → **„Mit PowerShell ausführen"**.

> **Tipp:** Für vollen Zugriff auf alle Systemordner als Administrator starten.  
> Disk Lens fragt beim Start automatisch danach.

---

## Startablauf

1. **Admin-Check** – als Administrator starten oder mit normalen Rechten weitermachen
2. **Laufwerksauswahl** – zu analysierendes Laufwerk wählen

Sprache und Theme werden live per Button oben rechts umgeschaltet – kein Neustart nötig. Einstellungen werden automatisch gespeichert.

---

## Projektstruktur

```
DiskLens/
├── DiskLens.ps1     # Gesamte Anwendung – GUI, Logik, Tools (eine Datei)
├── README.md        # English
├── README.de.md     # Deutsch
├── LICENSE
└── .gitignore
```

Die gesamte Anwendung – GUI, Scan-Engine, Duplikat-Finder, Leere-Ordner-Finder, alle Dialoge – steckt in einer einzigen `.ps1`-Datei. Keine Installation, keine Registry-Einträge, kein Setup.

Die Konfiguration (Fensterposition, Pfad-History, Sprache, Theme) wird unter `%APPDATA%\DiskLens\config.xml` gespeichert.

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

### v1.2.6 — 22.04.2026
- Einheitliche Button-Farben in allen Fenstern
- Duplikat-Finder: durchgängig grüne Akzentfarbe
- Leere-Ordner-Finder: durchgängig orangene Akzentfarbe
- Disabled-Buttons: einheitlich grau – kein verwaschenesAussehen mehr
- Browser: Größe absteigend als Standard-Sortierung (Live-Sorting)
- DataGrid-Spaltenbreiten ausgewogen verteilt
- Größenklassen-Badges: korrekte Farben im Light Mode (Bugfix)
- Code-Bereinigung: toter Code entfernt

### v1.2.5 — 03.04.2026
- **Live Dark/Light-Umschaltung** per Button im Header – kein Neustart nötig
- **Live Sprachwechsel** per Button im Header – kein Neustart nötig
- Keine Startup-Dialoge mehr für Sprache/Theme – werden aus config.xml geladen
- Erster Start: System-Theme wird automatisch erkannt

### v1.2.4 — 03.04.2026
- Dark / Light Mode mit vollständiger Farbpalette
- Kontrastreiche Light-Mode-Palette
- Code-Bereinigung

### v1.2.3 — 13.03.2026
- **Sprachauswahl** beim Start – Englisch oder Deutsch
- **In-App Sprachwechsel** per Button – jederzeit ohne Neustart umschaltbar
- Vollständig zweisprachige UI: alle Buttons, Labels, Dialoge, Statusmeldungen
- Umbenannt zu **Disk Lens** (`DiskLens.ps1`)

### v1.2.2 — 13.03.2026
- Browser: `IO.Directory`-Methoden ersetzen `Get-ChildItem` (schneller)
- Browser-Runspace: Stilles `Dispatcher.Invoke`-Scoping-Bug behoben
- Duplikat-Finder: COM `Shell.Application` durch `VisualBasic.FileIO.FileSystem` ersetzt
- Toter Code entfernt

### v1.2.1 — 13.03.2026
- Browser-Größen-Cache – kein Re-Scan beim Zurücknavigieren
- Stack-basierter `IO.Directory`-Scan ersetzt `Get-ChildItem -Recurse`

### v1.2.0 — 12.03.2026
- Breadcrumb-Navigation im Datei-Browser
- Leere-Ordner-Finder als eigener Prozess mit Fortschrittsbalken

### v1.1.5 — 12.03.2026
- Asynchrone Ordnergrößen-Berechnung im Browser
- Sortierung per Spaltenklick mit Richtungspfeil
- Duplikat-Finder mit MD5-Hash, Gruppierung, Verschwendungsanzeige

### v1.1.3 — 25.02.2026
- Laufwerksauslastung in Echtzeit-Statusleiste
- Papierkorb- und Temp-Anzeige mit Leeren-Button
- Changelog-Fenster

### v1.0.0 — 24.02.2026
- Initiale Version

---

## Credits

Die Idee, die Anforderungen und die Richtung dieses Projekts stammen von **Jan Erik Mueller**.  
Der gesamte Quellcode – jede Zeile PowerShell, die WPF-GUI, die Scan-Engine, alle Dialoge und Tools – wurde von **[Claude](https://claude.ai)** geschrieben, einem KI-Assistenten von [Anthropic](https://www.anthropic.com).

Dieses Projekt ist ein Beispiel für Mensch-KI-Kollaboration: ein Mensch mit einer Vision, und eine KI die sie umsetzt.

---

## Lizenz

MIT – siehe [LICENSE](LICENSE)
