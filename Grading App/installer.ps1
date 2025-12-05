# Installer for GradingApp
$AppName = "GradingApp"
$MainExecutable = "main.exe"
$IconFile = "icon.ico"

# Function to check if script is running as Administrator
function Test-IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host "This installer must be run as Administrator." -ForegroundColor Red
    Read-Host "Press Enter to exit."
    Exit
}

Write-Host "Starting installation for $AppName" -ForegroundColor DarkBlue

# Install folder on C:\
$InstallDir = "C:\$AppName"

# Determine script location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SourceFilesDir = Join-Path $ScriptDir "AppFiles"

# Verify source files exist
if (-not (Test-Path $SourceFilesDir)) {
    Write-Host "Error: Source folder not found at '$SourceFilesDir'" -ForegroundColor Red
    Write-Host "Make sure '$MainExecutable', '$IconFile', and data files are in the 'AppFiles' folder."
    Read-Host "Press Enter to exit."
    Exit
}

# Create installation directory
Write-Host "Creating installation directory at $InstallDir."
try {
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
} catch {
    Write-Host "Error creating directory: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit."
    Exit
}

# Copy all files from AppFiles to C:\GradingApp
Write-Host "Copying files..."
try {
    Copy-Item -Path (Join-Path $SourceFilesDir "*") -Destination $InstallDir -Recurse -Force -ErrorAction Stop
} catch {
    Write-Host "Error copying files: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit."
    Exit
}

# Create Desktop Shortcut for ALL users
Write-Host "Creating Desktop shortcut for all users..."
$AllUsersDesktop = "C:\Users\Public\Desktop"
$ShortcutPath = Join-Path $AllUsersDesktop "$AppName.lnk"
$TargetExePath = Join-Path $InstallDir $MainExecutable
$IconPath = Join-Path $InstallDir $IconFile

try {
    $WShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetExePath
    $Shortcut.WorkingDirectory = $InstallDir

    if (Test-Path $IconPath) {
        $Shortcut.IconLocation = $IconPath
    } else {
        Write-Host "Warning: Icon file not found, using default icon." -ForegroundColor DarkYellow
    }

    $Shortcut.Description = "Launch $AppName"
    $Shortcut.Save()
} catch {
    Write-Host "Error creating shortcut: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit."
    Exit
}

Write-Host ""
Write-Host "Installation Complete!" -ForegroundColor Green
Read-Host "Press Enter to exit."
