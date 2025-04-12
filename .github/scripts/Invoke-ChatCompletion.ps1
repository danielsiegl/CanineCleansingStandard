    function Invoke-ChatCompletionVerbose {
    param (
        [string]$Prompt,
        [string]$ApiKey,
        [string]$BaseUrl,
        [string]$Model
    )
        # Measure the execution time of the API call
        $startTime = Get-Date
        # Invoke the API with the updated prompt
        $ResponseMessage = Invoke-ChatCompletion -Prompt $updatedPromptContent -ApiKey $apiKey -BaseUrl $baseUrl -Model $model
        $endTime = Get-Date
        $executionTime = $endTime - $startTime
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $ResponseMessage[0] += " Model: $model Timestamp: $timestamp Length: $($ResponseMessage[1].Length) Exec. Time: $executionTime`r---"
        
        return $ResponseMessage
    }

    function Invoke-ChatCompletion {
    param (
        [string]$Prompt,
        [string]$ApiKey,
        [string]$BaseUrl,
        [string]$Model = "o3-mini"
    )

    # No manual escaping is needed when using ConvertTo-Json,
    # just trim the prompt to remove any leading or trailing whitespace.
    $Prompt = ConvertTo-Json $Prompt.Trim()


    # Define the request payload
    $Body = @{
        messages = @(
            @{ role = "system"; content = "" },
            @{ role = "user"; content = $Prompt }
        )
        model = $Model
    } | ConvertTo-Json -Depth 10

    # Define headers
    $Headers = @{
        "Authorization" = "Bearer $ApiKey"
        "Content-Type" = "application/json"
    }

    # Make the API request
    try {
        $url = "$BaseUrl/chat/completions"
        Write-Output "Request URL: $url"
        $Response = Invoke-RestMethod -Uri $url  -Method Post -Headers $Headers -Body $Body
        
        return $Response.choices[0].message.content
    } catch {
        Write-Error "The sample encountered an error: $_"
        throw
    }
}