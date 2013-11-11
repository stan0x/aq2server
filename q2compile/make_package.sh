#!/usr/bin/env bash
#Paul Klumpp 2012-11-19

ver=1.1

cwd=$(pwd)
q2dir=$cwd/../q2srv/
pkg_dir=$cwd/../


# clean q2compile
gits="aq2-tng q2admin q2a_mvd gs_starter q2pro"
for s in $gits; do

	if [ -d "${s}" ]; then
		rm -rf "$s"
	fi
done

# q2dir cleanup
cd $q2dir
rm -vf q2proded 2> /dev/null
rm -vf gs_starter.sh
rm -vf gs*sh
rm -vf action/game*.so
rm -vrf plugins

# editor backup cleanup
cd $pkg_dir
fuppa=$(find -type f -iname *~)
for x in $fuppa; do
	rm -v "$x"
done

# building package
# tar
cd $pkg_dir/../
rm -vf aq2-basesrv-pkg-$ver.tgz
tar --exclude-vcs -cvf - aq2-basesrv/ | gzip -9 - > aq2-basesrv-pkg-$ver.tgz
cp -v aq2-basesrv-pkg-$ver.tgz aq2-basesrv-pkg-latest.tgz
