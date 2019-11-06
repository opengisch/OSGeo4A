#!/bin/bash
IFS=' ' read -ra arches_array <<< "${ARCHES}"
for ARCH in "${arches_array[@]}"
do
	export ARCH=$ARCH
	/usr/src/distribute.sh -m qgis
done
cp -r /usr/src/build/stage/* /home/osgeo4a
rm -rf /usr/src
