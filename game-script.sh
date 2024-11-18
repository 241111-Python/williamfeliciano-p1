#!/usr/bin/bash

# Find and move inside to the directory the script is being ran from
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Absolute Path for each environment 
# UBUNTU_PATH="/mnt/c/Users/willi/Documents/DEV/REVATURE/williamfeliciano-p1"
# WINDOWS_PATH="/c/Users/willi/Documents/DEV/REVATURE/williamfeliciano-p1"

# # Determine the correct path based on the environment
# if [ -d "$UBUNTU_PATH" ]; then
#     # Running in Ubuntu (WSL)
#     BASE_PATH="$UBUNTU_PATH"
# else
#     # Running in Windows (Git Bash or similar)
#     BASE_PATH="$WINDOWS_PATH"
# fi

# Use the correct path to source the library
# source "${BASE_PATH}/functions-library.sh"
source "./functions-library.sh"

# File to read and store the stats of the different players
#FILE="${BASE_PATH}/game-stats.txt"
FILE="./game-stats.txt"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    # If the file doesn't exist, create it
    touch "$FILE"
fi



# variable to reference the player by name
read -p "Please enter your name: " username

# By default both values will be 0 to keep data consistent
games_played=0
player_wins=0

determine_winner(){
    player=$1
    computer=$2
    # (0 for Rock, 1 for Paper, 2 for Scissors)
    if [ "$player" -eq "$computer" ]; then
        echo "It's a tie!"
    elif [[ "$player" -eq 0  &&  "$computer" -eq 2 ]]; then
        echo "$username wins! Rock beats Scissors"
        player_wins=$((player_wins + 1))
    elif [[ "$player" -eq 1  &&  "$computer" -eq 0 ]]; then
        echo "$username wins! Paper beats Rock"
        player_wins=$((player_wins + 1))
    elif [[ "$player" -eq 2  &&  "$computer" -eq 1 ]]; then
        echo "$username wins! Scissors beats Paper"
        player_wins=$((player_wins + 1))
    else
        echo "$username Lost!"
    fi
    # If we are here one game has been won or lost so I should increment games_played variable
    games_played=$((games_played + 1))
}


# start of the game loop
while true; do
    read -p "Type 'exit' to quit, 'stats' for stats history, or 'play' to start playing: " input
    if [ "$input" == "exit" ]; then
        echo "Thanks for playing!"
        break
    elif [ "$input" == "stats" ]; then
        # get the stats scripts and display the stats on the terminal
       #source "${BASE_PATH}/stats-scripts.sh"
       source ./stats-scripts.sh
        # play the game
    elif [ "$input" == "play" ]; then
        while true; do
            read -p "Enter a choice (0 for rock, 1 for paper, 2 for scissors, 3 for exit): " player_selection
            

            computer_choice=$(get_random_choice 3)
            # Check the input is not alfabetic character  and it is numeric
            if [[ ! "$player_selection" =~ ^[a-zA-Z]+$ ]] && [[ "$player_selection" =~ ^[0-9]+$ ]];
            then
                if [[ "$player_selection" -eq 3 ]]; then
                # player does not want to play, show them previous menu to quit, show game stats or play again
                # Store the stats on the file
                echo "User_name=$username" >> $FILE
                echo "Player_wins=$player_wins" >> $FILE
                echo "Games_played=$games_played" >> $FILE
                break
                # Check the value is not alfa character first
                # Player pick Rock
                elif [ "$player_selection" -eq 0 ]; then
                determine_winner "$player_selection" "$computer_choice"
                # Check the value is not alfa character first
                # Player picks Paper
                elif [ "$player_selection" -eq 1 ]; then
                determine_winner "$player_selection" "$computer_choice"
                # Check the value is not alfa character first
                # Player picks Scissors
                elif [ "$player_selection" -eq 2 ]; then
                    determine_winner "$player_selection" "$computer_choice"
                else
                    # the menu options will be shown again so do nothing
                    echo " "
                fi
            else
                # the menu options will be shown again so do nothing because input what alphabetic 
                # not numberic
                    echo " "
            fi
        done
    else    
        # the menu options will be shown again so do nothing
        echo " "
    fi
done