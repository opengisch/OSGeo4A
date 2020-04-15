FROM opengisch/qt-ndk:5.13.2
MAINTAINER Matthias Kuhn <matthias@opengis.ch>

ARG ARCHES
ENV DEBIAN_FRONTEND noninteractive

USER root

# For ndk-build (libzip) to work properly we need `file` installed
RUN apt update && apt install -y file python3-six zip pkg-config protobuf-compiler

COPY .docker /usr/src/.docker
COPY tools /usr/src/tools
COPY recipes /usr/src/recipes
COPY layouts /usr/src/layouts
COPY distribute.sh /usr/src/distribute.sh
COPY scripts/build_arches.sh /usr/src/build_arches.sh
RUN mv /usr/src/.docker/config.conf /usr/src/config.conf
ENV ROOT_OUT_PATH=/usr/src/build
RUN ARCHES=$ARCHES /usr/src/build_arches.sh
