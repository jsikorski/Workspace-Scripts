Push-Location $PROFILE\..
$script:installDir 		  = Get-Location
$script:poshGitDir 		  = "$installDir\Posh-Git"
$script:copyDir    		  = "$installDir\Workspace scripts"
$script:configurationFile = "configuration.ps1" 
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
Push-Location $poshGitDir
.\install.ps1
Pop-Location
Write-Host "Posh-Git installed."

#Copying files
Write-Host
Write-Host "Copying files..."
if (!(Test-Path $copyDir))
{
	New-Item -Type Directory $copyDir > $null
}
if (!(Test-Path $copyDir\$configurationFile)) {
	Copy-Item * $copyDir
}
else {
	Copy-Item * $copyDir -Exclude $configurationFile
}
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

# Start Pageant
Start-Pageant
"@ | Out-File $PROFILE -Append -Encoding utf8
}

Write-Host "Poweshell module configured."

#Ending installation
Write-Host
Write-Host "Installation ended."
Write-Host
