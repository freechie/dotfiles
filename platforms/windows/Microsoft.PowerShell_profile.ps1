# PowerShell entry for this dotfiles repo.
# Zsh, Bash, tmux, and Ghostty stay on macOS and Ubuntu.

if (-not $env:HOME) {
    $env:HOME = $env:USERPROFILE
}

$extraPaths = @(
    "$env:ProgramFiles\Neovim\bin"
)

$emacsRoot = Join-Path $env:ProgramFiles "Emacs"
if (Test-Path $emacsRoot) {
    Get-ChildItem $emacsRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $bin = Join-Path $_.FullName "bin"
        if (Test-Path $bin) { $extraPaths += $bin }
    }
}

foreach ($dir in $extraPaths) {
    if ((Test-Path $dir) -and ($env:Path -notlike "*${dir}*")) {
        $env:Path = "$dir;$env:Path"
    }
}

$env:EDITOR = "nvim"
$env:VISUAL = "nvim"
$env:GIT_EDITOR = "nvim"

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
