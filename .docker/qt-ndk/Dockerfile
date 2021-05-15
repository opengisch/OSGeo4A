FROM ubuntu:20.04
MAINTAINER Matthias Kuhn <matthias@opengis.ch>

ARG QT_VERSION

ARG NDK_VERSION=r21d
ARG NDK_VERSION_ID=21.3.6528147

ARG SDK_BUILD_TOOLS=29.0.2
ARG SDK_PACKAGES="tools platform-tools"

# The ANDROID_MINIMUM_PLATFORM specifies the minimum API level supported by the application or library. This value corresponds to the application's minSdkVersion.
ARG ANDROID_MINIMUM_PLATFORM=21
ARG ANDROID_TARGET_PLATFORM=29

ENV DEBIAN_FRONTEND noninteractive
ENV QT_PATH /opt/Qt
ENV QT_ANDROID_BASE ${QT_PATH}/${QT_VERSION}
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_SDK_ROOT ${ANDROID_HOME}
ENV ANDROID_NDK_ROOT=/opt/android-sdk/ndk/${NDK_VERSION_ID}
ENV ANDROID_NDK_HOST linux-x86_64
ENV SDK_BUILD_TOOLS=$SDK_BUILD_TOOLS

# !! The minimum supported android platform (e.g. 21 => Android 5) !!
ENV ANDROID_MINIMUM_PLATFORM ${ANDROID_MINIMUM_PLATFORM}
# !! The target android platform (e.g. 29 => Android 10) !!
ENV ANDROID_TARGET_PLATFORM ${ANDROID_TARGET_PLATFORM}

ENV QMAKESPEC android-clang
ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

# Install updates & requirements:
#  * git, openssh-client, ca-certificates - clone & build
#  * locales, sudo - useful to set utf-8 locale & sudo usage
#  * curl - to download Qt bundle
#  * make, default-jdk, ant - basic build requirements
#  * libsm6, libice6, libxext6, libxrender1, libfontconfig1, libdbus-1-3 - dependencies of Qt bundle run-file
#  * libc6:i386, libncurses5:i386, libstdc++6:i386, libz1:i386 - dependencides of android sdk binaries
RUN dpkg --add-architecture i386 && apt-get -qq update && apt-get -qq dist-upgrade && apt-get install -qq -y --no-install-recommends \
    git \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
    make \
    autoconf \
    automake \
    autotools-dev \
    libtool \
    openjdk-8-jdk \
    ant \
    libarchive-tools \
    p7zip-full \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libfontconfig1 \
    libdbus-1-3 \
    xz-utils \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    libz1:i386 \
    libxkbcommon-x11-0 \
    && apt-get -qq clean

RUN apt-get install -qq -y --no-install-recommends \
    bzip2 \
    unzip \
    gcc \
    g++ \
    cmake \
    patch \
    python3 \
    rsync \
    flex \
    bison \
    file \
    python3-six \
    python3-distutils \
    zip \
    pkg-config \
    ninja-build \
    jq \
    bc \
    protobuf-compiler

COPY install-qt.sh /tmp/qt/

RUN /tmp/qt/install-qt.sh --version ${QT_VERSION} --target android --directory "${QT_PATH}" --toolchain any \
      qtbase \
      qtsensors \
      qtquickcontrols \
      qtquickcontrols2 \
      qtmultimedia \
      qtlocation \
      qtimageformats \
      qtgraphicaleffects \
      qtdeclarative \
      qtandroidextras \
      qttools \
      qtsvg \
      qtwebview \
      qtconnectivity \
      qtcharts

# Download & unpack android SDK
# ENV JAVA_OPTS="-XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee"
RUN apt-get remove -qq -y openjdk-11-jre-headless
RUN curl -Lo /tmp/sdk-tools.zip 'https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip' \
    && mkdir -p ${ANDROID_HOME} \
    && unzip /tmp/sdk-tools.zip -d ${ANDROID_HOME} \
    && rm -f /tmp/sdk-tools.zip \
    && yes | sdkmanager --licenses && sdkmanager --verbose "platforms;android-${ANDROID_TARGET_PLATFORM}" "build-tools;${SDK_BUILD_TOOLS}" "ndk;${NDK_VERSION_ID}" ${SDK_PACKAGES} \
    && find ${ANDROID_NDK_ROOT}/platforms/* -maxdepth 0 ! -name "android-$ANDROID_MINIMUM_PLATFORM" -type d -exec rm -r {} +

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
