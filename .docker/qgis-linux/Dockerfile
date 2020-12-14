FROM fedora:32
MAINTAINER Matthias Kuhn <matthias@opengis.ch>
ARG QGIS_URL

RUN dnf -y install \
    unzip \
    qt5-devel \
    clang \
    ninja-build \
    flex \
    bison \
    geos-devel \
    gdal-devel \
    libzip-devel \
    sqlite-devel \
    protobuf-devel \
    qca-qt5-devel \
    proj-devel \
    gsl-devel \
    python3-pyqt5-sip \
    python3-qt5-devel \
    python3-qscintilla-qt5 \
    exiv2-devel \
    qwt-qt5-devel \
    qtkeychain-qt5-devel \
    qscintilla-qt5-devel \
    spatialindex-devel \
    libspatialite-devel \
    protobuf-lite-devel \
    libpq-devel \
    libzstd-devel \
    qt5-qtwebview-devel


RUN curl -LJ -o QGIS.tar.gz $QGIS_URL && \
    tar xzf QGIS.tar.gz && \
    mkdir build && \
    cd build && \
    cmake -GNinja ../QGIS-* && \
    ninja install && \
    cd .. && \
    rm -rf build && \
    rm -rf ../QGIS-* && \
    rm ../QGIS.tar.gz

