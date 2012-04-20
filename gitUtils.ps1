. .\scriptsUtils.ps1

###### Private #####
function script:Invoke-ErrorCheck($errorMessage) {
	if (!$?) {
		Write-ErrorMessage "ERROR: $errorMessage"
		break
	}
}

function script:Get-BranchName($string) {
	$branchName = ([string]$string).Replace("*", "").Trim()
	return $branchName
}

function script:Get-CurrentBranch {
	$branches = git branch
	Invoke-ErrorCheck "Cannot get branches list."
	
	foreach ($branch in $branches) {
		if (([string]$branch).StartsWith("*")) {
			$branchName = Get-BranchName($branch)
			return $branchName;
		}
	}
}

##### Public #####
function Start-Feature {
	param(
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$FeatureName
	)
	
	Write-Info "Creating branch for feature $FeatureName..."	
	git branch $FeatureName
	Invoke-ErrorCheck "Cannot create branch."
	
	Write-Info "Switching to feature branch..."
	git checkout $FeatureName
	
	Write-Info "Feature $FeatureName started."
}

function Update-Feature {
	param(
		[switch]
		$Continue
	)

	if ($Continue) {
		Write-Info "Continuing rebasing feature..."
		git rebase --continue
		Invoke-ErrorCheck "Cannot rebase feature."
	}
	else {
		$currentBranch = Get-CurrentBranch
	
		Write-Info "Pulling changes from origin..."
		git checkout master
		Invoke-ErrorCheck "Cannot checkout branch to master."
		git pull origin master
		Invoke-ErrorCheck "Cannot pull changes from origin."

		Write-Info "Rebasing feature..."
		git checkout $currentBranch
		git rebase master
		Invoke-ErrorCheck "Cannot rebase feature."
	}
	
	Write-Info "Feature updated"	
}

function Submit-Feature {
	param(
		[switch]
		$Continue
	)

	if ($Continue) {
		Write-Info "Continuing updating feature..."
		Update-Feature -Continue
	}
	else {
		Write-Info "Updating feature..."
		Update-Feature
	}
	
	Write-Info "Merging master and feature branches..."
	git checkout master
	git merge $currentBranch
	
	Write-Info "Pushing changes to origin..."
	git push origin master
	Invoke-ErrorCheck "Cannot push changes to origin."
	
	Write-Info "Feature submited."
}

function Move-Changes {
	param(
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$NewBranchName
	)

	Write-Info "Stashing changes..."
	git stash
	Invoke-ErrorCheck "Cannot stash changes."
	
	Write-Info "Switching to target branch ($NewBranchName)..."
	git branch $NewBranchName
	git checkout $NewBranchName
	
	Write-Info "Applying changes to target branch..."
	git stash pop
	Invoke-ErrorCheck "Cannot apply changes to target branch."

	Write-Info "Changes moved to $NewBranchName branch or there are some confilcts to resolve."
}

function Remove-Branch {
	param(
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$BranchName
	)

	if ($BranchName -eq "master") {
		Write-ErrorMessage "Master branch shoudn't be removed."
		return
	}
	
	git branch -D $BranchName
	Invoke-ErrorCheck "Cannot remove branch $BranchName."
	Write-Info "Branch $BranchName removed."
}

function Clear-Branches {
	if (([string](Get-CurrentBranch)) -ne "master") {
		Write-ErrorMessage "Branches can be cleared only from master branch."
		return
	}

	$branches = git branch
	foreach ($branch in $branches) {
		if (!([string]$branch).StartsWith("*")) { 
			$branchName = Get-BranchName($branch)
			Remove-Branch -BranchName $branchName
		}
	}
	
	Write-Info "Branches cleared."
}