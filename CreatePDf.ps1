# Define file paths
# Needs pandoc installed and https://miktex.org/download installed
Set-Location "C:\repos\SmartGit.Demo\CanineCleansingStandard"

$markdownFile = "outputmarkdown.md"
$pdfFile = "C:\repos\SmartGit.Demo\CanineCleansingStandard\example.pdf"

# Check if Pandoc is installed
if (-not (Get-Command "pandoc" -ErrorAction SilentlyContinue)) {
    Write-Error "Pandoc is not installed or not in PATH. Please install Pandoc first."
    exit 1
}

# Convert Markdown to PDF
$pandocCommand = "pandoc `"$markdownFile`" -o `"$pdfFile`" --toc"
Write-Output $pandocCommand
Invoke-Expression $pandocCommand

# Check if PDF was created
if (Test-Path $pdfFile) {
    Write-Host "PDF successfully created at: $pdfFile"
} else {
    Write-Error "Failed to generate PDF."
}
