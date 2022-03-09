#!/bin/bash -x
export QMAKE_PATH=/usr/bin/qmake

export X_SOURCE_PATH=$PWD
export X_BUILD_NAME=xapkdetector_linux_portable
export X_RELEASE_VERSION=$(cat "release_version.txt")

source build_tools/linux.sh

check_file $QMAKE_PATH

if [ -z "$X_ERROR" ]; then
    make_init
    make_build "$X_SOURCE_PATH/xapkdetector_source.pro"
    cd "$X_SOURCE_PATH/gui_source"
    make_translate "gui_source_tr.pro"
    cd "$X_SOURCE_PATH"

    check_file "$X_SOURCE_PATH/build/release/xapkd"
    check_file "$X_SOURCE_PATH/build/release/xapkdc"
    if [ -z "$X_ERROR" ]; then
        create_deb_app_dir xapkd
        
        export X_PACKAGENAME='xapkdetector'
        export X_MAINTAINER='hors <horsicq@gmail.com>'
        
        export X_HOMEPAGE='http://ntinfo.biz'
        export X_DESCRIPTION='XAPKDetector shows an information about build tools, libraries and protection of Android/APK/DEX files'
        
        if [ "$X_DEBIAN_VERSION" -ge "11" ]; then
            export X_DEPENDS='libqt5core5a, libqt5svg5, libqt5gui5, libqt5widgets5, libqt5opengl5, libqt5dbus5, libqt5network5'
        else
            export X_DEPENDS='qt5-default, libqt5core5a, libqt5svg5, libqt5gui5, libqt5widgets5, libqt5opengl5, libqt5dbus5, libqt5network5'
        fi
        
        create_deb_control $X_SOURCE_PATH/release/$X_BUILD_NAME/DEBIAN/control
        
        cp -f $X_SOURCE_PATH/build/release/xapkd                              $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/bin/
        cp -f $X_SOURCE_PATH/build/release/xapkdc                             $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/bin/
        cp -f $X_SOURCE_PATH/LINUX/xapkd.desktop                             $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/share/applications/
        sed -i "s/#VERSION#/$X_RELEASE_VERSION/"                            $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/share/applications/xapkd.desktop
        cp -Rf $X_SOURCE_PATH/LINUX/hicolor/                               $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/share/icons/
        cp -Rf $X_SOURCE_PATH/XStyles/qss/                                  $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/lib/xapkd/
        mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/lib/xapkd/lang/
        cp -f $X_SOURCE_PATH/gui_source/translation/*.qm                    $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/lib/xapkd/lang/
        mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/lib/xapkd/signatures
        cp -f $X_SOURCE_PATH/signatures/crypto.db                           $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/lib/xapkd/signatures/

        make_deb
        mv $X_SOURCE_PATH/release/$X_BUILD_NAME.deb $X_SOURCE_PATH/release/die_${X_RELEASE_VERSION}_${X_OS_VERSION}_${X_ARCHITECTURE}.deb
        make_clear
    fi
fi
