#!/bin/bash
ACTIONDIR=./..
TNGDIR=$ACTIONDIR/tng
CFGDIR=$ACTIONDIR/config
cd $TNGDIR
ls -1 *ctf | sed s/.cfg// > $CFGDIR/ctfmaplist.ini.current
cd $CFGDIR
sort ctfmaplist.ini.current > ctfmaplist.ini
