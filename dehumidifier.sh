#!/bin/bash
###############################################################################
#
#                           dehumidifier
#
# Turns off steam after a set time period every day.
#
# Author : Roman Piták <roman@pitak.net>
# License: MIT
#
###############################################################################

set -u

###############################################################################
#                           configuration
###############################################################################

allowed_steam_running_minutes=80
tmp_dir='/tmp'
my_uid="$(id -u)"

###############################################################################
#                        end of configuration
###############################################################################

todays_file_name="dehumidifier-${my_uid}-$(date '+%Y-%m-%d')"

###############################################################################
# Find out if there are steam processes running under current user.
#
# Globals:
#   my_uid
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function steam_is_running() {
    pgrep --uid $my_uid --count steam > /dev/null
}

###############################################################################
# Delete tmp files from past days.
#
# Globals:
#   tmp_dir
#   my_uid
#   todays_file_name
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function cleanup_old_files() {
    find "${tmp_dir}" \
        -maxdepth 1 -type f \
        -name "dehumidifier-${my_uid}-"'*' \
        ! -name "${todays_file_name}" \
        -exec rm -- {} ';'
}

###############################################################################
#                                  main
###############################################################################

if steam_is_running; then
    echo 'running' >> "${tmp_dir}/${todays_file_name}"
    running_minutes="$(cat "${tmp_dir}/${todays_file_name}" | wc --lines)"
    if (($running_minutes > $allowed_steam_running_minutes)); then
        steam -shutdown
        sleep 5
        steam_is_running && kill -9 $(pgrep --uid $my_uid steam)
    fi
fi
