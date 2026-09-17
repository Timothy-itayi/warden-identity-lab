# upload_csv.ps1

# 1. Define where you want to save the CSV on the VM
$destinationPath = "C:\temp\new_users.csv"

# 2. Create the folder if it doesn't exist
if (-not (Test-Path "C:\temp")) { 
    New-Item -ItemType Directory -Path "C:\temp" | Out-Null 
}

# 3. Paste your CSV content exactly as it is inside this block
$csvData = @"
FirstName,LastName,SamAccountName,Department
Amina,Okafor,aokafor,Finance
Ben,Whitcombe,bwhitcombe,Operations
Chen,Liu,cliu,Engineering
Duc,Nguyen,dnguyen,Design
Elena,Rossi,erossi,HR
Fatima,Khan,fkhan,Sales
"@

# 4. Write it to the disk
Set-Content -Path $destinationPath -Value $csvData
Write-Host "Success! The CSV file has been written to $destinationPath on the VM."
