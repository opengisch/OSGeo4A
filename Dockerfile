FROM opengisch/qt-crystax:5.11.3
MAINTAINER Matthias Kuhn <matthias@opengis.ch>

ENV DEBIAN_FRONTEND noninteractive

USER root

RUN yes | sdkmanager --licenses && sdkmanager --verbose "platforms;android-21" "build-tools;28.0.2" tools platform-tools

# For ndk-build (libzip) to work properly we need `file` installed
RUN apt-get install -y file python3-six zip

COPY .docker /usr/src/.docker
COPY tools /usr/src/tools
COPY recipes /usr/src/recipes
COPY layouts /usr/src/layouts
COPY distribute.sh /usr/src/distribute.sh
RUN mv /usr/src/.docker/config.conf /usr/src/config.conf
RUN /usr/src/distribute.sh -m qgis && mv /usr/src/stage /home/osgeo4a && rm -rf /usr/src
