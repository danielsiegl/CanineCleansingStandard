# This script sets the API secret for the GitHub repository using PnP PowerShell.

# Ensure you have the PnP PowerShell module installed
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Install-Module PnP.PowerShell -Scope CurrentUser -AllowPrerelease -SkipPublisherCheck
} 

# Ask the User for the API secret
Write-Output "Please enter your GitHub API secret: <ctrl+shift+v> to paste"
Add-PnPStoredCredential -Name "https://github.com/syntdev/ai-commit-message-benchmarks/tree/main" -Username GITHUB_TOKEN -Password (Read-Host -Prompt "Enter your GitHub API secret" -AsSecureString)