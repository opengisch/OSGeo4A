#!/usr/bin/env bash

set -e

SHA=$1

# GNU prefix command for mac os support (gsed, gsplit)
GP=
if [[ "$OSTYPE" =~ darwin* ]]; then
  GP=g
fi

${GP}sed -i -r "s@(^URL_qgis.*)/\w+\.zip@\1/${SHA}.tar.gz@" recipes/qgis/recipe.sh

URL=$(${GP}sed -n -r 's/^URL_qgis=(.*)$/\1/p' recipes/qgis/recipe.sh)
wget $URL

FILE=${SHA}.tar.gz
SUM=$( md5sum ${FILE}  | cut -d' '  -f1 )

echo $SUM

${GP}sed -i -r "s/^MD5_qgis=.*/MD5_qgis=${SUM}/"  recipes/qgis/recipe.sh
rm ${FILE}
