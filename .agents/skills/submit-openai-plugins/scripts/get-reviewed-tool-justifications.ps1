function Get-ReviewedToolJustifications($Catalog, $ReviewedTools) {
    if ($Catalog.tools.Count -eq 0) { throw 'The MCP catalog must contain tools.' }
    $result = [ordered]@{}
    $hints = @('readOnlyHint', 'destructiveHint', 'openWorldHint')
    $reasons = [ordered]@{
        read_only_justification = 'readOnly'
        destructive_justification = 'destructive'
        open_world_justification = 'openWorld'
    }
    foreach ($tool in $Catalog.tools) {
        $name = $tool.name
        if ([string]::IsNullOrWhiteSpace($name) -or $result.Contains($name)) { throw "Missing or duplicate MCP tool name: $name" }
        if (-not $ReviewedTools.Contains($name)) { throw "Missing reviewed explanations for MCP tool: $name" }
        $reviewed = $ReviewedTools[$name]
        if (-not $tool.Contains('annotations') -or $null -eq $tool.annotations) { throw "$name requires explicit MCP annotations." }
        if (-not $reviewed.Contains('annotations') -or $null -eq $reviewed.annotations) { throw "$name requires reviewed annotations." }
        foreach ($hint in $hints) {
            if ($tool.annotations[$hint] -isnot [bool]) { throw "$name must explicitly declare boolean $hint in the MCP catalog." }
            if ($reviewed.annotations[$hint] -isnot [bool]) { throw "$name must explicitly declare reviewed boolean $hint." }
            if ($tool.annotations[$hint] -ne $reviewed.annotations[$hint]) { throw "$name $hint changed; review its behavior and explanation before preparing a submission." }
        }
        $justifications = [ordered]@{}
        foreach ($field in $reasons.Keys) {
            $reason = $reviewed[$reasons[$field]]
            if ($reason -isnot [string] -or [string]::IsNullOrWhiteSpace($reason)) { throw "$name requires a non-empty $($reasons[$field]) explanation." }
            $justifications[$field] = $reason
        }
        $result[$name] = $justifications
    }
    foreach ($name in $ReviewedTools.Keys) {
        if (-not $result.Contains($name)) { throw "Reviewed explanations reference an unknown MCP tool: $name" }
    }
    return $result
}
