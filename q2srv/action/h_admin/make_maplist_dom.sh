#!/bin/bash
ACTIONDIR=./..
TNGDIR=$ACTIONDIR/tng
CFGDIR=$ACTIONDIR/config
cd $TNGDIR
ls -1 *dom | sed s/.dom// > $CFGDIR/dommaplist.ini.current
cd $CFGDIR
sort dommaplist.ini.current > dommaplist.ini
