Push-Location $PROFILE\..
$script:installDir = Get-Location
Pop-Location

#Begining installation
Write-Host
Write-Host "Begining installation..."
Write-Host "Instalation directory: $installDir"

#Downloading Posh-Git
Write-Host
Write-Host "Downloading Posh-Git..."
Push-Location $installDir
git clone https://github.com/dahlbyk/posh-git.git Posh-Git
Pop-Location
Write-Host "Posh-Git downloaded."

#Installing Posh-Git (it creates also Powershell profile)
Write-Host
Write-Host "Installing Posh-Git..."
Push-Location $installDir\Posh-Git
.\install.ps1
Pop-Location
Write-Host "Posh-Git installed."

#Copying files
Write-Host
Write-Host "Copying files..."
if (!(Test-Path $installDir\"Workspace scripts"))
{
	New-Item -Type Directory $installDir\"Workspace scripts" > $null
}
Copy-Item * $installDir\"Workspace scripts"
Write-Host "Files copied."

#Configuring Powershell profile
Write-Host
Write-Host "Configuring Powershell module..."
$loadLine = "Import-Module '$installDir\Workspace scripts\workspace.psm1'"
if	(Select-String -Path $PROFILE -Pattern $loadLine -SimpleMatch -Quiet) {
	Write-Warning "It seems workspace scripts are already installed..."
}
else {
@"

# Load workspace scripts
$loadLine
"@ | Out-File $PROFILE -Append -Encoding utf8
}

Write-Host "Poweshell module configured."

#Ending installation
Write-Host
Write-Host "Installation ended."
Write-Host
