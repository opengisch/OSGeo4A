#!/bin/bash

set -e

mkdir -p /home/osgeo4a
IFS=' ' read -ra arches_array <<< "${ARCHES}"
for ARCH in "${arches_array[@]}"
do
	export ARCH=$ARCH
	/usr/src/distribute.sh -m qgis
	mv /usr/src/build/stage/$ARCH /home/osgeo4a
	strip --strip-unneeded /home/osgeo4a/*/lib/*.so
done
rm -rf /usr/src
