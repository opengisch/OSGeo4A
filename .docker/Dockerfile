# Minimal docker container to build project
# Image: rabits/qt:5.9-android

FROM ubuntu:16.04
MAINTAINER Rabit <home@rabits.org> (@rabits)
ARG QT_VERSION=5.9.3
ARG CRYSTAX_NDK_VERSION=10.3.2
ARG ANDROID_SDK_VERSION=24.4.1

ENV DEBIAN_FRONTEND noninteractive
ENV QT_PATH /opt/Qt
ENV QT_ANDROID ${QT_PATH}/${QT_VERSION}/android_armv7
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT ${ANDROID_HOME}
ENV ANDROID_NDK_ROOT /opt/android-ndk
ENV ANDROID_NDK_TOOLCHAIN_PREFIX arm-linux-androideabi
ENV ANDROID_NDK_TOOLCHAIN_VERSION 4.9
ENV ANDROID_NDK_HOST linux-x86_64
ENV ANDROID_NDK_PLATFORM android-15
ENV ANDROID_NDK_TOOLS_PREFIX ${ANDROID_NDK_TOOLCHAIN_PREFIX}
ENV QMAKESPEC android-g++
ENV PATH ${PATH}:${QT_ANDROID}/bin:${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

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
    default-jdk \
    ant \
    bsdtar \
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
    bison

COPY extract-qt-installer.sh /tmp/qt/

# Download & unpack Qt 5.9 toolchains & clean
RUN curl -Lo /tmp/qt/installer.run "https://download.qt-project.org/official_releases/qt/5.9/${QT_VERSION}/qt-opensource-linux-x64-${QT_VERSION}.run" \
    && QT_CI_PACKAGES=qt.$(echo "${QT_VERSION}" | sed 's/\.//g').android_armv7,qt.$(echo "${QT_VERSION}" | sed 's/\.//g').qtscript.android_armv7 /tmp/qt/extract-qt-installer.sh /tmp/qt/installer.run "$QT_PATH" \
    && find "$QT_PATH" -mindepth 1 -maxdepth 1 ! -name '5.*' -exec echo 'Cleaning Qt SDK: {}' \; -exec rm -r '{}' \; \
    && rm -rf /tmp/qt

# Download & unpack android SDK
RUN mkdir /tmp/android && curl -Lo /tmp/android/sdk.tgz "https://dl.google.com/android/android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz" \
    && bsdtar --no-same-owner -xf /tmp/android/sdk.tgz -C /opt \
    && rm -rf /tmp/android && echo "y" | android update sdk -u -a -t tools,platform-tools,build-tools-21.1.2,$ANDROID_NDK_PLATFORM

# Download & unpack android NDK
RUN mkdir /tmp/android && cd /tmp/android && curl -Lo ndk.xz "https://www.crystax.net/download/crystax-ndk-${CRYSTAX_NDK_VERSION}-linux-x86_64.tar.xz" \
    && bsdtar -xf /tmp/android/ndk.xz -C /tmp && mv /tmp/crystax-ndk-${CRYSTAX_NDK_VERSION} $ANDROID_NDK_ROOT \
    && rm -rf /tmp/android

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Add group & user
RUN groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

USER user
WORKDIR /home/user
ENV HOME /home/user
