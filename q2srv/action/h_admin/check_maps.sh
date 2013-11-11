#!/bin/bash

cwd=$(pwd)

actiondir=$cwd/../

sort $actiondir/config/maplist.ini > $actiondir/config/maplist.ini.current
cd $actiondir/maps
ls -1 *bsp | sed s/.bsp// > $actiondir/config/maplist.bsp.current

cd $actiondir/config

diff maplist.bsp.current maplist.ini.current

#
#
echo
echo \< means that there is a map, which is present in your
echo ./maps directory, but not yet listed in your maplist.ini
echo
echo \> means that there is a map listed in your maplist.ini
echo but not present in your ./maps directory
echo
echo When nothing is shown here except the helptext, then
echo your maplist.ini has exactly the maps listed, as in
echo your ./maps directory
echo


