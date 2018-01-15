#! /bin/bash

# get all good pings from all good files in dir. Search "maxDepth" of sub directories
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-sample}
export PGUSER=${PGUSER-btea}
export PGPASSWORD=${PGPASSWORD-my_password}
RUN_PSQL="psql -X --set AUTOCOMMIT=off --set ON_ERROR_STOP=off "

root=$1;    shift
set -e
set -u

# Set these environmental variables to override them,
# but they have safe defaults.

search_dir='/tmp/sample'
$RUN_PSQL -f clearTable.sql
((numFiles=0))
# for each cm file to run copy file to table
for entry in "$search_dir"/*; do
    if [ -f "$entry" ];then
		item=$search_dir/'test.txt'
        echo "$entry"
		echo "$item"
		sed 's/^[ \t]*//;s/[ \t]*$//' < $entry > $item
        $RUN_PSQL -f copyFileIntoTable.sql -v v1="'$item'"
        ((numFiles++))
    fi
done

date
