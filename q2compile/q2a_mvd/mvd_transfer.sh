#!/usr/bin/env bash
# small transfer script by Shaque 2012-11-22
# and more changes done by lots of people over the course ;)
mvd="$1"
game="$2"

_file="$game/demos/$mvd"

# here, someuser@aq2world.com is the target user and host, change that to your needs.
_targetuserhost="someuser@aq2world.com"

# here, demos/ is the target directory, change that to your needs.
_targetdir="demos/"


if [ -f "$_file" ]; then
  ( sleep 2 ) && ( echo "put $_file '$_targetdir'" | sftp -q -o PasswordAuthentication=no -p $_targetuserhost ) &
  # sleep a little, so q2proded has time to finalize the demo file
else
  echo "$0 Error: '$_file' not found. Not transferring anything. :("
fi


# vim: expandtab tabstop=2 autoindent:
# kate: space-indent on; indent-width 2; mixedindent off;