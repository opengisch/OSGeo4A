OSGeo4A
==========

This provides a set of scripts to build opensource geo tools for android.

This is *Experimental*

Dependencies instructions
-----------
- you need a JDK v6 or later (OpenJDK is also good)
- [Apache ant] (http://ant.apache.org/bindownload.cgi) v1.8 or later
- [Qt5 for android]
(http://download.qt.io/official_releases/qt/5.5/5.5.1/qt-opensource-linux-x64-android-5.5.1.run)
- and all the android stuff. the easiest way to get all the android dependencies
is to install [Android studio] (http://developer.android.com/sdk/index.html)
During install, download at least one android SDK platform and the NDK.

we suggest installing the ones that we show in the example config file below
(ANDROIDAPI, ANDROIDNDKVER).

please note that the API 22+ (Android 5.1+, is not yet supported by the NDK r10e)

[Here] (http://doc.qt.io/qt-5/androidgs.html) are more informations on building QT5
code for android

Alternatively you can manually get the Android SDK at
http://developer.android.com/sdk/index.html#Other and the Android NDK at
http://developer.android.com/ndk/downloads/index.html

Build instructions
-----------
Create a file config.conf in the root folder by copying the config.conf.default
 file and edit it accordingly to your needs 
```sh
cd OSGeo4A
cp config.conf.default config.conf
# nano config.conf
./distribute.sh -dqgis -mqgis
```

To get more info about the distribute file, call:
```sh
./distribute.sh -h
```

