#!/bin/bash
ACTIONDIR=./..
MAPDIR=$ACTIONDIR/maps
CFGDIR=$ACTIONDIR/config
cd $MAPDIR
ls -1 *bsp | sed s/.bsp// > $CFGDIR/maplist.ini.current
cd $CFGDIR
sort maplist.ini.current > maplist.ini
