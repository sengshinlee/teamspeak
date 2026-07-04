#!/bin/bash

function distribution() {
    if [ ! -f "/etc/debian_version" ]; then
        echo "ERROR: Linux distribution must be Ubuntu!"
        exit 1
    fi
}

function architecture() {
    local ARCHITECTURE=$(uname -m)

    if [ "${ARCHITECTURE}" != "x86_64" ]; then
        echo "ERROR: Architecture must be x86_64!"
        exit 1
    fi
}

function root() {
    if [ "$(echo ${USER})" != "root" ]; then
        echo "WARNING: You must be root to run the script!"
        exit 1
    fi
}

function install() {
    wget https://files.teamspeak-services.com/releases/server/3.13.7/teamspeak3-server_linux_amd64-3.13.7.tar.bz2
    if [ ! -f "/usr/bin/tar" ]; then
        apt-get install bzip2 -y >/dev/null 2>&1
    fi
    tar -xjf teamspeak3-server_linux_amd64-3.13.7.tar.bz2
    cd teamspeak3-server_linux_amd64
    touch .ts3server_license_accepted
    ./ts3server_minimal_runscript.sh &
    exit 0
}

function remove() {
    if [ -d "/root/teamspeak3-server_linux_amd64" ]; then
        cd /root/teamspeak3-server_linux_amd64
        rm -rf .ts3server_license_accepted \
               files \
               logs \
               query_ip_allowlist.txt \
               query_ip_denylist.txt \
               ssh_host_rsa_key \
               ts3server.sqlitedb \
               ts3server.sqlitedb-shm \
               ts3server.sqlitedb-wal >/dev/null 2>&1
    else
        echo "NOTICE: Not installed, no need to remove!"
    fi
    exit 0
}

function help() {
    cat <<EOF
USAGE
  bash teamspeak.sh [OPTION]

OPTION
  -h, --help    Show help manual
  -i, --install Install TeamSpeak3 Server and configure
  -r, --remove  Remove TeamSpeak3 Server
EOF
    exit 0
}

function main() {
    distribution
    architecture
    root

    if [ "$#" -eq 0 ]; then
        help
    fi

    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h|--help)
                help
                ;;
            -i|--install)
                install
                ;;
            -r|--remove)
                remove
                ;;
            *)
                echo "ERROR: Invalid option \"$1\"!"
                exit 1
                ;;
        esac
        shift
    done
}

main "$@"
