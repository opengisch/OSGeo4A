OSGeo4A
==========

This provides a set of scripts to build opensource geo tools for android.

This is *Experimental*

Dependencies instructions
-----------
the easiest way to get all the android build dependencies is to install android 
studio from http://developer.android.com/sdk/index.html
During install, download at least one android SDK platform (ANDROIDAPI) and the 
NDK (ANDROIDNDKVER).

we suggest installing the ones that we show in the example config file below.

please note that the API 23 (Android 6, is not yet supported by the NDK r10e) 

Alternatively you can manually get the Android SDK at
http://developer.android.com/sdk/index.html#Other and the Android NDK at 
http://developer.android.com/ndk/downloads/index.html

Build instructions
-----------
Create a file config.conf in the root folder with the following content

```sh
export ANDROIDSDK="/path/to/android-sdk"
# if installed with android studio, this is in ndk-bundle if not adjust it
export ANDROIDNDK="/path/to/android-sdk/ndk-bundle"
export ANDROIDNDKVER=r10e
export ANDROIDAPI=21
export ARCH="armeabi-v7a"
#export ARCH="x86"
export QTSDK="/path/to/qt/sdk/Qt5.4.0/5.4"

# To use local sourcecode instead of the configured URL:
# export O4A_[module]_DIR=/usr/src/mymodulesource like this
# export O4A_qfield_DIR="/home/marco/dev/QGIS/QField"
# export O4A_qgis_DIR="/home/marco/dev/QGIS/master"

# By default all cores will be used to build
# Use this option to override
# export CORES=4
```

Call
```sh
./distribute.sh -dqgis -mqgis
```

Options
-----------

<dl>
 <dt>-l</dt> <dd>List available modules</dd>
 <dt>-m</dt> <dd>Specifies the list of modules to build</dd>
 <dt>-a</dt> <dd>Layout to build</dd>
 <dt>-s</dt> <dd>Run a bash in an ARM cross compile environment</dd>
 <dt>-d</dt> <dd>Distribution to build</dd>
 <dt>-f</dt> <dd>Do a clean build</dd>
 <dt>-h</dt> <dd>Help</dd>
</dl>
