#!/bin/bash
mkdir -p /home/osgeo4a
IFS=' ' read -ra arches_array <<< "${ARCHES}"
for ARCH in "${arches_array[@]}"
do
	export ARCH=$ARCH
	/usr/src/distribute.sh -m qgis
	mv /usr/src/build/stage/$ARCH /home/osgeo4a
done
rm -rf /usr/src
