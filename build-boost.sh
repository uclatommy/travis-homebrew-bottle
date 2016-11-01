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
    brew unlink boost && brew install temp/boost-$BOOSTVER.$OSX_NAME.bottle*tar.gz;
    BUILD_BOOST=true;
else
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
fi;
if [ "$BUILD_BOOST" = true ]; then
    echo 'Building boost...';
    brew unlink boost
    if [ ! -d boost-$BOOSTVER ]; then
        brew unpack --patch --destdir=. boost;
    fi
    pushd boost-$BOOSTVER;
    echo "Bootstrap boost..."
    ./bootstrap.sh --prefix=/usr/local/Cellar/boost/$BOOSTVER --libdir=/usr/local/Cellar/boost/$BOOSTVER/lib --without-icu --without-libraries=python,mpi > boost_bootstrap.log
    {
    echo "using darwin : : /usr/local/llvm/bin/clang++"
    echo "             : <cxxflags>$MACOS_SDK <linkflags>$MACOS_SDK <compileflags>$MACOS_SDK ;"
    echo "using python : 3.5"
    echo "             : /usr/local/bin/python3.5"
    echo "             : /usr/local/Cellar/python3/$PYTHONVER/include/python3.5m ;"
    } > user-config.jam;
    echo 'boost headers...'
    ./b2 headers
    echo "Building boost..."
    ./b2 --prefix=/usr/local/Cellar/boost/$BOOSTVER --libdir=/usr/local/Cellar/boost/$BOOSTVER/lib -d2 -j4 --layout=tagged --user-config=user-config.jam install threading=multi,single link=shared,static > boost.log;
    popd
    brew link --overwrite boost
    brew bottle boost;
fi;
