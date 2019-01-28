#!/usr/bin/env bash

set -e

SHA=$1

sed -i -r "s@(^URL_qgis.*)/\w+\.zip@\1/${SHA}.zip@" recipes/qgis/recipe.sh

URL=$(sed -n -r 's/^URL_qgis=(.*)$/\1/p' recipes/qgis/recipe.sh)
wget $URL

FILE=${SHA}.zip
SUM=$( md5sum ${FILE}  | cut -d' '  -f1 )

echo $SUM

sed -i -r "s/^MD5_qgis=.*/MD5_qgis=${SUM}/"  recipes/qgis/recipe.sh
rm ${FILE}


