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
export QTSDK="/path/to/qt/sdk/Qt5.4.0/5.4"

# To use local sourcecode instead of the configured URL:
# export O4A_[module]_DIR=/usr/src/mymodulesource

# By default all cores will be used to build
# Use this option to override
# export CORES=4
```

Call
```sh
./distribute.sh d=qgis m='qgis'
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
