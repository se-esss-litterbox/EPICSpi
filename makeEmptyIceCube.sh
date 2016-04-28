#!/bin/bash

PORT="/dev/ttyUSB0"

for i in "$@"
do
case $i in
	-p=*)
	PORT="${i#*=}"
	shift
	;;
	
	*)
	;;
esac
done

# echo $PORT

wget http://active-valve-127312.appspot.com/files/iceCubeIOC.tar.gz

tar zvxf iceCubeIOC.tar.gz

sed -i "s|^drvAsynSerialPortConfigure.*|drvAsynSerialPortConfigure("SERIALPORT","$PORT",0,0,0)|" iceCubeIOC/iocBoot/iociceCubeIOC/st.cmd

