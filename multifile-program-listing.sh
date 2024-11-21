#!/bin/bash

# ======================= EDIT THIS ===========================================
# page configuration
#  content width in columns
width=130
#  form length in lines (lines per page)
formlen=64  # 241mm x 11" standard form continuous paper
#  left margin (for line numbers + 1 space)
leftmar=5   # enough for 9999
#  note: real print width is leftmar + width
# date format
datefmt="+%H:%M %b %d, %Y"
# =============================================================================

# check args
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <listing title> <author> <file1> [file2 file3...]"
    exit 1
fi

# title page content
title=$1
author=$2
date=$(date "$datefmt")

shift 2

# check files
for file in "$@"
do
    if [ ! -f "$file" ]; then
        echo "File $file not found"
        exit 1
    fi
done

# helpers
#  left margin
margin() {
    printf '%0.s ' $(seq 1 $leftmar)
}

#  print centered text
center() {
    padding="$(printf '%0.s ' {1..500})"
    printf '%*.*s %s %*.*s\n' 0 "$((((width-2-${#1})/2)+leftmar))" "$padding" "$1" 0 "$(((width-1-${#1})/2))" "$padding"
}

let extra=0
if [[ "$(((2*width/3) + (width/3)))" -lt 80 ]]; then
    let extra=1
fi

leftright() {
    margin
    printf "%-$(((2*width/3)+extra))s%$((width/3))s\n" "$1" "$2"
}



# =============================================================================
# print title page
leftright "TITLE" "$(printf "%s PAGE 1" "$title")"
printf '%0.s\n' $(seq 1 $(($formlen/3))) # vertical spacing
center "$title"
center "$author"
center "$date"
printf "\f"

# print index page
leftright "INDEX" "$(printf "%s PAGE 2" "$title")"
echo
leftright "$title: $# files" "PAGE    "

let pagei=3
for fname in "$@"
do
    flines=$(wc -l < "$fname")
    fsize=$(wc -c < "$fname")
    pages=$((1 + ($flines / (formlen-3)))) # at least 1 page; 1 header line, 2 top bottom spacing
    left=$(printf "    %s %sL %sB " "$fname" "$flines" "$fsize")
    leftlen=${#left}

    margin
    printf "$left"
    printf "%0.s." $(seq 1 $((width-leftlen-8)))
    printf " %3d\n" $pagei
    let pagei=pagei+pages
done
printf "\f"


let pagei=3
for file in "$@"
do
    flines=$(wc -l < "$fname")
    fsize=$(wc -c < "$fname")
    pages=$((1 + ($flines / (formlen-3)))) # at least 1 page; 1 header line, 2 top bottom spacing
    linenumlen=$((leftmar-1))

    let flinei=1
    let plinei=1
    while IFS= read -r line; do
        line="$(echo "$line" | tr -d '\n')"

        # page end
        if [[ "$plinei" -eq 65 ]]; then
            let plinei=1
            let pagei=pagei+1
            #echo
            printf "\f"
        fi

        # on page start
        if [[ "$plinei" -eq 1 ]]; then
            leftright "$(printf "%s %dL %dB" "$file" "$flines" "$fsize")" "$(printf "%s PAGE %d" "$title" "$pagei")"
            echo
            let plinei=plinei+2
        fi
    
        # print line width by width chars
        let wlinei=1
        while 
            if [[ "$wlinei" -eq 1 ]]; then
                printf "%${linenumlen}d " "$flinei"
            else
                margin
            fi

            printf "%s\n" "$(echo "$line" | cut -c 1-$width)"
            line="$(echo "$line" | cut -c $((width+1))-)"

            let plinei=plinei+1
            let wlinei=wlinei+1

            [ -n "$line" ]
        do true; done

        let flinei=flinei+1
    done < $file

    #echo
    printf "\f"
    
    let pagei=pagei+1
done

