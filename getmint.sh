#!/usr/bin/env bash

# getmint.sh - Marc Carlson 2024
# My other repositories: https://github.com/carls0n/

edition="xfce" # default edition
mirrors="mirrors.kernel.org" # default mirror

function usage {
echo "-v  (version) - Check for version other than latest version"
echo "-e  edition (mate, xfce, cinnamon and edge)"
echo "-d  Download selected version"
}

function get_args {
   while getopts ":hv:de:o" arg; do
   case $arg in
   v) version="$OPTARG" ;;
   d) download=1;;
   h) usage && exit;;  
   e) edition="$OPTARG";;
   o) override=1;;
   esac
   done
}

function systemd_check {
[[ ! -d /run/systemd/system ]] && echo This script requires a systemd based Linux system. && exit
}

function warn {
if [[ ! $override ]] &&  [[ $(hostnamectl | grep Op* | awk '{print $3,$4}') != "Linux Mint" ]]
then 
echo "This script is meant to be used with a Linux Mint installation. 
use -o to override and indicate which version and edition you want to download."
exit
fi
}

installed=$(hostnamectl | grep Op* | awk '{print $5}')
if [[ $installed == *.3 ]]; then
version=$(bc <<< "$installed+0.7")
else
version=$(bc <<< "$installed+0.1")
fi

function test {
if [[ $download == "1" ]] && [[ $edition == "edge" ]]
then 
wget -q -c --show-progress https://$mirrors/linuxmint/stable/$version/linuxmint-$version-cinnamon-64bit-edge.iso

elif [[ $download == "1" ]] && [[ $edition != "edge" ]]; then
wget -q -c --show-progress https://$mirrors/linuxmint/stable/$version/linuxmint-$version-$edition-64bit.iso
exit
fi

if curl -sL https://$mirrors/linuxmint/stable/$version/ | grep -q linuxmint-$version-$edition-64bit.iso
then printf "Linux Mint version $version $edition edition is available for download.\n"
else
printf "Linux Mint version $version $edition edition is not available.\n"
fi
}

get_args $@
systemd_check
warn
test
