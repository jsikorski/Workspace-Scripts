. .\configuration.ps1
. .\scriptsUtils.ps1

$script:powerShellDir     	  = Split-Path $PROFILE
$script:installDir 		  	  = "$powerShellDir\Workspace scripts"
$script:poshGitDir 		  	  = "$installDir\Posh-Git"
$script:configurationFile	  = "configuration.ps1"
$script:configurationFilePath = "$installDir\$configurationFile" 

function script:Invoke-ErrorCheck($errorMessage) {
	if (!$?) {
		Write-ErrorMessage ($errorMessage + " Installation aborted.")
		if (Test-Path $installDir) {
			Remove-Item -Recurse -Force $installDir
		}
		exit 1
	}
}

function script:Invoke-InstallationStep($step) {
	Write-Host
	& $step
}

function script:Start-Installation() {
	Write-Host "Starting installation..."
	Write-Host "Instalation directory: $installDir"
}

function script:Remove-OldInstallation() {
	Write-Host "Removing old installations..."
	if ((Test-Path $installDir)) {
		Remove-Item -Recurse -Force -Exclude $configurationFile "$installDir\*"
		Invoke-ErrorCheck "Cannot create PowerShell directory."	
		Write-Host "Old installations removed."
	}
	else {
		Write-Host "Old installations were not found."
	}
}

function script:Create-PowerShellDirectory() {
	Write-Host "Creating PowerShell directory..."
	
	if (!(Test-Path $powerShellDir)) {
		New-Item -Type Directory $powerShellDir > $null
		Invoke-ErrorCheck "Cannot create PowerShell directory."	
		Write-Host "PowerShell directory created."
	}
	else {
		Write-Host "PowerShell directory already exists."
	}
}

function script:Create-InstallationDirectory() {
	Write-Host "Creating installation directory..."
	
	if (!(Test-Path $installDir)) {
		New-Item -Type Directory $installDir > $null
		Invoke-ErrorCheck "Cannot create installation directory."	
		Write-Host "Installation directory created."
	}
	else {
		Write-Host "Installation directory already exists."
	}
}

function script:Get-PoshGit() {
	Write-Host "Downloading Posh-Git..."
	git clone https://github.com/dahlbyk/posh-git.git $poshGitDir
	Invoke-ErrorCheck "Cannot download Posh-Git."
	Write-Host "Posh-Git downloaded."
}

function script:Invoke-PoshGitInstallation() {
	Write-Host "Installing Posh-Git..."
	& "$poshGitDir\install.ps1"
	Invoke-ErrorCheck "Cannot install Posh-Git."
	Write-Host "Posh-Git installed."
}

function script:Copy-Files() {
	Write-Host "Copying files..."

	if (!(Test-Path $configurationFilePath)) {
		Copy-Item * $installDir
	}
	else {
		Write-Warning "Old configuration file was detected. It wont be removed..."
		
		$oldConfigurationContent = Get-Content -Path $configurationFilePath
		Copy-Item * $installDir
		Set-Content -Path $configurationFilePath -Value $oldConfigurationContent
	}
	Invoke-ErrorCheck "Cannot copy files."
	
	Write-Host "Files copied."
}

function script:Create-PowerShellProfile() {
	Write-Host "Creating PowerShell profile file..."
	
	if (!(Test-Path $PROFILE)) {
		New-Item -type File $PROFILE > $null
		Invoke-ErrorCheck "Cannot create PowerShell profile file."
		Write-Host "PowerShell profile file created."
	}
	else {
		Write-Host "PowerShell profile file already exists."
	}
}

function script:Set-Configuration() {
	Write-Host "Configuring PowerShell module..."
		
	$loadLine = "Import-Module '$installDir\workspace.psm1'"
	if	(Select-String -Path $PROFILE -Pattern $loadLine -SimpleMatch -Quiet) {
		Write-Warning "It seems workspace scripts were already installed..."
	}
	else {
@"

# Load workspace scripts
$loadLine

# Start Pageant
Start-Pageant
"@ | Out-File $PROFILE -Append -Encoding utf8
		Invoke-ErrorCheck "Cannot configure PowerShell module."
	}
	
	Write-Host "Poweshell module configured."
}

function script:Set-GitUserSettings() {
	Write-Host "Setting Git user settings..."
	
	git config --global user.name $gitUserName
	git config --global user.email $gitUserEmail
	
	Write-Host "Git user settings set (user.name = $gitUserName, user.email = $gitUserEmail)."
}

function script:Set-GitSSHVariable() {
	Write-Host "Setting GIT_SSH environment variable..."
	
	$plinkPath = "$puttyDirPath\plink.exe"
	[Environment]::SetEnvironmentVariable("GIT_SSH", $plinkPath, "User")
	
	Write-Host "GIT_SSH variable set to $plinkPath."
}

function script:Stop-Installation() {
	Write-Host "Installation ended."
	Write-Host
}

#Installation
Invoke-InstallationStep("Start-Installation")
Invoke-InstallationStep("Remove-OldInstallation")
Invoke-InstallationStep("Create-PowerShellDirectory")
Invoke-InstallationStep("Create-InstallationDirectory")
Invoke-InstallationStep("Get-PoshGit")
Invoke-InstallationStep("Invoke-PoshGitInstallation")
Invoke-InstallationStep("Copy-Files")
Invoke-InstallationStep("Create-PowerShellProfile")
Invoke-InstallationStep("Set-Configuration")
Invoke-InstallationStep("Set-GitUserSettings")
Invoke-InstallationStep("Set-GitSSHVariable")
Invoke-InstallationStep("Stop-Installation")
