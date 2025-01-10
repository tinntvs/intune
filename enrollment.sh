#!/bin/bash

logname='MSIntune---Onboarding: '

if [ "$EUID" -ne 0 ]
  then echo "Please run this script as root"
  exit 1
fi

# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    logger -t $logname - Set the error status
    set -e

    logger -t $logname - Install pre-requisite packages
    apt install -y wget apt-transport-https software-properties-common

    logger -t $logname - Download the Microsoft repository and GPG keys
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"

    logger -t $logname - Register the Microsoft repository and GPG keys
    dpkg -i packages-microsoft-prod.deb

    logger -t $logname - Update the list of packages after we have added packages.microsoft.com
    apt update

    logger -t $logname - Remove the repository & GPG key package (as we imported it above)
    rm packages-microsoft-prod.deb

    logger -t $logname - Install the Intune portal
    apt install -y intune-portal

    logger -t $logname - Enable the Edge browser repository
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"

    logger -t $logname - Install Microsoft Edge
    apt install -y microsoft-edge-stable
)
# Catch any necessary errors to prevent the program from improperly exiting. 
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    logger -t $logname - There was an error. Please restart the script or contact your admin if the error persists. - $ERROR_CODE
    exit $ERROR_CODE
fi
