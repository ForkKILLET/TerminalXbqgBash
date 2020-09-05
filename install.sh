#!/bin/bash
# xbqg install script

shopt -s expand_aliases
alias echo="echo -e"
fatel () { echo "\033[1;31m[Fatel] $1\033[0m"; exit 1; }
strong () { echo "\033[1;30m$1\033[0m"; }
OK="\033[1;32mOK\033[0m"
Done="\033[1;32mDone\033[0m"
not_OK="\033[1;31mnot OK\033[0m"

yn () {
    local res
    echo -n "\033[0;35m$1 \033[1;35m(yes/no) \033[0m"
    read res
    case "$res" in
      ([yY]|yes|YES|ye5|YE5) return 0 ;;
      ([nN]|no|NO|n0|N0) return 1 ;;
      (*) return 2
    esac
}

abs_path () {
    
    d="${d%/*}"
    ori_PWD="$PWD"
    cd "$d"
    if [ "$f" ]; then echo "$PWD/$f"
    else echo "$PWD"; fi
    cd "$ori_PWD"
}

strong "Installing xbqg.\n"

# 0/4
strong "[0/4] Checking install resource."

echo -n "Getting install.sh loc: "
fthis="./$0/../"
dthis="$(abs_path $fthis)"
echo "$dthis/"

check_res_res="$OK"
check_res() {
    echo -n "Checking $3 <$2>: "
    if [ -"$1" "$dthis/$2" ]; then echo "$OK"
    else
        echo "$not_OK"
        check_res_res="$OK but lost secondary res."
        if $4; then fatel "main resource lost."; fi
    fi
}

check_res d cmdbin/          "dependent cmds"    true  &&
check_res f cmdbin/div       "cmd: div"          true  &&
check_res f cmdbin/fragment  "cmd: fragment"     true  ;
      
check_res f main.ori.sh      "main script"       true  ;
check_res f storage.sh       "storage plugin"    false &&
check_res f data             "storage file"      false ;
check_res f bookext.sh       "bookext plugin"    false &&
check_res d bookext          "bookext exts"      false ;

strong "Checking result: $check_res_res\n"

# 1/4
strong "[1/4] Configuring install location."

if yn "Copy dependent cmds to some bin?"; then
    read -p "Path: " dbin
    if [ -d "$dbin" ]; then
        echo "Copying cmds..."
        cp -r "$dthis/cmdbin/." "$dbin"
        echo "$Done"
    else fatel "Bin path <$dbin> doesn't exist."; fi
elif yn "Add <cmdbin/> to \$PATH manually?"; then echo "$OK"
else fatel "You can't refuse all the time..."
fi

read -p "Configured main script path <main.sh>: " dmain
dmain=${dmain%/}
if yn "Custom script filename?"; then
    read -p "Filename: " res
    fmain="$dmain/$res"
else fmain="$dmain/main.sh"; fi
if [ -d "$dmain" ]; then
    echo "Copying script from <main.ori.sh>..."
    cp "$dthis/main.ori.sh" "$fmain"
    echo "$Done\n"
else fatel "Main path <$dmain> doesn't exist."; fi

# 2/4
strong "[2/4] Configuring storage plugin."

if yn "Continue?"; then
    if yn "Custom data file path?"; then
        read -p "Path: " fdata
        fdata="$(abs_path "$fdata")"
    else fdata="$dthis/data"; fi
    if [ -f "$fdata" ]; then
        source "$dthis/storage.sh"
        xbqg_storage --set "$fmain" "$fdata"
    else fatel "Data file <$fdata> doesn't exist."; fi
else echo "Jump, wiiiiiiiii\n"; fi

# 3/4
strong "[3/4] Configuring bookext plugin."

if yn "Continue?"; then
    if yn "Custom book extension path?"; then
        read -p "Path: " dext
        dext="${dext%/}/"
        fdata="$(abs_path "$dext")"
    else fdata="$dthis/bookext"; fi
    if [ -d "$dext" ]; then
        source "$dthis/bookext.sh"
        xbqg_bookext --set "$fmain" "$dext"
    else fatel "Book extension dir <$dext> doesn't exist."; fi
else echo "Jump, wiiiiiiiii\n"; fi

# 4/4
strong "[4/4] Installing finished."

