param (
    [string]$AddUser,
    [string]$DeleteUser,
    [string]$Import,
    [string]$Search
)

# Überprüft, ob ein Benutzer erstellt werden soll
if ($AddUser) {
    $UserName = Read-Host "Geben Sie den SamAccountName des Benutzers ein"

    # Prüft, ob der Benutzer bereits vorhanden ist
    if (Get-ADUser -Filter { SamAccountName -eq $UserName }) {
        Write-Host "Benutzer $UserName existiert bereits."
    } else {
        $UserParams = @{}
        
        $UserParams.SamAccountName = $UserName
        $UserParams.UserPrincipalName = "$($UserParams.SamAccountName)@m122.ch"
        $UserParams.Name = Read-Host "Geben Sie den Namen des Benutzers ein (Vorname Nachname)"
        $NameParts = $UserParams.Name -split " "
        $UserParams.GivenName = $NameParts[0]
        $UserParams.Surname = $NameParts[1]
        $UserParams.Enabled = $true

        $Password = Read-Host "Geben Sie das Passwort des Benutzers ein" -AsSecureString
        $UserParams.AccountPassword = $Password

        New-ADUser @UserParams
        Write-Host "Benutzer $($UserParams.SamAccountName) wurde erfolgreich erstellt."
    }

} elseif ($DeleteUser) {
    # Prüft, ob der zu löschende Benutzer existiert
    if (Get-ADUser -Filter { SamAccountName -eq $DeleteUser }) {
        Remove-ADUser -Identity $DeleteUser -Confirm:$false
        Write-Host "Benutzer $DeleteUser wurde erfolgreich gelöscht."
    } else {
        Write-Host "Benutzer $DeleteUser existiert nicht."
    }
    
} elseif ($Import) {
    $csvPath = Read-Host "Geben Sie den Pfad zur CSV-Datei für den Massenimport ein"

    if (-not (Test-Path -Path $csvPath -PathType Leaf)) {
        Write-Host "Die angegebene Datei existiert nicht oder ist ungültig. Bitte geben Sie einen gültigen Pfad an."
    } else {
        # Einlesen der CSV-Datei
        $users = Import-Csv -Path $csvPath

        # Durchlaufen der Benutzerdaten und Erstellen der Benutzer im AD
        foreach ($user in $users) {
            $firstName = $user.Vorname
            $lastName = $user.Nachname
            $userName = $user.Benutzername
            $password = $user.Passwort
            $department = $user.Abteilung

            # Prüfen, ob der Benutzer bereits vorhanden ist
            if (-not (Get-ADUser -Filter { SamAccountName -eq $userName })) {
                # Benutzer erstellen
                New-ADUser -SamAccountName $userName -GivenName $firstName -Surname $lastName -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -Enabled $true -Department $department
                Write-Host "Benutzer '$userName' wurde erstellt."
            } else {
                Write-Host "Benutzer '$userName' existiert bereits."
            }
        }
    }

# --- UNDER CONSTRUCTION ---
} elseif ($Search) {
    $UserName = ""
    
    if (Get-ADUser -Filter { SamAccountName -eq $UserName}){
        Write-Host "Benutzer '$userName' existiert."
    } else {
        Write-Host "Benutzer '$userName' existiert nicht."
    }
# --- UNDER CONSTRUCTION ---

} else {
    Write-Host "Es wurde keine gültige Aktion angegeben. Verwenden Sie '-AddUser', '-DeleteUser' oder '-Import', um eine Aktion auszuführen."
}
