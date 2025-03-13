# check for pwsh
if ($PSVersionTable.PSEdition -ne "Core") {
    throw  "This script is intended to be run in PowerShell Core (pwsh)."
}
#Check if the working directory is a git repository
if (-not (Test-Path .git)) {
    throw "This script must be run in a git repository."
}
#check if the working directory is the root folder of the git repository
if (-not (Test-Path .git/config)) {
    throw "This script must be run in the root folder of a git repository."
}
#check if the external fuction folder is available
$externalFunction = ".\.github\scripts\"
if (-not (Test-Path $externalFunction )) {
    throw "The external function folder is not available. Please check the path."
}

. $externalFunction\Get-ApiToken.ps1
. $externalFunction\Invoke-ChatCompletion.ps1

# OpenAI API https://api.openai.com/v1
# GitHub OpenAI API https://models.inference.ai.azure.com
$baseUrl = "https://api.openai.com/v1"  
if (Test-Path ".secret") {
    $apiKey = Get-Content ".secret" -Raw
} else {
    $apiKey = Get-ApiToken
}
$model ="o3-mini" #"o3-mini" # "gpt-4o-mini" #"gpt-4o"  # Specify the model you want to use

#load prompt from external file prompt.txt
$promptFile = "$externalFunction\prompt.txt"
if (Test-Path $promptFile) {
    $prompt = Get-Content $promptFile -Raw
} else {
    throw "The prompt file is not available. Please check the path."
}

# Load the content filenames into a collection
$markdownFileNames = @(Get-ChildItem -Path *.md -Exclude "README.md", "index.md", $ouputFile)
foreach ($markdownFilePath in $markdownFileNames) {
    $markdownFileName = $markdownFilePath.Name
    Write-Output "Processing $markdownFilePath; File name: $markdownFileName"
    # Read the content of the markdown file
    $fileContent = Get-Content -Path $markdownFilePath -Encoding UTF8

    # store the frontmatter ina variable
    $frontmatter = $fileContent -match '---\s*(.*?)\s*---'

    # # remove the frontmatter from the markdown file
    # if ($fileContent -match '---\s*(.*?)\s*---') {
    #     $fileContent = $fileContent -replace '---\s*(.*?)\s*---', ''
    # }

    #remove emptylines from the beginning of the file
    $fileContent = $fileContent -replace '^\s*[\r\n]+', ''

  

    $checkPrompt= $prompt+$fileContent
    $ResponseMessage = Invoke-ChatCompletion -Prompt $checkPrompt -ApiKey $apiKey -BaseUrl $baseUrl -Model $model
    

    $responsePayload = $ResponseMessage[1]





    Write-Output $responsePayload
    #write the response to the original file

    # #remove emptylines from the frontmatter
    # $frontmatter = $frontmatter -replace '^\s*[\r\n]+', ''

    #remove emptylines from the beginning of the file
    # $responsePayload = $responsePayload -replace '^\s*[\r\n]+', ''

    # $updatedFileContent = $frontmatter+$responsePayload
    $updatedFileContent=$responsePayload

    # remove 'n from the beginning of the file  
    $updatedFileContent = $updatedFileContent -replace "^\'n", ""

    # remove ```markdown from the beginning of the file
    $updatedFileContent = $updatedFileContent -replace '^```markdown', ""

    #we need to remove empty lines before and after the frontmatter
    $updatedFileContent = $updatedFileContent -replace '^\s*[\r\n]+', ''

    # Remove only empty lines after the frontmatter marker '---' while preserving the marker itself
    $updatedFileContent = $updatedFileContent -replace '(?m)^(---\s*[\r\n]+)(?:\s*[\r\n])+', '$1'

    #remove trailing spaces in each line of the file, equivalent to trimright
    $updatedFileContent = $updatedFileContent -replace '(?m)\s+$', ''

    Set-Content -Path $markdownFilePath -Value $updatedFileContent -Encoding UTF8
    
}



# Example usage
