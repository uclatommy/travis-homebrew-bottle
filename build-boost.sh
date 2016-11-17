#!/bin/sh

#  build-boost.sh
#
#
#  Created by Thomas Chen on 10/29/16.
#

set -x #verbose
set -e #exit on error

BOOSTVER=$3
PYTHONVER=$2
OSXVER=$1
BUILD_BOOST=$4
MACOS_SDK="-mmacosx-version-min=$OSXVER";
if [ $OSXVER = 10.10 ] ; then
    OSX_NAME=yosemite ;
elif [ $OSXVER = 10.11 ] ; then
    OSX_NAME=el_capitan ;
fi

# Build Boost
if ls boost-$BOOSTVER.$OSX_NAME.bottle*tar.gz 1>/dev/null 2>&1; then
    echo 'Installing boost from cache...';
    BUILD_BOOST=false;
    brew unlink boost;
    brew install boost-$BOOSTVER.$OSX_NAME.bottle*tar.gz;
elif [ "$BUILD_BOOST" = true ]; then
    echo 'Building homebrew bottle...';
    BUILD_BOOST=false;
    brew unlink boost;
    brew install --build-bottle boost --c++11 --with-python3 --without-python;
    brew bottle boost;
else
    BUILD_BOOST=false;
fi;
