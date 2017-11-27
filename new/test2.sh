#! /bin/bash

# get all good pings from all good files in dir. Search "maxDepth" of sub directories
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-loadsample}
export PGUSER=${PGUSER-btea}
export PGPASSWORD=${PGPASSWORD-my_password}
RUN_PSQL="psql -X --set AUTOCOMMIT=off --set ON_ERROR_STOP=off "

root=$1;    shift
set -e
set -u

# Set these environmental variables to override them,
# but they have safe defaults.

#file='../../cm_Data/example_data//01010020.cm'
file='t1.txt'
echo $file
#$RUN_PSQL -f copyFileIntoTable.sql -v tmpFile="'$file'"

#$RUN_PSQL -f kk.sql -v v1="'$file'"
$RUN_PSQL -f kk.sql -v v1="'t1.txt'"
#$RUN_PSQL -f create.sql -v v1="'$file'"
date
