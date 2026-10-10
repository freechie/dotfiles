# Windows setup for this dotfiles repo. Run from PowerShell 7:
#   ./install.ps1
#   ./install.ps1 -DryRun
#   ./install.ps1 -SkipDeps

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$SkipDeps
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackupRoot = Join-Path $env:USERPROFILE ("dotfiles_backup_{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$Script:Failures = @()

function Write-Plan {
    param([string]$Message)
    if ($DryRun) {
        Write-Host "DRY RUN: $Message"
    } else {
        Write-Host $Message
    }
}

function Add-Failure {
    param([string]$Message)
    $Script:Failures += $Message
    Write-Host "FAILED: $Message"
}

function Test-SameTarget {
    param(
        [string]$Link,
        [string]$Source
    )

    if (-not (Test-Path -LiteralPath $Link)) {
        return $false
    }

    $sourceFull = [IO.Path]::GetFullPath($Source)
    $item = Get-Item -LiteralPath $Link -Force
    if (-not $item.LinkType) {
        return $false
    }

    foreach ($target in @($item.Target)) {
        if ([IO.Path]::GetFullPath($target) -eq $sourceFull) {
            return $true
        }
    }

    return $false
}

function Backup-Existing {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    $leaf = Split-Path -Leaf $Path
    $dest = Join-Path $BackupRoot $leaf
    Write-Plan "backup $Path -> $dest"
    if ($DryRun) {
        return
    }

    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    Move-Item -LiteralPath $Path -Destination $dest
}

function Install-Link {
    param(
        [string]$Source,
        [string]$Link,
        [ValidateSet("File", "Directory")]
        [string]$Kind
    )

    $sourceFull = [IO.Path]::GetFullPath($Source)
    if (-not (Test-Path -LiteralPath $sourceFull)) {
        Add-Failure "missing link source $sourceFull"
        return
    }

    if (Test-SameTarget -Link $Link -Source $sourceFull) {
        Write-Host "already linked: $Link"
        return
    }

    $parent = Split-Path -Parent $Link
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        Write-Plan "mkdir $parent"
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
    }

    Backup-Existing -Path $Link
    Write-Plan "link $Kind $sourceFull -> $Link"
    if ($DryRun) {
        return
    }

    if ($Kind -eq "Directory") {
        New-Item -ItemType Junction -Path $Link -Target $sourceFull | Out-Null
        return
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $sourceFull | Out-Null
    } catch {
        New-Item -ItemType HardLink -Path $Link -Target $sourceFull | Out-Null
    }
}

function Install-WingetPackage {
    param([string]$Id)

    if ($DryRun) {
        Write-Plan "winget install --id $Id"
        return
    }

    & winget install --id $Id --exact --disable-interactivity --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
        return
    }

    Add-Failure "winget install $Id exited $LASTEXITCODE"
}

function Install-WindowsPackages {
    $ids = @(
        "Neovim.Neovim",
        "GNU.Emacs",
        "Starship.Starship",
        "BurntSushi.ripgrep.MSVC",
        "sharkdp.fd",
        "junegunn.fzf",
        "ajeetdsouza.zoxide",
        "eza-community.eza",
        "JesseDuffield.lazygit",
        "OpenJS.NodeJS.LTS"
    )

    foreach ($id in $ids) {
        Install-WingetPackage -Id $id
    }
}

function Install-TreeSitterCli {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "Skipping tree-sitter-cli: npm is not on PATH yet. Open a new shell and rerun ./install.ps1 -SkipDeps."
        return
    }

    if ($DryRun) {
        Write-Plan "npm install -g tree-sitter-cli"
        return
    }

    & npm install -g tree-sitter-cli
    if ($LASTEXITCODE -ne 0) {
        Add-Failure "npm install -g tree-sitter-cli exited $LASTEXITCODE"
    }
}

function Install-WindowsEarlyInit {
    $early = Join-Path $env:USERPROFILE ".emacs.d\early-init.el"
    $snippetPath = Join-Path $RepoRoot "emacs\windows-early-init.el"
    if (-not (Test-Path -LiteralPath $early)) {
        return
    }

    $text = [IO.File]::ReadAllText($early)
    if ($text.Contains("frame-resize-pixelwise")) {
        Write-Host "already patched: $early"
        return
    }

    $snippet = [IO.File]::ReadAllText($snippetPath)
    Write-Plan "append emacs/windows-early-init.el to $early"
    if ($DryRun) {
        return
    }

    [IO.File]::AppendAllText($early, "`r`n" + $snippet.TrimEnd() + "`r`n")
}

function Install-Spacemacs {
    $emacsDir = Join-Path $env:USERPROFILE ".emacs.d"
    if (Test-Path (Join-Path $emacsDir ".git")) {
        Write-Host "Spacemacs is already installed."
        return
    }

    if (Test-Path $emacsDir) {
        Add-Failure "$emacsDir exists and is not a Spacemacs checkout"
        return
    }

    Write-Plan "git clone --depth 1 -b develop https://github.com/syl20bnr/spacemacs.git $emacsDir"
    if ($DryRun) {
        return
    }

    & git clone --depth 1 --branch develop https://github.com/syl20bnr/spacemacs.git $emacsDir
    if ($LASTEXITCODE -ne 0) {
        Add-Failure "Spacemacs clone exited $LASTEXITCODE"
    }
}

if ($env:OS -ne "Windows_NT") {
    throw "install.ps1 is for Windows PowerShell. On macOS and Ubuntu, run ./install.sh."
}

Write-Host "Linking Windows configs from $RepoRoot"
Write-Host ".gitconfig is not linked. It enables commit signing with a macOS key path."

$profilePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell\Microsoft.PowerShell_profile.ps1"
Install-Link -Source (Join-Path $RepoRoot "platforms\windows\Microsoft.PowerShell_profile.ps1") -Link $profilePath -Kind File
Install-Link -Source (Join-Path $RepoRoot "nvim") -Link (Join-Path $env:LOCALAPPDATA "nvim") -Kind Directory
Install-Link -Source (Join-Path $RepoRoot "starship.toml") -Link (Join-Path $env:USERPROFILE ".config\starship.toml") -Kind File
Install-Link -Source (Join-Path $RepoRoot "emacs\.spacemacs") -Link (Join-Path $env:USERPROFILE ".spacemacs") -Kind File
Install-Link -Source (Join-Path $RepoRoot "emacs\local.el") -Link (Join-Path $env:USERPROFILE ".spacemacs.d\local.el") -Kind File
Install-Link -Source (Join-Path $RepoRoot "emacs\darwin.el") -Link (Join-Path $env:USERPROFILE ".spacemacs.d\darwin.el") -Kind File
Install-Link -Source (Join-Path $RepoRoot "emacs\windows.el") -Link (Join-Path $env:USERPROFILE ".spacemacs.d\windows.el") -Kind File
Install-Link -Source (Join-Path $RepoRoot ".gitignore_global") -Link (Join-Path $env:USERPROFILE ".gitignore_global") -Kind File

Install-Spacemacs
Install-WindowsEarlyInit

if ($SkipDeps) {
    Write-Host "Skipping winget packages."
} else {
    Install-WindowsPackages
}

Install-TreeSitterCli

if ($Script:Failures.Count -gt 0) {
    Write-Host ""
    Write-Host "$($Script:Failures.Count) step(s) failed."
    $Script:Failures | ForEach-Object { Write-Host " - $_" }
    exit 1
}

Write-Host "Windows setup finished. Open a new PowerShell window to load the profile."
