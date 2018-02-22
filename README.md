OSGeo4A
==========

This provides a set of scripts to build opensource geo tools for android. 

This is *Experimental*

Dependencies instructions
-------------------------
- you need a JDK v6 or later (OpenJDK is also good)
- [Apache ant] (http://ant.apache.org/bindownload.cgi) v1.8 or later
- [Qt5 for android >= 5.9] Install ARMv7 arch support
- Android SDK (https://developer.android.com/studio/index.html#downloads just command line tools, API 15)
- Android NDK (Crystax NDK 10.3.2)

Also read the [upstream Qt information on building Qt5 code for Android](http://doc.qt.io/qt-5/androidgs.html).

Build instructions
-----------
Create a file config.conf in the root folder by copying the config.conf.default
file and edit it accordingly to your needs.

The build system is maintained for QGIS 3.x releases. To build QGIS 2.x releases, modify recipes/qgis/recipe.sh
accordingly. Alternatively you may want to clone qgis/QGIS locally and point the config.conf file to your local 
repository.

```sh
cd OSGeo4A 
cp config.conf.default config.conf
# nano config.conf
./distribute.sh -dqgis -mqgis
```
