#!/bin/bash

SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Make sure root is being used
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Grab the necessary files
mkdir -p /home/pi/Downloads/tmp_epics
cd /home/pi/Downloads/tmp_epics

wget -nv http://www.aps.anl.gov/epics/download/base/baseR3.14.12.5.tar.gz
wget -nv http://aps.anl.gov/epics/download/modules/asyn4-28.tar.gz
wget -nv http://epics.web.psi.ch/software/streamdevice/StreamDevice-2.tgz

#########################################################################
# Step 1: Install EPICS Base
#########################################################################

# Unzip EPICS to the right place & make some soft-links
mkdir -p /home/pi/Apps/epics
tar -zxf /home/pi/Downloads/tmp_epics/baseR3.14.12.5.tar.gz -C /home/pi/Apps/epics/
ln -s /home/pi/Apps/epics /usr/local/
ln -s /home/pi/Apps/epics/base-3.14.12.5 /home/pi/Apps/epics/base

cat $SRCDIR/aliasContents.txt >> /home/pi/.bash_aliases
source /home/pi/.bash_aliases

cd /home/pi/Apps/epics/base
make
# echo "Pretending to make."

#########################################################################
# Step 2: Installing ASYN Driver
#########################################################################

mkdir -p /home/pi/Apps/epics/modules
tar -zxf /home/pi/Downloads/tmp_epics/asyn4-28.tar.gz -C /home/pi/Apps/epics/modules/
ln -s /home/pi/Apps/epics/modules/asyn4-28 /home/pi/Apps/epics/modules/asyn
cd /home/pi/Apps/epics/modules/asyn

cat configure/RELEASE
sed -i 's/^IPAC/#IPAC/' configure/RELEASE
sed -i 's/^SNCSEQ/#SNCSEQ/' configure/RELEASE
sed -i 's/^EPICS_BASE.*/EPICS_BASE=\/usr\/local\/epics\/base/' configure/RELEASE
cat configure/RELEASE

cd /home/pi/Apps/epics/modules/asyn
make

#########################################################################
# Step 3: Installing StreamDevice
#########################################################################

mkdir /home/pi/Apps/epics/modules/stream
cd /home/pi/Apps/epics/modules/stream
tar -zxvf /home/pi/Downloads/tmp_epics/StreamDevice-2.tgz -C  /home/pi/Apps/epics/modules/stream
makeBaseApp.pl -t support ""

echo "ASYN=/usr/local/epics/modules/asyn" >> configure/RELEASE
make
cd StreamDevice-2-6
make

#########################################################################
# Last step:  Make sure everything has the right ownership
#########################################################################
chown -R pi:pi /home/pi/Apps

