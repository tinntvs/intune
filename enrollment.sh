#!/bin/bash

logname='[Intune-Enrollment]'

if [ "$EUID" -ne 0 ]; then 
  echo -e "You are not running as the root user.  Please try again with root privileges"
  exit 1
fi

verx=$(grep -oP '(?<=VERSION_ID=").*(?=")' /etc/os-release)

(
    logger -t $logname - Set the error status
    set -e

    logger -t $logname Install pre-requisite packages
    apt install -y curl gpg wget apt-transport-https software-properties-common

    logger -t $logname Install Microsoft Edge Latest version
    wget https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_131.0.2903.112-1_amd64.deb
    sudo apt install -y ./microsoft-edge-stable_131.0.2903.112-1_amd64.deb

    logger -t $logname Install Microsoft Intune app
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/ 
    sudo sh -c "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/$verx/prod jammy main\" > /etc/apt/sources.list.d/microsoft-ubuntu-jammy-prod.list"
    sudo rm microsoft.gpg
    apt update
    apt install -y intune-portal

    logger -t $logname Install Microsoft Defender for Endpoint
    wget https://packages.microsoft.com/ubuntu/$verx/prod/pool/main/m/mde-netfilter/mde-netfilter_100.69.73_amd64.deb
    apt install -y ./mde-netfilter_100.69.73_amd64.deb
    apt install -y mdatp
)

ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    logger -t $logname - There was an error. Please restart the script or contact your admin if the error persists. - $ERROR_CODE
    exit $ERROR_CODE
fi
sudo init 6
