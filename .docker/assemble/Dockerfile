FROM qt-ndk
MAINTAINER Matthias Kuhn <matthias@opengis.ch>

ENV DEBIAN_FRONTEND noninteractive

USER root

RUN apt update && apt install -y file zip
COPY osgeo4a /home/osgeo4a
