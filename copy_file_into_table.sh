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

search_dir='/tmp/data/data'
search_dir1='/tmp/data/data/private'
search_dir2='/tmp/data/data/public'

# for debugging
#search_dir1='/tmp/data1'
#search_dir2='/tmp/data1'
((numFiles=0))


for entry in "$search_dir1"/*
do
	if [ -d "$entry" ];then
		access="$(basename $search_dir1)"
        org="$(basename $entry)"
        echo "$access"
        echo "$org"
		id=$(psql -qtA -d bathymetry -f insert_organization_table.sql  -v org="'$org'" -v acc="'$access'")
		echo "$id"
		for file in "$entry"/*.cm; do
			if [ -f "$file" ];then
				item=$search_dir/'test.txt'
				echo "$item"
				echo "$file"
				sed 's/^[ \t]*//;s/[ \t]*$//' < $file > $item
				$RUN_PSQL -f copy_file_into_table.sql -v v1="'$item'" -v v2="'$id'"
				((numFiles++))
			fi
		done
	fi
done


for entry in "$search_dir2"/*
do
	if [ -d "$entry" ];then
		access="$(basename $search_dir2)"
        org="$(basename $entry)"
        echo "$access"
        echo "$org"
		id=$(psql -qtA -d bathymetry -f insert_organization_table.sql  -v org="'$org'" -v acc="'$access'")
		echo "$id"
		for file in "$entry"/*.cm; do
			if [ -f "$file" ];then
				item=$search_dir/'test.txt'
				echo "$item"
				echo "$file"
				sed 's/^[ \t]*//;s/[ \t]*$//' < $file > $item
				$RUN_PSQL -f copy_file_into_table.sql -v v1="'$item'" -v v2="'$id'"
				((numFiles++))
			fi
		done
	fi
done

echo $numFiles
date
