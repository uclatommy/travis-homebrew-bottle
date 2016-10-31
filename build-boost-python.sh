#!/bin/sh

#  build-boost-python.sh
#  
#
#  Created by Thomas Chen on 10/29/16.
#

set -e
BOOSTVER=$3
PYTHONVER=$2
OSXVER=$1
MACOS_SDK="-mmacosx-version-min=$OSXVER";

# Build boost-python
brew unlink boost-python
if [ ! -d boost-python-$BOOSTVER ]; then
    brew unpack --patch --destdir=. boost-python;
fi
pushd boost-python-$BOOSTVER
echo "Bootstrapping boost-python..."
./bootstrap.sh --prefix=/usr/local/Cellar/boost-python/$BOOSTVER --libdir=/usr/local/Cellar/boost-python/$BOOSTVER/lib --with-libraries=python --with-python=python3 --with-python-root=/usr/local/Cellar/python3/$PYTHONVER;
{
echo "using darwin : : /usr/local/llvm/bin/clang++"
echo "             : <cxxflags>$MACOS_SDK <linkflags>$MACOS_SDK <compileflags>$MACOS_SDK ;"
echo "using python : 3.5"
echo "             : /usr/local/bin/python3.5"
echo "             : /usr/local/Cellar/python3/$PYTHONVER/include/python3.5m ;"
} > user-config.jam;
echo "Building boost-python"
sudo ./b2 --build-dir=build-python3 --stagedir=stage-python3 python=3.5 --prefix=/usr/local/Cellar/boost-python/$BOOSTVER --libdir=/usr/local/Cellar/boost-python/$BOOSTVER/lib -d2 -j4 --layout=tagged --user-config=user-config.jam threading=multi,single link=shared,static install;
brew link --overwrite boost-python
popd
