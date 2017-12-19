FROM opengisch/docker-qt-crystax:latest
MAINTAINER Matthias Kuhn <matthias@opengis.ch>
ARG QT_VERSION=5.9.3

ENV DEBIAN_FRONTEND noninteractive
ENV PATH ${PATH}:${QT_ANDROID}/bin:${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

USER root
COPY . /usr/src/
RUN ls /usr/src
RUN mv /usr/src/.docker/config.conf /usr/src/config.conf
RUN /usr/src/distribute.sh -m qgis
