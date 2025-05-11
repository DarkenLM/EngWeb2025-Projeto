#!/bin/bash

#####################################################################################
# prepare.sh
# Automatic service environment setup script for Node.js projects.
# 
# Version: 1.1.0
# Author: DarkenLM
#####################################################################################

# Edit this list in order to alter the node services to support. Must match a directory at level-1 
# depth from the location of this script.
services=(
    "api"
    "web"
)

# Edit these two lists to alter the package managers to support.
# WARN: They must both have the same number of elements.
pkgManagers=(
    "npm"
    "pnpm"
)
pkgManagerDisplays=(
    "\033[31mNPM\033[0m"
    "\033[33mPNPM\033[0m"
)

#region ============== Helper Functions ==============
function selectMenu() {
    local prompt="$1" 
    shift
    local outvar="$1"
    shift

    local optCount=$1
    shift
    local options=("${@:1:$optCount}") 
    local count=${#options[@]} 

    shift $optCount
    local dispOptions=("${@:1:$optCount}") 



    local esc=$(echo -en "\e") # ESC code, because bash doesn't really like them on conditionals.
    local cur=0 
    local index=0

    printf "$prompt\n"
    while true
    do
        local cols=$(stty size | cut -d\  -f2)

        # list all options (option list is zero-based)
        index=0 
        for i in "${!options[@]}"
        do
            local o="${dispOptions[$i]}"
            if [ "$index" == "$cur" ]; then 
                echo -e " > \e[1m$o\e[0m" 
            else 
                # echo "  $o"
                printf "  %-$(($cols - 2))b\n" "$o"
            fi

            (( index++ ))
        done

        read -s -n3 key # Wait for arrow or enter keys
        if [[ $key == $esc[A ]]; then # Up arrow 
            (( cur-- )); 
            (( cur < 0 )) && (( cur = count - 1 ))
        elif [[ $key == $esc[B ]]; then # Down arrow 
            (( cur++ )); 
            (( cur >= count )) && (( cur = 0 ))
        elif [[ $key == "" ]]; then # Enter 
            break
        fi

        echo -en "\e[${count}A" # Set cursor position to the list start to re-render
    done

    # Clean list and display only selected choice
    echo -en "\e[$(($count + 1))A"
    for o in "${options[@]}"
    do
        printf "%-${cols}s\n" ""
    done
    printf "%-${cols}s\n" ""
    echo -en "\e[$(($count + 1))A"
    printf "$prompt ${dispOptions[$cur]}\n"
    

    # Export the selection to the output variable
    printf -v $outvar "${options[$cur]}"
}

function has_param() {
    local n=$1
    local terms=("${@:2:$n}")
    for i in $(seq 0 $n); do shift; done;
    for arg; do
        for i in $(seq 0 $n); do
            if [[ $arg == "${terms[$i]}" ]]; then
                return 0
            fi
        done
    done
    return 1
}

function get_args() {
    local -n __args=$1
    shift;
    for arg; do
        if [[ $arg != -* ]]; then
            __args+=("$arg")
        fi
    done
}
#endregion ============== Helper Functions ==============

#region ============== CLI ==============
get_args args "$@"

selectMenu "Please select a package manager:" manager ${#pkgManagers[@]} "${pkgManagers[@]}" "${pkgManagerDisplays[@]}"
echo "$manager" > .build.meta

for s in "${services[@]}"
do
    echo -e "Preparing service \e[32m$s\e[0m..."

    cmd="cd ./$s"
    if has_param 1 '--relink' "$@"; then 
        cmd="$cmd && (rm -r ./link ||:)" 
    fi

    cmd="$cmd && mkdir -p link && ln -s ../../shared ./link/shared && $manager install"

    if ! has_param 1 '--no-build' "$@"; then 
        cmd="$cmd && $manager build" 
    fi
    
    eval "$cmd"
    # eval "cd ./$s && mkdir -p link && ln -s ../../shared ./link/shared && $manager install && $manager build"
    cd ..
done

echo -e "\e[32mServices prepared.\e[0m"
#endregion ============== CLI ==============