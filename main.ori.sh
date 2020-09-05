#!/bin/bash

function xbqg
{
    local f_storage
#< storage
#> storage
    if [ -f "$f_storage" ]; then source "$f_storage"; fi

    printf "\033c"

    case "$1" in
      -)
        div -s
        echo "
page-id:
prev = ${xbqg_prev:-null}
cur  = ${xbqg_cur:-null}
next = ${xbqg_next:-null}

head:
${xbqg_cur_head:-null}
"
        div -s
        return
        ;;
      =)
        echo "Re = current: $xbqg_cur"
        div
        ;;
      \[)
        xbqg_cur=$xbqg_prev
        echo "Turn [ prev: $xbqg_prev"
        div
        ;;
      \])
        if [ "${xbqg_cur/\/*//}" = "$xbqg_next" ]; then
            echo "Turn ] next: no more chapters."
            div; return
        else
            xbqg_cur=$xbqg_next
            echo "Turn ] next: $xbqg_next"
            div
        fi
        ;;
      *_*/*)
        xbqg_cur=$1 ;;
      *)
        div
        echo "xbqg (main.sh)

AUTHOR  ForkKILLET

UPDTIME 2020.08.26 22:01

SOURCE  https://xsbiquge.com

FUNC    xbqg

USAGE

· xbqg page-id
  Get a chapter from <https://xsbiquge.com/\`page-id\`.html>
  Format: nn_nnnnn/nnnnnn

· xbqg =
  Review the current page.
· xbqg [
  Turn to the prev page.
· xbqg ]
  Turn to the next page.

· xbqg -
  See page-id info and the head.

· xbqg (illegal OR null arg)
  Get infomation. (this)
"
        div
        return
        ;; 
    esac
    
    local t=$(curl "https://www.xsbiquge.com/$xbqg_cur.html")
    xbqg_cur_head=${t##*<title>}
    xbqg_cur_head=${xbqg_cur_head%%</title>*}
    if [[ "$xbqg_cur_head" =~ ^[3-5][01][0-9].* ]]; then
        echo "Something goes wrong. HTTP response code: $xbqg_cur_head"
        return 1
    fi
    xbqg_cur_head=${xbqg_cur_head%%- 新笔趣阁*}
    xbqg_cur_head=${xbqg_cur_head/-/ @ }
    # title "$xbqg_cur_head"
    local c=${t##*<div id=\"content\">}
    c=${c%%</div>*}
    c=${c//&nbsp;/ }
    c=${c//<br \/>/\\n}
    local ix=${xbqg_cur%%/*}

    local d_bookext
#< bookext
#> bookext
    if [ -d "$d_bookext" ]; then
        if [ -f "$d_bookext/ext-$ix" ]; then source "$d_bookext/ext-$ix"; fi
    fi

    local p=${t##*document.onkeydown=keypage;}
    p=${p%%function*}
    p=${p//var /}
    p=${p// = /=}
    p=${p/_page/}
    p=${p//\"\//\"}
    p=${p//.html/}
    xbqg_prev=${p##*prevpage=\"}
    xbqg_prev=${xbqg_prev%%\"*}
    xbqg_next=${p##*nextpage=\"}
    xbqg_next=${xbqg_next%%\"*}

    if [ -f "$f_storage" ]; then echo "#!/bin/bash
xbqg_prev=$xbqg_prev
xbqg_next=$xbqg_next
xbqg_cur=$xbqg_cur
xbqg_cur_head=\"$xbqg_cur_head\"
" > "$f_storage"; fi

    div -s
    echo "$xbqg_cur_head"
    div -s
    echo -e "$c"
    div
    echo "$p"
}
