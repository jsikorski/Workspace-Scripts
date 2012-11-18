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

function script:Test-LocalBranch($branchName) {
	git show-ref --verify --quiet "refs/heads/$branchName"
	return $?
}

##### Public #####
function Start-Feature {
	param(
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$FeatureName
	)
	
	$featureBranch = "feature/$FeatureName"

	Write-Info "Creating branch for feature $FeatureName..."	
	git branch $featureBranch
	Invoke-ErrorCheck "Cannot create branch."
	
	Write-Info "Switching to feature branch..."
	git checkout $featureBranch
	
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
	
		Write-Info "Pulling changes from origin to master branch..."
		git checkout master
		Invoke-ErrorCheck "Cannot switch branch to master."
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
		Update-Feature -Continue
	}
	else {
		Update-Feature
	}
	
	Write-Host
	$featureBranch = Get-CurrentBranch
	
	Write-Info "Creating integration branch..."
	$featureName = $featureBranch.Split("/")[1]
	$integrationBranch = "integration/$featureName"
	if ((Test-LocalBranch $integrationBranch)) {
		$gitLogLine = git log -1 --oneline $integrationBranch
		$firstSpaceIndex = $gitLogLine.IndexOf(" ")
		$previousCommitMessage = $gitLogLine.Substring($firstSpaceIndex + 1)
		git branch -D $integrationBranch
	}
	git checkout master
	git branch $integrationBranch
	
	Write-Info "Merge changes for integration..."
	git checkout $integrationBranch	
	git merge --squash $featureBranch
	Invoke-ErrorCheck "Cannot merge changes with integration branch."

	if ($previousCommitMessage) {
		$message = $previousCommitMessage
	}
	else {
		$message = ""
	}
	
	git add .
	git commit -a --message=$message --edit

	if (!$?) {
		git checkout $featureBranch
		Write-Info "Submitting feature aborted."
		return
	}

	Write-Info "Pushing changes to origin..."
	git push -f origin "${integrationBranch}:$featureBranch"
	Invoke-ErrorCheck "Cannot push changes to origin."
	
	git checkout $featureBranch

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
	Invoke-ErrorCheck "Cannot apply changes to target branch or there are some confilcts to resolve."

	Write-Info "Changes moved to $NewBranchName branch."
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