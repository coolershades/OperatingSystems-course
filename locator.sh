#!/bin/bash
input="$1"
 
if [ "$input" = "." ]; then
    input=`pwd`
fi
 
if [ "$input" = "-h" -o "$input" = "--help" -o "$input" = "" ]; then
    echo Copyright \(c\) Pakhtusova Ekaterina, CS-101, 2020.
    echo locator: locator [-h] [--h] [dir][filename]
    echo ""
    # echo Locator returns the pathname of the file which 
    # echo would be executed in the current environment.
    echo Locator returns a list of directories where a given
    echo file can be found \(only PATH directories and current 
    echo directory are being taken into consideration while
    echo searching\).
    echo you 
    exit 0
fi
 
IFS=:
location_status="not found"
path_contains=no
 
# checking if input contains directory.
# if it does..
if [ `dirname "$input"` != . -a -x "$input" ]; then
 
    # check whether the given dir is from path...
    for path in $PATH; do
        if [ "$path" = `dirname $input` ]; then
            echo $input
            location_status=external
            path_contains=yes
        fi
    done
    
    # ... or is a current directory.
    if [ "`pwd`" = `dirname $input` ]; then
        echo $input
        location_status=external
    fi
    
    input=`basename $input`
else
    # trimming directory off (if there is ./ or nothing at the beg.)
    input=`basename $input`
    for path in $PATH; do
        filepath="$path/$input"
        if [ -x "$filepath" ]; then
            echo "$filepath"
            location_status=external
            path_contains=yes
        fi
    done
 
    if [ -x "./$input" ]; then
        echo `pwd`/$input
        location_status=external
        # exit 0
    fi
fi
 
if [ "`type $input 2>/dev/null`" = "$input is a shell builtin" -a "$path_contains" = "yes" ]; then
    location_status=internal
fi
 
echo File is $location_status.
 
manual=$(man $input 2>/dev/null)
if [ "$manual" != "" -a "$path_contains" = "yes" ]; then
    echo Would you like to get a manual for this command? [y/n]
    read ans
    if [ $ans = y ]; then
        man $input
    fi  
fi
 
exit 0