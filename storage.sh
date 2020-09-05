#!/bin/bash

function xbqg_storage
{
    local s="$(cat $2)"

    case $1 in
      -g|--get)
        if [ -f "$2" ]; then
            v=$(fragment -g storage "$(cat $2)")
            echo "Storage file: ${v##*f_storage=}"
        else
            echo "Script doesn't exist."
            return 1
        fi
        ;;
      -s|--set)
        if [ -f "$2" ]; then
            fragment -s storage "$s" "f_storage=$3" > "$2"
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

