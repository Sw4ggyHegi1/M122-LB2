# M122-LB2

## Checkliste
Checkliste mit Funktionen die das Script machen soll
- [x] User Erstellen
- [x] User Löschen
- [ ] User Suchen -> in arbeit
- [x] CSV Import
- [ ] CSV Export
- [ ] User in Organisation Unit verschieben


## Usage

Create User
```powershell
.\EzAD.ps1 -AddUser [Username eingeben]
```

Delete User
```powershell
.\EzAD.ps1 -DeleteUser [SamAccountName eingeben]
```

Import CSV
```powershell
.\EzAD.ps1 -Import "C:\pfad\zur\CSV"
```
