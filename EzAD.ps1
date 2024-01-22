param (
    [string]$AddUser,
    [string]$DeleteUser,
    [string]$Import,
    [string]$SearchUser,
    [string]$Export,
    [string]$Move
)

if ($AddUser) {
    # Script User wird aufgefordert den zukünftigen SamAccountName des neuen Users einzugeben
    $UserName = Read-Host "Geben Sie den SamAccountName des Benutzers ein"

    # Prüft, ob der Benutzer bereits vorhanden ist
    if (Get-ADUser -Filter { SamAccountName -eq $UserName }) {
        Write-Host "Benutzer $UserName existiert bereits."
    } else {
        $UserParams = @{}
        
        # Teilweise wird der Script User aufgefordert in der Kosnole etwas einzugeben
        $UserParams.SamAccountName = $UserName
        $UserParams.UserPrincipalName = "$($UserParams.SamAccountName)@m122.ch"
        $UserParams.Name = Read-Host "Geben Sie den Namen des Benutzers ein (Vorname Nachname)"
        $NameParts = $UserParams.Name -split " "
        $UserParams.GivenName = $NameParts[0]
        $UserParams.Surname = $NameParts[1]
        $UserParams.Enabled = $true

        $Password = Read-Host "Geben Sie das Passwort des Benutzers ein" -AsSecureString
        $UserParams.AccountPassword = $Password

        # Fügt alle eingaben des Script Users in das cmdlet ein und erstellt AD User
        New-ADUser @UserParams
        Write-Host "Benutzer $($UserParams.SamAccountName) wurde erfolgreich erstellt."
    }

} elseif ($DeleteUser) {

    # Prüft, ob der zu löschende Benutzer existiert
    if (Get-ADUser -Filter { SamAccountName -eq $DeleteUser }) {
        Remove-ADUser -Identity $DeleteUser -Confirm:$false
        Write-Host "Benutzer $DeleteUser wurde erfolgreich gelöscht."
    } else {
        # Falls dieser nicht existiert, wird das Script abgebrochen
        Write-Host "Benutzer $DeleteUser existiert nicht."
    }
    
} elseif ($Import) {
    $csvPath = $Import

    # Prüft, ob der Pfad zur CSV gültig ist
    if (-not (Test-Path -Path $csvPath -PathType Leaf)) {
        Write-Host "Die angegebene Datei existiert nicht oder ist ungültig. Bitte geben Sie einen gültigen Pfad an."
    } else {
       
        # Einlesen der CSV-Datei
        $users = Import-Csv -Path $csvPath

        # Durchlaufen der Benutzerdaten und Erstellen der Benutzer im AD
        foreach ($user in $users) {
            $Name = $user.Anzeigename
            $firstName = $user.Vorname
            $lastName = $user.Nachname
            $userName = $user.Benutzername
            $password = $user.Passwort
            $userPrincipalName = $user.UserPrincipalName

            # Prüfen, ob der Benutzer bereits vorhanden ist
            if (-not (Get-ADUser -Filter { SamAccountName -eq $userName })) {
                # Benutzer wird erstellt
                New-ADUser -SamAccountName $userName -UserPrincipalName $userPrincipalName -Name $Name -GivenName $firstName -Surname $lastName -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -Enabled $true -ChangePasswordAtLogon $true
                Write-Host "Benutzer '$userName' wurde erstellt."
            } else {
                
                # Wenn der User existiert wird der betroffene CSV Eintrag übersprungen
                Write-Host "Benutzer '$userName' existiert bereits."
            }
        }
    }

} elseif ($SearchUser) {
    $UserName = $SearchUser
    $foundUser = Get-ADUser -Filter { SamAccountName -eq $UserName }

    if ($foundUser) {
        
        # Kann spezifischen User exportieren
        if ($Export) {
            $ExportPath = $Export

            # Prüft ob der Pfad kein Leerzeichen oder Null ist
            if (-not [string]::IsNullOrWhiteSpace($ExportPath)) {
                # Exportiert spezifischen User im AD zum angegebenen Pfad
                $foundUser | Select-Object SamAccountName, Name, UserPrincipalName | Export-Csv -Path $ExportPath -NoTypeInformation
                Write-Host "Benutzerdaten von '$UserName' wurden erfolgreich nach '$ExportPath' exportiert."
            } else {
                Write-Host "Bitte geben Sie einen gültigen Pfad für den Export an."
            }
        } else {
            $foundUser | Format-List -Property *
        }
    } else {
        Write-Host "Benutzer '$UserName' existiert nicht."
    }

} elseif ($Export) {
    $ExportPath = $Export

    # Prüft ob der Pfad kein Leerzeichen oder Null ist
    if (-not [string]::IsNullOrWhiteSpace($ExportPath)) {
        # Exportiert alle User im AD zum angegebenen Pfad
        Get-ADUser -filter * -Properties * | Select-Object SamAccountName, Name, UserPrincipalName | Export-Csv -Path $ExportPath -NoTypeInformation
        Write-Host "Benutzerdaten wurden erfolgreich nach '$ExportPath' exportiert."
    } else {
        Write-Host "Bitte geben Sie einen gültigen Pfad für den Export an."
    }

} elseif ($Move){

    $params = $Move -split ':'
    if ($params.Count -ne 2) {
        # Gibt das Format an mit welchem der User verschoben werden kann
        Write-Host "Bitte geben Sie den Benutzernamen und den Ziel-OU im Format 'Benutzername:OU' an."

    # Verschiebt User anhand der Eingabe des Script Users
    } else {
        $UserName = $params[0]
        $TargetOU = $params[1]
        $foundUser = Get-ADUser -Filter { SamAccountName -eq $UserName }

        if ($foundUser) {
            try {
                # Verschieben des Benutzers
                Move-ADObject -Identity $foundUser.DistinguishedName -TargetPath "OU=$TargetOU,DC=M122,DC=CH"
                Write-Host "Benutzer '$UserName' wurde erfolgreich nach '$TargetOU' verschoben."
            } catch {
                Write-Host "Es gab ein Problem beim Verschieben des Benutzers: $_"
            }
        } else {
            Write-Host "Benutzer '$UserName' existiert nicht."
        }
    }

# Falls ein Schreibfehler eines Parameters oder ein ungültiger Parameter angegeben wurde gibt das Script diese Usage aus
} else {
    Write-Host "Es wurde keine gültige Aktion angegeben. Verwenden Sie '-AddUser', '-DeleteUser', '-SearchUser', '-Import', '-Export' oder '-Move' um eine Aktion auszuführen. Genauere Details bezüglich Script Usage ist auf der Github Repo zu finden."
}
