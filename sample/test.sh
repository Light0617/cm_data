#! /bin/bash
# get all good pings from all good files in dir. Search "maxDepth" of sub directories
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-bathymetry}
export PGUSER=${PGUSER-btea}
export PGPASSWORD=${PGPASSWORD-my_password}
RUN_PSQL="psql -X --set AUTOCOMMIT=off --set ON_ERROR_STOP=off "

root=$1;    shift
set -e
set -u

# Set these environmental variables to override them,
# but they have safe defaults.

search_dir='/tmp/data'
search_dir1='/tmp/data/private'
search_dir2='/tmp/data/public'

# for debugging
#search_dir1='/tmp/data1'
#search_dir2='/tmp/data1'
((numFiles=0))


for entry in "$search_dir1"/* "$search_dir2"/*
do
	if [ -d "$entry" ];then
		for file in "$entry"/*.cm; do
			if [ -f "$file" ];then
				item=$search_dir/'test.txt'
				echo "$item"
				echo "$file"
				sed 's/^[ \t]*//;s/[ \t]*$//' < $file > $item
				$RUN_PSQL -f copyFileIntoTable.sql -v v1="'$item'"
				((numFiles++))
			fi
		done
	fi
	if [ -f "$entry" ];then
		item=$search_dir/'test.txt'
		echo "$entry"
		sed 's/^[ \t]*//;s/[ \t]*$//' < $entry > $item
		$RUN_PSQL -f copyFileIntoTable.sql -v v1="'$item'"
		((numFiles++))
	fi
done

echo $numFiles
date
