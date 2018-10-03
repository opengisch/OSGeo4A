OSGeo4A
==========

This provides a set of scripts to build opensource geo tools for android. 

This is *Experimental*

Dependencies instructions
-------------------------
- you need a JDK v6 or later (OpenJDK is also good)
- [Apache ant](http://ant.apache.org/bindownload.cgi) v1.8 or later
- [Qt5 for android >= 5.9] Install ARMv7 arch support
Also read the [upstream Qt information on building Qt5 code for Android](http://doc.qt.io/qt-5/androidgs.html).
=======
- Android SDK ([Download from developer.android.com](https://developer.android.com/studio/index.html#downloads) just command line tools, API 15)
- Android NDK ([Crystax NDK 10.3.2](https://www.crystax.net/en/android/ndk#download))

[Here](http://doc.qt.io/qt-5/androidgs.html) are more information on building QT5 code for android

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

MacOS Specific instructions
---------------------------

- `brew install ant`

To build on MacOS High Sierra, you need java8, not default java 10, since
you would get `Could not determine java version from '10.0.2' during gradle install step`
with Qt 5.11.2.

- `brew tap caskroom/versions` 
- `brew cask install java8` (with java 10 you got  in gradle step) 

To build QGIS, you need relatively new version of bison (3.x). MacOS ships with bison 2.x
so it is required to install one newer and add to PATH

- `brew install bison`