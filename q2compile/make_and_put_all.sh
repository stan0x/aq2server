#!/usr/bin/env bash
#Paul Klumpp 2012-11-19

cwd=$(pwd)
q2srv=$cwd/../q2srv/
cd $cwd


function checkuser {
    if [ "${USER}" == "root" ]; then
        echo "Nono! Don't run this as root! Don't!"
        echo "Switch to a normal user!"
        echo
        exit
    fi
}


function checkinstalled {
    if [ "$1" != "" ]; then
        woot=$(which "$1" 2> /dev/null)
        if [ -f "$woot" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}


function systemcheck {

    echo "Before continuing, make sure you have the following installed:"
    echo "* git"
    echo "* make"
    echo "* cc"
    echo "* screen"
    echo "* realpath"
    echo "* Lua 5.1, only 5.1!, dev headers"
    echo "* libz, also known as zlib1g-dev on Debian/Ubuntu"
    echo 
    echo "  PRESS ENTER"
    echo
    read

    software="git make cc realpath lua screen"
    for soft in $software; do

        see=$(checkinstalled "$soft")
        if [ $see -eq 0 ]; then
            echo "'$soft' not found on your system. Please have a system administrator install it!"
            exit
        fi
    done

}

level=0

function checkargs {

    case "$1" in
        clean)
            level=3
        ;;
        update)
            level=2
        ;;
        install)
            level=1
        ;;
        *)
            echo "Usage: $0 <clean/update/install>"
            echo
            echo "  clean: cleans the compilation directories, compiles and installs"
            echo "  update: compiles and installs"
            echo "  install: just installs the binaries, which are hopefully ready"
            echo
            exit
        ;;
    esac

}


function main {
    checkuser
    checkargs $*
    systemcheck

    repo[1]="q2admin"
    url[1]="https://github.com/stan0x/q2admin.git"
    cleanit[1]="make clean"
    makeit[1]="make"

    repo[2]="aq2-tng"
    url[2]="https://github.com/aq2-tng/aq2-tng.git"
    cleanit[2]="cd source && pwd && make clean"
    makeit[2]="cd source && pwd && make"

    repo[3]="q2a_mvd"
    url[3]="git://b4r.org/q2a_mvd"
    cleanit[3]=""
    makeit[3]=""

    repo[4]="gs_starter"
    url[4]="git://b4r.org/gs_starter"
    cleanit[4]=""
    makeit[4]=""

    repo[5]="q2pro"
    url[5]="https://github.com/hifi/q2pro.git"
    cleanit[5]="make clean"
    makeit[5]="cp -v ../q2proconfig ./.config && INCLUDES='-DUSE_FPS=1 -DUSE_PACKETDUP=1' make q2proded"

    ARCH=$(uname -m | sed -e s/i.86/i386/ -e s/sun4u/sparc/ -e s/sparc64/sparc/ -e s/arm.*/arm/ -e s/sa110/arm/ -e s/alpha/axp/)

    for idx in ${!repo[*]}; do
        echo

        # always get sources
        echo "$idx: ${repo[$idx]} from ${url[$idx]}"
        if [ ! -d "${repo[$idx]}" ]; then
            echo "Source dir missing, we get it"
            git clone ${url[$idx]}
        else
            echo "Source dir exists, we update it"
            cd $cwd/${repo[$idx]} 
            git pull
            cd ..
        fi


        if [ $level -gt 2 ]; then
            # clean it
            cd $cwd/${repo[$idx]}
            eval ${cleanit[$idx]}
        fi

        if [ $level -gt 1 ]; then
            # compile it
            cd $cwd/${repo[$idx]}
            eval ${makeit[$idx]}
        fi

        if [ $level -gt 0 ]; then

            # install it
            case "${repo[$idx]}" in
                aq2-tng)
                    if [ -f "game$ARCH.so" ]; then
                        cp -v game$ARCH.so $q2srv/action/game$ARCH.real.so
                        cd ..
                        cd action
                        cp -v prules.ini $q2srv/action/
                        cp -vr doc/ $q2srv/action/
                        cp -vr models/ $q2srv/action/
                        cp -vr pics/ $q2srv/action/
                        cp -vr players/ $q2srv/action/
                        cp -vr sound/ $q2srv/action/
						cd tng
                        find . -name "*.flg" -type f -delete
                        find . -name "*.aqg" -type f -delete
                        cd ..
                        cp -vr tng/ $q2srv/action/
                    else
                        echo "Whaaat? 'aq2-tng' did not compile. Something was wrong."
                        echo
                        echo "Please find the error messages of the compilation happening above and"
                        echo "file them as an issue at https://github.com/hifi/aq2-tng"
                        exit
                    fi
                ;;
                q2admin)
                    if [ -f "game$ARCH.so" ]; then
                        cp -v game$ARCH.so $q2srv/action/game$ARCH.so
                        cp -vr plugins/ $q2srv/
                    else
                        echo "W0000000t .. q2admin did not compile. Something was wrong."
                        echo
                        echo "It's possible that Lua5.1 is missing. "
                        echo "Or you're just using 'install' as parameter and forgot to compile q2admin first."
                        echo
                        echo "If you are on Debian or Ubuntu, please try to install the following"
                        echo "package server wide: liblua5.1-0-dev"
                        echo
                        echo "To do that, try: 'sudo apt-get install liblua5.1-0-dev'"
                        echo
                        echo "Then start this script again."
                        echo
                        exit
                    fi
                ;;
                q2a_mvd)
                    cp -v mvd.lua $q2srv/plugins/
                    if [ ! -f "$q2srv/plugins/mvd_transfer.sh" ]; then
                        cp -uv mvd_transfer.sh $q2srv/plugins/
                    fi
                ;;
                gs_starter)
                    cp -v gs_starter.sh $q2srv/
                    if [ ! -f "$q2srv/gs_starter.cfg" ]; then
                        cp -v gs_starter.cfg $q2srv
                    fi
                ;;
                q2pro)
                    if [ -f "q2proded" ]; then
                        cp -v q2proded $q2srv/
                    else
                        echo "Errm... q2pro dedicated did not compile. Something was wrong."
                        echo
                        echo "It's possible that ZLIB is missing."
                        echo "Or you're just using 'install' as parameter and forgot to compile q2proded first."
                        echo
                        echo "If you are on Debian or Ubuntu, please try to install the following"
                        echo "package server wide: zlib1g-dev"
                        echo
                        echo "To do that, try: 'sudo apt-get install zlib1g-dev'"
                        echo
                        echo "Then start this script again."
                        echo
                        exit
                    fi
                ;;

            esac

        fi

        cd $cwd

        echo

    done

    echo 
    echo "Everything should be in place now."
    echo
    echo "Please review the files h_passwords.cfg, aq2_*.cfg in 'q2srv/action'."
    echo "Other than that ;) read the README file"
    echo
    
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
    sed -e "4s/.*/set rcon_password \"$password\"/" $q2srv/action/h_passwords.cfg > $q2srv/action/changed.cfg && mv $q2srv/action/changed.cfg $q2srv/action/h_passwords.cfg
    sed -e "27s/.*/sets _admin \"$name $irc $ircserver\"/" $q2srv/action/h_passwords.cfg > $q2srv/action/changed.cfg && mv $q2srv/action/changed.cfg $q2srv/action/h_passwords.cfg

    #change hostname
    sed -e "9s/.*/set hostname \"$hostname #1 - Teamplay\"/" $q2srv/action/aq2_1_tp.cfg > $q2srv/action/changed.cfg && mv $q2srv/action/changed.cfg $q2srv/action/aq2_1_tp.cfg
    sed -e "9s/.*/set hostname \"$hostname #2 - Deathmatch\"/" $q2srv/action/aq2_2_dm.cfg > $q2srv/action/changed.cfg && mv $q2srv/action/changed.cfg $q2srv/action/aq2_2_dm.cfg
    sed -e "9s/.*/set hostname \"$hostname #3 - Team Deathmatch\"/" $q2srv/action/aq2_3_tdm.cfg > $q2srv/action/changed.cfg && mv $q2srv/action/changed.cfg $q2srv/action/aq2_3_tdm.cfg
    sed -e "9s/.*/set hostname \"$hostname #4 - CTF\"/" $q2srv/action/aq2_4_ctf.cfg > $q2srv/action/changed.cfg && mv $q2srv/action/changed.cfg $q2srv/action/aq2_4_ctf.cfg
    sed -e "9s/.*/set hostname \"$hostname #5 - Domination\"/" $q2srv/action/aq2_5_dom.cfg > $q2srv/action/changed.cfg && mv $q2srv/action/changed.cfg $q2srv/action/aq2_5_dom.cfg
    sed -e "9s/.*/set hostname \"$hostname #6 - Clan war\"/" $q2srv/action/aq2_6_cw.cfg > $q2srv/action/changed.cfg && mv $q2srv/action/changed.cfg $q2srv/action/aq2_6_cw.cfg
    sed -e "9s/.*/set hostname \"$hostname #7 - Clan war\"/" $q2srv/action/aq2_7_cw.cfg > $q2srv/action/changed.cfg && mv $q2srv/action/changed.cfg $q2srv/action/aq2_7_cw.cfg

    #get maps from the file repo
    cd $q2srv/
    wget -N -r -np -nH –cut-dirs=3 -R index.html http://stan0x.nl/action/maps/

    #update maplist so they all voteable
    cd $q2srv/action/h_admin/
    ./make_maplist.sh
    ./make_sndlist.sh
    ./make_maplist_ctf.sh
    ./make_maplist_dom.sh

	
	

}

main $*

# vim: expandtab tabstop=4 autoindent:
# kate: space-indent on; indent-width 4; mixedindent off;
