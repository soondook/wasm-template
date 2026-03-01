$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
Write-Host "git path: "
Get-Command git -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
git --version
Write-Host "Setting global git user.name and user.email"
git config --global user.name 'soondook'
git config --global user.email 'soondook@gmail.com'
git config --global --list

.\scripts\deploy.ps1 -RemoteUrl 'https://github.com/soondook/wasm-template.git'