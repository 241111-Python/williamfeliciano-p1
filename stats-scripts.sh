#!/usr/bin/bash

# Command line arguments
TIMESTAMP=$1

# Find and move inside to the directory the script is being ran from
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Absolute Path for each environment 
# UBUNTU_PATH="/mnt/c/Users/willi/Documents/DEV/REVATURE/williamfeliciano-p1"
# WINDOWS_PATH="/c/Users/willi/Documents/DEV/REVATURE/williamfeliciano-p1"

# if [ -d "$UBUNTU_PATH" ];
# then
#     # I am on Linux
#     PATH="$UBUNTU_PATH"
    
# else
#     # I am using Windows
#    PATH="$WINDOWS_PATH"
# fi

LOGFILE="./cron-log.txt"
# LOGFILE="${PATH}${LOGFILE}"
FILE1="./calculated-stats.txt"
# FILE1="${Path}${FILE1}"
FILE2="./game-stats.txt"
# FILE2="${PATH}${FILE2}"


# Reading/ creating logfile and logging into it
###############################################################
# tries to find the file
if [ ! -f $"$LOGFILE" ]; then
    # File not found create it
    touch "$LOGFILE"
fi

# teest if the TimeStamp argument is empty
if [ -z "$1" ];
then    
    # $1 argument was empty
echo "I ran from game script $(which date)" >> "$LOGFILE"
else 
    # $1 argument was provided
   echo "I am being called from cron $TIMESTAMP" >> "$LOGFILE"
fi
################################################################

function win_percentage()
{
    local games_won=$1
    local games_played=$2
    # since there is the possibility of division by zero validate variable
    if [[ $games_played -gt 0 ]];
    then 
        echo "$(( 100 * games_won / games_played ))"
    else
        echo "0"
    fi
}

function loss_count()
{
    local games_won=$1
    local games_played=$2
    # since there is no possibility of division by zero theres no need to validate variables
    echo "$(( games_played - games_won ))"
}

function loss_percentage()
{
    local games_won=$1
    local games_played=$2
    local loss_count=$(( games_played - games_won ))
    # since there is the possibility of division by zero validate variable
    if [[ $games_played -gt 0 ]];
    then 
        echo "$(( 100 * loss_count / games_played ))"
    else
        echo "0"
    fi
}


function win_loss_ratio()
{
    local games_won=$1
    local games_played=$2
    local games_lost=$(( games_played - games_won ))
    # since there is the possibility of division by zero validate variable
    if [[ $games_lost -gt 0 ]];
    then 
        # Multiply by a 1k to shift the decimal point by 3 before dividing
        # this way we dont have to use pipe bc to get the decimal
        win_loss_ratio=$(( 1000 * games_won / games_lost ))
        # this division by 1000 to get the whole part and the modulus 1000 to get the decimal part
        echo "$(( win_loss_ratio / 1000 )).$(( win_loss_ratio % 1000 ))"
    else    
        echo "win/loss ratio: 0"
    fi
}


function saveStatsToFile()
{
    local player_name=$1
    local player_wins=$2
    local player_games_played=$3
    local player_win_percentage=$4
    local player_loss_count=$5
    local player_loss_percentage=$6
    local player_win_loss_ratio=$7

    

    if [ ! -f "$FILE1" ]; then
        # File not found create it
        touch "$FILE1"
    fi

    echo "Generating stats: $(which date)" >> "$FILE1"
    # test the name is only compose of alphanumeric and that both stats are 0 or greater than 0 like the file format expects
    if [[ "$player_name" =~ ^[a-zA-Z]+$ ]] && [[ "$player_wins" -ge 0 ]] && [[ "$player_games_played" -ge 0 ]];
    then
        # Print the stats for the player to file
        echo "-------------------------------------------" >> "$FILE1"
        echo "$player_name stats:" >> "$FILE1"
        echo "Games played: $player_games_played" >> "$FILE1"
        echo "Win count: $player_wins" >> "$FILE1"
        echo "Win percentage: $player_win_percentage" >> "$FILE1"
        echo "Loss count: $player_loss_count" >> "$FILE1"
        echo "Loss percentage: $player_loss_percentage" >> "$FILE1"
        echo "win/loss ratio: $player_win_loss_ratio" >> "$FILE1"
        echo "-------------------------------------------" >> "$FILE1"
    else
        echo "-------------------------------------------"  >> "$FILE1"
        echo "The Data is corrupted"  >> "$FILE1"
        echo "-------------------------------------------"  >> "$FILE1"
    fi


}


# Will attempt to read stats from game-stats.txt and calculate more information based on games_won and games_played
function calculate_stats()
{
    # Check if File exists
    if [ ! -f $FILE2 ] 
    then
        # File not found, player needs to play the game to generate this file and fill it with our variables
        echo "You need to play the game to generate stats"
        return 1
    fi


    while true; do

        #Initialize the variables
        local player_name=""
        local player_wins=0
        local player_games_played=0
        local player_win_percentage=0
        local player_loss_count=0
        local player_loss_percentage=0
        local player_win_loss_ratio=0


        for i in {1..3}; do
            # || break 2 will break out of both loops if end of file is reached
            read -r line || break 2
            
            if [ "$i" -eq 1 ]; then
                # the _ takes the value before the "=" sign which we don't want
                # From the file format the first line should be a player name
                IFS="=" read -r _ player_name <<< "$line"
            elif [ "$i" -eq 2 ]; then
                #From the file format the second line should be the player wins
                IFS="=" read -r _ player_wins <<< "$line"
            else
                #From the file format the third line should be the player games played
                IFS="=" read -r _ player_games_played <<< "$line"
            fi
        done 

        # test the name is only compose of alphanumeric and that both stats are 0 or greater than 0 like the file format expects
        if [[ "$player_name" =~ ^[a-zA-Z]+$ ]] && [[ "$player_wins" -ge 0 ]] &&  [[ "$player_games_played" -ge 0 ]];
        then
            # Print the stats for the player
            echo "$player_name stats:"
            echo "Games played: $player_games_played"
            echo "Win count: $player_wins"
            player_win_percentage=$(win_percentage "$player_wins" "$player_games_played")
            echo "Win percentage: $player_win_percentage %"
            player_loss_count=$(loss_count "$player_wins" "$player_games_played")
            echo "Loss count: $player_loss_count"
            player_loss_percentage=$(loss_percentage "$player_wins" "$player_games_played")
            echo "Loss percentage: $player_loss_percentage %"
            player_win_loss_ratio=$(win_loss_ratio "$player_wins" "$player_games_played")
            echo "win/loss ratio: $player_win_loss_ratio "
            echo "-------------------------------------------"
            saveStatsToFile "$player_name" "$player_wins" "$player_games_played" "$player_win_percentage" "$player_loss_count" "$player_loss_percentage" "$player_win_loss_ratio"

        else
            echo "-------------------------------------------"
            echo "The Data is corrupted"
            echo "-------------------------------------------"
        fi
        #  Helps the outer loop keep reading data and providing the lines to inner
        #  loop which will attempt to read line or break if end of file is reached
        #  this will also help the outer loop keep looping through the file without
        #  starting from the beginning again
    done < "$FILE2"

    # save global stats with the help of awk
   awk -F'=' '
/^Player_wins=/ { total_wins += $2 }
/^Games_played=/ { total_games += $2 }
END {
    total_losses = total_games - total_wins
    if (total_games > 0) {
        win_percentage = (total_wins / total_games) * 100
        loss_percentage = (total_losses / total_games) * 100
        win_loss_ratio = total_losses > 0 ? total_wins / total_losses : "Infinity"

        # Print the results to the terminal
        
        print "----------------------------------"
        print "Global Stats"
        print "----------------------------------"
        print "Total Wins: " total_wins
        print "Total Losses: " total_losses
        print "Global Win Percentage: " win_percentage "%"
        print "Global Loss Percentage: " loss_percentage "%"
        print "Win/Loss Ratio: " win_loss_ratio
        print "----------------------------------"

        # Print to file

        printf "----------------------------------\n" >> "'"$FILE1"'"
        printf "Global Stats\n" >> "'"$FILE1"'"
        printf "----------------------------------\n" >> "'"$FILE1"'"
        printf "Total Wins: %d\n", total_wins >> "'"$FILE1"'"
        printf "Total Losses: %d\n", total_losses >> "'"$FILE1"'"
        printf "Total Games: %d\n", total_games >> "'"$FILE1"'"
        printf "Global Win Percentage: %.2f%%\n", win_percentage >> "'"$FILE1"'"
        printf "Global Loss Percentage: %.2f%%\n", loss_percentage >> "'"$FILE1"'"
        printf "Win/Loss Ratio: %.2f\n", win_loss_ratio >> "'"$FILE1"'"
        printf "----------------------------------\n" >> "'"$FILE1"'"
    }
}
' "$FILE2"

    
    return 0   
}


calculate_stats





# allows file to be read as source and it's functions to be called from other scripts
"$@"