#!/usr/bin/bash

get_random_choice(){
    one_above_the_number_of_choices=$1
    # A random value between 0 and 2
    echo $(( RANDOM % $one_above_the_number_of_choices ))
}