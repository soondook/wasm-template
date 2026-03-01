param(
    [string]$RemoteUrl = "https://github.com/soondook/wasm-template.git",
    [string]$MainBranch = "main",
    [string]$DeployBranch = "gh-pages",
    [switch]$NoPush,
    [switch]$Serve
)

Write-Host "1) dotnet publish (project WasmTemplateApp.csproj)..."
if (Test-Path "WasmTemplateApp.csproj") {
    dotnet publish ./WasmTemplateApp.csproj -c Release -o publish
} elseif (Test-Path "wasm-template.sln") {
    dotnet publish ./wasm-template.sln -c Release -o publish
} else {
    Write-Error "No project or solution file found to publish."
    exit 1
}

$index = Join-Path "publish/wwwroot" "index.html"
if (Test-Path $index) {
    Write-Host "2) Update <base href> in $index"
    if ($RemoteUrl -match "/([^/]+)\.git$") { $repoName = $matches[1] } else { $repoName = [IO.Path]::GetFileNameWithoutExtension($RemoteUrl) }
    $raw = Get-Content $index -Raw
     $replacement = '<base href="/' + $repoName + '/" />'
     $raw = $raw -replace '<base\s+href\s*=\s*"[^\"]*"\s*/?>', $replacement
    Set-Content -Path $index -Value $raw -Encoding UTF8
} else {
    Write-Warning "index.html not found at $index"
}

Write-Host "3) Copy publish/wwwroot to temp folder and prepare push to $DeployBranch"
$temp = Join-Path $env:TEMP ("ghp-deploy-{0}" -f ([System.Guid]::NewGuid().ToString()))
if (Test-Path $temp) { Remove-Item $temp -Recurse -Force }
New-Item -ItemType Directory -Path $temp | Out-Null

Copy-Item -Path "publish/wwwroot/*" -Destination $temp -Recurse -Force

if ($NoPush) {
    Write-Host "NoPush: prepared files at $temp"
} else {
    # Perform git operations in temp
    Push-Location $temp
    try {
        git init | Out-Null
        git checkout -b $DeployBranch | Out-Null
        git add .
        git commit -m "Deploy from deploy.ps1 - $(Get-Date -Format 'u')" | Out-Null
        git remote add origin $RemoteUrl | Out-Null
        Write-Host "Pushing to $RemoteUrl -> branch $DeployBranch"
        git push --force origin $DeployBranch
    } catch {
        Write-Error "Deploy error: $_"
    } finally {
        Pop-Location
    }
}

if (-not $NoPush) {
    Write-Host "Cleaning up temp folder"
    Remove-Item $temp -Recurse -Force
}

if ($Serve) {
    Write-Host "Starting local server (dotnet-serve)..."
    dotnet tool install --global dotnet-serve -ErrorAction SilentlyContinue
    dotnet serve -d publish/wwwroot -p 8080
}

Write-Host "Done."
