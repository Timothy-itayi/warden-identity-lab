[CmdletBinding()]
param(
    [string]$CsvPath = ".\users.csv"
)

Import-Module ActiveDirectory

$domain = Get-ADDomain
$base   = $domain.DistinguishedName
$usersOu = "OU=Users,$base"

$defaultPassword = Read-Host "Enter temporary password for lab users" -AsSecureString

Import-Csv $CsvPath | ForEach-Object {
    $existing = Get-ADUser -Filter "SamAccountName -eq '$($_.SamAccountName)'" -ErrorAction SilentlyContinue

    if ($existing) {
        Write-Host "SKIP: $($_.SamAccountName) already exists"
        return
    }

    New-ADUser `
        -Name "$($_.FirstName) $($_.LastName)" `
        -GivenName $_.FirstName `
        -Surname $_.LastName `
        -SamAccountName $_.SamAccountName `
        -UserPrincipalName "$($_.SamAccountName)@warden.internal" `
        -Department $_.Department `
        -Path $usersOu `
        -AccountPassword $defaultPassword `
        -Enabled $true `
        -ChangePasswordAtLogon $false

    Write-Host "CREATED: $($_.SamAccountName)"
}
```