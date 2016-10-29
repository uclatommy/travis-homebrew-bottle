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

# Build Boost
brew unlink boost
if [ ! -d boost-$BOOSTVER ]; then
    brew unpack --patch --destdir=. boost;
fi
pushd boost-$BOOSTVER;
echo "Bootstrap boost..."
./bootstrap.sh --prefix=/usr/local/Cellar/boost/$BOOSTVER --libdir=/usr/local/Cellar/boost/$BOOSTVER/lib --without-icu --without-libraries=python,mpi > boost_bootstrap.log
{
echo "using darwin : : /usr/local/llvm39/bin/clang++"
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
