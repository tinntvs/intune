#!/bin/bash

logname='[Intune-Enrollment]'

if [ "$EUID" -ne 0 ]; then 
  echo -e "You are not running as the root user.  Please try again with root privileges"
  exit 1
fi

function app_msedge()
{
  logger -t $logname Install Microsoft Edge Latest version
  wget https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_131.0.2903.112-1_amd64.deb
  sudo apt install -y ./microsoft-edge-stable_131.0.2903.112-1_amd64.deb
}

function app_msintune()
{
  logger -t $logname Install Microsoft Intune Portal
  if [ -f "/etc/apt/sources.list.d/microsoft-prod.list" ]; then
    rm -rf /etc/apt/sources.list.d/microsoft-prod.list
  fi
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
  rm microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" >> /etc/apt/sources.list.d/microsoft-ubuntu-$(lsb_release -cs)-prod.list'
  sudo apt update -y
  sudo apt install intune-portal -y
}
function app_mdatp()
{
  logger -t $logname Install Microsoft Defender for Endpoint
  #  wget https://packages.microsoft.com/ubuntu/$verx/prod/pool/main/m/mde-netfilter/mde-netfilter_100.69.73_amd64.deb
  #  apt install -y ./mde-netfilter_100.69.73_amd64.deb
  #  apt install -y mdatp
  curl -o microsoft.list https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list
  sudo mv ./microsoft.list /etc/apt/sources.list.d/microsoft-prod.list
  sudo apt-get update -y
  sudo apt-get install mdatp -y
}

#main_script
logger -t $logname - Set the error status
set -e

logger -t $logname Install pre-requisite packages
apt install -y curl gpg gnupg wget libplist-utils apt-transport-https software-properties-common

(
  app_msedge
  app_mdatp
  app_msintune
)
ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    logger -t $logname - There was an error. Please restart the script or contact your admin if the error persists. - $ERROR_CODE
    exit $ERROR_CODE
fi
sudo init 6
