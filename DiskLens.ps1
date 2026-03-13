#Requires -Version 5.1
<#
.SYNOPSIS
    Disk Lens - WPF GUI Tool
.DESCRIPTION
    Analysiert Ordnergroessen auf Windows-Systemen mit grafischer Oberflaeche.
    Paralleler Scan, Live-Updates, Pfad-History, integrierter Datei-Browser.
.NOTES
    Ausfuehren: powershell -ExecutionPolicy Bypass -File DiskLens.ps1
#>
param(
    [string]$StartLang = ""
)

# ===== Version & Changelog =====
$script:AppVersion = "1.2.3"
$script:AppName    = "Disk Lens"
$script:ChangelogDE = @(
    [PSCustomObject]@{ Version="1.2.3"; Datum="13.03.2026"; Aenderungen=@(
        "Sprachauswahl beim Start: Englisch oder Deutsch (Dialogfenster vor Admin-Pruefung)"
        "Vollstaendige zweisprachige UI: alle Texte, Buttons, Dialoge, Statusmeldungen"
        "Duplikat-Finder und Leere-Ordner-Finder vollstaendig uebersetzt"
        "Umbenennung zu Disk Lens"
    )}
    [PSCustomObject]@{ Version="1.2.2"; Datum="13.03.2026"; Aenderungen=@(
        "Browser: Get-ChildItem durch IO.Directory-Methoden ersetzt (schneller, kein Pipeline-Overhead)"
        "Browser-Runspace: Stilles Bug mit Dispatcher.Invoke entfernt (Variablen-Scoping)"
        "Duplikat-Finder: COM-Objekt durch VisualBasic.FileIO.FileSystem ersetzt"
        "Leere-Ordner-Runspace: DirectoryInfo-Massenerstellung durch String-Liste ersetzt"
        "Toter Code entfernt: maxDepth, dupeGroups, duplizierte Formatierungslogik"
    )}
    [PSCustomObject]@{ Version="1.2.1"; Datum="13.03.2026"; Aenderungen=@(
        "Browser-Groessencache: Bereits berechnete Ordner werden nicht neu gescannt"
        "Scan-Performance: Stack-basierter IO.Directory-Scan statt Get-ChildItem -Recurse"
        "Get-TempSize: Stack-basierter IO.Directory-Scan"
        "New-Object FileInfo durch [System.IO.FileInfo]::new() ersetzt"
        "Breadcrumb: Toter Code entfernt"
    )}
    [PSCustomObject]@{ Version="1.2.0"; Datum="12.03.2026"; Aenderungen=@(
        "Breadcrumb-Navigation im Datei-Browser (klickbare Pfadsegmente)"
        "Leere-Ordner-Finder: rekursive Suche, Einzeln- und Alle-Loeschen"
        "Leere-Ordner-Finder: eigener Prozess mit Fortschrittsbalken"
        "Tiefste Ordner werden zuerst geprueft (korrekte Reihenfolge)"
    )}
    [PSCustomObject]@{ Version="1.1.5"; Datum="12.03.2026"; Aenderungen=@(
        "Datei-Browser zeigt Ordnergroessen asynchron an"
        "Groessenberechnung blockiert die UI nicht mehr"
        "Sortierung per Spaltenklick (Name, Typ, Groesse, Datum)"
        "Duplikat-Finder: eigener Prozess, MD5-Hash, Gruppen, Verschwendung"
        "Duplikat-Finder: Loeschen in Papierkorb oder endgueltig"
    )}
    [PSCustomObject]@{ Version="1.1.4"; Datum="25.02.2026"; Aenderungen=@(
        "Format-FileSize vereinheitlicht"
        "TrimEnd-Bugfix bei Laufwerksanzeige"
        "Get-TempSize: Force-Flag fuer versteckte Dateien ergaenzt"
        "Verwaiste Variablen und Leerzeilen bereinigt"
    )}
    [PSCustomObject]@{ Version="1.1.3"; Datum="25.02.2026"; Aenderungen=@(
        "Changelog-Fenster per Button erreichbar"
        "Versionsnummer im Header sichtbar"
        "Laufwerksauslastung in Echtzeit-Statusleiste"
        "Papierkorb- und Temp-Anzeige mit Leeren-Funktion"
        "Kontextmenue: Endgueltig loeschen hinzugefuegt"
        "Laufwerksauswahl-Dialog repariert"
    )}
    [PSCustomObject]@{ Version="1.0.0"; Datum="24.02.2026"; Aenderungen=@(
        "Initiale Version"
        "WPF GUI mit dunklem Theme"
        "Paralleler Ordner-Scan mit Live-Updates"
        "Integrierter Datei-Browser mit Navigation"
        "Baumansicht der Scan-Ergebnisse"
        "Kontextmenue: Oeffnen, Umbenennen, Kopieren, Ausschneiden, Einfuegen, Loeschen"
        "Kein-Zugriff-Erkennung mit roter Markierung"
        "Pfad-History, Fensterposition gespeichert"
        "Admin-Pruefung beim Start, Laufwerksauswahl"
    )}
)
$script:ChangelogEN = @(
    [PSCustomObject]@{ Version="1.2.3"; Datum="2026-03-13"; Aenderungen=@(
        "Language selection at startup: English or German (dialog before admin check)"
        "Fully bilingual UI: all texts, buttons, dialogs, status messages"
        "Duplicate finder and empty folder finder fully translated"
        "Renamed to Disk Lens"
    )}
    [PSCustomObject]@{ Version="1.2.2"; Datum="2026-03-13"; Aenderungen=@(
        "Browser: Replaced Get-ChildItem with IO.Directory methods (faster, no pipeline overhead)"
        "Browser runspace: Fixed silent bug with Dispatcher.Invoke (variable scoping)"
        "Duplicate finder: Replaced COM object with VisualBasic.FileIO.FileSystem"
        "Empty folder runspace: Replaced mass DirectoryInfo allocation with string list"
        "Dead code removed: maxDepth, dupeGroups, duplicated formatting logic"
    )}
    [PSCustomObject]@{ Version="1.2.1"; Datum="2026-03-13"; Aenderungen=@(
        "Browser size cache: already calculated folders are not re-scanned"
        "Scan performance: Stack-based IO.Directory scan instead of Get-ChildItem -Recurse"
        "Get-TempSize: Stack-based IO.Directory scan"
        "Replaced New-Object FileInfo with [System.IO.FileInfo]::new()"
        "Breadcrumb: Removed dead code"
    )}
    [PSCustomObject]@{ Version="1.2.0"; Datum="2026-03-12"; Aenderungen=@(
        "Breadcrumb navigation in file browser (clickable path segments)"
        "Empty folder finder: recursive search, delete individually or all at once"
        "Empty folder finder: separate process with progress bar"
        "Deepest folders are checked first (correct deletion order)"
    )}
    [PSCustomObject]@{ Version="1.1.5"; Datum="2026-03-12"; Aenderungen=@(
        "File browser shows folder sizes asynchronously"
        "Size calculation no longer blocks the UI"
        "Sort by column click (Name, Type, Size, Date)"
        "Duplicate finder: separate process, MD5 hash, groups, wasted space"
        "Duplicate finder: delete to Recycle Bin or permanently"
    )}
    [PSCustomObject]@{ Version="1.1.4"; Datum="2026-02-25"; Aenderungen=@(
        "Format-FileSize unified"
        "TrimEnd bugfix in drive status bar"
        "Get-TempSize: added Force flag for hidden files"
        "Cleaned up orphaned variables and blank lines"
    )}
    [PSCustomObject]@{ Version="1.1.3"; Datum="2026-02-25"; Aenderungen=@(
        "Changelog window accessible via button"
        "Version number visible in header"
        "Drive usage in real-time status bar"
        "Recycle Bin and Temp display with empty button"
        "Context menu: added permanent delete"
        "Drive selection dialog fixed"
    )}
    [PSCustomObject]@{ Version="1.0.0"; Datum="2026-02-24"; Aenderungen=@(
        "Initial release"
        "WPF GUI with dark theme"
        "Parallel folder scan with live updates"
        "Integrated file browser with navigation"
        "Tree view of scan results"
        "Context menu: Open, Rename, Copy, Cut, Paste, Delete"
        "No-access detection with red highlight"
        "Path history and window position saved"
        "Admin check at startup, drive selection"
    )}
)

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ===== Sprachdialog / Language Dialog (Windows Forms) =====
$script:Lang = "DE"
if ($StartLang -eq "EN" -or $StartLang -eq "DE") {
    # Via Argument übergeben (nach Admin-Neustart) – kein Dialog
    $script:Lang = $StartLang
} else {
    Add-Type -AssemblyName System.Windows.Forms
    $langForm                  = [System.Windows.Forms.Form]::new()
    $langForm.Text             = "Language / Sprache"
    $langForm.Size             = [System.Drawing.Size]::new(380, 160)
    $langForm.StartPosition    = "CenterScreen"
    $langForm.FormBorderStyle  = "FixedDialog"
    $langForm.MaximizeBox      = $false
    $langForm.MinimizeBox      = $false
    $langForm.BackColor        = [System.Drawing.ColorTranslator]::FromHtml("#1E1E2E")

    $lbl                       = [System.Windows.Forms.Label]::new()
    $lbl.Text                  = "Please select your language / Bitte Sprache waehlen"
    $lbl.ForeColor             = [System.Drawing.ColorTranslator]::FromHtml("#9CA3AF")
    $lbl.Font                  = [System.Drawing.Font]::new("Segoe UI", 10)
    $lbl.AutoSize              = $false
    $lbl.Size                  = [System.Drawing.Size]::new(340, 30)
    $lbl.Location              = [System.Drawing.Point]::new(16, 14)
    $lbl.TextAlign             = "MiddleCenter"

    $btnEN                     = [System.Windows.Forms.Button]::new()
    $btnEN.Text                = "EN  English"
    $btnEN.Size                = [System.Drawing.Size]::new(158, 44)
    $btnEN.Location            = [System.Drawing.Point]::new(16, 56)
    $btnEN.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#1D4ED8")
    $btnEN.ForeColor           = [System.Drawing.Color]::White
    $btnEN.FlatStyle           = "Flat"
    $btnEN.Font                = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $btnEN.Add_Click({ $script:Lang = "EN"; $langForm.Close() })

    $btnDE                     = [System.Windows.Forms.Button]::new()
    $btnDE.Text                = "DE  Deutsch"
    $btnDE.Size                = [System.Drawing.Size]::new(158, 44)
    $btnDE.Location            = [System.Drawing.Point]::new(190, 56)
    $btnDE.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#7C3AED")
    $btnDE.ForeColor           = [System.Drawing.Color]::White
    $btnDE.FlatStyle           = "Flat"
    $btnDE.Font                = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $btnDE.Add_Click({ $script:Lang = "DE"; $langForm.Close() })

    $langForm.Controls.AddRange(@($lbl, $btnEN, $btnDE))
    $langForm.ShowDialog() | Out-Null
    $langForm.Dispose()
}

# ===== Sprachtexte / Language Strings =====
$script:Strings = @{
    DE = @{
        AdminTitle          = "Administratorrechte empfohlen"
        AdminWarning        = "⚠  Kein Administratorzugriff"
        AdminText1          = "Das Script laeuft ohne Administratorrechte. Manche Systemordner koennen nicht gelesen werden."
        AdminText2          = "Moechtest du das Script als Administrator neu starten?"
        AdminYes            = "Als Admin starten"
        AdminNo             = "Trotzdem fortfahren"
        DriveTitle          = "Laufwerk auswaehlen"
        DriveHeader         = "Laufwerk auswaehlen"
        DriveSubtitle       = "Welches Laufwerk soll analysiert werden?"
        DriveOk             = "Weiter"
        DriveCancel         = "Abbrechen"
        DriveNoName         = "Kein Name"
        DriveFree           = "frei"
        AppSubtitle         = "Ordnergroessen analysieren und visualisieren"
        BtnBrowse           = "Durchsuchen"
        BtnScan             = "▶  Analyse starten"
        BtnCancel           = "⏹  Abbrechen"
        BtnExplorer         = "Im Explorer oeffnen"
        BtnDupes            = "🔍  Duplikate"
        BtnEmpty            = "🗁  Leere Ordner"
        BtnChangelog        = "Changelog"
        BtnSwitchLang       = "EN"
        TooltipSwitchLang   = "Switch to English"
        TooltipPath         = "Pfad aus History auswaehlen"
        TooltipExplorer     = "Ausgewaehlten Ordner im Explorer oeffnen"
        TooltipDupes        = "Doppelte Dateien finden und loeschen"
        TooltipEmpty        = "Leere Ordner finden und loeschen"
        ColPath             = "Pfad"
        ColSize             = "Groesse"
        ColFiles            = "Dateien"
        ColShare            = "Anteil"
        ColSizeClass        = "Groessenklasse"
        ColName             = "Name"
        ColType             = "Typ"
        ColDate             = "Datum"
        SizeVeryLarge       = "Sehr gross"
        SizeLarge           = "Gross"
        SizeMedium          = "Mittel"
        SizeSmall           = "Klein"
        SizeVerySmall       = "Sehr klein"
        SortName            = "Name"
        SortType            = "Typ"
        SortSize            = "Groesse"
        SortDate            = "Datum"
        CtxOpen             = "📂  Oeffnen"
        CtxOpenExplorer     = "🗂  Im Explorer anzeigen"
        CtxRename           = "✏  Umbenennen"
        CtxNewFolder        = "📁  Neuer Ordner"
        CtxCopy             = "📋  Kopieren"
        CtxCut              = "✂  Ausschneiden"
        CtxPaste            = "📌  Einfuegen"
        CtxCopyPath         = "🔗  Pfad kopieren"
        CtxDelete           = "🗑  Loeschen"
        CtxDeletePerm       = "⚠  Endgueltig loeschen"
        StatusReady         = "Bereit. Pfad auswaehlen und Analyse starten."
        TrashLabel          = "Papierkorb"
        TrashEmpty          = "Leer"
        BtnEmptyTrash       = "Leeren"
        TempLabel           = "Temp"
        BtnCleanTemp        = "Leeren"
        DriveStatusFree     = "frei"
        StatusScanning      = "Analysiere ..."
        StatusScanFolder    = "Scanne: "
        StatusCancelling    = "Abbruch wird durchgefuehrt ..."
        StatusDone          = "Fertig. {0} Ordner analysiert"
        StatusCancelled     = "Abgebrochen. {0} Ordner gefunden (unvollstaendig)"
        StatusNoAccess      = "  |  {0} ohne Zugriff"
        SummaryText         = "Gesamt: {0}  |  {1} Dateien"
        ProgressCancelled   = "Abgebrochen"
        BrowseDesc          = "Startordner auswaehlen"
        PathNotFound        = "Der angegebene Pfad existiert nicht oder ist nicht erreichbar:`n{0}"
        PathNotFoundTitle   = "Pfad nicht gefunden"
        NoAccess            = "Kein Zugriff"
        BrowserDirLabel     = "[DIR]"
        BrowserFileLabel    = "[FILE]"
        BtnBrowserUp        = "↑ Oben"
        StatusCopied        = "Kopiert: {0}"
        StatusCut           = "Ausgeschnitten: {0}"
        StatusPasted        = "Eingefuegt: {0}"
        StatusRenamed       = "Umbenannt: {0} -> {1}"
        StatusDeleted       = "Geloescht: {0}"
        StatusDeletedPerm   = "Endgueltig geloescht: {0}"
        StatusFolderCreated = "Ordner erstellt: {0}"
        RenamePrompt        = "Neuen Namen eingeben:"
        RenameTitle         = "Umbenennen"
        NewFolderPrompt     = "Name des neuen Ordners:"
        NewFolderTitle      = "Neuer Ordner"
        NewFolderDefault    = "Neuer Ordner"
        DeleteConfirmDir    = "Ordner wirklich loeschen?``n``n{0}"
        DeleteConfirmFile   = "Datei wirklich loeschen?``n``n{0}"
        DeleteConfirmTitle  = "Loeschen bestaetigen"
        DeletePermConfirm   = "ACHTUNG: {0} wird ENDGUELTIG geloescht und kann nicht wiederhergestellt werden!``n``n{1}``n``nWirklich fortfahren?"
        DeletePermTitle     = $L.DupeCtxPermDelete
        WordFolder          = "Ordner"
        WordFile            = "Datei"
        ErrPaste            = "Fehler beim Einfuegen:``n{0}"
        ErrRename           = "Fehler beim Umbenennen:``n{0}"
        ErrCreate           = "Fehler beim Erstellen:``n{0}"
        ErrDelete           = "Fehler beim Loeschen:``n{0}"
        ErrTitle            = "Fehler"
        TrashConfirm        = "Papierkorb wirklich leeren?"
        TrashConfirmTitle   = "Papierkorb leeren"
        StatusTrashEmptied  = "Papierkorb geleert."
        TempConfirmTitle    = "Temp leeren"
        TempConfirmText     = "Temp-Ordner wirklich leeren?``nGesamtgroesse: {0}``n{1}"
        TempNotFound        = "  (nicht vorhanden)"
        TempElements        = " Elemente"
        StatusTempEmptied   = "Temp geleert: {0} Elemente{1}."
        TempFailSuffix      = ", {0} nicht loeschbar"
        TreeFiles           = " Dateien"
        ChangelogTitle      = "Changelog"
        ChangelogSubtitle   = "Versionshistorie"
        ChangelogClose      = "Schliessen"
        # Duplikat-Finder
        DupeTitle           = "Duplikat-Finder"
        DupeHeader          = "Doppelte Dateien finden"
        DupeSubtitle1       = "Findet identische Dateien anhand von MD5-Hash."
        DupeSubtitle2       = "Hinweis: Nur Dateien mit gleicher Groesse werden verglichen."
        BtnScanDupe         = "🔍  Suchen"
        DupeColName         = "Dateiname"
        DupeColDate         = "Geaendert"
        DupeColGroup        = "Gruppe"
        DupeGroupFiles      = "Dateien"
        DupeStatusReady     = "Pfad auswaehlen und Suche starten."
        DupeDeleteSelected  = "🗑  Ausgewaehlt loeschen"
        DupeCtxTrash        = "🗑  In Papierkorb"
        DupeCtxPermDelete   = "Endgueltig loeschen"
        DupeDeletePermMsg   = "ENDGUELTIG loeschen: {0} Datei(en). Wirklich fortfahren?"
        DupeDeleteTrashMsg  = "{0} Datei(en) in Papierkorb verschieben?"
        DupeConfirmTitle    = "Loeschen bestaetigen"
        DupeScanFiles       = "Dateien einlesen..."
        DupeFilesFound      = "Dateien gefunden..."
        DupeCancelled       = "Abgebrochen."
        DupeStartSearch     = "Dateien - starte Hash-Vergleich..."
        DupeQuickHash       = "Schnell-Hash"
        DupeCandidates      = "Kandidaten"
        DupeFullHash        = "Voll-Hash"
        DupeHits            = "Treffer"
        DupeGroup           = "Gruppe"
        DupeSummary         = "{0} Duplikat-Gruppen gefunden."
        DupeNoneFound       = "Keine Duplikate gefunden."
        DupeWasted          = "Verschwendet"
        DupeBrowseDesc      = "Ordner fuer Duplikat-Suche auswaehlen"
        DupeInvalidPath     = "Bitte gueltigen Pfad eingeben."
        # Leere-Ordner-Finder
        EmptyTitle          = "Leere-Ordner-Finder"
        EmptyHeader         = "Leere Ordner"
        EmptySubtitle       = "Findet rekursiv alle leeren Ordner (keine Dateien, keine Unterordner)."
        EmptyBtnScan        = "▶  Scan starten"
        EmptyBtnCancel      = "⏹  Abbrechen"
        EmptyBtnBrowse      = "Durchsuchen"
        EmptyBtnDeleteAll   = "🗑  Alle loeschen"
        EmptyBtnDeleteSel   = "Ausgewaehlte loeschen"
        EmptyColPath        = "Pfad"
        EmptyColDate        = "Geaendert"
        EmptyStatusReady    = "Bereit."
        EmptyCtxExplorer    = "🗂  Im Explorer anzeigen"
        EmptyCtxCopyPath    = "📋  Pfad kopieren"
        EmptyCtxDelete      = "🗑  Loeschen"
        EmptyDeleteSelMsg   = "Loeschen?``n``n{0} Ordner"
        EmptyDeleteAllMsg   = "ALLE {0} leeren Ordner loeschen?"
        EmptyConfirmTitle   = "Bestaetigen"
        EmptyFound          = "{0} leere Ordner gefunden"
        EmptyAllDeleted     = "Alle geloescht."
        EmptySearching      = "Suche laeuft..."
        EmptyReadAll        = "Alle Ordner einlesen..."
        EmptyFoundN         = "{0} Ordner gefunden..."
        EmptyAborted        = "Abgebrochen."
        EmptyChecking       = "{0} Ordner - pruefe auf leere..."
        EmptyCheckProgress  = "Pruefe: {0} / {1}..."
        EmptyNoneFound      = "Keine leeren Ordner gefunden."
        EmptyInvalidPath    = "Bitte gueltigen Pfad eingeben."
    }
    EN = @{
        AdminTitle          = "Administrator rights recommended"
        AdminWarning        = "⚠  No administrator access"
        AdminText1          = "The script is running without administrator rights. Some system folders cannot be read."
        AdminText2          = "Would you like to restart the script as administrator?"
        AdminYes            = "Run as Admin"
        AdminNo             = "Continue anyway"
        DriveTitle          = "Select drive"
        DriveHeader         = "Select drive"
        DriveSubtitle       = "Which drive should be analyzed?"
        DriveOk             = "Continue"
        DriveCancel         = "Cancel"
        DriveNoName         = "No name"
        DriveFree           = "free"
        AppSubtitle         = "Analyze and visualize folder sizes"
        BtnBrowse           = "Browse"
        BtnScan             = "▶  Start analysis"
        BtnCancel           = "⏹  Cancel"
        BtnExplorer         = "Open in Explorer"
        BtnDupes            = "🔍  Duplicates"
        BtnEmpty            = "🗁  Empty folders"
        BtnChangelog        = "Changelog"
        BtnSwitchLang       = "DE"
        TooltipSwitchLang   = "Auf Deutsch wechseln"
        TooltipPath         = "Select path from history"
        TooltipExplorer     = "Open selected folder in Explorer"
        TooltipDupes        = "Find and delete duplicate files"
        TooltipEmpty        = "Find and delete empty folders"
        ColPath             = "Path"
        ColSize             = "Size"
        ColFiles            = "Files"
        ColShare            = "Share"
        ColSizeClass        = "Size class"
        ColName             = "Name"
        ColType             = "Type"
        ColDate             = "Date"
        SizeVeryLarge       = "Very large"
        SizeLarge           = "Large"
        SizeMedium          = "Medium"
        SizeSmall           = "Small"
        SizeVerySmall       = "Very small"
        SortName            = "Name"
        SortType            = "Type"
        SortSize            = "Size"
        SortDate            = "Date"
        CtxOpen             = "📂  Open"
        CtxOpenExplorer     = "🗂  Show in Explorer"
        CtxRename           = "✏  Rename"
        CtxNewFolder        = "📁  New folder"
        CtxCopy             = "📋  Copy"
        CtxCut              = "✂  Cut"
        CtxPaste            = "📌  Paste"
        CtxCopyPath         = "🔗  Copy path"
        CtxDelete           = "🗑  Delete"
        CtxDeletePerm       = "⚠  Delete permanently"
        StatusReady         = "Ready. Select path and start analysis."
        TrashLabel          = "Recycle Bin"
        TrashEmpty          = "Empty"
        BtnEmptyTrash       = "Empty"
        TempLabel           = "Temp"
        BtnCleanTemp        = "Clean"
        DriveStatusFree     = "free"
        StatusScanning      = "Analyzing ..."
        StatusScanFolder    = "Scanning: "
        StatusCancelling    = "Cancelling ..."
        StatusDone          = "Done. {0} folders analyzed"
        StatusCancelled     = "Cancelled. {0} folders found (incomplete)"
        StatusNoAccess      = "  |  {0} without access"
        SummaryText         = "Total: {0}  |  {1} files"
        ProgressCancelled   = "Cancelled"
        BrowseDesc          = "Select start folder"
        PathNotFound        = "The specified path does not exist or is not accessible:``n{0}"
        PathNotFoundTitle   = "Path not found"
        NoAccess            = "No access"
        BrowserDirLabel     = "[DIR]"
        BrowserFileLabel    = "[FILE]"
        BtnBrowserUp        = "↑ Up"
        StatusCopied        = "Copied: {0}"
        StatusCut           = "Cut: {0}"
        StatusPasted        = "Pasted: {0}"
        StatusRenamed       = "Renamed: {0} -> {1}"
        StatusDeleted       = "Deleted: {0}"
        StatusDeletedPerm   = "Permanently deleted: {0}"
        StatusFolderCreated = "Folder created: {0}"
        RenamePrompt        = "Enter new name:"
        RenameTitle         = "Rename"
        NewFolderPrompt     = "Name of the new folder:"
        NewFolderTitle      = "New folder"
        NewFolderDefault    = "New folder"
        DeleteConfirmDir    = "Really delete folder?``n``n{0}"
        DeleteConfirmFile   = "Really delete file?``n``n{0}"
        DeleteConfirmTitle  = "Confirm deletion"
        DeletePermConfirm   = "WARNING: {0} will be PERMANENTLY deleted and cannot be restored!``n``n{1}``n``nContinue?"
        DeletePermTitle     = "Delete permanently"
        WordFolder          = "Folder"
        WordFile            = "File"
        ErrPaste            = "Error pasting:``n{0}"
        ErrRename           = "Error renaming:``n{0}"
        ErrCreate           = "Error creating:``n{0}"
        ErrDelete           = "Error deleting:``n{0}"
        ErrTitle            = "Error"
        TrashConfirm        = "Really empty Recycle Bin?"
        TrashConfirmTitle   = "Empty Recycle Bin"
        StatusTrashEmptied  = "Recycle Bin emptied."
        TempConfirmTitle    = "Clean Temp"
        TempConfirmText     = "Really clean temp folders?``nTotal size: {0}``n{1}"
        TempNotFound        = "  (not found)"
        TempElements        = " items"
        StatusTempEmptied   = "Temp cleaned: {0} items{1}."
        TempFailSuffix      = ", {0} could not be deleted"
        TreeFiles           = " files"
        ChangelogTitle      = "Changelog"
        ChangelogSubtitle   = "Version history"
        ChangelogClose      = "Close"
        # Duplicate Finder
        DupeTitle           = "Duplicate Finder"
        DupeHeader          = "Find duplicate files"
        DupeSubtitle1       = "Finds identical files using MD5 hash."
        DupeSubtitle2       = "Note: Only files with the same size are compared."
        BtnScanDupe         = "🔍  Search"
        DupeColName         = "Filename"
        DupeColDate         = "Modified"
        DupeColGroup        = "Group"
        DupeGroupFiles      = "files"
        DupeStatusReady     = "Select path and start search."
        DupeDeleteSelected  = "🗑  Delete selected"
        DupeCtxTrash        = "🗑  Move to Recycle Bin"
        DupeCtxPermDelete   = "Delete permanently"
        DupeDeletePermMsg   = "PERMANENTLY delete: {0} file(s). Are you sure?"
        DupeDeleteTrashMsg  = "Move {0} file(s) to Recycle Bin?"
        DupeConfirmTitle    = "Confirm deletion"
        DupeScanFiles       = "Reading files..."
        DupeFilesFound      = "files found..."
        DupeCancelled       = "Cancelled."
        DupeStartSearch     = "files - starting hash comparison..."
        DupeQuickHash       = "Quick hash"
        DupeCandidates      = "candidates"
        DupeFullHash        = "Full hash"
        DupeHits            = "hits"
        DupeGroup           = "Group"
        DupeSummary         = "{0} duplicate groups found."
        DupeNoneFound       = "No duplicates found."
        DupeWasted          = "Wasted"
        DupeBrowseDesc      = "Select folder for duplicate search"
        DupeInvalidPath     = "Please enter a valid path."
        # Empty Folder Finder
        EmptyTitle          = "Empty Folder Finder"
        EmptyHeader         = "Empty folders"
        EmptySubtitle       = "Recursively finds all empty folders (no files, no subfolders)."
        EmptyBtnScan        = "▶  Start scan"
        EmptyBtnCancel      = "⏹  Cancel"
        EmptyBtnBrowse      = "Browse"
        EmptyBtnDeleteAll   = "🗑  Delete all"
        EmptyBtnDeleteSel   = "Delete selected"
        EmptyColPath        = "Path"
        EmptyColDate        = "Modified"
        EmptyStatusReady    = "Ready."
        EmptyCtxExplorer    = "🗂  Show in Explorer"
        EmptyCtxCopyPath    = "📋  Copy path"
        EmptyCtxDelete      = "🗑  Delete"
        EmptyDeleteSelMsg   = "Delete?``n``n{0} folder(s)"
        EmptyDeleteAllMsg   = "Delete ALL {0} empty folders?"
        EmptyConfirmTitle   = "Confirm"
        EmptyFound          = "{0} empty folders found"
        EmptyAllDeleted     = "All deleted."
        EmptySearching      = "Searching..."
        EmptyReadAll        = "Reading all folders..."
        EmptyFoundN         = "{0} folders found..."
        EmptyAborted        = "Cancelled."
        EmptyChecking       = "{0} folders - checking for empty..."
        EmptyCheckProgress  = "Checking: {0} / {1}..."
        EmptyNoneFound      = "No empty folders found."
        EmptyInvalidPath    = "Please enter a valid path."
    }
}
$L = $script:Strings[$script:Lang]

# BrowserItem mit INotifyPropertyChanged damit WPF Aenderungen (z.B. Groesse) live anzeigt
Add-Type -ReferencedAssemblies PresentationFramework,PresentationCore,WindowsBase -TypeDefinition @"
using System;
using System.ComponentModel;
public class BrowserItem : INotifyPropertyChanged {
    public event PropertyChangedEventHandler PropertyChanged;
    private void N(string p) { if (PropertyChanged != null) PropertyChanged(this, new PropertyChangedEventArgs(p)); }

    private string _groesse;
    private long   _groesseBytes;
    public string Name         { get; set; }
    public string Typ          { get; set; }
    public string Groesse      { get { return _groesse; }      set { _groesse = value;      N("Groesse");      } }
    public long   GroesseBytes { get { return _groesseBytes; } set { _groesseBytes = value; N("GroesseBytes"); } }
    public string Datum        { get; set; }
    public string Hinweis      { get; set; }
    public string Farbe        { get; set; }
    public string FullPath     { get; set; }
    public bool   IsDir        { get; set; }
    public bool   HasAccess    { get; set; }
}
"@

# ===== Einstellungen / Persistenz =====
$script:ConfigPath = "$env:APPDATA\DiskLens\config.xml"
$script:Config = [PSCustomObject]@{
    PathHistory    = [System.Collections.Generic.List[string]]::new()
    WindowLeft     = [double]100
    WindowTop      = [double]100
    WindowWidth    = [double]1050
    WindowHeight   = [double]700
}

function Save-Config {
    try {
        $dir = Split-Path $script:ConfigPath
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $script:Config | Export-Clixml -Path $script:ConfigPath -Force
    } catch {}
}

function Load-Config {
    try {
        if (Test-Path $script:ConfigPath) {
            $loaded = Import-Clixml -Path $script:ConfigPath
            if ($loaded.PathHistory)  { $script:Config.PathHistory  = $loaded.PathHistory }
            if ($loaded.WindowLeft)   { $script:Config.WindowLeft   = $loaded.WindowLeft }
            if ($loaded.WindowTop)    { $script:Config.WindowTop    = $loaded.WindowTop }
            if ($loaded.WindowWidth)  { $script:Config.WindowWidth  = $loaded.WindowWidth }
            if ($loaded.WindowHeight) { $script:Config.WindowHeight = $loaded.WindowHeight }
        }
    } catch {}
}

function Add-PathHistory {
    param([string]$Path)
    $script:Config.PathHistory.Remove($Path) | Out-Null
    $script:Config.PathHistory.Insert(0, $Path)
    while ($script:Config.PathHistory.Count -gt 10) {
        $script:Config.PathHistory.RemoveAt($script:Config.PathHistory.Count - 1)
    }
}

Load-Config

# ===== Admin-Pruefung =====
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    [xml]$AdminXAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$($L.AdminTitle)" Height="240" Width="440"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize" Background="#1E1E2E">
    <Grid Margin="24">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBlock Grid.Row="0" Text="$($L.AdminWarning)"
                   FontSize="17" FontWeight="Bold" Foreground="#FBBF24" Margin="0,0,0,10"/>
        <TextBlock Grid.Row="1" TextWrapping="Wrap" Foreground="#E2E8F0" FontSize="13" Margin="0,0,0,6"
                   Text="$($L.AdminText1)"/>
        <TextBlock Grid.Row="2" TextWrapping="Wrap" Foreground="#9CA3AF" FontSize="12"
                   Text="$($L.AdminText2)"/>
        <Grid Grid.Row="3" Margin="0,16,0,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <Button x:Name="btnAdminYes" Grid.Column="0" Content="$($L.AdminYes)" Margin="0,0,6,0"
                    Background="#D97706" Foreground="White" FontWeight="SemiBold" Padding="12,8" BorderThickness="0" Cursor="Hand">
                <Button.Template><ControlTemplate TargetType="Button">
                    <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#B45309"/></Trigger></ControlTemplate.Triggers>
                </ControlTemplate></Button.Template>
            </Button>
            <Button x:Name="btnAdminNo" Grid.Column="1" Content="$($L.AdminNo)" Margin="6,0,0,0"
                    Background="#374151" Foreground="White" FontWeight="SemiBold" Padding="12,8" BorderThickness="0" Cursor="Hand">
                <Button.Template><ControlTemplate TargetType="Button">
                    <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#4B5563"/></Trigger></ControlTemplate.Triggers>
                </ControlTemplate></Button.Template>
            </Button>
        </Grid>
    </Grid>
</Window>
"@
    $adminReader = [System.Xml.XmlNodeReader]::new($AdminXAML)
    $adminWindow = [Windows.Markup.XamlReader]::Load($adminReader)
    $adminWindow.FindName("btnAdminYes").Add_Click({ $adminWindow.DialogResult = $true })
    $adminWindow.FindName("btnAdminNo").Add_Click({ $adminWindow.DialogResult = $false })

    if ($adminWindow.ShowDialog() -eq $true) {
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -StartLang $script:Lang" -Verb RunAs
        exit
    }
}

# ===== Laufwerks-Auswahldialog =====
[xml]$DriveXAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$($L.DriveTitle)" Height="420" Width="480"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize" Background="#1E1E2E">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="$($L.DriveHeader)"
                   FontSize="18" FontWeight="Bold" Foreground="#A78BFA" Margin="0,0,0,4"/>
        <TextBlock Grid.Row="1" Text="$($L.DriveSubtitle)"
                   FontSize="12" Foreground="#6B7280" Margin="0,0,0,12"/>

        <ListBox x:Name="lstDrives" Grid.Row="2" Background="#2D2D3F" BorderBrush="#4B5563"
                 BorderThickness="1" Margin="0,0,0,12"
                 FontSize="13" FontFamily="Consolas"
                 ScrollViewer.HorizontalScrollBarVisibility="Disabled">
            <ListBox.ItemContainerStyle>
                <Style TargetType="ListBoxItem">
                    <Setter Property="Background" Value="Transparent"/>
                    <Setter Property="Foreground" Value="#E2E8F0"/>
                    <Setter Property="Padding" Value="10,8"/>
                    <Setter Property="Margin" Value="2"/>
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="ListBoxItem">
                                <Border Background="{TemplateBinding Background}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                                    <ContentPresenter/>
                                </Border>
                                <ControlTemplate.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#3D3D5C"/></Trigger>
                                    <Trigger Property="IsSelected" Value="True"><Setter Property="Background" Value="#7C3AED"/><Setter Property="Foreground" Value="White"/></Trigger>
                                </ControlTemplate.Triggers>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                </Style>
            </ListBox.ItemContainerStyle>
        </ListBox>

        <Grid Grid.Row="3">
            <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
            <Button x:Name="btnDriveOk" Grid.Column="0" Content="$($L.DriveOk)" Margin="0,0,6,0"
                    Background="#7C3AED" Foreground="White" FontWeight="SemiBold" Padding="12,8" BorderThickness="0" Cursor="Hand">
                <Button.Template><ControlTemplate TargetType="Button">
                    <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#6D28D9"/></Trigger></ControlTemplate.Triggers>
                </ControlTemplate></Button.Template>
            </Button>
            <Button x:Name="btnDriveCancel" Grid.Column="1" Content="$($L.DriveCancel)" Margin="6,0,0,0"
                    Background="#374151" Foreground="White" FontWeight="SemiBold" Padding="12,8" BorderThickness="0" Cursor="Hand">
                <Button.Template><ControlTemplate TargetType="Button">
                    <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#4B5563"/></Trigger></ControlTemplate.Triggers>
                </ControlTemplate></Button.Template>
            </Button>
        </Grid>
    </Grid>
</Window>
"@

$driveReader = [System.Xml.XmlNodeReader]::new($DriveXAML)
$driveWindow = [Windows.Markup.XamlReader]::Load($driveReader)
$lstDrives      = $driveWindow.FindName("lstDrives")
$btnDriveOk     = $driveWindow.FindName("btnDriveOk")
$btnDriveCancel = $driveWindow.FindName("btnDriveCancel")

$script:DriveMap = @{}
$drives = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.IsReady }
foreach ($drive in $drives) {
    $driveType = switch ($drive.DriveType) {
        "Fixed"     { "[HDD]" }
        "Removable" { "[USB]" }
        "Network"   { "[NET]" }
        "CDRom"     { "[CD] " }
        default     { "[?]  " }
    }
    $freeGB  = [math]::Round($drive.AvailableFreeSpace / 1GB, 1)
    $totalGB = [math]::Round($drive.TotalSize / 1GB, 1)
    $label   = if ($drive.VolumeLabel) { $drive.VolumeLabel } else { $L.DriveNoName }
    $displayText = "$driveType  $($drive.Name)  $label   ($freeGB GB frei / $totalGB GB)"
    $script:DriveMap[$displayText] = $drive.RootDirectory.FullName
    $lstDrives.Items.Add($displayText) | Out-Null
}
if ($lstDrives.Items.Count -gt 0) { $lstDrives.SelectedIndex = 0 }
$lstDrives.Add_MouseDoubleClick({ $driveWindow.DialogResult = $true })
$btnDriveOk.Add_Click({ if ($lstDrives.SelectedItem) { $driveWindow.DialogResult = $true } })
$btnDriveCancel.Add_Click({ $driveWindow.DialogResult = $false })

$driveResult = $driveWindow.ShowDialog()
$selectedDrivePath = "C:\"
if ($driveResult -eq $true -and $lstDrives.SelectedItem) {
    $selectedDrivePath = $script:DriveMap[$lstDrives.SelectedItem]
} elseif ($driveResult -ne $true) { exit }

# ===== HAUPT-XAML =====
[xml]$XAML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Disk Lens" Height="700" Width="1050"
    WindowStartupLocation="Manual"
    Background="#1E1E2E">

    <Window.Resources>
        <Style TargetType="Button" x:Key="Btn">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bd" Property="Opacity" Value="0.85"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="bd" Property="Background" Value="#4B5563"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ComboBox" x:Key="ModernComboBox">
            <Setter Property="Background" Value="#2D2D3F"/>
            <Setter Property="Foreground" Value="#E2E8F0"/>
            <Setter Property="BorderBrush" Value="#4B5563"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <ToggleButton Background="#2D2D3F" BorderBrush="#4B5563" BorderThickness="1"
                                          IsChecked="{Binding IsDropDownOpen, RelativeSource={RelativeSource TemplatedParent}, Mode=TwoWay}" Cursor="Hand">
                                <ToggleButton.Template>
                                    <ControlTemplate TargetType="ToggleButton">
                                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                                                BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="20"/>
                                                </Grid.ColumnDefinitions>
                                                <TextBlock Grid.Column="0"
                                                           Text="{Binding SelectionBoxItem, RelativeSource={RelativeSource AncestorType=ComboBox}}"
                                                           Foreground="#E2E8F0" FontSize="13" Margin="6,5,0,5" VerticalAlignment="Center"/>
                                                <TextBlock Grid.Column="1" Text="&#x25BE;" Foreground="#A78BFA"
                                                           HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <ControlTemplate.Triggers>
                                            <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#3D3D5C"/></Trigger>
                                        </ControlTemplate.Triggers>
                                    </ControlTemplate>
                                </ToggleButton.Template>
                            </ToggleButton>
                            <Popup IsOpen="{Binding IsDropDownOpen, RelativeSource={RelativeSource TemplatedParent}}"
                                   Placement="Bottom" AllowsTransparency="True">
                                <Border Background="#2D2D3F" BorderBrush="#7C3AED" BorderThickness="1" CornerRadius="4"
                                        MinWidth="{Binding ActualWidth, RelativeSource={RelativeSource AncestorType=ComboBox}}">
                                    <ScrollViewer MaxHeight="200"><ItemsPresenter/></ScrollViewer>
                                </Border>
                            </Popup>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Setter Property="ItemContainerStyle">
                <Setter.Value>
                    <Style TargetType="ComboBoxItem">
                        <Setter Property="Background" Value="#2D2D3F"/>
                        <Setter Property="Foreground" Value="#E2E8F0"/>
                        <Setter Property="Padding" Value="10,6"/>
                        <Setter Property="FontSize" Value="13"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="ComboBoxItem">
                                    <Border Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}">
                                        <ContentPresenter/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Background" Value="#4C1D95"/>
                                            <Setter Property="Foreground" Value="White"/>
                                        </Trigger>
                                        <Trigger Property="IsSelected" Value="True">
                                            <Setter Property="Background" Value="#7C3AED"/>
                                            <Setter Property="Foreground" Value="White"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="16">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Grid Grid.Row="0" Margin="0,0,0,14">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <StackPanel Grid.Column="0">
                <TextBlock Text="Disk Lens" FontSize="22" FontWeight="Bold" Foreground="#A78BFA"/>
                <TextBlock x:Name="lblSubtitle" Text="$($L.AppSubtitle)" FontSize="12" Foreground="#6B7280" Margin="0,3,0,0"/>
            </StackPanel>
            <Grid Grid.Column="1" HorizontalAlignment="Right" VerticalAlignment="Center">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>
                <TextBlock x:Name="lblVersion" Grid.Row="0" Text="" Foreground="#6B7280" FontSize="11"
                           HorizontalAlignment="Right" Margin="0,0,0,4"/>
                <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right">
                    <Button x:Name="btnSwitchLang" Content="$($L.BtnSwitchLang)"
                            Background="#1D4ED8" Foreground="White" FontWeight="SemiBold"
                            Padding="10,4" FontSize="11" BorderThickness="0" Cursor="Hand"
                            Margin="0,0,6,0" ToolTip="$($L.TooltipSwitchLang)">
                        <Button.Template>
                            <ControlTemplate TargetType="Button">
                                <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <ControlTemplate.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter TargetName="bd" Property="Opacity" Value="0.85"/>
                                    </Trigger>
                                </ControlTemplate.Triggers>
                            </ControlTemplate>
                        </Button.Template>
                    </Button>
                    <Button x:Name="btnChangelog" Content="$($L.BtnChangelog)"
                            Background="#374151" Foreground="White" FontWeight="SemiBold"
                            Padding="10,4" FontSize="11" BorderThickness="0" Cursor="Hand">
                        <Button.Template>
                            <ControlTemplate TargetType="Button">
                                <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <ControlTemplate.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter TargetName="bd" Property="Opacity" Value="0.85"/>
                                    </Trigger>
                                </ControlTemplate.Triggers>
                            </ControlTemplate>
                        </Button.Template>
                    </Button>
                </StackPanel>
            </Grid>
        </Grid>

        <!-- Pfad-Zeile -->
        <Grid Grid.Row="1" Margin="0,0,0,10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <ComboBox x:Name="cmbPath" Grid.Column="0"
                      Style="{StaticResource ModernComboBox}"
                      IsEditable="False"
                      ToolTip="$($L.TooltipPath)"/>

            <Button x:Name="btnBrowse" Grid.Column="1" Style="{StaticResource Btn}"
                    Content="$($L.BtnBrowse)" Margin="8,0,0,0" Background="#374151"/>

            <Button x:Name="btnScan" Grid.Column="2" Style="{StaticResource Btn}"
                    Content="$($L.BtnScan)" Margin="8,0,0,0" Background="#7C3AED"/>

            <Button x:Name="btnCancel" Grid.Column="3" Style="{StaticResource Btn}"
                    Content="$($L.BtnCancel)" Margin="8,0,0,0" Background="#991B1B" IsEnabled="False"/>

            <Button x:Name="btnOpenExplorer" Grid.Column="4" Style="{StaticResource Btn}"
                    Content="$($L.BtnExplorer)" Margin="8,0,0,0" Background="#1D4ED8" IsEnabled="False"
                    ToolTip="$($L.TooltipExplorer)"/>

            <Button x:Name="btnDupeFinder" Grid.Column="5" Style="{StaticResource Btn}"
                    Content="$($L.BtnDupes)" Margin="8,0,0,0" Background="#065F46"
                    ToolTip="$($L.TooltipDupes)"/>

            <Button x:Name="btnEmptyFolders" Grid.Column="6" Style="{StaticResource Btn}"
                    Content="$($L.BtnEmpty)" Margin="8,0,0,0" Background="#92400E"
                    ToolTip="$($L.TooltipEmpty)"/>
        </Grid>

        <!-- Inhaltsbereich: Links Ergebnisse, Rechts Browser -->
        <Grid Grid.Row="2">
            <Grid.RowDefinitions>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Grid Grid.Row="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" MinWidth="200"/>
                    <ColumnDefinition Width="5"/>
                    <ColumnDefinition Width="550" MinWidth="150" x:Name="colBrowser"/>
                </Grid.ColumnDefinitions>

                <!-- Linke Seite: Ergebnisliste / Baum -->
                <Grid Grid.Column="0">
                    <!-- Flache Liste -->
                    <DataGrid x:Name="dgResults"
                              Background="#2D2D3F" Foreground="#E2E8F0"
                              BorderBrush="#374151" BorderThickness="1"
                              GridLinesVisibility="Horizontal" HorizontalGridLinesBrush="#374151"
                              RowBackground="#2D2D3F" AlternatingRowBackground="#252535"
                              SelectionMode="Single" CanUserAddRows="False" CanUserDeleteRows="False"
                              AutoGenerateColumns="False" IsReadOnly="True" FontSize="13"
                              CanUserSortColumns="True">
                        <DataGrid.ColumnHeaderStyle>
                            <Style TargetType="DataGridColumnHeader">
                                <Setter Property="Background" Value="#1A1A2E"/>
                                <Setter Property="Foreground" Value="#A78BFA"/>
                                <Setter Property="FontWeight" Value="SemiBold"/>
                                <Setter Property="Padding" Value="10,8"/>
                                <Setter Property="BorderBrush" Value="#374151"/>
                                <Setter Property="BorderThickness" Value="0,0,1,1"/>
                                <Setter Property="Cursor" Value="Hand"/>
                            </Style>
                        </DataGrid.ColumnHeaderStyle>
                        <DataGrid.RowStyle>
                            <Style TargetType="DataGridRow">
                                <Setter Property="Foreground" Value="#E2E8F0"/>
                                <Style.Triggers>
                                    <Trigger Property="IsSelected" Value="True"><Setter Property="Background" Value="#4C1D95"/></Trigger>
                                    <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#3D3D5C"/></Trigger>
                                </Style.Triggers>
                            </Style>
                        </DataGrid.RowStyle>
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="#"       Binding="{Binding Rang}"      Width="45"  SortMemberPath="Rang"/>
                            <DataGridTextColumn Header="$($L.ColPath)"    Binding="{Binding Pfad}"       Width="*"   SortMemberPath="Pfad"/>
                            <DataGridTextColumn Header="$($L.ColSize)" Binding="{Binding GraesseFmt}" Width="110" SortMemberPath="Groesse"/>
                            <DataGridTextColumn Header="$($L.ColFiles)" Binding="{Binding Dateien}"    Width="80"  SortMemberPath="Dateien"/>
                            <DataGridTemplateColumn Header="$($L.ColShare)" Width="160" SortMemberPath="Anteil">
                                <DataGridTemplateColumn.CellTemplate>
                                    <DataTemplate>
                                        <Grid Margin="4,2">
                                            <ProgressBar Value="{Binding Anteil}" Maximum="100" Height="14"
                                                         Background="#374151" Foreground="#7C3AED" BorderThickness="0"/>
                                            <TextBlock Text="{Binding AnteilFmt}" HorizontalAlignment="Center"
                                                       VerticalAlignment="Center" FontSize="11" Foreground="White"/>
                                        </Grid>
                                    </DataTemplate>
                                </DataGridTemplateColumn.CellTemplate>
                            </DataGridTemplateColumn>
                            <DataGridTemplateColumn Header="$($L.ColSizeClass)" Width="100" SortMemberPath="Groesse">
                                <DataGridTemplateColumn.CellTemplate>
                                    <DataTemplate>
                                        <Border CornerRadius="4" Margin="4,2" Padding="6,2"
                                                Background="{Binding FarbHintergrund}">
                                            <TextBlock Text="{Binding FarbLabel}" Foreground="White"
                                                       FontSize="11" FontWeight="SemiBold"
                                                       HorizontalAlignment="Center"/>
                                        </Border>
                                    </DataTemplate>
                                </DataGridTemplateColumn.CellTemplate>
                            </DataGridTemplateColumn>
                        </DataGrid.Columns>
                    </DataGrid>

                    <!-- Baumansicht -->
                    <TreeView x:Name="tvResults" Visibility="Collapsed"
                              Background="#2D2D3F" BorderBrush="#374151" Foreground="#E2E8F0" FontSize="13">
                        <TreeView.ItemContainerStyle>
                            <Style TargetType="TreeViewItem">
                                <Setter Property="Foreground" Value="#E2E8F0"/>
                                <Setter Property="Padding" Value="4,3"/>
                                <Style.Triggers>
                                    <Trigger Property="IsSelected" Value="True"><Setter Property="Background" Value="#4C1D95"/></Trigger>
                                    <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#3D3D5C"/></Trigger>
                                </Style.Triggers>
                            </Style>
                        </TreeView.ItemContainerStyle>
                    </TreeView>
                </Grid>

                <!-- Splitter -->
                <GridSplitter Grid.Column="1" Width="5" HorizontalAlignment="Stretch"
                              Background="#374151" Cursor="SizeWE"/>

                <!-- Rechte Seite: Ordner-Browser -->
                <Grid Grid.Column="2">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- Browser-Header -->
                    <Border Grid.Row="0" Background="#1A1A2E" Padding="8,6" BorderBrush="#374151" BorderThickness="0,0,0,1">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Button x:Name="btnBrowserBack" Grid.Column="0" Content="&#x2190;" Style="{StaticResource Btn}"
                                    Background="#374151" Padding="8,4" FontSize="14" IsEnabled="False"/>
                            <Button x:Name="btnBrowserUp" Grid.Column="1" Content="$($L.BtnBrowserUp)" Style="{StaticResource Btn}"
                                    Background="#374151" Padding="8,4" Margin="4,0,0,0" IsEnabled="False"/>
                            <ScrollViewer Grid.Column="2" HorizontalScrollBarVisibility="Auto"
                                          VerticalScrollBarVisibility="Disabled"
                                          Margin="8,0,0,0" VerticalAlignment="Center">
                                <ItemsControl x:Name="breadcrumb">
                                    <ItemsControl.ItemsPanel>
                                        <ItemsPanelTemplate>
                                            <StackPanel Orientation="Horizontal"/>
                                        </ItemsPanelTemplate>
                                    </ItemsControl.ItemsPanel>
                                </ItemsControl>
                            </ScrollViewer>
                        </Grid>
                    </Border>

                    <!-- WPF Ordner-Browser (ListView) -->
                    <ListView x:Name="lvBrowser" Grid.Row="1"
                              Background="#2D2D3F" BorderThickness="0"
                              Foreground="#E2E8F0" FontSize="13"
                              ScrollViewer.HorizontalScrollBarVisibility="Disabled">
                        <ListView.View>
                            <GridView>
                                <GridView.ColumnHeaderContainerStyle>
                                    <Style TargetType="GridViewColumnHeader">
                                        <Setter Property="Background" Value="#1A1A2E"/>
                                        <Setter Property="Foreground" Value="#A78BFA"/>
                                        <Setter Property="FontWeight" Value="SemiBold"/>
                                        <Setter Property="Padding" Value="8,6"/>
                                        <Setter Property="BorderBrush" Value="#374151"/>
                                        <Setter Property="BorderThickness" Value="0,0,1,1"/>
                                    </Style>
                                </GridView.ColumnHeaderContainerStyle>
                                <GridViewColumn Header="$($L.ColName)"    Width="220" DisplayMemberBinding="{Binding Name}"/>
                                <GridViewColumn Header="$($L.ColType)"     Width="60"  DisplayMemberBinding="{Binding Typ}"/>
                                <GridViewColumn Header="$($L.ColSize)" Width="90"  DisplayMemberBinding="{Binding Groesse}"/>
                                <GridViewColumn Header="$($L.ColDate)"   Width="130" DisplayMemberBinding="{Binding Datum}"/>
                                <GridViewColumn Header=""        Width="100" DisplayMemberBinding="{Binding Hinweis}"/>
                            </GridView>
                        </ListView.View>
                        <ListView.ItemContainerStyle>
                            <Style TargetType="ListViewItem">
                                <Setter Property="Foreground" Value="{Binding Farbe}"/>
                                <Setter Property="Padding" Value="4,3"/>
                                <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
                                <Style.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter Property="Background" Value="#3D3D5C"/>
                                        <Setter Property="Foreground" Value="#FFFFFF"/>
                                    </Trigger>
                                    <Trigger Property="IsSelected" Value="True">
                                        <Setter Property="Background" Value="#4C1D95"/>
                                        <Setter Property="Foreground" Value="#FFFFFF"/>
                                    </Trigger>
                                </Style.Triggers>
                            </Style>
                        </ListView.ItemContainerStyle>
                        <ListView.ContextMenu>
                            <ContextMenu x:Name="ctxBrowser" Background="#2D2D3F" BorderBrush="#4B5563"
                                         Foreground="#E2E8F0" FontSize="13">
                                <MenuItem x:Name="ctxOpen"        Header="$($L.CtxOpen)"                    Background="#2D2D3F" Foreground="#E2E8F0"/>
                                <MenuItem x:Name="ctxOpenExplorer" Header="$($L.CtxOpenExplorer)"      Background="#2D2D3F" Foreground="#E2E8F0"/>
                                <Separator Background="#4B5563"/>
                                <MenuItem x:Name="ctxRename"      Header="$($L.CtxRename)"                  Background="#2D2D3F" Foreground="#E2E8F0"/>
                                <MenuItem x:Name="ctxNewFolder"   Header="$($L.CtxNewFolder)"              Background="#2D2D3F" Foreground="#E2E8F0"/>
                                <Separator Background="#4B5563"/>
                                <MenuItem x:Name="ctxCopy"        Header="$($L.CtxCopy)"                  Background="#2D2D3F" Foreground="#E2E8F0"/>
                                <MenuItem x:Name="ctxCut"         Header="$($L.CtxCut)"               Background="#2D2D3F" Foreground="#E2E8F0"/>
                                <MenuItem x:Name="ctxPaste"       Header="$($L.CtxPaste)"                 Background="#2D2D3F" Foreground="#E2E8F0"/>
                                <Separator Background="#4B5563"/>
                                <MenuItem x:Name="ctxCopyPath"    Header="$($L.CtxCopyPath)"             Background="#2D2D3F" Foreground="#E2E8F0"/>
                                <Separator Background="#4B5563"/>
                                <MenuItem x:Name="ctxDelete"       Header="$($L.CtxDelete)"                  Background="#2D2D3F" Foreground="#FF6B6B"/>
                                <MenuItem x:Name="ctxDeletePerm"   Header="$($L.CtxDeletePerm)"         Background="#2D2D3F" Foreground="#FF2222"/>
                            </ContextMenu>
                        </ListView.ContextMenu>
                    </ListView>
                </Grid>
            </Grid>

            <!-- Statusbar -->
            <Border Grid.Row="1" Background="#252535" Padding="10,6">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock x:Name="lblStatus" Text="$($L.StatusReady)"
                               Foreground="#6B7280" FontSize="12" VerticalAlignment="Center"/>
                    <TextBlock x:Name="lblSummary" Text="" Foreground="#A78BFA" FontSize="12"
                               Grid.Column="1" VerticalAlignment="Center" FontWeight="SemiBold"/>
                </Grid>
            </Border>
        </Grid>

        <!-- Fortschritt -->
        <Grid Grid.Row="3" Margin="0,8,0,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <ProgressBar x:Name="progressBar" Grid.Column="0" Height="14"
                         Background="#374151" Foreground="#7C3AED" BorderThickness="0" Value="0"/>
            <TextBlock x:Name="lblProgress" Grid.Column="1" Text="" Foreground="#A78BFA"
                       FontSize="12" FontWeight="SemiBold" VerticalAlignment="Center" Margin="10,0,0,0" MinWidth="90"/>
        </Grid>

        <!-- Untere Leiste: Laufwerksauslastung + Papierkorb + Temp -->
        <Grid Grid.Row="4" Background="#161622" Margin="0,6,0,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <StackPanel x:Name="pnlDriveStatus" Grid.Column="0"
                        Orientation="Horizontal" VerticalAlignment="Center" Margin="10,8,0,8"/>

            <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" Margin="0,6,10,6">
                <Border Background="#252535" CornerRadius="6" Padding="10,4" Margin="0,0,8,0">
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="[T]" Foreground="#F87171" FontWeight="Bold"
                                   FontSize="12" VerticalAlignment="Center" Margin="0,0,6,0"/>
                        <TextBlock x:Name="lblTrashSize" Text="$($L.TrashLabel): ..."
                                   Foreground="#E2E8F0" FontSize="12" VerticalAlignment="Center"/>
                        <Button x:Name="btnEmptyTrash" Content="$($L.BtnEmptyTrash)" Margin="8,0,0,0"
                                Background="#7F1D1D" Foreground="White" FontSize="11"
                                FontWeight="SemiBold" Padding="6,2" BorderThickness="0" Cursor="Hand"/>
                    </StackPanel>
                </Border>
                <Border Background="#252535" CornerRadius="6" Padding="10,4">
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="[TMP]" Foreground="#FBBF24" FontWeight="Bold"
                                   FontSize="12" VerticalAlignment="Center" Margin="0,0,6,0"/>
                        <TextBlock x:Name="lblTempSize" Text="$($L.TempLabel): ..."
                                   Foreground="#E2E8F0" FontSize="12" VerticalAlignment="Center"/>
                        <Button x:Name="btnCleanTemp" Content="$($L.BtnCleanTemp)" Margin="8,0,0,0"
                                Background="#78350F" Foreground="White" FontSize="11"
                                FontWeight="SemiBold" Padding="6,2" BorderThickness="0" Cursor="Hand"/>
                    </StackPanel>
                </Border>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@

# ===== Hilfsfunktionen =====
function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -ge 1TB) { return "{0:N2} TB" -f ($Bytes / 1TB) }
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}

function Get-SizeColor {
    param([long]$Bytes)
    if ($Bytes -ge 10GB) { return @{ Bg="#7F1D1D"; Label=$L.SizeVeryLarge } }
    if ($Bytes -ge 1GB)  { return @{ Bg="#92400E"; Label=$L.SizeLarge } }
    if ($Bytes -ge 100MB){ return @{ Bg="#1E3A5F"; Label=$L.SizeMedium } }
    if ($Bytes -ge 10MB) { return @{ Bg="#064E3B"; Label=$L.SizeSmall } }
    return @{ Bg="#1F2937"; Label=$L.SizeVerySmall }
}

# ===== GUI laden =====
$reader = [System.Xml.XmlNodeReader]::new($XAML)
$window = [Windows.Markup.XamlReader]::Load($reader)

$cmbPath        = $window.FindName("cmbPath")
$btnBrowse      = $window.FindName("btnBrowse")
$btnScan        = $window.FindName("btnScan")
$btnCancel      = $window.FindName("btnCancel")
$btnOpenExplorer= $window.FindName("btnOpenExplorer")
$btnDupeFinder  = $window.FindName("btnDupeFinder")
$btnEmptyFolders= $window.FindName("btnEmptyFolders")
$dgResults      = $window.FindName("dgResults")
$tvResults        = $window.FindName("tvResults")
$lvBrowser        = $window.FindName("lvBrowser")
$breadcrumb       = $window.FindName("breadcrumb")
$btnBrowserBack   = $window.FindName("btnBrowserBack")
$btnBrowserUp     = $window.FindName("btnBrowserUp")
$lblStatus        = $window.FindName("lblStatus")

$lblSummary     = $window.FindName("lblSummary")
$progressBar    = $window.FindName("progressBar")
$lblProgress    = $window.FindName("lblProgress")
$pnlDriveStatus = $window.FindName("pnlDriveStatus")
# Buttons/Labels in verschachtelten Containern werden im Loaded-Event per VisualTree verdrahtet

# Fensterpositon wiederherstellen
$window.Left   = $script:Config.WindowLeft
$window.Top    = $script:Config.WindowTop
$window.Width  = $script:Config.WindowWidth
$window.Height = $script:Config.WindowHeight

# Pfad-History befuellen
foreach ($h in $script:Config.PathHistory) {
    $cmbPath.Items.Add($h) | Out-Null
}
if (-not $script:Config.PathHistory.Contains($selectedDrivePath)) {
    $cmbPath.Items.Insert(0, $selectedDrivePath) | Out-Null
}
$cmbPath.SelectedIndex = 0
$cmbPath.Text = $cmbPath.Items[0]

# ===== Zustandsvariablen =====
$script:ScanResults     = $null
$script:CancelRequested = $false

# ===== Browser-Logik (nativer WPF ListView) =====
$script:BrowserHistory   = [System.Collections.Generic.Stack[string]]::new()
$script:BrowserCurrent  = ""
$script:BrowserSizeCache = [System.Collections.Concurrent.ConcurrentDictionary[string,long]]::new()

function Show-FolderInBrowser {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -ErrorAction SilentlyContinue)) { return }

    # Laufenden Größen-Runspace abbrechen
    if ($script:BrowserSharedState) {
        $script:BrowserSharedState["current"] = ""
    }

    # History
    if ($script:BrowserCurrent -and $script:BrowserCurrent -ne $Path) {
        $script:BrowserHistory.Push($script:BrowserCurrent)
        $btnBrowserBack.IsEnabled = $true
    }
    $script:BrowserCurrent    = $Path
    $parent = Split-Path $Path -Parent
    $btnBrowserUp.IsEnabled   = ($parent -and $parent -ne $Path)

    # Breadcrumb aufbauen
    $breadcrumb.Items.Clear()
    $parts = $Path.TrimEnd('\').Split('\')
    for ($i = 0; $i -lt $parts.Count; $i++) {
        $part = $parts[$i]
        if ($part -eq "") { continue }
        $fullSegment = if ($i -eq 0) { $parts[0] + "\" } else { ($parts[0..($i)] -join "\") }
        # Separator außer beim ersten
        if ($i -gt 0) {
            $sep = [System.Windows.Controls.TextBlock]::new()
            $sep.Text       = " › "
            $sep.Foreground = [System.Windows.Media.Brushes]::Gray
            $sep.FontSize   = 11
            $sep.VerticalAlignment = "Center"
            $breadcrumb.Items.Add($sep) | Out-Null
        }
        $btn = [System.Windows.Controls.Button]::new()
        $btn.Content    = $part
        $btn.FontSize   = 11
        $btn.Padding    = [System.Windows.Thickness]::new(3,1,3,1)
        $btn.Margin     = [System.Windows.Thickness]::new(0)
        $btn.Cursor     = [System.Windows.Input.Cursors]::Hand
        $btn.Background = [System.Windows.Media.Brushes]::Transparent
        $btn.BorderThickness = [System.Windows.Thickness]::new(0)
        if ($i -eq $parts.Count - 1) {
            $btn.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xa7,0x8b,0xfa))
            $btn.FontWeight = "SemiBold"
        } else {
            $btn.Foreground = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x9c,0xa3,0xaf))
        }
        $navPath = $fullSegment
        $btn.Add_Click({ Show-FolderInBrowser $navPath }.GetNewClosure())
        $btn.Add_MouseEnter({ $this.Foreground = [System.Windows.Media.Brushes]::White })
        $btn.Add_MouseLeave({
            param($s)
            $isLast = ($s.Tag -eq "last")
            $s.Foreground = if ($isLast) {
                [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0xa7,0x8b,0xfa))
            } else {
                [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromRgb(0x9c,0xa3,0xaf))
            }
        })
        $btn.Tag = if ($i -eq $parts.Count - 1) { "last" } else { "mid" }
        $breadcrumb.Items.Add($btn) | Out-Null
    }

    $items = [System.Collections.Generic.List[object]]::new()

    # Ordner – Größe aus Cache oder "..." bis Runspace sie berechnet
    $dirItems = [System.Collections.Generic.List[object]]::new()
    try {
        $dirPaths = [System.IO.Directory]::GetDirectories($Path) | Sort-Object
        foreach ($dp in $dirPaths) {
            $d = [System.IO.DirectoryInfo]::new($dp)
            $hasAccess = $true
            try { [System.IO.Directory]::GetFiles($dp) | Out-Null } catch { $hasAccess = $false }
            $cachedSize = [long]0
            $hasCached  = $script:BrowserSizeCache.TryGetValue($dp, [ref]$cachedSize)
            $b = $cachedSize
            $cachedFmt = if ($hasCached) { Format-FileSize $b } else { "..." }
            $item = [BrowserItem]@{
                Name         = $d.Name
                Typ          = $L.BrowserDirLabel
                Groesse      = $cachedFmt
                GroesseBytes = if ($hasCached) { $cachedSize } else { -1 }
                Datum        = $d.LastWriteTime.ToString("dd.MM.yyyy HH:mm")
                Hinweis      = if (-not $hasAccess) { $L.NoAccess } else { "" }
                Farbe        = if (-not $hasAccess) { "#F87171" } else { "#60A5FA" }
                FullPath     = $dp
                IsDir        = $true
                HasAccess    = $hasAccess
            }
            $items.Add($item)
            if ($hasAccess -and -not $hasCached) { $dirItems.Add($item) }
        }
    } catch {}

    # Dateien
    try {
        $filePaths = [System.IO.Directory]::GetFiles($Path) | Sort-Object
        foreach ($fp in $filePaths) {
            $f = [System.IO.FileInfo]::new($fp)
            $items.Add([BrowserItem]@{
                Name       = $f.Name
                Typ        = $L.BrowserFileLabel
                Groesse    = Format-FileSize $f.Length
                Datum      = $f.LastWriteTime.ToString("dd.MM.yyyy HH:mm")
                Hinweis    = ""
                Farbe      = "#E2E8F0"
                FullPath   = $fp
                IsDir      = $false
                HasAccess  = $true
            })
        }
    } catch {}

    $lvBrowser.ItemsSource = $items

    # Ordnergrößen asynchron per Runspace berechnen
    if ($dirItems.Count -gt 0) {
        $scanPath    = $Path
        $itemsToScan = $dirItems.ToArray()

        # Shared state: Runspace kann nicht direkt auf $script:-Vars zugreifen
        # Wir übergeben ein Objekt das den aktuellen Pfad trägt
        $sharedState = [System.Collections.Concurrent.ConcurrentDictionary[string,string]]::new()
        $sharedState["current"] = $scanPath
        # Damit der Runspace abbrechen kann wenn User weiternavigiert:
        # Wir aktualisieren $sharedState["current"] beim nächsten Navigate
        $script:BrowserSharedState = $sharedState

        $rs = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
        $rs.ApartmentState = "MTA"
        $rs.ThreadOptions  = "ReuseThread"
        $rs.Open()
        $rs.SessionStateProxy.SetVariable("itemsToScan", $itemsToScan)
        $rs.SessionStateProxy.SetVariable("scanPath",    $scanPath)
        $rs.SessionStateProxy.SetVariable("sharedState", $sharedState)
        $rs.SessionStateProxy.SetVariable("sizeCache",   $script:BrowserSizeCache)

        $ps = [System.Management.Automation.PowerShell]::Create()
        $ps.Runspace = $rs
        $null = $ps.AddScript({
            foreach ($dirItem in $itemsToScan) {
                # Abbrechen wenn User weiternavigiert hat
                if ($sharedState["current"] -ne $scanPath) { break }

                $size = [long]0
                try {
                    $stack = [System.Collections.Generic.Stack[string]]::new()
                    $stack.Push($dirItem.FullPath)
                    while ($stack.Count -gt 0) {
                        $cur = $stack.Pop()
                        try {
                            foreach ($f in [System.IO.Directory]::GetFiles($cur)) {
                                try { $size += [System.IO.FileInfo]::new($f).Length } catch {}
                            }
                            foreach ($sub in [System.IO.Directory]::GetDirectories($cur)) {
                                $stack.Push($sub)
                            }
                        } catch {}
                    }
                } catch {}

        # Größe in Cache speichern
                $sizeCache[$dirItem.FullPath] = $size

                # Größe formatieren (Format-FileSize nicht im Runspace verfügbar)
                $b   = $size
                $fmt = if     ($b -ge 1TB) { "{0:N2} TB" -f ($b/1TB) }
                       elseif ($b -ge 1GB) { "{0:N2} GB" -f ($b/1GB) }
                       elseif ($b -ge 1MB) { "{0:N2} MB" -f ($b/1MB) }
                       elseif ($b -ge 1KB) { "{0:N2} KB" -f ($b/1KB) }
                       else                { "$b B" }

                # Update-Bridge: sharedState trägt den formatierten Wert
                # key = FullPath des Items, Wert = "SIZE:$fmt|$size"
                $sharedState["update:$($dirItem.FullPath)"] = "SIZE:$fmt|$size"
            }
        })
        $null = $ps.BeginInvoke()

        # Timer im UI-Thread liest sharedState und aktualisiert BrowserItems
        $browserUpdateTimer = [System.Windows.Threading.DispatcherTimer]::new()
        $browserUpdateTimer.Interval = [TimeSpan]::FromMilliseconds(120)
        $browserUpdateTimer.Tag = $sharedState  # Referenz halten
        $localItems = $itemsToScan
        $localSPath  = $scanPath
        $browserUpdateTimer.Add_Tick({
            $st = $browserUpdateTimer.Tag
            if ($null -eq $st) { $browserUpdateTimer.Stop(); return }
            # Abgebrochen?
            if ($st["current"] -ne $localSPath) { $browserUpdateTimer.Stop(); return }
            $keysToRemove = [System.Collections.Generic.List[string]]::new()
            foreach ($kv in $st.ToArray()) {
                if ($kv.Key.StartsWith("update:")) {
                    $fullPath = $kv.Key.Substring(7)
                    $val      = $kv.Value
                    if ($val -and $val.StartsWith("SIZE:")) {
                        $parts = $val.Substring(5).Split("|")
                        $fmt   = $parts[0]
                        $sz    = [long]$parts[1]
                        $target = $localItems | Where-Object { $_.FullPath -eq $fullPath }
                        if ($target) {
                            $target.Groesse      = $fmt
                            $target.GroesseBytes = $sz
                        }
                    }
                    $keysToRemove.Add($kv.Key)
                }
            }
            $dummy = [object]$null
            foreach ($k in $keysToRemove) { $st.TryRemove($k, [ref]$dummy) | Out-Null }
            # Timer stoppen wenn alle Items Größe haben
            $allDone = $true
            foreach ($item in $localItems) {
                if ($item.GroesseBytes -eq -1) { $allDone = $false; break }
            }
            if ($allDone) { $browserUpdateTimer.Stop() }
        }.GetNewClosure())
        $browserUpdateTimer.Start()
    }
}

# ===== Kontextmenü-Referenzen =====
$ctxMenu         = $lvBrowser.ContextMenu
$ctxOpen         = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxOpen" }
$ctxOpenExplorer = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxOpenExplorer" }
$ctxRename       = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxRename" }
$ctxNewFolder    = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxNewFolder" }
$ctxCopy         = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxCopy" }
$ctxCut          = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxCut" }
$ctxPaste        = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxPaste" }
$ctxCopyPath     = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxCopyPath" }
$ctxDelete       = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxDelete" }
$ctxDeletePerm   = $ctxMenu.Items | Where-Object { $_ -is [System.Windows.Controls.MenuItem] -and $_.Name -eq "ctxDeletePerm" }
$script:ClipboardPath  = $null
$script:ClipboardIsCut = $false

# Menupunkte je nach Selektion aktivieren/deaktivieren
$ctxMenu.Add_Opened({
    $sel       = $lvBrowser.SelectedItem
    $hasSel    = $null -ne $sel
    $hasAccess = $hasSel -and $sel.HasAccess
    $isDir     = $hasSel -and $sel.IsDir
    $hasClip   = $null -ne $script:ClipboardPath

    $ctxOpen.IsEnabled         = $hasSel -and $isDir -and $hasAccess
    $ctxOpenExplorer.IsEnabled = $hasSel -and $hasAccess
    $ctxRename.IsEnabled       = $hasSel -and $hasAccess
    $ctxCopy.IsEnabled         = $hasSel -and $hasAccess
    $ctxCut.IsEnabled          = $hasSel -and $hasAccess
    $ctxPaste.IsEnabled        = $hasClip -and ($null -ne $script:BrowserCurrent)
    $ctxCopyPath.IsEnabled     = $hasSel
    $ctxDelete.IsEnabled       = $hasSel -and $hasAccess
    $ctxDeletePerm.IsEnabled   = $hasSel -and $hasAccess
    $ctxNewFolder.IsEnabled    = $null -ne $script:BrowserCurrent
})

# Oeffnen
$ctxOpen.Add_Click({
    $sel = $lvBrowser.SelectedItem
    if ($sel -and $sel.IsDir -and $sel.HasAccess) { Show-FolderInBrowser $sel.FullPath }
})

# Im Explorer anzeigen
$ctxOpenExplorer.Add_Click({
    $sel = $lvBrowser.SelectedItem
    if ($sel) { Start-Process explorer.exe -ArgumentList "/select,`"$($sel.FullPath)`"" }
})

# Pfad kopieren
$ctxCopyPath.Add_Click({
    $sel = $lvBrowser.SelectedItem
    if ($sel) { [System.Windows.Clipboard]::SetText($sel.FullPath) }
})

# Kopieren
$ctxCopy.Add_Click({
    $sel = $lvBrowser.SelectedItem
    if ($sel -and $sel.HasAccess) {
        $script:ClipboardPath  = $sel.FullPath
        $script:ClipboardIsCut = $false
        $lblStatus.Text = ($L.StatusCopied -f $sel.Name)
    }
})

# Ausschneiden
$ctxCut.Add_Click({
    $sel = $lvBrowser.SelectedItem
    if ($sel -and $sel.HasAccess) {
        $script:ClipboardPath  = $sel.FullPath
        $script:ClipboardIsCut = $true
        $lblStatus.Text = ($L.StatusCut -f $sel.Name)
    }
})

# Einfuegen
$ctxPaste.Add_Click({
    if (-not $script:ClipboardPath -or -not $script:BrowserCurrent) { return }
    $src  = $script:ClipboardPath
    $name = [System.IO.Path]::GetFileName($src)
    $dest = Join-Path $script:BrowserCurrent $name
    if ($dest -eq $src) {
        $base = [System.IO.Path]::GetFileNameWithoutExtension($src)
        $ext  = [System.IO.Path]::GetExtension($src)
        $dest = Join-Path $script:BrowserCurrent "$base - Kopie$ext"
    }
    try {
        if (Test-Path -LiteralPath $src -PathType Container) {
            if ($script:ClipboardIsCut) { Move-Item -LiteralPath $src -Destination $dest -Force }
            else { Copy-Item -LiteralPath $src -Destination $dest -Recurse -Force }
        } else {
            if ($script:ClipboardIsCut) { Move-Item -LiteralPath $src -Destination $dest -Force }
            else { Copy-Item -LiteralPath $src -Destination $dest -Force }
        }
        if ($script:ClipboardIsCut) { $script:ClipboardPath = $null }
        $lblStatus.Text = ($L.StatusPasted -f $name)
        Show-FolderInBrowser $script:BrowserCurrent
    } catch {
        [System.Windows.MessageBox]::Show(($L.ErrPaste -f $_.Exception.Message), $L.ErrTitle, "OK", "Error")
    }
})

# Umbenennen (InputBox via VB)
Add-Type -AssemblyName Microsoft.VisualBasic
$ctxRename.Add_Click({
    $sel = $lvBrowser.SelectedItem
    if (-not $sel -or -not $sel.HasAccess) { return }
    $input = [Microsoft.VisualBasic.Interaction]::InputBox($L.RenamePrompt, $L.RenameTitle, $sel.Name)
    if ($input -and $input -ne $sel.Name) {
        try {
            Rename-Item -LiteralPath $sel.FullPath -NewName $input -Force
            $lblStatus.Text = ($L.StatusRenamed -f $sel.Name, $input)
            Show-FolderInBrowser $script:BrowserCurrent
        } catch {
            [System.Windows.MessageBox]::Show(($L.ErrRename -f $_.Exception.Message), $L.ErrTitle, "OK", "Error")
        }
    }
})

# Neuer Ordner
$ctxNewFolder.Add_Click({
    if (-not $script:BrowserCurrent) { return }
    $input = [Microsoft.VisualBasic.Interaction]::InputBox($L.NewFolderPrompt, $L.NewFolderTitle, $L.NewFolderDefault)
    if ($input) {
        try {
            New-Item -ItemType Directory -Path (Join-Path $script:BrowserCurrent $input) -Force | Out-Null
            $lblStatus.Text = ($L.StatusFolderCreated -f $input)
            Show-FolderInBrowser $script:BrowserCurrent
        } catch {
            [System.Windows.MessageBox]::Show(($L.ErrCreate -f $_.Exception.Message), $L.ErrTitle, "OK", "Error")
        }
    }
})

# Loeschen
$ctxDelete.Add_Click({
    $sel = $lvBrowser.SelectedItem
    if (-not $sel -or -not $sel.HasAccess) { return }
    $typ = if ($sel.IsDir) { $L.WordFolder } else { $L.WordFile }
    $msg = if ($sel.IsDir) { $L.DeleteConfirmDir -f $sel.FullPath } else { $L.DeleteConfirmFile -f $sel.FullPath }
    $result = [System.Windows.MessageBox]::Show($msg, $L.DeleteConfirmTitle, "YesNo", "Warning")
    if ($result -eq "Yes") {
        try {
            if ($sel.IsDir) { Remove-Item -LiteralPath $sel.FullPath -Recurse -Force }
            else            { Remove-Item -LiteralPath $sel.FullPath -Force }
            $lblStatus.Text = ($L.StatusDeleted -f $sel.Name)
            Show-FolderInBrowser $script:BrowserCurrent
        } catch {
            [System.Windows.MessageBox]::Show(($L.ErrDelete -f $_.Exception.Message), $L.ErrTitle, "OK", "Error")
        }
    }
})

# Endgueltig loeschen (kein Papierkorb)
$ctxDeletePerm.Add_Click({
    $sel = $lvBrowser.SelectedItem
    if (-not $sel -or -not $sel.HasAccess) { return }
    $typ = if ($sel.IsDir) { $L.WordFolder } else { $L.WordFile }
    $result = [System.Windows.MessageBox]::Show(
        ($L.DeletePermConfirm -f $typ, $sel.FullPath),
        $L.DeletePermTitle, "YesNo", "Warning")
    if ($result -eq "Yes") {
        try {
            if ($sel.IsDir) {
                # Alle Attribute entfernen und dann loeschen
                Get-ChildItem -LiteralPath $sel.FullPath -Recurse -Force -ErrorAction SilentlyContinue |
                    ForEach-Object { $_.Attributes = "Normal" }
                [System.IO.Directory]::Delete($sel.FullPath, $true)
            } else {
                [System.IO.File]::SetAttributes($sel.FullPath, "Normal")
                [System.IO.File]::Delete($sel.FullPath)
            }
            $lblStatus.Text = ($L.StatusDeletedPerm -f $sel.Name)
            Show-FolderInBrowser $script:BrowserCurrent
        } catch {
            [System.Windows.MessageBox]::Show("Fehler beim Loeschen:`n$($_.Exception.Message)", "Fehler", "OK", "Error")
        }
    }
})

# Doppelklick = in Ordner navigieren
$lvBrowser.Add_MouseDoubleClick({
    $sel = $lvBrowser.SelectedItem
    if ($sel -and $sel.IsDir -and $sel.HasAccess) {
        Show-FolderInBrowser $sel.FullPath
    }
})

$btnBrowserBack.Add_Click({
    if ($script:BrowserHistory.Count -gt 0) {
        $prev = $script:BrowserHistory.Pop()
        $script:BrowserCurrent = ""  # Reset damit Show-FolderInBrowser keinen History-Eintrag erzeugt
        Show-FolderInBrowser $prev
        if ($script:BrowserHistory.Count -eq 0) { $btnBrowserBack.IsEnabled = $false }
    }
})

$btnBrowserUp.Add_Click({
    if ($script:BrowserCurrent) {
        $parent = Split-Path $script:BrowserCurrent -Parent
        if ($parent -and $parent -ne $script:BrowserCurrent -and (Test-Path -LiteralPath $parent)) {
            Show-FolderInBrowser $parent
        }
    }
})

# ===== Browser-Sortierung per Spaltenklick =====
$script:BrowserSortCol = "Name"
$script:BrowserSortAsc = $true

$lvBrowser.AddHandler(
    [System.Windows.Controls.GridViewColumnHeader]::ClickEvent,
    [System.Windows.RoutedEventHandler]{
    $header = $_.OriginalSource -as [System.Windows.Controls.GridViewColumnHeader]
    if (-not $header -or -not $header.Column) { return }

    $headerText = ($header.Content -replace " ▲| ▼", "").Trim()
    $col = switch ($headerText) {
        "$($L.SortName)"    { "Name" }
        "$($L.SortType)"     { "Typ" }
        "$($L.SortSize)" { "GroesseBytes" }
        "$($L.SortDate)"   { "Datum" }
        default   { $null }
    }
    if (-not $col) { return }

    if ($script:BrowserSortCol -eq $col) {
        $script:BrowserSortAsc = -not $script:BrowserSortAsc
    } else {
        $script:BrowserSortCol = $col
        $script:BrowserSortAsc = $true
    }

    $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($lvBrowser.ItemsSource)
    if (-not $view) { return }

    $dir = if ($script:BrowserSortAsc) {
        [System.ComponentModel.ListSortDirection]::Ascending
    } else {
        [System.ComponentModel.ListSortDirection]::Descending
    }

    $view.SortDescriptions.Clear()
    $view.SortDescriptions.Add(
        [System.ComponentModel.SortDescription]::new($col, $dir)
    )
    $view.Refresh()

    # Pfeil im Header aktualisieren
    $arrow = if ($script:BrowserSortAsc) { " ▲" } else { " ▼" }
    $gv = $lvBrowser.View -as [System.Windows.Controls.GridView]
    foreach ($c in $gv.Columns) {
        $base = ($c.Header -replace " ▲| ▼", "").Trim()
        $c.Header = if ($base -eq $headerText) { $base + $arrow } else { $base }
    }
}
)

# ===== Laufwerk / Papierkorb / Temp Funktionen =====

function Get-TrashSize {
    try {
        $shell = New-Object -ComObject Shell.Application
        $trash = $shell.Namespace(0xA)
        $size  = 0
        foreach ($item in $trash.Items()) {
            try { $size += $item.Size } catch {}
        }
        return $size
    } catch { return 0 }
}

function Get-TempSize {
    $size  = [long]0
    $paths = @($env:TEMP, $env:TMP, "C:\Windows\Temp") | Select-Object -Unique
    foreach ($p in $paths) {
        if (-not (Test-Path -LiteralPath $p -ErrorAction SilentlyContinue)) { continue }
        try {
            $stk = [System.Collections.Generic.Stack[string]]::new()
            $stk.Push($p)
            while ($stk.Count -gt 0) {
                $cur = $stk.Pop()
                try {
                    foreach ($f in [System.IO.Directory]::GetFiles($cur)) {
                        try { $size += [System.IO.FileInfo]::new($f).Length } catch {}
                    }
                    foreach ($sub in [System.IO.Directory]::GetDirectories($cur)) { $stk.Push($sub) }
                } catch {}
            }
        } catch {}
    }
    return $size
}

function Update-BottomBar {
    # Laufwerksauslastung
    if (-not $pnlDriveStatus) { return }
    $pnlDriveStatus.Children.Clear()
    $drives = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.IsReady -and $_.DriveType -in @("Fixed","Removable","Network") }
    foreach ($drive in $drives) {
        $totalGB = [math]::Round($drive.TotalSize / 1GB, 1)
        $freeGB  = [math]::Round($drive.AvailableFreeSpace / 1GB, 1)
        $usedPct = if ($drive.TotalSize -gt 0) { [math]::Round((($drive.TotalSize - $drive.AvailableFreeSpace) / $drive.TotalSize) * 100) } else { 0 }
        $barColor = if ($usedPct -ge 90) { "#7F1D1D" } elseif ($usedPct -ge 75) { "#92400E" } else { "#4C1D95" }

        $drivePanel = [System.Windows.Controls.StackPanel]::new()
        $drivePanel.Margin = [System.Windows.Thickness]::new(0,0,16,0)

        $topRow = [System.Windows.Controls.StackPanel]::new()
        $topRow.Orientation = "Horizontal"

        $lblDrive = [System.Windows.Controls.TextBlock]::new()
        $lblDrive.Text = $drive.Name.TrimEnd("\")
        $lblDrive.Foreground = "#E2E8F0"
        $lblDrive.FontWeight = "SemiBold"
        $lblDrive.FontSize = 11
        $lblDrive.Margin = [System.Windows.Thickness]::new(0,0,6,0)

        $lblSpace = [System.Windows.Controls.TextBlock]::new()
        $lblSpace.Text = "$freeGB GB $($L.DriveStatusFree) / $totalGB GB  ($usedPct%)"
        $lblSpace.Foreground = "#9CA3AF"
        $lblSpace.FontSize = 11

        $topRow.Children.Add($lblDrive) | Out-Null
        $topRow.Children.Add($lblSpace) | Out-Null

        # Fortschrittsbalken
        $barBg = [System.Windows.Controls.Border]::new()
        $barBg.Background = "#374151"
        $barBg.CornerRadius = [System.Windows.CornerRadius]::new(3)
        $barBg.Height = 5
        $barBg.Width = 120
        $barBg.Margin = [System.Windows.Thickness]::new(0,3,0,0)

        $barFill = [System.Windows.Controls.Border]::new()
        $barFill.Background = $barColor
        $barFill.CornerRadius = [System.Windows.CornerRadius]::new(3)
        $barFill.Height = 5
        $barFill.HorizontalAlignment = "Left"
        $barFill.Width = [math]::Round(120 * $usedPct / 100)

        $barGrid = [System.Windows.Controls.Grid]::new()
        $barGrid.Children.Add($barBg) | Out-Null
        $barGrid.Children.Add($barFill) | Out-Null

        $drivePanel.Children.Add($topRow) | Out-Null
        $drivePanel.Children.Add($barGrid) | Out-Null
        $pnlDriveStatus.Children.Add($drivePanel) | Out-Null
    }

    # Papierkorb
    $trashBytes = Get-TrashSize
    if ($lblTrashSize) { $lblTrashSize.Text = "$($L.TrashLabel): $(if($trashBytes -gt 0){ Format-FileSize $trashBytes }else{ $L.TrashEmpty })" }

    # Temp
    $tempBytes = Get-TempSize
    if ($lblTempSize) { $lblTempSize.Text = "$($L.TempLabel): $(Format-FileSize $tempBytes)" }
}

# ===== Baumansicht aufbauen =====
function Build-TreeView {
    param($RawData, $RootPath)
    $tvResults.Items.Clear()

    # Hierarchie aufbauen: Pfad -> Kinder
    $byPath = @{}
    foreach ($item in $RawData) { $byPath[$item.Pfad] = $item }

    function New-TreeItem {
        param($Item)
        $color = Get-SizeColor $Item.Groesse
        $node = [System.Windows.Controls.TreeViewItem]::new()
        $node.Tag = $Item.Pfad

        $sp = [System.Windows.Controls.StackPanel]::new()
        $sp.Orientation = "Horizontal"

        $tb1 = [System.Windows.Controls.TextBlock]::new()
        $tb1.Text = [System.IO.Path]::GetFileName($Item.Pfad)
        if (-not $tb1.Text) { $tb1.Text = $Item.Pfad }
        $tb1.FontWeight = "SemiBold"
        $tb1.Foreground = "#E2E8F0"

        $tb2 = [System.Windows.Controls.TextBlock]::new()
        $tb2.Text = "   $(Format-FileSize $Item.Groesse)   $($Item.Dateien)$($L.TreeFiles)"
        $tb2.Foreground = "#9CA3AF"
        $tb2.FontSize = 12

        $badge = [System.Windows.Controls.Border]::new()
        $badge.CornerRadius = [System.Windows.CornerRadius]::new(4)
        $badge.Margin = [System.Windows.Thickness]::new(8,1,0,0)
        $badge.Padding = [System.Windows.Thickness]::new(5,1,5,1)
        $badge.Background = $color.Bg
        $badgeTxt = [System.Windows.Controls.TextBlock]::new()
        $badgeTxt.Text = $color.Label
        $badgeTxt.Foreground = "White"
        $badgeTxt.FontSize = 11
        $badge.Child = $badgeTxt

        $sp.Children.Add($tb1) | Out-Null
        $sp.Children.Add($tb2) | Out-Null
        $sp.Children.Add($badge) | Out-Null
        $node.Header = $sp
        return $node
    }

    # Top-Level-Eintraege (Tiefe 1) als Wurzel, Unterordner einhaengen
    $topItems = $RawData | Where-Object { $_.Tiefe -eq 1 } | Sort-Object Groesse -Descending
    foreach ($top in $topItems) {
        $topNode = New-TreeItem $top
        # Direkte Kinder (Tiefe 2, die unter diesem Top-Ordner liegen)
        $children = $RawData | Where-Object {
            $_.Tiefe -eq 2 -and $_.Pfad.StartsWith($top.Pfad + "\")
        } | Sort-Object Groesse -Descending
        foreach ($child in $children) {
            $childNode = New-TreeItem $child
            # Enkinder (Tiefe 3)
            $grandchildren = $RawData | Where-Object {
                $_.Tiefe -eq 3 -and $_.Pfad.StartsWith($child.Pfad + "\")
            } | Sort-Object Groesse -Descending
            foreach ($gc in $grandchildren) {
                $childNode.Items.Add((New-TreeItem $gc)) | Out-Null
            }
            $topNode.Items.Add($childNode) | Out-Null
        }
        $tvResults.Items.Add($topNode) | Out-Null
    }
}

# ===== Events =====

# Hilfsfunktion: Control im visuellen Baum suchen
function Find-VisualChild {
    param($Parent, [string]$Name)
    $count = [System.Windows.Media.VisualTreeHelper]::GetChildrenCount($Parent)
    for ($i = 0; $i -lt $count; $i++) {
        $child = [System.Windows.Media.VisualTreeHelper]::GetChild($Parent, $i)
        if ($child -is [System.Windows.FrameworkElement] -and $child.Name -eq $Name) { return $child }
        $found = Find-VisualChild $child $Name
        if ($found) { return $found }
    }
    return $null
}

# Echtzeit-Timer: Laufwerksauslastung alle 30 Sekunden aktualisieren
$driveTimer = [System.Windows.Threading.DispatcherTimer]::new()
$driveTimer.Interval = [TimeSpan]::FromSeconds(30)
$driveTimer.Add_Tick({ Update-BottomBar })
$driveTimer.Start()

# Nach Loaded: Buttons per VisualTree verdrahten + BottomBar befuellen
$window.Add_Loaded({
    $script:btnEmptyTrash = Find-VisualChild $window "btnEmptyTrash"
    $script:btnCleanTemp  = Find-VisualChild $window "btnCleanTemp"
    $script:lblTrashSize  = Find-VisualChild $window "lblTrashSize"
    $script:lblTempSize   = Find-VisualChild $window "lblTempSize"

    if ($script:btnEmptyTrash) {
        $script:btnEmptyTrash.Add_Click({
            $result = [System.Windows.MessageBox]::Show(
                $L.TrashConfirm, $L.TrashConfirmTitle, "YesNo", "Warning")
            if ($result -eq "Yes") {
                try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch {}
                $lblStatus.Text = $L.StatusTrashEmptied
                Update-BottomBar
            }
        })
    }

    if ($script:btnCleanTemp) {
        $script:btnCleanTemp.Add_Click({
            $paths     = @($env:TEMP, $env:TMP, "C:\Windows\Temp") | Sort-Object -Unique
            $tempBytes = Get-TempSize
            $details   = ""
            foreach ($p in $paths) {
                if (Test-Path $p) {
                    $cnt = @(Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue).Count
                    $details += "`n  $p`n  -> $cnt$($L.TempElements)`n"
                } else {
                    $details += "`n  $p$($L.TempNotFound)`n"
                }
            }
            $result = [System.Windows.MessageBox]::Show(
                ($L.TempConfirmText -f (Format-FileSize $tempBytes), $details), $L.TempConfirmTitle, "YesNo", "Warning")
            if ($result -eq "Yes") {
                $deleted = 0; $failed = 0
                foreach ($p in $paths) {
                    if (Test-Path $p) {
                        Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | ForEach-Object {
                            try { Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop; $deleted++ }
                            catch { $failed++ }
                        }
                    }
                }
                $lblStatus.Text = ($L.StatusTempEmptied -f $deleted, $(if($failed -gt 0){ $L.TempFailSuffix -f $failed } else { "" }))
                Update-BottomBar
            }
        })
    }

    Update-BottomBar

    # Changelog-Button, SwitchLang-Button und Version per VisualTree
    $script:btnChangelog  = Find-VisualChild $window "btnChangelog"
    $script:btnSwitchLang = Find-VisualChild $window "btnSwitchLang"
    $script:lblVersion    = Find-VisualChild $window "lblVersion"
    if ($script:btnChangelog)  { $script:btnChangelog.Add_Click({ Show-Changelog }) }
    if ($script:lblVersion)    { $script:lblVersion.Text = "v$($script:AppVersion)" }
    if ($script:btnSwitchLang) {
        $script:btnSwitchLang.Add_Click({
            # Sprache umschalten
            $script:Lang = if ($script:Lang -eq "DE") { "EN" } else { "DE" }
            $L = $script:Strings[$script:Lang]
            # $L auch im Script-Scope aktualisieren damit alle Funktionen die neue Sprache sehen
            Set-Variable -Name L -Value $L -Scope Script

            # Alle UI-Texte sofort aktualisieren
            $script:btnSwitchLang.Content     = $L.BtnSwitchLang
            $script:btnSwitchLang.ToolTip     = $L.TooltipSwitchLang
            $script:btnChangelog.Content      = $L.BtnChangelog
            $btnScan.Content                  = $L.BtnScan
            $btnCancel.Content                = $L.BtnCancel
            $btnBrowse.Content                = $L.BtnBrowse
            $btnOpenExplorer.Content          = $L.BtnExplorer
            $btnOpenExplorer.ToolTip          = $L.TooltipExplorer
            $btnDupeFinder.Content            = $L.BtnDupes
            $btnDupeFinder.ToolTip            = $L.TooltipDupes
            $btnEmptyFolders.Content          = $L.BtnEmpty
            $btnEmptyFolders.ToolTip          = $L.TooltipEmpty
            $cmbPath.ToolTip                  = $L.TooltipPath
            $lblStatus.Text                   = $L.StatusReady
            $script:btnEmptyTrash.Content     = $L.BtnEmptyTrash
            $script:btnCleanTemp.Content      = $L.BtnCleanTemp
            $btnBrowserUp.Content             = $L.BtnBrowserUp
            ($window.FindName("lblSubtitle")).Text = $L.AppSubtitle

            # DataGrid-Spaltenheader aktualisieren
            foreach ($col in $dgResults.Columns) {
                switch -Regex ($col.Header) {
                    $L.ColPath    { }  # bereits richtig
                    $L.ColSize    { }
                    $L.ColFiles   { }
                    $L.ColShare   { }
                    $L.ColSizeClass { }
                }
            }
            # Spaltenheader direkt per Index setzen (Reihenfolge: #, Pfad, Groesse, Dateien, Anteil, Groessenklasse)
            if ($dgResults.Columns.Count -ge 6) {
                $dgResults.Columns[1].Header = $L.ColPath
                $dgResults.Columns[2].Header = $L.ColSize
                $dgResults.Columns[3].Header = $L.ColFiles
                $dgResults.Columns[4].Header = $L.ColShare
                $dgResults.Columns[5].Header = $L.ColSizeClass
            }
            # Browser-Spaltenheader (ListView GridView)
            $gv = $lvBrowser.View
            if ($gv -and $gv.Columns.Count -ge 4) {
                $gv.Columns[0].Header = $L.ColName
                $gv.Columns[1].Header = $L.ColType
                $gv.Columns[2].Header = $L.ColSize
                $gv.Columns[3].Header = $L.ColDate
            }
            # Statusleiste Papierkorb/Temp
            Update-BottomBar
        })
    }
})

# Changelog-Fenster anzeigen
function Show-Changelog {
    $L = $script:Strings[$script:Lang]
    [xml]$clXAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$($L.ChangelogTitle)" Height="620" Width="780"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanResize" Background="#1E1E2E">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBlock Grid.Row="0" Text="Changelog" FontSize="20" FontWeight="Bold"
                   Foreground="#A78BFA" Margin="0,0,0,4"/>
        <TextBlock Grid.Row="1" FontSize="12" Foreground="#6B7280" Margin="0,0,0,16"
                   Text="$($L.ChangelogSubtitle)"/>
        <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto">
            <StackPanel x:Name="pnlChangelog"/>
        </ScrollViewer>
        <Button Grid.Row="3" x:Name="btnClClose" Content="$($L.ChangelogClose)"
                HorizontalAlignment="Right" Margin="0,16,0,0"
                Background="#374151" Foreground="White" FontWeight="SemiBold"
                Padding="16,8" BorderThickness="0" Cursor="Hand">
            <Button.Template>
                <ControlTemplate TargetType="Button">
                    <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <ControlTemplate.Triggers>
                        <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#4B5563"/></Trigger>
                    </ControlTemplate.Triggers>
                </ControlTemplate>
            </Button.Template>
        </Button>
    </Grid>
</Window>
"@
    $clReader = [System.Xml.XmlNodeReader]::new($clXAML)
    $script:clWindow = [Windows.Markup.XamlReader]::Load($clReader)
    $script:clWindow.Add_Loaded({
        $pnlCl   = Find-VisualChild $script:clWindow "pnlChangelog"
        $btnCl   = Find-VisualChild $script:clWindow "btnClClose"
        if ($btnCl)  { $btnCl.Add_Click({ $script:clWindow.Close() }) }

        $changelogData = if ($script:Lang -eq "EN") { $script:ChangelogEN } else { $script:ChangelogDE }
        foreach ($entry in $changelogData) {
            # Versions-Header
            $headerBorder = [System.Windows.Controls.Border]::new()
            $headerBorder.Background  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#252535")
            $headerBorder.CornerRadius = [System.Windows.CornerRadius]::new(6)
            $headerBorder.Margin      = [System.Windows.Thickness]::new(0,0,0,2)
            $headerBorder.Padding     = [System.Windows.Thickness]::new(12,8,12,8)

            $headerGrid = [System.Windows.Controls.Grid]::new()
            $col1 = [System.Windows.Controls.ColumnDefinition]::new(); $col1.Width = [System.Windows.GridLength]::Auto
            $col2 = [System.Windows.Controls.ColumnDefinition]::new(); $col2.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
            $headerGrid.ColumnDefinitions.Add($col1)
            $headerGrid.ColumnDefinitions.Add($col2)

            $versionBadge = [System.Windows.Controls.Border]::new()
            $versionBadge.Background  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#7C3AED")
            $versionBadge.CornerRadius = [System.Windows.CornerRadius]::new(4)
            $versionBadge.Padding     = [System.Windows.Thickness]::new(8,2,8,2)
            $versionBadge.Margin      = [System.Windows.Thickness]::new(0,0,10,0)
            $vTxt = [System.Windows.Controls.TextBlock]::new()
            $vTxt.Text       = "v$($entry.Version)"
            $vTxt.Foreground = [System.Windows.Media.Brushes]::White
            $vTxt.FontWeight = [System.Windows.FontWeights]::Bold
            $vTxt.FontSize   = 13
            $versionBadge.Child = $vTxt
            [System.Windows.Controls.Grid]::SetColumn($versionBadge, 0)

            $dateTxt = [System.Windows.Controls.TextBlock]::new()
            $dateTxt.Text              = $entry.Datum
            $dateTxt.Foreground        = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#9CA3AF")
            $dateTxt.FontSize          = 12
            $dateTxt.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            [System.Windows.Controls.Grid]::SetColumn($dateTxt, 1)

            $headerGrid.Children.Add($versionBadge) | Out-Null
            $headerGrid.Children.Add($dateTxt)      | Out-Null
            $headerBorder.Child = $headerGrid
            $pnlCl.Children.Add($headerBorder)      | Out-Null

            # Eintraege
            $listBorder = [System.Windows.Controls.Border]::new()
            $listBorder.Background  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1A1A2E")
            $listBorder.CornerRadius = [System.Windows.CornerRadius]::new(0,0,6,6)
            $listBorder.Margin      = [System.Windows.Thickness]::new(0,0,0,16)
            $listBorder.Padding     = [System.Windows.Thickness]::new(12,8,12,8)

            $listPanel = [System.Windows.Controls.StackPanel]::new()
            foreach ($change in $entry.Aenderungen) {
                $row = [System.Windows.Controls.StackPanel]::new()
                $row.Orientation = [System.Windows.Controls.Orientation]::Horizontal
                $row.Margin      = [System.Windows.Thickness]::new(0,2,0,2)

                $dot = [System.Windows.Controls.TextBlock]::new()
                $dot.Text              = "•  "
                $dot.Foreground        = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#7C3AED")
                $dot.FontSize          = 13
                $dot.VerticalAlignment = [System.Windows.VerticalAlignment]::Top

                $txt = [System.Windows.Controls.TextBlock]::new()
                $txt.Text        = $change
                $txt.Foreground  = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#E2E8F0")
                $txt.FontSize    = 13
                $txt.TextWrapping = [System.Windows.TextWrapping]::Wrap

                $row.Children.Add($dot)  | Out-Null
                $row.Children.Add($txt)  | Out-Null
                $listPanel.Children.Add($row) | Out-Null
            }
            $listBorder.Child = $listPanel
            $pnlCl.Children.Add($listBorder) | Out-Null
        }
    })

    $script:clWindow.Show()
}

# Fenster schliessen -> Config speichern
$window.Add_Closing({
    $script:Config.WindowLeft   = $window.Left
    $script:Config.WindowTop    = $window.Top
    $script:Config.WindowWidth  = $window.Width
    $script:Config.WindowHeight = $window.Height
    Save-Config
})

# Explorer oeffnen bei Selektion
$dgResults.Add_SelectionChanged({
    $sel = $dgResults.SelectedItem
    $btnOpenExplorer.IsEnabled = ($null -ne $sel)
    if ($sel -and (Test-Path -LiteralPath $sel.Pfad)) {
        Show-FolderInBrowser $sel.Pfad
    }
})
$tvResults.Add_SelectedItemChanged({
    $node = $tvResults.SelectedItem
    $btnOpenExplorer.IsEnabled = ($null -ne $node)
    if ($node -and $node.Tag -and (Test-Path -LiteralPath $node.Tag)) {
        Show-FolderInBrowser $node.Tag
    }
})

$btnOpenExplorer.Add_Click({
    $path = $null
    if ($dgResults.Visibility -eq "Visible" -and $dgResults.SelectedItem) {
        $path = $dgResults.SelectedItem.Pfad
    } elseif ($tvResults.SelectedItem) {
        $path = $tvResults.SelectedItem.Tag
    }
    if ($path -and (Test-Path -LiteralPath $path)) {
        Start-Process explorer.exe -ArgumentList "`"$path`""
    }
})

# Ordner-Browser
$btnBrowse.Add_Click({
    $dialog = [System.Windows.Forms.FolderBrowserDialog]::new()
    $dialog.Description = $L.BrowseDesc
    $dialog.SelectedPath = if ($cmbPath.SelectedItem) { $cmbPath.SelectedItem } else { "C:\" }
    if ($dialog.ShowDialog() -eq "OK") {
        $newPath = $dialog.SelectedPath
        if (-not $cmbPath.Items.Contains($newPath)) { $cmbPath.Items.Insert(0, $newPath) }
        $cmbPath.SelectedItem = $newPath
    }
})

# Abbrechen
$btnCancel.Add_Click({
    $script:CancelRequested = $true
    $btnCancel.IsEnabled = $false
    $lblStatus.Text = $L.StatusCancelling
})

# ===== Analyse starten =====
$btnScan.Add_Click({
    $startPath = if ($cmbPath.SelectedItem) { $cmbPath.SelectedItem } else { $cmbPath.Text.Trim() }

    if (-not (Test-Path -LiteralPath $startPath -ErrorAction SilentlyContinue)) {
        [System.Windows.MessageBox]::Show(
            ($L.PathNotFound -f $startPath), $L.PathNotFoundTitle, "OK", "Warning")
        return
    }

    # Pfad in History aufnehmen
    Add-PathHistory $startPath
    $cmbPath.Items.Clear()
    foreach ($h in $script:Config.PathHistory) { $cmbPath.Items.Add($h) | Out-Null }
    $cmbPath.SelectedIndex = 0
    $cmbPath.Text = $startPath

    $script:CancelRequested  = $false
    $script:ScanResults      = $null
    $script:BrowserSizeCache.Clear()

    $btnScan.IsEnabled        = $false
    $btnCancel.IsEnabled      = $true
    $btnOpenExplorer.IsEnabled= $false
    $progressBar.Value        = 0
    $lblProgress.Text         = ""
    $dgResults.ItemsSource    = $null
    $tvResults.Items.Clear()
    $lblSummary.Text          = ""
    $lblStatus.Text           = $L.StatusScanning

    $dispatcher = $window.Dispatcher

    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.ApartmentState = "STA"
    $runspace.ThreadOptions  = "ReuseThread"
    $runspace.Open()

    $runspace.SessionStateProxy.SetVariable("startPath",     $startPath)
    $runspace.SessionStateProxy.SetVariable("dispatcher",    $dispatcher)
    $runspace.SessionStateProxy.SetVariable("dgResults",     $dgResults)
    $runspace.SessionStateProxy.SetVariable("lblStatus",     $lblStatus)
    $runspace.SessionStateProxy.SetVariable("lblSummary",    $lblSummary)
    $runspace.SessionStateProxy.SetVariable("progressBar",   $progressBar)
    $runspace.SessionStateProxy.SetVariable("lblProgress",   $lblProgress)
    $runspace.SessionStateProxy.SetVariable("btnScan",       $btnScan)
    $runspace.SessionStateProxy.SetVariable("btnCancel",     $btnCancel)
    $runspace.SessionStateProxy.SetVariable("CancelRef",     ([ref]$script:CancelRequested))
    $runspace.SessionStateProxy.SetVariable("ScanResultsRef",([ref]$script:ScanResults))
    $runspace.SessionStateProxy.SetVariable("L",             $L)

    $psCode = {
        function Format-FileSize {
            param([long]$Bytes)
            if ($Bytes -ge 1TB) { return "{0:N2} TB" -f ($Bytes / 1TB) }
            if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
            if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
            if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
            return "$Bytes B"
        }

        function Get-SizeColor {
            param([long]$Bytes)
            if ($Bytes -ge 10GB) { return @{ Bg="#7F1D1D"; Label=$L.SizeVeryLarge } }
            if ($Bytes -ge 1GB)  { return @{ Bg="#92400E"; Label=$L.SizeLarge } }
            if ($Bytes -ge 100MB){ return @{ Bg="#1E3A5F"; Label=$L.SizeMedium } }
            if ($Bytes -ge 10MB) { return @{ Bg="#064E3B"; Label=$L.SizeSmall } }
            return @{ Bg="#1F2937"; Label=$L.SizeVerySmall }
        }

        # Ordnergroesse parallel berechnen
        function Get-FolderSizeParallel {
            param([string]$Path, [int]$CurrentDepth = 0)

            $results = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
            try {
                $dirs = @([System.IO.Directory]::GetDirectories($Path))
                $jobs = [System.Collections.Generic.List[object]]::new()

                foreach ($dirPath in $dirs) {
                    if ($CancelRef.Value) { break }
                    $d     = $dirPath
                    $depth = $CurrentDepth
                    $rs    = [System.Collections.Concurrent.ConcurrentBag[object]]::new()

                    $job = [System.Threading.Tasks.Task]::Run([Action]{
                        try {
                            [System.IO.Directory]::GetAccessControl($d) | Out-Null
                            $sz = [long]0; $fc = 0
                            $stk = [System.Collections.Generic.Stack[string]]::new()
                            $stk.Push($d)
                            while ($stk.Count -gt 0) {
                                $cur = $stk.Pop()
                                try {
                                    foreach ($f in [System.IO.Directory]::GetFiles($cur)) {
                                        try { $sz += [System.IO.FileInfo]::new($f).Length; $fc++ } catch {}
                                    }
                                    foreach ($sub in [System.IO.Directory]::GetDirectories($cur)) { $stk.Push($sub) }
                                } catch {}
                            }
                            $rs.Add([PSCustomObject]@{
                                Pfad        = $d
                                Groesse     = $sz
                                Dateien     = $fc
                                Tiefe       = $depth + 1
                                KeinZugriff = $false
                            })
                        } catch {
                            $rs.Add([PSCustomObject]@{
                                Pfad        = $d
                                Groesse     = [long]0
                                Dateien     = 0
                                Tiefe       = $depth + 1
                                KeinZugriff = $true
                            })
                        }
                    })
                    $jobs.Add([PSCustomObject]@{ Job=$job; DirPath=$d; Rs=$rs })
                }

                [System.Threading.Tasks.Task]::WaitAll(($jobs | ForEach-Object { $_.Job }))

                foreach ($j in $jobs) {
                    foreach ($r in $j.Rs) { $results.Add($r) }
                    if (-not $CancelRef.Value) {
                        $sub = Get-FolderSizeParallel -Path $j.DirPath -CurrentDepth ($CurrentDepth + 1)
                        foreach ($s in $sub) { $results.Add($s) }
                    }
                }
            } catch {}
            return $results
        }

        function Build-DisplayData {
            param($RawData)
            $sorted = @($RawData | Sort-Object Groesse -Descending)

            $gesamt = ($RawData | Where-Object { $_.Tiefe -eq 1 } | Measure-Object -Property Groesse -Sum).Sum
            if (-not $gesamt -or $gesamt -eq 0) { $gesamt = ($sorted | Select-Object -First 1).Groesse }
            if (-not $gesamt) { $gesamt = 1 }

            $list = [System.Collections.Generic.List[object]]::new()
            $rang = 1
            foreach ($item in $sorted) {
                if ($item.KeinZugriff) {
                    $list.Add([PSCustomObject]@{
                        Rang            = "-"
                        Pfad            = $item.Pfad
                        Groesse         = [long]0
                        GraesseFmt      = "---"
                        Dateien         = "---"
                        Anteil          = 0
                        AnteilFmt       = "---"
                        FarbHintergrund = "#7F1D1D"
                        FarbLabel       = $L.NoAccess
                        KeinZugriff     = $true
                    })
                } else {
                    $anteil = if ($gesamt -gt 0) { [math]::Round(($item.Groesse / $gesamt) * 100, 1) } else { 0 }
                    if ($anteil -gt 100) { $anteil = 100 }
                    $color = Get-SizeColor $item.Groesse
                    $list.Add([PSCustomObject]@{
                        Rang            = $rang++
                        Pfad            = $item.Pfad
                        Groesse         = $item.Groesse
                        GraesseFmt      = Format-FileSize $item.Groesse
                        Dateien         = $item.Dateien
                        Anteil          = $anteil
                        AnteilFmt       = "$anteil %"
                        FarbHintergrund = $color.Bg
                        FarbLabel       = $color.Label
                        KeinZugriff     = $false
                    })
                }
            }
            # KeinZugriff-Eintraege ans Ende sortieren
            $sorted2 = @($list | Where-Object { -not $_.KeinZugriff }) + @($list | Where-Object { $_.KeinZugriff })
            return [System.Collections.Generic.List[object]]$sorted2
        }

        # Top-Level-Ordner ermitteln
        $topDirs = @(try { [System.IO.Directory]::GetDirectories($startPath) | ForEach-Object { [System.IO.DirectoryInfo]::new($_) } } catch {})
        $total   = $topDirs.Count
        if ($total -eq 0) { $total = 1 }

        $rawData   = [System.Collections.Generic.List[object]]::new()
        $doneCount = 0

        foreach ($topDir in $topDirs) {
            if ($CancelRef.Value) { break }

            $doneCount++
            $pct    = [math]::Round(($doneCount / $total) * 100)
            $folder = $topDir.Name

            $dispatcher.Invoke([Action]{
                $progressBar.Value = $pct
                $lblProgress.Text  = "$pct %  ($doneCount / $total)"
                $lblStatus.Text    = "$($L.StatusScanFolder)$folder"
            })

            try {
                [System.IO.Directory]::GetAccessControl($topDir.FullName) | Out-Null
                $sz = [long]0; $fc = 0
                $stk = [System.Collections.Generic.Stack[string]]::new()
                $stk.Push($topDir.FullName)
                while ($stk.Count -gt 0) {
                    $cur = $stk.Pop()
                    try {
                        foreach ($f in [System.IO.Directory]::GetFiles($cur)) {
                            try { $sz += [System.IO.FileInfo]::new($f).Length; $fc++ } catch {}
                        }
                        foreach ($sub in [System.IO.Directory]::GetDirectories($cur)) { $stk.Push($sub) }
                    } catch {}
                }

                $rawData.Add([PSCustomObject]@{
                    Pfad        = $topDir.FullName
                    Groesse     = $sz
                    Dateien     = $fc
                    Tiefe       = 1
                    KeinZugriff = $false
                })

                # Unterordner parallel
                if (-not $CancelRef.Value) {
                    $sub = Get-FolderSizeParallel -Path $topDir.FullName -CurrentDepth 1
                    foreach ($s in $sub) { $rawData.Add($s) }
                }
            } catch {
                $rawData.Add([PSCustomObject]@{
                    Pfad        = $topDir.FullName
                    Groesse     = [long]0
                    Dateien     = 0
                    Tiefe       = 1
                    KeinZugriff = $true
                })
            }

            # Live-Update nach jedem Top-Level-Ordner (nicht beim letzten – Abschluss macht das)
            if ($doneCount -lt $total -and -not $CancelRef.Value) {
                $dd         = Build-DisplayData -RawData $rawData
                $totalFiles = ($rawData | Measure-Object -Property Dateien -Sum).Sum
                $totalSize  = Format-FileSize (($rawData | Where-Object { $_.Tiefe -eq 1 } | Measure-Object -Property Groesse -Sum).Sum)
                $dispatcher.Invoke([Action]{
                    $dgResults.ItemsSource = $dd
                    $lblSummary.Text       = ($L.SummaryText -f $totalSize, ("{0:N0}" -f $totalFiles))
                })
            }
        }

        # Abschluss
        $displayData  = Build-DisplayData -RawData $rawData
        $totalFiles   = ($rawData | Measure-Object -Property Dateien -Sum).Sum
        $totalFolders = $rawData.Count
        $totalSize    = Format-FileSize (($rawData | Where-Object { $_.Tiefe -eq 1 } | Measure-Object -Property Groesse -Sum).Sum)
        $cancelled    = $CancelRef.Value

        $noAccessCount = ($rawData | Where-Object { $_.KeinZugriff } | Measure-Object).Count
        $dispatcher.Invoke([Action]{
            $dgResults.ItemsSource   = $displayData
            $noAccessHint = if ($noAccessCount -gt 0) { $L.StatusNoAccess -f $noAccessCount } else { "" }
            $lblStatus.Text          = if ($cancelled) {
                ($L.StatusCancelled -f $totalFolders) + $noAccessHint
            } else {
                ($L.StatusDone -f $totalFolders) + $noAccessHint
            }
            $lblSummary.Text         = ($L.SummaryText -f $totalSize, ("{0:N0}" -f $totalFiles))
            $progressBar.Value       = 100
            $lblProgress.Text        = if ($cancelled) { $L.ProgressCancelled } else { "100 %" }
            $btnScan.IsEnabled       = $true
            $btnCancel.IsEnabled     = $false
        })

        $ScanResultsRef.Value = $rawData
    }

    $ps = [powershell]::Create()
    $ps.Runspace = $runspace
    $ps.AddScript($psCode) | Out-Null
    $handle = $ps.BeginInvoke()

    $timer = [System.Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $timer.Add_Tick({
        if ($handle.IsCompleted) {
            $timer.Stop()
            try { $ps.EndInvoke($handle) } catch {}
            $ps.Dispose()
            $runspace.Dispose()
        }
    })
    $timer.Start()
})

# ===== Duplikat-Finder =====
$btnDupeFinder.Add_Click({
    $startPath = if ($script:BrowserCurrent) { $script:BrowserCurrent }
                 elseif ($cmbPath.Text)       { $cmbPath.Text }
                 else                         { $env:USERPROFILE }

    # Duplikat-Script als eingebetteter String – läuft in eigenem Prozess
    $dupeScript = @'
# Konsolenfenster sofort verstecken
Add-Type -Name Win32 -Namespace Native -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
$consoleHwnd = (Get-Process -Id $PID).MainWindowHandle
if ($consoleHwnd -ne [IntPtr]::Zero) { [Native.Win32]::ShowWindow($consoleHwnd, 0) | Out-Null }

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$startPath = "STARTPATH_PLACEHOLDER"

function fmt($b) {
    if ($b -ge 1TB) { return "{0:N2} TB" -f ($b/1TB) }
    if ($b -ge 1GB) { return "{0:N2} GB" -f ($b/1GB) }
    if ($b -ge 1MB) { return "{0:N2} MB" -f ($b/1MB) }
    if ($b -ge 1KB) { return "{0:N2} KB" -f ($b/1KB) }
    return "$b B"
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Disk Lens – ##L.DupeTitle##" Height="700" Width="1000"
        Background="#1E1E2E" Foreground="#E2E8F0" WindowStartupLocation="CenterScreen">
    <Window.Resources>
        <Style x:Key="Btn" TargetType="Button">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="Opacity" Value="0.8"/></Trigger>
                            <Trigger Property="IsEnabled" Value="False"><Setter TargetName="bd" Property="Opacity" Value="0.4"/></Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Grid Margin="16">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <StackPanel Grid.Row="0" Margin="0,0,0,14">
            <TextBlock Text="##L.DupeHeader##" FontSize="22" FontWeight="Bold" Foreground="#A78BFA"/>
            <TextBlock Text="##L.DupeSubtitle1##" FontSize="11" Foreground="#9CA3AF" Margin="0,3,0,0"/>
            <TextBlock Text="##L.DupeSubtitle2##" FontSize="12" Foreground="#6B7280" Margin="0,3,0,0"/>
        </StackPanel>

        <!-- Pfad-Zeile -->
        <Grid Grid.Row="1" Margin="0,0,0,10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBox x:Name="txtPath" Grid.Column="0" Background="#2D2D3F" Foreground="#E2E8F0"
                     BorderBrush="#374151" BorderThickness="1" Padding="8,6" FontSize="13"
                     Text="STARTPATH_PLACEHOLDER"/>
            <Button x:Name="btnBrowse" Grid.Column="1" Style="{StaticResource Btn}"
                    Content="##L.BtnBrowse##" Margin="8,0,0,0" Background="#374151"/>
            <Button x:Name="btnScan" Grid.Column="2" Style="{StaticResource Btn}"
                    Content="##L.BtnScanDupe##" Margin="8,0,0,0" Background="#7C3AED"/>
            <Button x:Name="btnCancel" Grid.Column="3" Style="{StaticResource Btn}"
                    Content="##L.BtnCancel##" Margin="8,0,0,0" Background="#991B1B" IsEnabled="False"/>
        </Grid>

        <!-- Fortschritt -->
        <Grid Grid.Row="2" Margin="0,0,0,10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <ProgressBar x:Name="pb" Grid.Column="0" Height="10" Minimum="0" Maximum="100"
                         Background="#374151" Foreground="#7C3AED" BorderThickness="0"/>
            <TextBlock x:Name="lblPct" Grid.Column="1" Foreground="#A78BFA" FontWeight="SemiBold"
                       FontSize="12" Margin="10,0,0,0" VerticalAlignment="Center" Text=""/>
        </Grid>

        <!-- Ergebnisse -->
        <ListView x:Name="lvResults" Grid.Row="3"
                  Background="#2D2D3F" BorderBrush="#374151" BorderThickness="1"
                  Foreground="#E2E8F0" FontSize="12">
            <ListView.View>
                <GridView>
                    <GridView.ColumnHeaderContainerStyle>
                        <Style TargetType="GridViewColumnHeader">
                            <Setter Property="Background" Value="#1A1A2E"/>
                            <Setter Property="Foreground" Value="#A78BFA"/>
                            <Setter Property="FontWeight" Value="SemiBold"/>
                            <Setter Property="Padding" Value="8,6"/>
                            <Setter Property="BorderBrush" Value="#374151"/>
                            <Setter Property="BorderThickness" Value="0,0,1,1"/>
                        </Style>
                    </GridView.ColumnHeaderContainerStyle>
                    <GridViewColumn Header="##L.DupeColName##"  Width="220" DisplayMemberBinding="{Binding Name}"/>
                    <GridViewColumn Header="##L.ColPath##"       Width="320" DisplayMemberBinding="{Binding Dir}"/>
                    <GridViewColumn Header="##L.ColSize##"    Width="90"  DisplayMemberBinding="{Binding SizeFmt}"/>
                    <GridViewColumn Header="##L.DupeColDate##"  Width="135" DisplayMemberBinding="{Binding Date}"/>
                    <GridViewColumn Header="##L.DupeColGroup##"     Width="60"  DisplayMemberBinding="{Binding Group}"/>
                </GridView>
            </ListView.View>
            <ListView.GroupStyle>
                <GroupStyle>
                    <GroupStyle.HeaderTemplate>
                        <DataTemplate>
                            <Border Background="#1A1A2E" Padding="8,4" Margin="0,4,0,0" CornerRadius="4">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="{Binding Name}" Foreground="#A78BFA" FontWeight="Bold" FontSize="12"/>
                                    <TextBlock Text="{Binding ItemCount, StringFormat=' — {0} ##L.DupeGroupFiles##'}" Foreground="#6B7280" FontSize="12" Margin="4,0,0,0"/>
                                </StackPanel>
                            </Border>
                        </DataTemplate>
                    </GroupStyle.HeaderTemplate>
                </GroupStyle>
            </ListView.GroupStyle>
            <ListView.ItemContainerStyle>
                <Style TargetType="ListViewItem">
                    <Setter Property="Padding" Value="4,3"/>
                    <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
                    <Style.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter Property="Background" Value="#3D3D5C"/>
                            <Setter Property="Foreground" Value="#FFFFFF"/>
                        </Trigger>
                        <Trigger Property="IsSelected" Value="True">
                            <Setter Property="Background" Value="#4C1D95"/>
                            <Setter Property="Foreground" Value="#FFFFFF"/>
                        </Trigger>
                    </Style.Triggers>
                </Style>
            </ListView.ItemContainerStyle>
        </ListView>

        <!-- Statusleiste -->
        <Grid Grid.Row="4" Margin="0,8,0,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock x:Name="lblStatus" Grid.Column="0" Foreground="#6B7280" FontSize="12"
                       VerticalAlignment="Center" Text="##L.DupeStatusReady##"/>
            <TextBlock x:Name="lblWaste"  Grid.Column="1" Foreground="#F87171" FontWeight="Bold"
                       FontSize="12" VerticalAlignment="Center" Margin="0,0,16,0" Text=""/>
            <Button x:Name="btnDelete" Grid.Column="2" Style="{StaticResource Btn}"
                    Content="##L.DupeDeleteSelected##" Background="#991B1B" IsEnabled="False"/>
        </Grid>
    </Grid>
</Window>
"@

$script:w           = [Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($xaml))
$script:txtPath     = $script:w.FindName("txtPath")
$script:btnBrowse   = $script:w.FindName("btnBrowse")
$script:btnScan     = $script:w.FindName("btnScan")
$script:btnCancel   = $script:w.FindName("btnCancel")
$script:btnDelete   = $script:w.FindName("btnDelete")
$script:lvResults   = $script:w.FindName("lvResults")
$script:lblStatus   = $script:w.FindName("lblStatus")
$script:lblWaste    = $script:w.FindName("lblWaste")
$script:pb          = $script:w.FindName("pb")
$script:lblPct      = $script:w.FindName("lblPct")

$script:cancelScan = $false

# Kontextmenu
$ctx = [System.Windows.Controls.ContextMenu]::new()
$miExplorer = [System.Windows.Controls.MenuItem]::new(); $miExplorer.Header = "##L.CtxOpenExplorer##".Replace("🗂  ","")
$miCopyPath = [System.Windows.Controls.MenuItem]::new(); $miCopyPath.Header = "##L.CtxCopyPath##".Replace("🔗  ","")
$miDelete   = [System.Windows.Controls.MenuItem]::new(); $miDelete.Header   = "##L.DupeCtxTrash##"
$miDeleteP  = [System.Windows.Controls.MenuItem]::new(); $miDeleteP.Header  = "##L.DupeCtxPermDelete##"
$ctx.Items.Add($miExplorer) | Out-Null
$ctx.Items.Add($miCopyPath) | Out-Null
$ctx.Items.Add([System.Windows.Controls.Separator]::new()) | Out-Null
$ctx.Items.Add($miDelete)   | Out-Null
$ctx.Items.Add($miDeleteP)  | Out-Null
$script:lvResults.ContextMenu = $ctx

function Delete-Selected($permanent) {
    $sel = $script:lvResults.SelectedItems
    if (-not $sel -or $sel.Count -eq 0) { return }
    $msg = if ($permanent) { "##L.DupeDeletePermMsg##" -f $sel.Count }
           else            { "##L.DupeDeleteTrashMsg##" -f $sel.Count }
    if ([System.Windows.MessageBox]::Show($msg,"##L.DupeConfirmTitle##",[System.Windows.MessageBoxButton]::YesNo,[System.Windows.MessageBoxImage]::Warning) -ne "Yes") { return }
    foreach ($item in @($sel)) {
        try {
            if ($permanent) {
                Remove-Item -LiteralPath $item.FullPath -Force -ErrorAction Stop
            } else {
                # In Papierkorb via VisualBasic FileSystem (kein COM-Overhead)
                [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
                    $item.FullPath,
                    [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
                    [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
                )
            }
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($script:lvResults.ItemsSource)
            ($script:lvResults.ItemsSource).Remove($item)
            $view.Refresh()
        } catch { [System.Windows.MessageBox]::Show(("##L.ErrTitle##" + ": $_")) }
    }
    Update-Waste
}

function Update-Waste {
    $items = $script:lvResults.ItemsSource
    if (-not $items -or $items.Count -eq 0) { $script:lblWaste.Text = ""; return }
    # Verschwende = pro Hash-Gruppe: (Anzahl-1) * Dateigröße
    $groups = $items | Group-Object Hash
    $waste  = 0
    foreach ($g in $groups) { $waste += ($g.Count - 1) * ($g.Group[0].Size) }
    $script:lblWaste.Text = "##L.DupeWasted##: $(fmt $waste)"
}

$miExplorer.Add_Click({
    $sel = $script:lvResults.SelectedItem
    if ($sel) { Start-Process explorer.exe "/select,`"$($sel.FullPath)`"" }
})
$miCopyPath.Add_Click({
    $sel = $script:lvResults.SelectedItem
    if ($sel) { [System.Windows.Clipboard]::SetText($sel.FullPath) }
})
$miDelete.Add_Click({  Delete-Selected $false })
$miDeleteP.Add_Click({ Delete-Selected $true  })

$script:btnDelete.Add_Click({ Delete-Selected $false })

$script:lvResults.Add_SelectionChanged({
    $script:btnDelete.IsEnabled = ($script:lvResults.SelectedItems.Count -gt 0)
})

$script:btnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description     = "##L.DupeBrowseDesc##"
    $dlg.SelectedPath    = $script:txtPath.Text
    $dlg.ShowNewFolderButton = $false
    if ($dlg.ShowDialog() -eq "OK") { $script:txtPath.Text = $dlg.SelectedPath }
})

$script:btnCancel.Add_Click({ $script:cancelScan = $true })

$script:btnScan.Add_Click({
    $scanPath = $script:txtPath.Text.Trim()
    if (-not $scanPath -or -not (Test-Path -LiteralPath $scanPath)) {
        [System.Windows.MessageBox]::Show("##L.DupeInvalidPath##")
        return
    }

    $script:btnScan.IsEnabled   = $false
    $script:btnCancel.IsEnabled = $true
    $script:btnDelete.IsEnabled = $false
    $script:lblStatus.Text      = "##L.DupeScanFiles##"
    $script:pb.Value            = 0
    $script:lblPct.Text         = ""
    $script:lblWaste.Text       = ""
    $script:cancelScan   = $false

    $script:allItems = [System.Collections.ObjectModel.ObservableCollection[object]]::new()
    $script:lvResults.ItemsSource = $script:allItems
    $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($script:allItems)
    $view.GroupDescriptions.Add([System.Windows.Data.PropertyGroupDescription]::new("HashShort"))

    $dispatcher  = $script:w.Dispatcher
    $script:pathForRS   = $scanPath
    $script:cancelRef   = [System.Collections.Concurrent.ConcurrentDictionary[string,bool]]::new()
    $script:cancelRef["cancel"] = $false

    # UI-State-Bridge: Runspace schreibt, Dispatcher liest
    $script:uiState = [System.Collections.Concurrent.ConcurrentDictionary[string,object]]::new()
    $script:uiState["pct"]    = [object]0
    $script:uiState["status"] = [object]"##L.DupeScanFiles##"

    $script:dupeRS      = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $script:dupeRS.ApartmentState = "MTA"
    $script:dupeRS.ThreadOptions  = "ReuseThread"
    $script:dupeRS.Open()
    $script:dupeRS.SessionStateProxy.SetVariable("scanPath",  $script:pathForRS)
    $script:dupeRS.SessionStateProxy.SetVariable("cancelRef", $script:cancelRef)
    $script:dupeRS.SessionStateProxy.SetVariable("allItems",  $script:allItems)
    $script:dupeRS.SessionStateProxy.SetVariable("uiState",   $script:uiState)

    $script:dupePS = [System.Management.Automation.PowerShell]::Create()
    $script:dupePS.Runspace = $script:dupeRS
    $null = $script:dupePS.AddScript({
        function fmtR($b) {
            if ($b -ge 1TB) { return "{0:N2} TB" -f ($b/1TB) }
            if ($b -ge 1GB) { return "{0:N2} GB" -f ($b/1GB) }
            if ($b -ge 1MB) { return "{0:N2} MB" -f ($b/1MB) }
            if ($b -ge 1KB) { return "{0:N2} KB" -f ($b/1KB) }
            return "$b B"
        }

        $uiState["status"] = "##L.DupeScanFiles##"
        $uiState["pct"]    = 0

        $files   = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
        $counter = 0
        try {
            $stack = [System.Collections.Generic.Stack[string]]::new()
            $stack.Push($scanPath)
            while ($stack.Count -gt 0) {
                if ($cancelRef["cancel"]) { break }
                $cur = $stack.Pop()
                try {
                    foreach ($f in [System.IO.Directory]::GetFiles($cur)) {
                        try {
                            $fi = [System.IO.FileInfo]::new($f)
                            if ($fi.Length -gt 0) { $files.Add($fi); $counter++ }
                        } catch {}
                    }
                    foreach ($d in [System.IO.Directory]::GetDirectories($cur)) { $stack.Push($d) }
                } catch {}
                if ($counter % 200 -eq 0 -and $counter -gt 0) {
                    $uiState["status"] = "$counter ##L.DupeFilesFound##"
                }
            }
        } catch {}

        if ($cancelRef["cancel"]) {
            $uiState["status"] = "##L.DupeCancelled##"
            $uiState["done"]   = $true
            return
        }

        $total = $files.Count
        $uiState["status"] = "$total ##L.DupeStartSearch##"
        $uiState["pct"]    = 0

        $bySize     = $files | Group-Object Length | Where-Object { $_.Count -gt 1 }
        $candidates = @($bySize | ForEach-Object { $_.Group })
        $cTotal     = $candidates.Count
        $done       = 0
        $md5        = [System.Security.Cryptography.MD5]::Create()
        $chunkSize  = 65536

        $uiState["status"] = "##L.DupeQuickHash##: $cTotal ##L.DupeCandidates##..."

        $quickMap = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[System.IO.FileInfo]]]::new()

        foreach ($fi in $candidates) {
            if ($cancelRef["cancel"]) { break }
            $done++
            try {
                $fs  = [System.IO.File]::OpenRead($fi.FullName)
                $len = $fs.Length
                $buf = [byte[]]::new([Math]::Min($chunkSize * 2, $len))
                $read = $fs.Read($buf, 0, [Math]::Min($chunkSize, $len))
                if ($len -gt $chunkSize) {
                    $fs.Seek([Math]::Max(0, $len - $chunkSize), "Begin") | Out-Null
                    $null = $fs.Read($buf, $read, $buf.Length - $read)
                }
                $fs.Dispose()
                $qhash = [System.BitConverter]::ToString($md5.ComputeHash($buf)).Replace("-","")
                if (-not $quickMap.ContainsKey($qhash)) {
                    $quickMap[$qhash] = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
                }
                $quickMap[$qhash].Add($fi)
            } catch { try { $fs.Dispose() } catch {} }

            if ($done % 20 -eq 0 -or $done -eq $cTotal) {
                $uiState["pct"]    = [int]($done / [Math]::Max($cTotal,1) * 50)
                $uiState["status"] = "##L.DupeQuickHash##: $done / $cTotal..."
            }
        }

        $fullCandidates = @($quickMap.Values | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_ })
        $fTotal = $fullCandidates.Count
        $fdone  = 0
        $uiState["status"] = "##L.DupeFullHash##: $fTotal ##L.DupeHits##..."

        $hashMap = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[System.IO.FileInfo]]]::new()

        foreach ($fi in $fullCandidates) {
            if ($cancelRef["cancel"]) { break }
            $fdone++
            try {
                $fs   = [System.IO.File]::OpenRead($fi.FullName)
                $hash = [System.BitConverter]::ToString($md5.ComputeHash($fs)).Replace("-","")
                $fs.Dispose()
                if (-not $hashMap.ContainsKey($hash)) {
                    $hashMap[$hash] = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
                }
                $hashMap[$hash].Add($fi)
            } catch { try { $fs.Dispose() } catch {} }

            if ($fdone % 10 -eq 0 -or $fdone -eq $fTotal) {
                $uiState["pct"]    = 50 + [int]($fdone / [Math]::Max($fTotal,1) * 50)
                $uiState["status"] = "##L.DupeFullHash##: $fdone / $fTotal..."
            }
        }
        $md5.Dispose()

        $dupes   = $hashMap.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
        $groupNr = 0
        $waste   = [long]0

        foreach ($entry in $dupes) {
            if ($cancelRef["cancel"]) { break }
            $groupNr++
            $hash      = $entry.Key
            $hashShort = "##L.DupeGroup## $groupNr  [$($hash.Substring(0,8))]"
            $grpFiles  = $entry.Value | Sort-Object LastWriteTime

            $waste += ($grpFiles.Count - 1) * $grpFiles[0].Length

            foreach ($fi in $grpFiles) {
                $item = [PSCustomObject]@{
                    Name      = $fi.Name
                    Dir       = $fi.DirectoryName
                    FullPath  = $fi.FullName
                    SizeFmt   = fmtR $fi.Length
                    Size      = $fi.Length
                    Date      = $fi.LastWriteTime.ToString("dd.MM.yyyy HH:mm")
                    Hash      = $hash
                    HashShort = $hashShort
                    Group     = "#$groupNr"
                }
                $allItems.Add($item)
            }
        }

        $uiState["groupNr"] = $groupNr
        $uiState["waste"]   = $waste
        $uiState["pct"]     = 100
        $uiState["status"]  = if ($cancelRef["cancel"]) { "##L.DupeCancelled##" }
                               elseif ($groupNr -eq 0)  { "##L.DupeNoneFound##" }
                               else                     { "##L.DupeSummary##" -f $groupNr }
        $uiState["done"]    = $true
    })

    $script:dupeHandle = $script:dupePS.BeginInvoke()

    # Timer im UI-Thread pollt $script:uiState alle 150ms
    $script:dupeTimer = [System.Windows.Threading.DispatcherTimer]::new()
    $script:dupeTimer.Interval = [TimeSpan]::FromMilliseconds(150)
    $script:dupeTimer.Add_Tick({
        if ($script:cancelScan -and $script:cancelRef) {
            $script:cancelRef["cancel"] = $true
        }
        $pct    = $script:uiState["pct"]
        $status = $script:uiState["status"]
        if ($null -ne $pct)    { $script:pb.Value      = [int]$pct; $script:lblPct.Text    = "$([int]$pct) %" }
        if ($null -ne $status) { $script:lblStatus.Text = [string]$status }

        if ($script:uiState["done"]) {
            $script:dupeTimer.Stop()
            try { $script:dupePS.EndInvoke($script:dupeHandle) } catch {}
            $script:dupePS.Dispose()
            $script:dupeRS.Dispose()
            $script:btnScan.IsEnabled   = $true
            $script:btnCancel.IsEnabled = $false
            $waste   = $script:uiState["waste"]
            if ($waste -and [long]$waste -gt 0) {
                $script:lblWaste.Text = "##L.DupeWasted##: $(fmt ([long]$waste))"
            } else { $script:lblWaste.Text = "" }
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($script:lvResults.ItemsSource)
            if ($view) { $view.Refresh() }
        }
    })
    $script:dupeTimer.Start()
})

$script:w.ShowDialog() | Out-Null
'@

    $dupeScript  = $dupeScript.Replace("STARTPATH_PLACEHOLDER", $startPath)
    # Sprachtexte einsetzen: ##L.Key## → aufgelöster Wert
    foreach ($key in $L.Keys) {
        $dupeScript = $dupeScript.Replace("##L.$key##", $L[$key])
    }

    # Temp-Datei schreiben und als eigenen Prozess starten
    $tmp = [System.IO.Path]::GetTempFileName() -replace "\.tmp$", ".ps1"
    [System.IO.File]::WriteAllText($tmp, $dupeScript, [System.Text.Encoding]::UTF8)

    $psi = [System.Diagnostics.ProcessStartInfo]::new("powershell.exe")
    $psi.Arguments       = "-ExecutionPolicy Bypass -NonInteractive -File `"$tmp`""
    $psi.CreateNoWindow  = $true
    $psi.UseShellExecute = $false
    [System.Diagnostics.Process]::Start($psi) | Out-Null
})

# ===== Leere-Ordner-Finder =====
$btnEmptyFolders.Add_Click({
    $startPath = if ($script:BrowserCurrent) { $script:BrowserCurrent }
                 elseif ($cmbPath.Text)       { $cmbPath.Text }
                 else                         { $env:USERPROFILE }

    $emptyScript = @'
Add-Type -Name Win32 -Namespace Native -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
$consoleHwnd = (Get-Process -Id $PID).MainWindowHandle
if ($consoleHwnd -ne [IntPtr]::Zero) { [Native.Win32]::ShowWindow($consoleHwnd, 0) | Out-Null }

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$startPath = "STARTPATH_PLACEHOLDER"

$xaml = [xml]@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Disk Lens – ##L.EmptyTitle##" Height="640" Width="860"
        Background="#1E1E2E" Foreground="#E2E8F0" FontFamily="Segoe UI" FontSize="13"
        WindowStartupLocation="CenterScreen">
  <Window.Resources>
    <Style x:Key="Btn" TargetType="Button">
      <Setter Property="Foreground" Value="#E2E8F0"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="Padding" Value="12,6"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Opacity" Value="0.85"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Opacity" Value="0.4"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>
  <Grid Margin="20">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- Header -->
    <StackPanel Grid.Row="0" Margin="0,0,0,16">
      <TextBlock Text="##L.EmptyHeader##" FontSize="22" FontWeight="Bold" Foreground="#F59E0B"/>
      <TextBlock Text="##L.EmptySubtitle##" FontSize="11" Foreground="#9CA3AF" Margin="0,3,0,0"/>
    </StackPanel>

    <!-- Pfad-Zeile -->
    <Grid Grid.Row="1" Margin="0,0,0,10">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="Auto"/>
        <ColumnDefinition Width="Auto"/>
        <ColumnDefinition Width="Auto"/>
      </Grid.ColumnDefinitions>
      <TextBox x:Name="txtPath" Grid.Column="0" Text="STARTPATH_PLACEHOLDER"
               Background="#2D2D3F" Foreground="#E2E8F0" BorderBrush="#4B5563"
               BorderThickness="1" Padding="8,6" FontSize="13"/>
      <Button x:Name="btnBrowse" Grid.Column="1" Content="##L.EmptyBtnBrowse##" Style="{StaticResource Btn}"
              Background="#374151" Margin="8,0,0,0"/>
      <Button x:Name="btnScan" Grid.Column="2" Content="##L.EmptyBtnScan##" Style="{StaticResource Btn}"
              Background="#D97706" Margin="8,0,0,0"/>
      <Button x:Name="btnCancel" Grid.Column="3" Content="##L.EmptyBtnCancel##" Style="{StaticResource Btn}"
              Background="#374151" IsEnabled="False" Margin="8,0,0,0"/>
    </Grid>

    <!-- Fortschritt -->
    <Grid Grid.Row="2" Margin="0,0,0,10">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="Auto"/>
      </Grid.ColumnDefinitions>
      <ProgressBar x:Name="pb" Grid.Column="0" Height="6" Minimum="0" Maximum="100" Value="0"
                   Background="#374151" Foreground="#F59E0B"/>
      <TextBlock x:Name="lblPct" Grid.Column="1" Text="" Foreground="#9CA3AF"
                 FontSize="11" Margin="8,0,0,0" VerticalAlignment="Center" Width="36"/>
    </Grid>

    <!-- Ergebnisliste -->
    <ListView x:Name="lvResults" Grid.Row="3"
              Background="#2D2D3F" BorderThickness="0"
              Foreground="#E2E8F0" FontSize="13"
              SelectionMode="Extended">
      <ListView.View>
        <GridView>
          <GridView.ColumnHeaderContainerStyle>
            <Style TargetType="GridViewColumnHeader">
              <Setter Property="Background" Value="#1A1A2E"/>
              <Setter Property="Foreground" Value="#F59E0B"/>
              <Setter Property="FontWeight" Value="SemiBold"/>
              <Setter Property="Padding" Value="8,6"/>
              <Setter Property="BorderBrush" Value="#374151"/>
              <Setter Property="BorderThickness" Value="0,0,1,1"/>
            </Style>
          </GridView.ColumnHeaderContainerStyle>
          <GridViewColumn Header="##L.EmptyColPath##" Width="620" DisplayMemberBinding="{Binding FullPath}"/>
          <GridViewColumn Header="##L.EmptyColDate##" Width="140" DisplayMemberBinding="{Binding Date}"/>
        </GridView>
      </ListView.View>
      <ListView.ItemContainerStyle>
        <Style TargetType="ListViewItem">
          <Setter Property="Padding" Value="4,3"/>
          <Style.Triggers>
            <Trigger Property="IsMouseOver" Value="True">
              <Setter Property="Background" Value="#3D3D5C"/>
            </Trigger>
            <Trigger Property="IsSelected" Value="True">
              <Setter Property="Background" Value="#78350F"/>
            </Trigger>
          </Style.Triggers>
        </Style>
      </ListView.ItemContainerStyle>
      <ListView.ContextMenu>
        <ContextMenu Background="#2D2D3F" BorderBrush="#4B5563" Foreground="#E2E8F0">
          <MenuItem x:Name="ctxExplorer"  Header="##L.EmptyCtxExplorer##" Background="#2D2D3F" Foreground="#E2E8F0"/>
          <MenuItem x:Name="ctxCopyPath"  Header="##L.EmptyCtxCopyPath##" Background="#2D2D3F" Foreground="#E2E8F0"/>
          <Separator Background="#374151"/>
          <MenuItem x:Name="ctxDelete"    Header="##L.EmptyCtxDelete##" Background="#2D2D3F" Foreground="#F87171"/>
        </ContextMenu>
      </ListView.ContextMenu>
    </ListView>

    <!-- Aktionsleiste -->
    <Grid Grid.Row="4" Margin="0,10,0,0">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="Auto"/>
        <ColumnDefinition Width="Auto"/>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="Auto"/>
      </Grid.ColumnDefinitions>
      <Button x:Name="btnDeleteAll" Grid.Column="0" Content="##L.EmptyBtnDeleteAll##" Style="{StaticResource Btn}"
              Background="#7F1D1D" IsEnabled="False"/>
      <Button x:Name="btnDeleteSel" Grid.Column="1" Content="##L.EmptyBtnDeleteSel##" Style="{StaticResource Btn}"
              Background="#991B1B" IsEnabled="False" Margin="8,0,0,0"/>
      <TextBlock x:Name="lblCount" Grid.Column="2" Text="" Foreground="#9CA3AF"
                 FontSize="12" VerticalAlignment="Center" Margin="12,0,0,0"/>
    </Grid>

    <!-- Statusleiste -->
    <Border Grid.Row="5" Background="#111827" Padding="8,6" Margin="0,10,0,0" CornerRadius="6">
      <TextBlock x:Name="lblStatus" Text="##L.EmptyStatusReady##" Foreground="#9CA3AF" FontSize="11"/>
    </Border>
  </Grid>
</Window>
"@

$script:w         = [Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($xaml))
$script:txtPath   = $script:w.FindName("txtPath")
$script:btnBrowse = $script:w.FindName("btnBrowse")
$script:btnScan   = $script:w.FindName("btnScan")
$script:btnCancel = $script:w.FindName("btnCancel")
$script:lvResults = $script:w.FindName("lvResults")
$script:lblStatus = $script:w.FindName("lblStatus")
$script:lblCount  = $script:w.FindName("lblCount")
$script:pb        = $script:w.FindName("pb")
$script:lblPct    = $script:w.FindName("lblPct")
$script:btnDeleteAll = $script:w.FindName("btnDeleteAll")
$script:btnDeleteSel = $script:w.FindName("btnDeleteSel")
$ctxExplorer      = $script:w.FindName("ctxExplorer")
$ctxCopyPath      = $script:w.FindName("ctxCopyPath")
$ctxDelete        = $script:w.FindName("ctxDelete")

$script:cancelScan = $false

function deleteFolder($path) {
    try {
        Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
        return $true
    } catch { return $false }
}

# Kontextmenü
$ctxExplorer.Add_Click({
    $sel = $script:lvResults.SelectedItem
    if ($sel) { Start-Process explorer.exe "/select,`"$($sel.FullPath)`"" }
})
$ctxCopyPath.Add_Click({
    $sel = $script:lvResults.SelectedItem
    if ($sel) { [System.Windows.Clipboard]::SetText($sel.FullPath) }
})
$ctxDelete.Add_Click({
    $sel = @($script:lvResults.SelectedItems)
    if (-not $sel) { return }
    $msg = "##L.EmptyDeleteSelMsg##" -f $sel.Count
    if ([System.Windows.MessageBox]::Show($msg,"##L.EmptyConfirmTitle##","YesNo","Warning") -ne "Yes") { return }
    foreach ($item in $sel) { deleteFolder $item.FullPath | Out-Null }
    $src = $script:lvResults.ItemsSource
    foreach ($item in $sel) { $src.Remove($item) | Out-Null }
    $script:lblCount.Text = "##L.EmptyFound##" -f $src.Count
    $script:btnDeleteAll.IsEnabled = $src.Count -gt 0
})

$script:lvResults.Add_SelectionChanged({
    $script:btnDeleteSel.IsEnabled = ($script:lvResults.SelectedItems.Count -gt 0)
})

$script:btnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.SelectedPath = $script:txtPath.Text
    if ($dlg.ShowDialog() -eq "OK") { $script:txtPath.Text = $dlg.SelectedPath }
})

$script:btnCancel.Add_Click({ $script:cancelScan = $true })

$script:btnDeleteAll.Add_Click({
    $src = $script:lvResults.ItemsSource
    if (-not $src -or $src.Count -eq 0) { return }
    $msg = "##L.EmptyDeleteAllMsg##" -f $src.Count
    if ([System.Windows.MessageBox]::Show($msg,"##L.EmptyConfirmTitle##","YesNo","Warning") -ne "Yes") { return }
    $all = @($src)
    # Tiefste Pfade zuerst (laengster Pfad = am tiefsten)
    $sorted = $all | Sort-Object { $_.FullPath.Length } -Descending
    foreach ($item in $sorted) { deleteFolder $item.FullPath | Out-Null }
    $src.Clear()
    $script:lblCount.Text = "##L.EmptyAllDeleted##"
    $script:btnDeleteAll.IsEnabled = $false
    $script:btnDeleteSel.IsEnabled = $false
})

$script:btnDeleteSel.Add_Click({
    $sel = @($script:lvResults.SelectedItems)
    if (-not $sel) { return }
    $sorted = $sel | Sort-Object { $_.FullPath.Length } -Descending
    foreach ($item in $sorted) { deleteFolder $item.FullPath | Out-Null }
    $src = $script:lvResults.ItemsSource
    foreach ($item in $sel) { $src.Remove($item) | Out-Null }
    $script:lblCount.Text = "##L.EmptyFound##" -f $src.Count
    $script:btnDeleteAll.IsEnabled = $src.Count -gt 0
    $script:btnDeleteSel.IsEnabled = $false
})

$script:btnScan.Add_Click({
    $scanPath = $script:txtPath.Text.Trim()
    if (-not $scanPath -or -not (Test-Path -LiteralPath $scanPath)) {
        [System.Windows.MessageBox]::Show("##L.EmptyInvalidPath##")
        return
    }
    $script:btnScan.IsEnabled      = $false
    $script:btnCancel.IsEnabled    = $true
    $script:btnDeleteAll.IsEnabled = $false
    $script:btnDeleteSel.IsEnabled = $false
    $script:cancelScan             = $false
    $script:pb.Value               = 0
    $script:lblPct.Text            = ""
    $script:lblStatus.Text         = "##L.EmptySearching##"
    $script:lblCount.Text          = ""

    $script:allItems  = [System.Collections.ObjectModel.ObservableCollection[object]]::new()
    $script:lvResults.ItemsSource = $script:allItems
    # ConcurrentBag als thread-sicherer Puffer – Timer überträgt in ObservableCollection
    $script:resultBag = [System.Collections.Concurrent.ConcurrentBag[object]]::new()

    $script:uiState   = [System.Collections.Concurrent.ConcurrentDictionary[string,object]]::new()
    $script:cancelRef = [System.Collections.Concurrent.ConcurrentDictionary[string,bool]]::new()
    $script:cancelRef["cancel"] = $false

    $script:dupeRS = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $script:dupeRS.ApartmentState = "MTA"; $script:dupeRS.ThreadOptions = "ReuseThread"; $script:dupeRS.Open()
    $script:dupeRS.SessionStateProxy.SetVariable("scanPath",   $scanPath)
    $script:dupeRS.SessionStateProxy.SetVariable("cancelRef",  $script:cancelRef)
    $script:dupeRS.SessionStateProxy.SetVariable("resultBag",  $script:resultBag)
    $script:dupeRS.SessionStateProxy.SetVariable("uiState",    $script:uiState)

    $script:dupePS = [System.Management.Automation.PowerShell]::Create()
    $script:dupePS.Runspace = $script:dupeRS
    $null = $script:dupePS.AddScript({
        $uiState["status"] = "##L.EmptyReadAll##"
        $uiState["pct"]    = 0

        $allDirs = [System.Collections.Generic.List[string]]::new()
        $stack   = [System.Collections.Generic.Stack[string]]::new()
        $stack.Push($scanPath)
        $counter = 0
        while ($stack.Count -gt 0) {
            if ($cancelRef["cancel"]) { break }
            $cur = $stack.Pop()
            try {
                $allDirs.Add($cur)
                $counter++
                if ($counter % 300 -eq 0) { $uiState["status"] = "##L.EmptyFoundN##".Replace("{0}",$counter) }
                foreach ($sub in [System.IO.Directory]::GetDirectories($cur)) { $stack.Push($sub) }
            } catch {}
        }

        if ($cancelRef["cancel"]) {
            $uiState["status"] = "##L.EmptyAborted##"; $uiState["done"] = $true; return
        }

        $total = $allDirs.Count
        $uiState["status"] = "##L.EmptyChecking##".Replace("{0}",$total)
        $done  = 0

        $sorted = $allDirs | Sort-Object { $_.Length } -Descending

        foreach ($dirPath in $sorted) {
            if ($cancelRef["cancel"]) { break }
            $done++
            if ($done % 50 -eq 0) {
                $uiState["pct"]    = [int]($done / [Math]::Max($total,1) * 100)
                $uiState["status"] = "##L.EmptyCheckProgress##".Replace("{0}",$done).Replace("{1}",$total)
            }
            try {
                $hasFiles = [System.IO.Directory]::GetFiles($dirPath).Length -gt 0
                $hasDirs  = [System.IO.Directory]::GetDirectories($dirPath).Length -gt 0
                if (-not $hasFiles -and -not $hasDirs) {
                    $di = [System.IO.DirectoryInfo]::new($dirPath)
                    $resultBag.Add([PSCustomObject]@{
                        FullPath = $dirPath
                        Date     = $di.LastWriteTime.ToString("dd.MM.yyyy HH:mm")
                    })
                }
            } catch {}
        }

        $uiState["pct"]  = 100
        $uiState["done"] = $true
    })

    $script:dupeHandle = $script:dupePS.BeginInvoke()

    $script:dupeTimer = [System.Windows.Threading.DispatcherTimer]::new()
    $script:dupeTimer.Interval = [TimeSpan]::FromMilliseconds(150)
    $script:dupeTimer.Add_Tick({
        if ($script:cancelScan -and $script:cancelRef) {
            $script:cancelRef["cancel"] = $true
        }
        $pct    = $script:uiState["pct"]
        $status = $script:uiState["status"]
        if ($null -ne $pct)    { $script:pb.Value = [int]$pct; $script:lblPct.Text = "$([int]$pct) %" }
        if ($null -ne $status) { $script:lblStatus.Text = [string]$status }

        if ($script:uiState["done"]) {
            $script:dupeTimer.Stop()
            try { $script:dupePS.EndInvoke($script:dupeHandle) } catch {}
            $script:dupePS.Dispose(); $script:dupeRS.Dispose()
            $script:btnScan.IsEnabled   = $true
            $script:btnCancel.IsEnabled = $false
            # Ergebnisse aus ConcurrentBag in ObservableCollection übertragen (UI-Thread)
            $item = $null
            while ($script:resultBag.TryTake([ref]$item)) { $script:allItems.Add($item) }
            $cnt = $script:allItems.Count
            if ($cnt -gt 0) {
                $script:lblCount.Text          = "##L.EmptyFound##" -f $cnt
                $script:lblStatus.Text         = "##L.EmptyFound##" -f $cnt
                $script:btnDeleteAll.IsEnabled = $true
            } else {
                $script:lblCount.Text  = ""
                $script:lblStatus.Text = "##L.EmptyNoneFound##"
            }
        }
    })
    $script:dupeTimer.Start()
})

$script:w.ShowDialog() | Out-Null
'@

    $emptyScript = $emptyScript.Replace("STARTPATH_PLACEHOLDER", $startPath)
    # Sprachtexte einsetzen: ##L.Key## → aufgelöster Wert
    foreach ($key in $L.Keys) {
        $emptyScript = $emptyScript.Replace("##L.$key##", $L[$key])
    }

    $tmp = [System.IO.Path]::GetTempFileName() -replace "\.tmp$", ".ps1"
    [System.IO.File]::WriteAllText($tmp, $emptyScript, [System.Text.Encoding]::UTF8)

    $psi = [System.Diagnostics.ProcessStartInfo]::new("powershell.exe")
    $psi.Arguments       = "-ExecutionPolicy Bypass -NonInteractive -File `"$tmp`""
    $psi.CreateNoWindow  = $true
    $psi.UseShellExecute = $false
    [System.Diagnostics.Process]::Start($psi) | Out-Null
})

# ===== Fenster anzeigen =====
$window.ShowDialog() | Out-Null
