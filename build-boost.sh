#!/bin/sh

#  build-boost.sh
#
#
#  Created by Thomas Chen on 10/29/16.
#

set -e
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
    brew unlink boost && brew install boost-$BOOSTVER.$OSX_NAME.bottle*tar.gz;
elif ls temp/boost-$BOOSTVER.$OSX_NAME.bottle*tar.gz 1>/dev/null 2>&1; then
    echo 'Installing boost from cached homebrew version...';
    time brew unlink boost;
    time brew install temp/boost-$BOOSTVER.$OSX_NAME.bottle*tar.gz;
    BUILD_BOOST=true;
elif [ "$BUILD_BOOST" = true ]; then
    echo 'Building homebrew bottle...';
    BUILD_BOOST=false;
    brew unlink boost;
    brew install --build-bottle boost;
    if [ ! -d temp ]; then
        mkdir temp;
    fi;
    pushd temp;
    brew bottle boost;
    popd;
else
    BUILD_BOOST=false;
fi;
if [ "$BUILD_BOOST" = true ]; then
    echo 'Building boost...';
    time brew unlink boost;
    if [ ! -f Library/Caches/Homebrew/boost-$BOOSTVER.tar.bz2 ]; then
        #Just unpack and cache.
        BUILD_BOOST=false;
    fi;
    time brew unpack --patch --destdir=. boost;
    if [ "$BUILD_BOOST" = true ]; then
        pushd boost-$BOOSTVER;
        echo "Bootstrap boost...";
        time ./bootstrap.sh --prefix=/usr/local/Cellar/boost/$BOOSTVER --libdir=/usr/local/Cellar/boost/$BOOSTVER/lib --without-icu --without-libraries=python,mpi > boost_bootstrap.log;
        {
        echo "using darwin : : /usr/local/llvm/bin/clang++"
        echo "             : <cxxflags>$MACOS_SDK <linkflags>$MACOS_SDK <compileflags>$MACOS_SDK ;"
        echo "using python : 3.5"
        echo "             : /usr/local/bin/python3.5"
        echo "             : /usr/local/Cellar/python3/$PYTHONVER/include/python3.5m ;"
        } > user-config.jam;
        echo 'boost headers...';
        time ./b2 headers;
        echo "Building boost...";
        travis_wait 40 ./b2 --prefix=/usr/local/Cellar/boost/$BOOSTVER --libdir=/usr/local/Cellar/boost/$BOOSTVER/lib -d2 -j4 --layout=tagged --user-config=user-config.jam install threading=multi,single link=shared,static;
        popd;
        brew link --overwrite boost;
        brew bottle boost;
        rm -rf boost-$BOOSTVER;
    fi;
fi;
