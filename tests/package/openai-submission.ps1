param([string] $RepositoryRoot = (Resolve-Path "$PSScriptRoot/../..").Path)
$ErrorActionPreference = 'Stop'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) "relewise-openai-submission-$([guid]::NewGuid())"
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Assert-ArchiveContainsTree([string] $ArchivePath, [string] $SourceRoot) {
    $archive = [IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        $entries = @($archive.Entries | Where-Object { -not [string]::IsNullOrEmpty($_.Name) } | ForEach-Object { $_.FullName.Replace('\', '/') })
        $sourceFiles = @(Get-ChildItem -LiteralPath $SourceRoot -Recurse -File | ForEach-Object { [IO.Path]::GetRelativePath($SourceRoot, $_.FullName).Replace('\', '/') })
        foreach ($sourceFile in $sourceFiles) { if ($entries -notcontains $sourceFile) { throw "$ArchivePath is missing $sourceFile" } }
    } finally { $archive.Dispose() }
}
try {
    foreach ($plugin in @('relewise', 'relewise-developer')) {
        $metadataPath = Join-Path $RepositoryRoot "marketplace/$plugin/openai/submission.json"
        $schemaPath = Join-Path $RepositoryRoot 'contracts/openai-plugin-submission.schema.json'
        if (-not (Test-Json -LiteralPath $metadataPath -SchemaFile $schemaPath)) { throw "$plugin metadata is invalid." }
        foreach ($submissionMode in @('Initial', 'Update')) {
        $output = Join-Path $testRoot "$plugin-$submissionMode"
        & (Join-Path $RepositoryRoot '.agents/skills/submit-openai-plugins/scripts/prepare-openai-plugin-submission.ps1') `
            -Plugin $plugin -SubmissionMode $submissionMode -Version '9.9.9' -ReleaseNotes 'Automated packaging validation.' -RepositoryRoot $RepositoryRoot -OutputRoot $output
        foreach ($required in @('chatgpt-app-submission.json','canonical-submission.json','artifact-manifest.json','manual-checklist.md','reviewer-setup.md','reviewer-test-cases.md',"$plugin-plugin.zip",'assets/directory-icon.png','assets/composer-icon.png')) {
            if (-not (Test-Path -LiteralPath (Join-Path $output $required) -PathType Leaf)) { throw "$plugin missing artifact: $required" }
        }
        $submission = Get-Content -Raw -LiteralPath (Join-Path $output 'chatgpt-app-submission.json') | ConvertFrom-Json
        if ($submission.version -ne '9.9.9' -or $submission.test_cases.Count -ne 5 -or $submission.negative_test_cases.Count -ne 3 -or $submission.screenshots.Count -gt 3) {
            throw "$plugin generated portal metadata has invalid counts or version."
        }
        $manifest = Get-Content -Raw -LiteralPath (Join-Path $output 'artifact-manifest.json') | ConvertFrom-Json
        if ($manifest.submissionMode -ne $submissionMode) { throw "$plugin did not preserve submission mode $submissionMode." }
        if ($manifest.skills.Count -ne (Get-Content -Raw -LiteralPath $metadataPath | ConvertFrom-Json).skills.Count) { throw "$plugin did not package every skill." }
        $checklist = Get-Content -Raw -LiteralPath (Join-Path $output 'manual-checklist.md')
        $expectedAction = if ($submissionMode -eq 'Initial') { 'Create plugin / With MCP' } else { 'plugin-level Create Draft' }
        if ($checklist -notlike "*$expectedAction*") { throw "$plugin $submissionMode checklist has the wrong portal action." }
        Assert-ArchiveContainsTree (Join-Path $output "$plugin-plugin.zip") (Join-Path $RepositoryRoot "plugins/$plugin")
        foreach ($skill in $manifest.skills.name) {
            Assert-ArchiveContainsTree (Join-Path $output "skills/$skill.zip") (Join-Path $RepositoryRoot "plugins/$plugin/skills/$skill")
        }
        if ($plugin -eq 'relewise') {
            $catalog = Get-Content -Raw -LiteralPath (Join-Path $RepositoryRoot 'generated/mcp-tools.json') | ConvertFrom-Json
            $knownTools = $catalog.tools.name
            $declaredTools = $submission.test_cases.tools_triggered -split ', ' | Sort-Object -Unique
            foreach ($tool in $declaredTools) { if ($knownTools -notcontains $tool) { throw "Unknown Relewise test tool: $tool" } }
            if (@($submission.tool_justifications.PSObject.Properties).Count -ne $catalog.toolCount) { throw 'Relewise must generate a justification for every MCP tool.' }
        } elseif (@($submission.tool_justifications.PSObject.Properties).Count -ne 5) {
            throw 'Relewise Developer must generate a justification for every MCP tool.'
        }
        }
    }
    Write-Host 'OpenAI submission metadata and deterministic packaging validated.'
} finally {
    $resolved = [IO.Path]::GetFullPath($testRoot)
    if ($resolved.StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolved)) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
