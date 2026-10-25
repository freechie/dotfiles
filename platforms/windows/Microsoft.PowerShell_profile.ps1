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

# starship and zoxide print a shell script from `init`. Cache that script and
# rebuild it only when the executable changes. Generating it on every launch
# starts each program twice and is most of the profile time.
function Import-CachedShellInit {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string[]]$InitArgs
    )

    $cacheDir = Join-Path $env:LOCALAPPDATA "shell-init"
    $cache = Join-Path $cacheDir "$Name.ps1"
    $stampPath = Join-Path $cacheDir "$Name.stamp"
    $source = $null

    if ((Test-Path -LiteralPath $stampPath) -and (Test-Path -LiteralPath $cache)) {
        $cached = (Get-Content -LiteralPath $stampPath -Raw).Trim()
        $bar = $cached.IndexOf("|")
        if ($bar -gt 0) {
            $source = $cached.Substring(0, $bar)
            $ticks = $cached.Substring($bar + 1)
            if ((Test-Path -LiteralPath $source) -and ((Get-Item -LiteralPath $source).LastWriteTimeUtc.Ticks.ToString() -eq $ticks)) {
                . $cache
                return
            }
        }
    }

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { return }

    $source = $cmd.Source
    $output = & $source @InitArgs | Out-String
    if ([string]::IsNullOrWhiteSpace($output)) { return }

    New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
    [System.IO.File]::WriteAllText($cache, $output)
    $token = "{0}|{1}" -f $source, (Get-Item -LiteralPath $source).LastWriteTimeUtc.Ticks
    [System.IO.File]::WriteAllText($stampPath, $token)
    . $cache
}

Import-CachedShellInit -Name starship -InitArgs @("init", "powershell", "--print-full-init")
Import-CachedShellInit -Name zoxide -InitArgs @("init", "powershell")
Remove-Item Function:\Import-CachedShellInit
