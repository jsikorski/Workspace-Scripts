if (Get-Module workspace) {
	return
}

#Load scripts
Push-Location $PROFILE\..\"Workspace scripts"

. .\configuration.ps1
. .\gitUtils.ps1
. .\systemUtils.ps1
. .\pageantLoader.ps1

Pop-Location
