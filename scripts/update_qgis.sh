#!/usr/bin/env bash

set -e

SHA=$1

# GNU prefix command for mac os support (gsed, gsplit)
GP=
if [[ "$OSTYPE" =~ darwin* ]]; then
  GP=g
fi

${GP}sed -i -r "s@(^URL_qgis.*)/\w+\.tar.gz@\1/${SHA}.tar.gz@" recipes/qgis/recipe.sh

URL=$(${GP}sed -n -r 's/^URL_qgis=(.*)$/\1/p' recipes/qgis/recipe.sh)

SUM=$(wget $URL -O- | md5sum | cut -d ' ' -f 1)

echo $SUM

${GP}sed -i -r "s/^MD5_qgis=.*/MD5_qgis=${SUM}/"  recipes/qgis/recipe.sh
