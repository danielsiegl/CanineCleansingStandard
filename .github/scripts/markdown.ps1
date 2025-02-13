function New-SingleMarkdownFile {
  param (
    [string]$version,
    [string]$mode,
    [string]$reponame,
    [string]$commitHash,
    [string]$pandocHeaderFile,
    [string]$ouputFile
  )

  

  $versionStrings = New-Version-Strings -mode $mode -version $version -commitHash $commitHash -reponame $reponame
  $verboseVersionPDF = $versionStrings.verboseVersionPDF
   
  # Get all markdown files in the repository that should be concatenated
  $markdownFileNames = @(Get-ChildItem -Path *.md -Exclude "README.md", "index.md", $ouputFile)

  # Load the markdown files into a collection
  $pageCollection = Get-Markdown-Files -markdownFileNames $markdownFileNames

  # Read and add Latex Header file to Output Markdown
  $outputMarkdown = Get-Content $pandocHeaderFile -Raw
  $outputMarkdown = $outputMarkdown.Replace("\def\version",$verboseVersionPDF).Replace("\def\commitid",$commitHash).Replace("\def\tag",$version)

  # Add the content of the markdown files to a single markdown
  $outputMarkdown += Join-Markdown -pageCollection $pageCollection
         
  # Write the output markdown to a file
  Set-Content -Encoding UTF8 -Path $ouputFile -Value $outputMarkdown
  }

function Get-Markdown-Files {
  param (
    [string[]]$markdownFileNames
  )

  $fileCount = $markdownFileNames.Length
  Write-Output "Files found: $FileCount"

  $pageCollection = @()

  foreach ($markdownFilePath in $markdownFileNames) {
    
    $markdownFileName = $markdownFilePath.Name
    Write-Output "Processing $markdownFilePath; File name: $markdownFileName"

    $fileContent = Get-Content -Path $markdownFilePath -Encoding UTF8

    $pageCollection += New-Object -Type PSObject -Property @{
      'Filename' = $markdownFileName
      'Path' = $markdownFilePath
      'Content' = $fileContent
    }
  }

  Write-Output $pageCollection.Length
  return $pageCollection
}

function Join-Markdown {
    param (
      [Parameter(Mandatory=$true)]
      [array]$pageCollection
    )

    $outputMarkdown = ""

    foreach ($page in $pageCollection) {
      $pageContent = $page.Content
    
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
          $filteredContent += "$optimizedLine`n"
        }
      }

      $outputMarkdown += $filteredContent
    }

    return $outputMarkdown
  }
  
function New-Version-Strings {
    param (
      [string]$mode,
      [string]$version,
      [string]$commitHash,
      [string]$reponame
    )

    $prefix = if ($mode -eq 'build') { 'Draft' } else { 'Release' }
    $verboseVersion = "$prefix-$version-$commitHash"
    $verboseVersionPDF = "${prefix}: $version-$commitHash"
    $pdffileName = "$reponame-$verboseVersion.pdf"

    return @{
      verboseVersion = $verboseVersion
      verboseVersionPDF = $verboseVersionPDF
      pdffileName = $pdffileName
    }
  }