#!/bin/bash

function xbqg_bookext
{
    local s="$(cat $2)"

    case $1 in
      -g|--get)
        if [ -f "$2" ]; then
            fragment -g bookext "$(cat $2)"
            echo "Bookext dir: ${FRAG_VALUE##*d_bookext=}"
        else
            echo "Script doesn't exist."
            return 1
        fi
        ;;
      -s|--set)
        if [ -f "$2" ]; then
            fragment -s bookext "$s" "d_bookext=$3"
            echo "$FRAG_NEWSTR" > "$2"
            echo -e "Succeed, please run:\n\033[1;32m. $2\033[0m"
        else
            echo "Script doesn't exist."
            return 1
        fi
        ;;  
      *)
        :
        ;;
    esac
}

