# M122-LB2

## Beschreibung
Dieses Script soll die Bedienung im AD mittels dem AD Powershell Modul vereinfachen.

## Checkliste
Checkliste mit Funktionen die das Script machen soll
- [x] User Erstellen
- [x] User Löschen
- [x] User Suchen
- [x] CSV Import
- [ ] CSV Export
- [ ] User in Organisation Unit verschieben

## Script ablauf
[Flussdiagram](https://nc.daddyhegii.ch/index.php/apps/files_sharing/publicpreview/5tmfWeT5yK9gX3G?file=/&fileId=6460&x=1920&y=1080&a=true&etag=b6e43d91a0b9a18cc2f62a76c94c2340)

## Usage

Create User
```powershell
.\EzAD.ps1 -AddUser "Benutzername"
```

Delete User
```powershell
.\EzAD.ps1 -DeleteUser "Benutzername"
```

Search User
```powershell
.\EzAD.ps1 -SearchUser "Benutzername"
```

Import CSV
```powershell
.\EzAD.ps1 -Import "C:\pfad\zur\CSV"
```
> [!NOTE]
> Eine Vorlage für den CSV Import ist beigelegt.
