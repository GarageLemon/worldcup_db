#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "truncate games, teams")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    #get winner id
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    #if not found
    if [[ -z $WINNER_ID ]]
    then
      #insert winner team
      INSERT_WINNER_TEAM=$($PSQL "insert into teams(name) values('$WINNER')")
      if [[ $INSERT_WINNER_TEAM == 'INSERT 0 1' ]]
      then
        echo "Inserted into teams, $WINNER"
      fi
      #get new winner_team_id
      WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    fi
    
    #get opponent id
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
    #if not found
    if [[ -z $OPPONENT_ID ]]
    then
      #insert opponent team
      INSERT_OPPONENT_TEAM=$($PSQL "insert into teams(name) values('$OPPONENT')")
      if [[ $INSERT_OPPONENT_TEAM == 'INSERT 0 1' ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi
      #get new opponent team id
      OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
    fi

  #Insert info to games table
  INSERT_GAMES_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)");
  if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted games result, $YEAR : $ROUND : $WINNER_ID : $OPPONENT_ID : $WINNER_GOALS : $OPPONENT_GOALS"
      fi
  fi
done
