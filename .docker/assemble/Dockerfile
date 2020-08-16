FROM qt-ndk
MAINTAINER Matthias Kuhn <matthias@opengis.ch>

ENV DEBIAN_FRONTEND noninteractive

USER root

RUN apt update && apt install -y file zip bc cmake ninja-build jq
ADD osgeo4a-armeabi-v7a.tar.gz /home/osgeo4a
ADD osgeo4a-arm64-v8a.tar.gz /home/osgeo4a
ADD osgeo4a-x86.tar.gz /home/osgeo4a
ADD osgeo4a-x86_64.tar.gz /home/osgeo4a
