#!/usr/bin/bash

# File to read and strore the stats of the different players
FILE="game-stats.txt"

#Check if the file exists
if [ ! -f "$FILE" ]; then
     #I am here so the file does not exist let me create it
     touch "$FILE"
fi

# variable to reference the player by name
read -p "Please enter your name: " username

# By default both values will be 0 to keep data consistent
games_played=0
player_wins=0


get_random_choice(){
    # A random value between 0 and 2
    echo $((RANDOM % 3))
}

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
        source ./stats-scripts.sh
        calculate_stats
        # play the game
    elif [ "$input" == "play" ]; then
        while true; do
            read -p "Enter a choice (0 for rock, 1 for paper, 2 for scissors, 3 for exit): " player_selection
            computer_choice=$(get_random_choice)
            # Check the input is not alfabetic character  and it is numeric
            if [[ ! "$player_slection" =~ ^[a-zA-Z]+$ ]] && [[ "$player_selection" =~ ^[0-9]+$ ]];
            then
                if [[ "$player_selection" -eq 3 ]]; then
                # player does not want to play, show them previous menu to quit, show game stats or play again
                # Store the stats on the file
                echo "user_name=$username" >> $FILE
                echo "Player wins=$player_wins" >> $FILE
                echo "Games played=$games_played" >> $FILE
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