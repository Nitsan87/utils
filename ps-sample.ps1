$buildNumber = "v0.0.4"
$headers = @{ Authorization = "Bearer $(System.AccessToken)" }

# Step 1: get all builds with that build number
$buildsUrl = "$(System.TeamFoundationCollectionUri)$(System.TeamProject)/_apis/build/builds?buildNumber=$buildNumber&definitions=$(System.DefinitionId)&api-version=6.0"
$builds = Invoke-RestMethod -Uri $buildsUrl -Headers $headers -Method Get

# Step 2: iterate builds (newest first) and find the first one with artifacts
$targetBuildId = $null

foreach ($build in $builds.value) {
    $artifactsUrl = "$(System.TeamFoundationCollectionUri)$(System.TeamProject)/_apis/build/builds/$($build.id)/artifacts?api-version=6.0"
    $artifacts = Invoke-RestMethod -Uri $artifactsUrl -Headers $headers -Method Get

    if ($artifacts.count -gt 0) {
        $targetBuildId = $build.id
        Write-Host "Found build with artifacts: $targetBuildId"
        break
    }
}

if ($null -eq $targetBuildId) {
    Write-Error "No build found with artifacts for build number $buildNumber"
    exit 1
}

Write-Host "##vso[task.setvariable variable=TargetBuildId]$targetBuildId"
