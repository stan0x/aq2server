#!/usr/bin/env bash

#Simple script to change cfg's when installed aq2server
#made by stan0x

#Fill in vars
echo "RUNNING THIS SCRIPT WILL RESET YOUR CURRENT SETTINGS. BE AWARE ! ! :D"
echo "RUN THIS ONLY THE FIRST TIME !!"
echo "RUNNING THIS SCRIPT WILL RESET YOUR CURRENT SETTINGS. BE AWARE ! ! :D"
echo "Type in the rcon_password u want to set."
read password
echo "Type your name"
read name
echo "Type your irc chanel eq: #channel"
read irc
echo "Type in quakenet server eq: irc.quakenet.com"
read ircserver
echo "Fill in the host name max 12 chars"
read hostname

#change h_password.cfg
sed -e "4s/.*/set rcon_password \"$password\"/" action/h_passwords.cfg > action/changed.cfg && mv action/changed.cfg action/h_passwords.cfg
sed -e "27s/.*/sets _admin \"$name $irc $ircserver\"/" action/h_passwords.cfg > action/changed.cfg && mv action/changed.cfg action/h_passwords.cfg

#change hostname
sed -e "9s/.*/set hostname \"$hostname #1 - Teamplay\"/" action/aq2_1_tp.cfg > action/changed.cfg && mv action/changed.cfg action/aq2_1_tp.cfg
sed -e "9s/.*/set hostname \"$hostname #2 - Deathmatch\"/" action/aq2_2_dm.cfg > action/changed.cfg && mv action/changed.cfg action/aq2_2_dm.cfg
sed -e "9s/.*/set hostname \"$hostname #3 - Team Deathmatch\"/" action/aq2_3_tdm.cfg > action/changed.cfg && mv action/changed.cfg action/aq2_3_tdm.cfg
sed -e "9s/.*/set hostname \"$hostname #4 - CTF\"/" action/aq2_4_ctf.cfg > action/changed.cfg && mv action/changed.cfg action/aq2_4_ctf.cfg
sed -e "9s/.*/set hostname \"$hostname #5 - Domination\"/" action/aq2_5_dom.cfg > action/changed.cfg && mv action/changed.cfg action/aq2_5_dom.cfg
sed -e "9s/.*/set hostname \"$hostname #6 - Clan war\"/" action/aq2_6_cw.cfg > action/changed.cfg && mv action/changed.cfg action/aq2_6_cw.cfg
sed -e "9s/.*/set hostname \"$hostname #7 - Clan war\"/" action/aq2_7_cw.cfg > action/changed.cfg && mv action/changed.cfg action/aq2_7_cw.cfg

#get maps from the file repo
wget -N -r -np -nH –cut-dirs=3 -R index.html http://149.210.173.39/action/maps/

#update maplist so they all voteable
cd action/h_admin/
./make_maplist.sh
./make_sndlist.sh