###### Private #####
function Get-BranchName($string) {
	$branchName = ([string]$string).Replace("*", "").Trim()
	return $branchName
}

function Get-CurrentBranch {
	$branches = git branch
	foreach($branch in $branches) {
		if (([string]$branch).StartsWith("*")) {
			$branchName = Get-BranchName($branch)
			return $branchName;
		}
	}
}

##### Public #####
function Get-Repositories {
	Set-Location $repositoriesPath
}

function Start-Feature($featureName) {
	if (Is-StringEmpty($featureName))
	{
		Write-Host "Please type feature name."
		return
	}

	git branch $featureName
	git checkout $featureName
}

function Submit-Feature {
	$currentBranch = Get-CurrentBranch

	git checkout master
	git pull origin master
	git checkout $currentBranch
	git rebase master
	git checkout master
	git merge $currentBranch
	git push origin master
}

function Sync-Feature {
	$currentBranch = Get-CurrentBranch
	
	git checkout master
	git pull origin master
	git checkout $currentBranch
	git rebase master
}

function Move-Changes($newBranchName) {
	git stash
	git checkout $newBranchName
	git stash pop
}

function Remove-Branch($branchName) {
	git branch -D $branchName
}

function Clear-Branches() {
	if (([string](Get-CurrentBranch)) -ne "master") {
		Write-Host "Branches can be cleared only from master branch."
		return
	}

	$branches = git branch
	foreach ($branch in $branches) {
		if (!([string]$branch).StartsWith("*")) { 
			$branchName = Get-BranchName($branch)
			git branch -D $branchName
		}
	}
}