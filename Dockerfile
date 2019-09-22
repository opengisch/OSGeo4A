FROM opengisch/qt-ndk:5.13.0-2
MAINTAINER Matthias Kuhn <matthias@opengis.ch>

ENV DEBIAN_FRONTEND noninteractive

USER root

# For ndk-build (libzip) to work properly we need `file` installed
RUN apt-get update
RUN apt-get install -y file python3-six zip

COPY .docker /usr/src/.docker
COPY tools /usr/src/tools
COPY recipes /usr/src/recipes
COPY layouts /usr/src/layouts
COPY distribute.sh /usr/src/distribute.sh
RUN mv /usr/src/.docker/config.conf /usr/src/config.conf
ENV ROOT_OUT_PATH=/usr/src/build
RUN /usr/src/distribute.sh -m qgis && cp -r /usr/src/build/stage /home/osgeo4a && rm -rf /usr/src
