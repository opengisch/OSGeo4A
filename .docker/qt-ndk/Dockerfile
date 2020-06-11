FROM ubuntu:20.04
MAINTAINER Matthias Kuhn <matthias@opengis.ch>
ARG QT_VERSION
ARG NDK_VERSION=r21
ARG SDK_PLATFORM=android-21
ARG SDK_BUILD_TOOLS=28.0.3
ARG SDK_PACKAGES="tools platform-tools"

ENV DEBIAN_FRONTEND noninteractive
ENV QT_PATH /opt/Qt
ENV QT_ANDROID_BASE ${QT_PATH}/${QT_VERSION}
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_SDK_ROOT ${ANDROID_HOME}
ENV ANDROID_NDK_ROOT /opt/android-ndk
ENV ANDROID_NDK_HOST linux-x86_64
ENV ANDROID_NDK_PLATFORM android-21
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
    zip \
    pkg-config \
    protobuf-compiler

COPY install-qt.sh /tmp/qt/

RUN /tmp/qt/install-qt.sh --version ${QT_VERSION} --target android --directory "${QT_PATH}" --toolchain any \
      qtbase \
      qtsensors \
      qtquickcontrols2 \
      qtquickcontrols \
      qtmultimedia \
      qtlocation \
      qtimageformats \
      qtgraphicaleffects \
      qtdeclarative \
      qtandroidextras \
      qttools \
      qtimageformats \
      qtsvg

# Download & unpack android SDK
# ENV JAVA_OPTS="-XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee"
RUN apt-get remove -qq -y openjdk-11-jre-headless
RUN curl -Lo /tmp/sdk-tools.zip 'https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip' \
    && mkdir -p ${ANDROID_HOME} \
    && unzip /tmp/sdk-tools.zip -d ${ANDROID_HOME} \
    && rm -f /tmp/sdk-tools.zip \
    && yes | sdkmanager --licenses && sdkmanager --verbose "platforms;${SDK_PLATFORM}" "build-tools;${SDK_BUILD_TOOLS}" ${SDK_PACKAGES}

# Download & unpack android NDK & remove any platform which is not used
RUN mkdir /tmp/android \
    && curl -Lo /tmp/android/ndk.zip "https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip" \
    && unzip /tmp/android/ndk.zip -d /tmp \
    && mv /tmp/android-ndk-${NDK_VERSION} ${ANDROID_NDK_ROOT} \
    && cd / \
    && rm -rf /tmp/android \
    && find ${ANDROID_NDK_ROOT}/platforms/* -maxdepth 0 ! -name "$ANDROID_NDK_PLATFORM" -type d -exec rm -r {} +

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
