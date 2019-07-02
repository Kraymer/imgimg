#!/bin/bash

# Stitch two images side by side with optional captions
# Copyright kray.me 2019

usage() {
    echo "Usage: $0 [OPTIONS] IMAGE_1 IMAGE2
Stitch two images and put captions below.

OPTIONS
  -l,  --labels     Add labels separated by comma. eg: before,after"
}

OPTS=`getopt -o hl: --long help,labels: -- "$@"`
eval set -- $OPTS

add_border_caption() {
    local IMG="${1}"
    local CAPTION="${2}"
    local COLOR="${3}"
    local IMG_EXT="${IMG##*.}"
    local IMG_BORDER=`mktemp /tmp/tmp.XXXXX.${IMG_EXT}`
    if [ -n "$CAPTION" ]; then
        OPTION="-background ${COLOR} label:"${CAPTION}" -gravity Center -append"  
    fi
    convert ${IMG} -bordercolor black -border 1 $OPTION ${IMG_BORDER}
    echo ${IMG_BORDER}
}

# $1 - first image
# $1 - second image
imgimg() {
    local IMG1="${1}"
    local IMG2="${2}"
    IFS="," read -ra LABEL1 <<< "${LABELS}";
    local LABEL2=`echo ${LABELS##*,}` 
    local IMG1_BORDER=`add_border_caption ${IMG1} ${LABEL1} Khaki`
    local IMG2_BORDER=`add_border_caption ${IMG2} ${LABEL2} Plum`
    local OUT=`mktemp /tmp/tmp.XXXXX.jpg`
    convert +append -background none -gravity south $IMG1_BORDER $IMG2_BORDER $OUT
    echo $OUT
    display $OUT
}

main() {
    LABELS=''
    while [ $# -gt 0 ];do
    case "$1" in
        -h|--help)
            usage;
            exit 0;;
        -l|--labels)
            shift;
            LABELS=$1
            ;;
        --)
            shift;
            break
            ;;
    esac
    shift
    done

    if (( $# != 2 )); then
        usage
        exit 0
    fi
    IMG1=${@:$OPTIND:1}
    IMG2=${@:$OPTIND+1:1}
    
    imgimg "$@"
}
main "$@"
