function Get-Markdown-Files {
  param (
    [string[]]$markdownFileNames
  )

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
  return $pageCollection
}

function Join-Markdown {
    param (
      [Parameter(Mandatory=$true)]
      [array]$pageCollection,
      [Parameter(Mandatory=$true)]
      [string]$verboseVersionPDF,
      [Parameter(Mandatory=$true)]
      [string]$commitHash,
      [Parameter(Mandatory=$true)]
      [string]$version
    )

    $outputMarkdown = ""

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

    return $outputMarkdown
  }
