#!/bin/bash

set -e

SRCPATH=/mnt/c/Users/sunwp/Documents/GitHub/MindgoMachineConfigTool
DESTPATH=/opt/MindGoArm/Src

echo ===rsync code===
rsync -r --delete --exclude=".o" --exclude=".git" ${SRCPATH}/ ${DESTPATH}

echo ===qmake===
cd ${DESTPATH}
/home/raspi/build/qt5.8-host/bin/qmake ${DESTPATH}/MindGoTool_AllInOne.pro

echo ===make===
make -j2

mkdir -p ../MindGoArm/UserInterfaceLayer/config
cp ./MindGoTool_AllInOne ../MindGoArm/
cp -avf ./UserInterfaceLayer/config/* ../MindGoArm/UserInterfaceLayer/config/

rsync -avztr --delete --rsh="/usr/bin/sshpass -p raspberry ssh -o StrictHostKeyChecking=no -l pi" ../MindGoArm/ 192.168.3.1:/home/pi/MindGoArm



