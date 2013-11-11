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

    software="git make cc realpath lua screen"
    for soft in $software; do

        see=$(checkinstalled "$soft")
        if [ $see -eq 0 ]; then
            echo "'$soft' not found on your system. Please have a system administrator install it!"
            exit
        fi
    done

}


function checkdir {
    that=$(pwd | sed -e "s/^.\+\///")
    if [ "$that" == "q2compile" ]; then
        echo "Not allowed from this directory"
        exit
    fi
}

level=0
function checkargs {
    if [ "$1" == "" ]; then
        echo "Usage: $0 <first/update>"
        echo
        echo "  first: gets git baseserver directory, compiles and puts binaries into that directory"
        echo "  update: updates git baseserver directory"
        echo
        exit
    fi

    case "$1" in
        first)
            level=3
        ;;
        update)
            level=2
        ;;
    esac


}


function main {
    checkuser
    checkdir
    checkargs $*
    systemcheck

    repo[1]="aq2-server"
    url[1]="https://github.com/stan0x/aq2-server.git"

    ARCH=$(uname -m | sed -e s/i.86/i386/ -e s/sun4u/sparc/ -e s/sparc64/sparc/ -e s/arm.*/arm/ -e s/sa110/arm/ -e s/alpha/axp/)

    for idx in ${!repo[*]}; do
        echo

        # get sources
        if [ $level -gt 0 ]; then
            echo "$idx: ${repo[$idx]} from ${url[$idx]}"
            if [ ! -d "${repo[$idx]}" ]; then
                echo "git dir missing, we get it"
                git clone ${url[$idx]}
            else
                echo "git dir exists, we update it"
                cd $cwd/${repo[$idx]} 
                git pull
                cd ..
            fi
        fi


        case "$level" in
            3)
                # first install
                # get gits, compile everything cleanly and put it into baseserver directory
                cd $cwd/${repo[$idx]}
                cd q2compile && ./make_and_put_all.sh clean
            ;;
            2)
                # update check
                # get gits, compile everything and put it into baseserver directory
                cd $cwd/${repo[$idx]}
                cd q2compile && ./make_and_put_all.sh update
            ;;
        esac

        cd $cwd

        echo

    done

}

main $*

# vim: expandtab tabstop=4 autoindent:
# kate: space-indent on; indent-width 4; mixedindent off;
