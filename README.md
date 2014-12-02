OSGeo4A
==========

This provides a set of scripts to build opensource geo tools for android.

This is *Experimental*

Build instructions
-----------

Create a file config.conf in the root folder with the following content

```sh
export ANDROIDSDK="/path/to/android-sdk"
export ANDROIDNDK="/path/to/android-sdk"
export ANDROIDNDKVER=r10c
export ANDROIDAPI=14
export CORES=8
export QTSDK="/path/to/qt/sdk/Qt5.4.0/5.4"

# To use local sourcecode instead of the configured URL:
# export O4A_[module]_DIR=/usr/src/mymodulesource
```

Call
```sh
./distribute.sh d=qgis m='qgis'
```

Options
-----------

 -l: List available modules
 -m: Specifies the list of modules to build
 -a: Layout to build
 -s: Run a bash in an ARM cross compile environment
 -d: Distribution to build
 -f: Do a clean build
 -h: Help

