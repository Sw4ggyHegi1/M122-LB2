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
[Flussdiagram](https://github.com/Sw4ggyHegi1/M122-LB2/issues/1#issue-2032320056)

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
