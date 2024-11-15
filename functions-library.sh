#!/usr/bin/bash

function get_random_choice(){
    one_above_the_number_of_choices=$1
    # A random value between 0 and 2
    echo $(( RANDOM % $one_above_the_number_of_choices ))
}

function detect_OS_Environment(){
    PATH_OS_LINUX=$1
    PATH_OS_WINDOWS=$2
    # Check if running on Ubuntu or GitBash on Windows
if [ -d "$PATH_OS_LINUX" ];
then
    # I am on Linux
    echo "$PATH_OS_LINUX"
    
else
    # I am using Windows
   echo "$PATH_OS_WINDOWS"
fi
}

"$@"