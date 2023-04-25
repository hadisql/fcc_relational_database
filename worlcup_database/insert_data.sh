#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")

ARRAY=()
YEARS=()

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != "year" ]]
then
  #check if the team names are in the array (both winner and opponent)
  if [[ " ${ARRAY[*]} " != *"$WINNER"* ]] && [[ " ${ARRAY[*]} " != *"$OPPONENT"* ]]
  then
    #append array with both team names
    ARRAY+=($WINNER $OPPONENT)
    INSERT_NAMES=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    INSERT_NAMES=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_NAMES == "INSERT 0 1" ]]
    then
      echo inserted both team names : $WINNER $OPPONENT
    fi
  # check if winner name in array
  elif [[ " ${ARRAY[*]} " != *"$WINNER"* ]]
  then
    INSERT_NAMES=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    ARRAY+=($WINNER)
    if [[ $INSERT_NAMES == "INSERT 0 1" ]]
    then
      echo inserted winner name : $WINNER
    fi
  # check if opponent name in array
  elif [[ " ${ARRAY[*]} " != *"$OPPONENT"* ]]
  then
    INSERT_NAMES=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    ARRAY+=($OPPONENT)
    if [[ $INSERT_NAMES == "INSERT 0 1" ]]
    then
      echo inserted opponent name : $OPPONENT
    fi
  fi
#get winner and opponent id, then insert it with all other infos in games table
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
INSERT_WINNER_ID=$($PSQL "INSERT INTO games(year, winner_id, opponent_id, round, winner_goals, opponent_goals) VALUES($YEAR, $WINNER_ID, $OPPONENT_ID, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS)")
fi
done
