#!/usr/bin/env bash

set -o nounset
set -o errexit

releaseZip="${1}"

if ! [ -f $releaseZip ]; then
    echo "Release doesn't exist : $releaseZip"
    exit 1
fi

# ------------------------------------------------------------------------------
# Initialise variables and paths

# Get the current location
startDir=`pwd`

releaseDir=`echo ~/peek_dist_macos`

# Delete the existing dist dir if it exists
if [ -d ${releaseDir} ]; then
    echo "Deleting old extracted release"
    rm -rf ${releaseDir}
fi

# ------------------------------------------------------------------------------
# Extract the release to a interim directory

# Create the new release dir
mkdir -p ${releaseDir}

# Decompress the release
echo "Extracting release to $releaseDir"
tar xjf ${releaseZip} -C ${releaseDir}

# ------------------------------------------------------------------------------
# Create the virtual environment

# Get the release name from the package
echo "Get the release name from the package"
peekPkgVer=`cd $releaseDir/py && ls synerty_peek-* | cut -d'-' -f2`

# This variable is the path of the new virtualenv
venvDir="/Users/peek/synerty-peek-${peekPkgVer}"


# Check if this release is already deployed
# Delete the existing dist dir if it exists
if [ -d ${venvDir} ]; then
    echo "directory already exists : ${venvDir}"
    echo "This release is already deployed, delete it to re-deploy"
fi

# Create the new virtual environment
virtualenv $venvDir

# Activate the virtual environment
export PATH="$venvDir/bin:$PATH"

# ------------------------------------------------------------------------------
# Install the python packages

# install the py wheels from the release
pip install --no-index --no-cache --find-links "$releaseDir/py" synerty-peek

# ------------------------------------------------------------------------------
# Install node

# Copy the node_modules into place
# This is crude, we kind of mash the two together
rsync -a $releaseDir/node/* ${venvDir}

# ------------------------------------------------------------------------------
# Install the frontend node_modules

# Make a var pointing to site-packages
sp="$venvDir/lib/python3.6/site-packages"

# Move the node_modules into place
mv $releaseDir/mobile-build-web/node_modules $sp/peek_mobile/build-web
mv $releaseDir/desktop-build-web/node_modules $sp/peek_desktop/build-web
mv $releaseDir/admin-build-web/node_modules $sp/peek_admin/build-web

# ------------------------------------------------------------------------------
# Show complete message

echo " "
echo "Peek is now deployed to $venvDir"

# ------------------------------------------------------------------------------
# OPTIONALLY - Update the environment for the user.

q='"'
d='$'

echo " "
echo "Run the following to switch to the new releases environment :";
echo "export PATH=${q}${venvDir}/bin:${d}{PATH}${q}"
echo " "

read -p "Do you want to permanently enable this release? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sed -i "s,export PEEK_ENV.*,export PEEK_ENV=${q}${venvDir}${q},g" ~/.bash_profile
    echo " "
    echo "Done"
    echo " "
    echo "Close and reopen your terminal for the update to take effect"
fi

# ------------------------------------------------------------------------------
# Remove release dir

rm -rf ${releaseDir}