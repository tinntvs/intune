#!/bin/bash

logname='[Intune-Enrollment]'

if [ "$EUID" -ne 0 ]; then 
  echo -e "You are not running as the root user.  Please try again with root privileges"
  exit 1
fi

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

    logger -t $logname - Remove the repository GPG key package
    rm packages-microsoft-prod.deb

    logger -t $logname - Install the Intune portal
    apt install -y intune-portal

    logger -t $logname - Enable the Edge browser repository
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"

    logger -t $logname - Install Microsoft Edge
    apt install -y microsoft-edge-stable

    logger -t $logname - Install Microsoft Defender for Endpoint
    apt install -y mdatp
)

ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    logger -t $logname - There was an error. Please restart the script or contact your admin if the error persists. - $ERROR_CODE
    exit $ERROR_CODE
fi
