# This powershell script demonstrates how to create a single markdown file from multiple markdown files
# and replace the internal links with the generated links.
# The script is part of the Canine Cleansing Standard (CCS-2025) project.
# The script is used to generate a single markdown file that can be used to generate a PDF using pandoc.
# pandoc.exe .\outputmarkdown.md -o output.pdf --toc

$ouputFile = "outputmarkdown.md"
$readmeFile = "README.md"
$indexFile = "index.md"   
$markdownFileNames = @(Get-ChildItem -Path *.md -Exclude $readmeFile, $indexFile, $ouputFile)

$fileCount = $markdownFileNames.Length
Write-Output "Files found: $FileCount"

$pageCollection = @()

foreach ($markdownFilePath in $markdownFileNames) {
    Write-Output "Processing $markdownFilePath"
    $markdownFileName = $markdownFilePath.Name
    Write-Output "File name: $markdownFileName"
  

    $fileContent = Get-Content -Path $markdownFilePath -Encoding UTF8

    # Find the first line that starts with a Markdown heading indicator (#)
    $firstHeadline = $fileContent | Where-Object { $_ -match '^#+\s+' } | Select-Object -First 1

    # Check if a headline was found
    if ($null -ne $firstHeadline) {
        Write-Output "First headline found: $firstHeadline"
    } else {
        Write-Output "No headlines found in the Markdown file."
    }

    $pageCollection += New-Object -Type PSObject -Property @{
      'Filename' = $markdownFileName
      'Path' = $markdownFilePath
      'Headline' = $firstHeadline
      'Content' = $fileContent
      'Linkstring' = [uri]::EscapeDataString($firstHeadline.Trim().Replace("%23%20","#").Replace("%2A","").Replace("%3F","").Replace("%2C","").Replace("%2F","").Replace("%3A","").Replace("%3B","").Replace("%3D","").Replace("%40","").Replace("%26","").Replace("%3C","").Replace("%3E","").Replace("%22","").Replace("%7B","").Replace("%7D","").Replace("%7C","").Replace("%5C","").Replace("%5E","").Replace("%7E","").Replace("%5B","").Replace("%5D","").Replace("%60",""))
    }
}

Write-Output $pageCollection.Length


$outputMarkdown ="";

$outputMarkdown +="---`n"
$outputMarkdown +="title: The Canine Cleansing Standard (CCS-2025)`n"
$outputMarkdown +="author: 'https://github.com/danielsiegl/CanineCleansingStandard/'`n"
$outputMarkdown +="toc: true`n"
$outputMarkdown +="include-before: |`n"
$outputMarkdown +="   The Ultimate Guide to Grooming and Bathing Your Dog. A systematic and standardized approach to maintaining optimal cleanliness and hygiene for your dog.\newline`n"
$outputMarkdown +="   This is a fictitious Standard to show case how to develop a standard using [GitHub](https://github.com/danielsiegl/CanineCleansingStandard), [SmartGit](https://www.syntevo.com/smartgit/) and [Obsidian](https://obsidian.md/)\newpage`n"
$outputMarkdown +="header-includes: |`n"
$outputMarkdown +="   \usepackage{fancyhdr}`n"
$outputMarkdown +="   \pagestyle{fancy}`n"
$outputMarkdown +="   \fancyhf{}`n"
$outputMarkdown +="   \fancyhead[R]{Created: \date{\today}}`n"
$outputMarkdown +="   \fancyfoot[R]{\newline{\thepage}}`n"
$outputMarkdown +="   \fancyfoot[L]{\tiny{https://github.com/danielsiegl/CanineCleansingStandard/commit/9b1fda051ff3842d84b6c8ad1cc0d3c0589a3962}}`n"
$outputMarkdown +="---`n"

foreach ($page in $pageCollection) {
    $pageContent = $page.Content
    $pageHeadline = $page.Headline
    $pageLinkString = $page.LinkString
    $pageFilename = $page.Filename
   
    # remove jekyll properties
    $insideFrontMatter = $false
    $filteredContent = ""

    # Loop through each line and remove the front matter
    $filteredContent += "\newpage`n`n"
    foreach ($line in $pageContent) {
        if ($line -eq "---") {
            # Toggle the state when encountering ---
            $insideFrontMatter = -not $insideFrontMatter
            continue
        }
        # If not inside the front matter block, add the line to the output
        if (-not $insideFrontMatter) {
            $optimizedLine = $line.Trim()
            # Write-Output " ***$optimizedLine***"
            $filteredContent += "$optimizedLine`n"
        }
    }

    # internal link: [Drying Protocol](#5.%20Drying%20Protocol)<br>
    # External link:[Post Cleaning Care](06_Post-Cleaning_Care.md)<br>

    $outputMarkdown += $filteredContent
    Write-Output "$pageFilename $pageHeadline $pageLinkString"
}

#now that we have all the content, in a string we need to replace all the file names with the links generated above
foreach ($page in $pageCollection) {
    $pageLinkString = $page.LinkString
    $pageFilename = $page.Filename
    $outputMarkdown = $outputMarkdown -replace $pageFilename, $pageLinkString
    Write-Output "Replace: ***$pageFilename*** ***$pageLinkString***"
}

Set-Content -Encoding UTF8 -Path $ouputFile -Value $outputMarkdown


