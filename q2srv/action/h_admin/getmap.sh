#!/usr/bin/env bash
#########
# this simple shellscript just gets the .zip from the server and 
# puts the .bsp, which comes out of it (./maps/) to the current directory.
#
# Just put this script into your map-directory.
# Try: ./getmap.sh cliff2

# This is where you get your maps from...
# Set this with trailing slash pls:
# by Haudrauf
MAPSERVER=http://aq2maps.quadaver.org/
#########

# just the name of the zip

MAP2GET=$1
CWD=$(pwd)
ACTIONDIR=$CWD/../
MAPDIR=$ACTIONDIR/maps
MTEMP=$CWD/maptemp

function getMap {
  cd $MTEMP
  wget $MAPSERVER$MAP2GET.zip
}

function unzipMap {
  cd $MTEMP
  unzip $MAP2GET.zip *bsp
}

function copyBSP {
  cd $MTEMP
  THEMAP=`find | grep -i \.bsp`
  cp -u $THEMAP $MAPDIR
}

function makeTemp {
  mkdir $MTEMP
  cd $MTEMP
}
function killTemp {
  cd $CWD
  rm -rf $MTEMP
}

function main {
  if [ "$1" != "" ]; then
    makeTemp
    getMap
    unzipMap
    copyBSP
    killTemp
  else
    echo "Usage: $0 <mapname>"
  fi

  if [ -x ./make_maplist.sh ]; then
    ./make_maplist.sh
  fi
}

main $*


