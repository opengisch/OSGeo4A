FROM qt-ndk
MAINTAINER Matthias Kuhn <matthias@opengis.ch>
ARG ARCHES

COPY .docker /usr/src/.docker
COPY tools /usr/src/tools
COPY recipes /usr/src/recipes
COPY layouts /usr/src/layouts
COPY distribute.sh /usr/src/distribute.sh
COPY scripts/build_arches.sh /usr/src/build_arches.sh
RUN mv /usr/src/.docker/config.conf /usr/src/config.conf
ENV ROOT_OUT_PATH=/usr/src/build
RUN ARCHES="${ARCHES}" /usr/src/build_arches.sh
