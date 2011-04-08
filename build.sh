#!/bin/bash
#set -xv
##################################
##  Buildfile for cygwin-axel   ##
##                              ##
##    Copyright 2011 ghuntley   ##
##################################
#

if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` release-version"
  exit 1
fi


export PROJHOME=`pwd`

# remove previous release
  rm $PROJHOME/release/*.bz2
  rm $PROJHOME/release/md5.sum

# create build structure 
  mkdir -p build
  rm -rf $PROJHOME/build/*

# Retrieve upstream src
  git submodule sync
  git submodule update

# Build source tarball
  cd src.submodule/trunk
  export DEST=$PROJHOME/build/axel\-$1
  mkdir -p $DEST
  cp -R * $DEST
  cd $PROJHOME/build
  tar -cvf axel\-$1\-src.tar *
  bzip2 *.tar
  mv *.bz2 ../release

# clean build directory
  cd $PROJHOME
  rm -rf $PROJHOME/build

# Compile source
  cd src.submodule/trunk
  mkdir -p $PROJHOME/build/usr/share/doc

  make clean
  ./configure --prefix=$PROJHOME/build/usr \
      --etcdir=$PROJHOME/build/etc \
      --datadir=$PROJHOME/usr/share \
      --mandir=$PROJHOME/usr/share/man 
  
  make 
  make install
  
  export DEST=$PROJHOME/build/usr/share/doc/axel/
  mkdir -p $DEST
  cp API CHANGES COPYING CREDITS README ROADMAP  $DEST


# Copy build instructions into release.
  export DEST=build/usr/share/doc/Cygwin
  mkdir -p $DEST
  cp $PROJHOME/release/axel.README $DEST

# build binary release
  cd $PROJHOME/build
  tar -cvf axel\-$1\.tar *
  bzip2 *.tar
  mv *.bz2 ../release


# generate md5sums

  cd $PROJHOME/release
  md5sum *.bz2 *.hint > md5.sum	
