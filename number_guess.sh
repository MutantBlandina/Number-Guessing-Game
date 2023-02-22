#!/bin/bash
# Number Guessing Game

PSQL="psql -X --username=freecodecamp --dbname=number_guessing --tuples-only -c"

# Get Username Input
echo "Enter your username:"
read USERNAME

# Generate number to guess
NUMBER=$(($RANDOM % (1 + 1000)))

# Create new score variable
SCORE=0

# Get User Id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# If not any user id
if [[ $USER_ID ]]
then
  # get other variables
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(score) FROM games WHERE user_id=$USER_ID")
  # format
  GAMES_PLAYED_FORMATTED=$(echo $GAMES_PLAYED | sed 's/^ *//')
  BEST_GAME_FORMATTED=$(echo $BEST_GAME | sed 's/^ *//')
  # Welcome back the user
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED_FORMATTED games, and your best game took $BEST_GAME_FORMATTED guesses."
else
  # enter user in the database
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  # Get new User Id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  # Welcome the user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
fi


COMPARE_GUESS_TO_NUMBER() {
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    SCORE=$((SCORE+1))
    echo -e "\nThat is not an integer, guess again:"
    COMPARE_GUESS_TO_NUMBER
  else
    if [[ $GUESS -eq $NUMBER ]]
    then
      SCORE=$((SCORE+1))
      echo -e "\nYou guessed it in $SCORE tries. The secret number was $NUMBER. Nice job!"
      UPDATE_SCORE=$($PSQL "INSERT INTO games(score, user_id) VALUES ($SCORE, $USER_ID)")
      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")
    elif [[ $GUESS -lt $NUMBER ]]
    then
      SCORE=$((SCORE+1))
      echo -e "\nIt's higher than that, guess again:"
      COMPARE_GUESS_TO_NUMBER
    else
      SCORE=$((SCORE+1))
      echo -e "\nIt's lower than that, guess again:"
      COMPARE_GUESS_TO_NUMBER 
    fi
  fi
}

# Get guess input
echo -e "\nGuess the secret number between 1 and 1000:"
COMPARE_GUESS_TO_NUMBER
