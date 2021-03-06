param([String]$releaseZip)

# Make PowerShell stop if it has errors
$ErrorActionPreference = "Stop"

$7zExe="C:\Program Files\7-Zip\7z.exe";

if ([string]::IsNullOrEmpty($releaseZip) -or [string]::IsNullOrWhitespace($releaseZip)) {
    Write-Error "Pass the path of the release to install to this script";
}


# ------------------------------------------------------------------------------
# Initialise variables and paths

# Get the current location
$startDir=Get-Location

$releaseDir="C:\Users\peek\peek_dist_win";

# Delete the existing dist dir if it exists
If (Test-Path $releaseDir){
    Remove-Item $releaseDir -Force -Recurse;
}

# ------------------------------------------------------------------------------
# Extract the release to a interim directory

# Create our new release dir
New-Item $releaseDir -ItemType directory;

# Decompress the release
Write-Host "Extracting release to $releaseDir";

if (Test-Path $7zExe) {
    Write-Host "7z is present, this will be faster";
    Invoke-Expression "&`"$7zExe`" x -y -r `"$releaseZip`" -o`"$releaseDir`"";

} else {
    Write-Host "Using standard windows zip handler, this will be slow";
    Add-Type -Assembly System.IO.Compression.FileSystem;
    [System.IO.Compression.ZipFile]::ExtractToDirectory($releaseZip, $releaseDir);
}

# ------------------------------------------------------------------------------
# Create teh virtual environment

# Get the release name from the package
$peekPkgName = Get-ChildItem "$releaseDir\py" |
                    Where-Object {$_.Name.StartsWith("synerty_peek-")} |
                    Select-Object -exp Name;
$peekPkgVer = $peekPkgName.Split('-')[1];

# This variable is the path of the new virtualenv
$venvDir = "C:\Users\peek\synerty-peek-$peekPkgVer";

# Check if this release is already deployed
If (Test-Path $venvDir){
    Write-Host "directory already exists : $venvDir";
    Write-Error "This release is already deployed, delete it to re-deploy";
}

# Create the new virtual environment
virtualenv.exe $venvDir;

# Activate the virtual environment
$env:Path = "$venvDir\Scripts;$env:Path";

# ------------------------------------------------------------------------------
# Install the python packages

# install the py wheels from the release
pip install --no-index --no-cache --find-links "$releaseDir\py" synerty-peek Shapely pymssql

# ------------------------------------------------------------------------------
# Install node

# Move the node_modules into place
# This is crude, we kind of mash the two together
Move-Item $releaseDir\node\* $venvDir\Scripts -Force

# ------------------------------------------------------------------------------
# Install the frontend node_modules

# Make a var pointing to site-packages
$sp="$venvDir\Lib\site-packages";

# Move the node_modules into place
Move-Item $releaseDir\mobile-build-web\node_modules $sp\peek_mobile\build-web -Force
Move-Item $releaseDir\desktop-build-web\node_modules $sp\peek_desktop\build-web -Force
Move-Item $releaseDir\admin-build-web\node_modules $sp\peek_admin\build-web -Force

# ------------------------------------------------------------------------------
# Show complete message

# All done.
Write-Host "Peek is now deployed to $venvDir";
Write-Host " ";

# ------------------------------------------------------------------------------
# OPTIONALLY - Update the environment for the user.

# Ask if the user would like to update the PATH environment variables
$title = "Environment Variables"
$message = "Do you want to update the system to use the release just installed?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "I want to update the PATH System Environment Variables."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "I do NOT want the PATH System Environment Variables changed."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0)

switch ($result) {
    0 {
        Write-Host "You selected Yes.";

        $newPath = "$venvDir\Scripts";
        Write-Host "Added PATH variable:" $newPath;

        ([Environment]::GetEnvironmentVariable("PATH", "User")).split(';') | foreach-object {
            if ($_ -notmatch 'synerty-peek') {
                $newPath = $newPath + ';' + $_
            }
            else {
                Write-Host "Removed PATH variable:" $_ ;
            }
        }
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User");
        Write-Host " ";
        Write-Host "Environment Variables have been updated."
        Write-Host " ";
        Write-Host "IMPORTANT, you must restart the PowerShell window for the";
        Write-Host "Environment Variable changes to take effect!";
    }

    1 {
        Write-Host "You selected No.";
        Write-Host " ";
        Write-Host "Activate the new environment from command :";
        Write-Host "    set PATH=`"$venvDir\Scripts;%PATH%`"";
        Write-Host " ";
        Write-Host "Activate the new environment from PowerShell :";
        Write-Host "    `$env:Path = `"$venvDir\Scripts;`$env:Path`"";
    }
}

# ------------------------------------------------------------------------------
# OPTIONALLY - Reinstall the services

# Ask if the user would like to update the PATH environment variables
$title = "Windows Services"
$message = "Do you want to install/update the Peek windows services"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "I want the services setup."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "No services for me, this is a dev machine."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0)

switch ($result) {
    0 {
        Write-Host "Ok, We're setting up the services.";

        # Get the password to start the services
        $pass = Read-Host 'What is the peek windows users password?'

        # Define the list of services to manage
        $services = @('peek_worker', 'peek_agent', 'peek_client', 'peek_server', 'peek_restarter');

        foreach ($service in $services)
        {
            $arguments = "winsvc_$service --username .\peek --password $pass --startup auto install"
            $arguments = "CMD /C '" + $arguments + "'"
            Write-Output $arguments
            Start-Process powershell -Verb runAs -Wait -ArgumentList $arguments
        }

    }

    1 {
        Write-Host "Ok, We've left the services alone.";
    }
}

# ------------------------------------------------------------------------------
# Remove release dir

Remove-Item $releaseDir -Force -Recurse;

