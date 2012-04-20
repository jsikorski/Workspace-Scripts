function script:Write-Info($messageText) {
	Write-Host -Foreground Blue $messageText
}

function script:Write-ErrorMessage($messageText) {
	Write-Host -Foreground Red $messageText
}