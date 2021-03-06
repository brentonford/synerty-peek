#!/usr/bin/env bash

set -o nounset
set -o errexit
# set -x

export PACKAGES="
peek-plugin-base
peek-platform
peek-agent
peek-desktop
peek-worker
peek-mobile
peek-client
peek-doc-user
peek-admin
peek-doc-admin
peek-server
synerty-peek
peek-core-email
peek-core-device"


# Dynamicall list plugins

# Get the location of this script
#here=$(dirname `readlink -f $(dirname $0)`)
#echo $here

## Plugins are siblings to this project
#if ls -d $here/peek-plugin-* 2> /dev/null 2>&1; then
#    export PLUGINS=`ls -d $here/peek-plugin-* | grep -v peek-plugin-base`
#else
#    echo "There are no plugins at $here"
#    export PLUGINS=""
#fi

# Ignore all that, define the ones JJC wants for Orion

export PLUGINS="
peek-plugin-noop
peek-plugin-data-dms
peek-plugin-user
peek-plugin-inbox
peek-plugin-chat
peek-plugin-livedb
peek-plugin-docdb
peek-plugin-search
peek-plugin-diagram
peek-plugin-pof-sql
peek-plugin-pof-soap
peek-plugin-pof-chat
peek-plugin-pof-field-switching
peek-plugin-pof-field-incidents
peek-plugin-pof-field-assessments
peek-plugin-pof-field-online
peek-plugin-pof-event
peek-plugin-gis-diagram
peek-plugin-pof-diagram
peek-plugin-pof-diagram-loader
peek-plugin-pof-equipment-loader
peek-plugin-pof-livedb-loader
peek-plugin-gis-diagram-loader
peek-plugin-pof-gis-location-loader
peek-plugin-pof-user-loader
peek-plugin-pof-email-incidents
peek-plugin-generic-diagram-menu
peek-plugin-zepben-diagram-menu
peek-plugin-gis-dms-positioner"

export bold=$(tput bold)
export normal=$(tput sgr0)



# -------------------------------------
if ! [ -f "setup.py" ]; then
    echo "$0 must be run in the directory where setup.py is" >&2
    exit 1
fi
