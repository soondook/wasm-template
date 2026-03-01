$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
$tmp = 'C:\tmp\wasm-ghp-inspect'
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
$gitPath = 'C:\Program Files\Git\cmd\git.exe'
if (-not (Test-Path $gitPath)) {
    Write-Host "Git executable not found at $gitPath"
    exit 1
}
Write-Host "Using git: $gitPath"
& $gitPath --version

Write-Host "Cloning gh-pages..."
& $gitPath clone --branch gh-pages --single-branch 'https://github.com/soondook/wasm-template.git' $tmp

if (-not (Test-Path $tmp)) {
    Write-Host 'Clone failed or folder missing'
    exit 1
}

Write-Host '--- Root (first-level) ---'
Get-ChildItem -Path $tmp -Force | Select-Object Name,Length | Format-Table -AutoSize

Write-Host '--- Recursive (depth 4) ---'
Get-ChildItem -Path $tmp -Recurse -Depth 4 | Select-Object FullName,Length | Format-Table -AutoSize -Wrap

if (Test-Path (Join-Path $tmp 'index.html')) { Write-Host 'index.html exists at root' } else { Write-Host 'index.html missing at root' }
if (Test-Path (Join-Path $tmp '_framework')) { Write-Host '_framework exists' } else { Write-Host '_framework missing' }

Write-Host 'Done.'
