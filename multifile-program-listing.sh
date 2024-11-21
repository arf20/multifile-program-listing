#!/bin/bash

# ======================= EDIT THIS ===========================================
# page configuration
#  content width in columns
width=80
#  form length in lines (lines per page)
formlen=60  # 241mm x 11" standard form continuous paper
#  left margin (for line numbers + 1 space)
leftmar=4   # 
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
#  print centered text
center() {
    padding="$(printf '%0.s ' {1..500})"
    printf '%*.*s %s %*.*s\n' 0 "$(((formlen-2-${#1})/2))" "$padding" "$1" 0 "$(((formlen-1-${#1})/2))" "$padding"
}

margin() {
    printf '%0.s ' $(seq 1 $leftmar)
}



# =============================================================================
# print title page
printf '%0.s\n' $(seq 1 $(($formlen/3))) # vertical spacing
margin
center "$title"
margin
center "$author"
margin
center "$date"
printf "\f"

let pagec=2
for file in "$@"
do
    lhead=$(printf "%s %dL %dB" "$file")
    rhead=$(printf "%s PAGE %d" "$title" "$pagec"
    printf "%-30s%$((width-30))s" "$lhead" "$rhead"
    cat -n "$file" | fold -w 88 -s
    printf "\f"
    #let pagec=pagec+1
done

