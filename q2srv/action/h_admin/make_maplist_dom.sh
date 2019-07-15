#!/bin/bash
ACTIONDIR=./..
TNGDIR=$ACTIONDIR/tng
CFGDIR=$ACTIONDIR/config
cd $TNGDIR
ls -1 *dom | sed s/.dom// > $CFGDIR/dom_maplist.ini.current
cd $CFGDIR
sort dom_maplist.ini.current > dom_maplist.ini
