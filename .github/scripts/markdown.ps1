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
