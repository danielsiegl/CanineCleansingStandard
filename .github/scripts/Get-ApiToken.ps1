# Ensure you have the PnP PowerShell module installed
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Install-Module PnP.PowerShell -Scope CurrentUser -AllowPrerelease -SkipPublisherCheck
} 

function Get-ApiToken {
    if (-not $env:CHATAPI_TOKEN) {
        $apiSecret = Get-PnPStoredCredential -Name "https://github.com/syntdev/ai-commit-message-benchmarks/tree/main"
        if (-not $apiSecret) {
            throw "API key is not set. runSetAPISecret.ps1 or set the CHATAPI_TOKEN environment variable."
        }
        
        # Convert the secure string to plain text it it is just a PAT so not too worried about it
        return ConvertFrom-SecureString -SecureString $apiSecret.Password -AsPlainText
    } else {
        
        return $env:CHATAPI_TOKEN  # Ensure you have set this environment variable
    }
}