function Start-Pageant {
	$pageantPath = $puttyDirPath + "\pageant.exe"

	if (!(Test-Path $pageantPath)) {
		Write-Warning "Pageant is not installed or Pageant path is incorrect."
		return
	}
	
	if (!(Test-Path $pageantKeysDirPath)) {
		Write-Warning "Paegant keys directory path is incorrect."
		return
	}
	
	$runCommand = $pageantPath
	[Array]$keys = Get-ChildItem $pageantKeysDirPath -Filter *.ppk
	
	if ($keys.Count -lt 1) {
		Write-Warning "Any Paegant keys was found."
		return
	}
	
	Push-Location $pageantKeysDirPath
	& $runCommand $keys
	Pop-Location
}