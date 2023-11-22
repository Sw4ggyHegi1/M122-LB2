param(
    [string]$UserName,
    [string]$DeleteUser,
    [string]$Vorname,
    [string]$Nachname,
    [string]$Passwort
)


# --- User erstellen ---
# Prüft ob user schon vorhanden ist
if (Get-ADUser -Filter {SamAccountName -eq $UserName}) {
    Write-Host "Benutzer $UserName existiert bereits."
    Exit

} else {
    $UserParams = @{
        SamAccountName = $UserName
        UserPrincipalName = "$UserName@m122.ch"
        Name = "$Vorname $Nachname"
        GivenName = $Vorname
        Surname = $Nachname
        Enabled = $true
        AccountPassword = (ConvertTo-SecureString -AsPlainText $Passwort -Force)
    }

    New-ADUser @UserParams
    Write-Host " "
    Write-Host "Benutzer $UserName wurde erfolgreich erstellt."
    Write-Host " "
    Exit
}
# --- User erstellen ende ---

# --- User löschen ---
# Löscht Benutzer
if (Get-ADUser -Filter {SamAccountName -eq $DeleteUser}) {
    Remove-ADUser -Identity $DeleteUser -Confirm:$false
    Write-Host "Benutzer $DeleteUser wurde erfolgreich gelöscht."

# Falls user nicht existiert
} else {
    Write-Host "Benutzer $DeleteUser existiert nicht."
}

# --- User löschen ende ---
