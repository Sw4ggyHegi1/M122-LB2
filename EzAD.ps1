param (
    [string]$AddUser,
    [string]$DeleteUser,
    [string]$Import,
    [string]$SearchUser,
    [string]$Export
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
    $csvPath = $Import

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
                # Benutzer erstellen
                New-ADUser -SamAccountName $userName -UserPrincipalName $userPrincipalName -Name $Name -GivenName $firstName -Surname $lastName -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -Enabled $true -ChangePasswordAtLogon $true
                Write-Host "Benutzer '$userName' wurde erstellt."
            } else {
                Write-Host "Benutzer '$userName' existiert bereits."
            }
        }
    }

} elseif ($SearchUser) {
    $UserName = $SearchUser
    $foundUser = Get-ADUser -Filter { SamAccountName -eq $UserName }

    if ($foundUser) {
        # kann spezifischen user exportieren
        if ($Export) {
            $ExportPath = $Export
            if (-not [string]::IsNullOrWhiteSpace($ExportPath)) {
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
    if (-not [string]::IsNullOrWhiteSpace($ExportPath)) {
        Get-ADUser -filter * -Properties * | Select-Object SamAccountName, Name, UserPrincipalName | Export-Csv -Path $ExportPath -NoTypeInformation
        Write-Host "Benutzerdaten wurden erfolgreich nach '$ExportPath' exportiert."
    } else {
        Write-Host "Bitte geben Sie einen gültigen Pfad für den Export an."
    }

} else {
    Write-Host "Es wurde keine gültige Aktion angegeben. Verwenden Sie '-AddUser', '-DeleteUser', '-SearchUser' oder '-Import', um eine Aktion auszuführen."
}
