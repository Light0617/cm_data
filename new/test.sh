#! /bin/bash

# get all good pings from all good files in dir. Search "maxDepth" of sub directories
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-loadsample}
export PGUSER=${PGUSER-btea}
export PGPASSWORD=${PGPASSWORD-my_password}
# export PGOPTIONS='--client-min-messages=notice'
RUN_PSQL="psql -X --set AUTOCOMMIT=off --set ON_ERROR_STOP=off "
date

root=$1;    shift
depth=$1;   shift

set -e
set -u

# Set these environmental variables to override them,
# but they have safe defaults.

((numFiles=0))
((numDefectiveFiles=0))

tmpFile=`../../cm_Data/example_data/15050090.cm`

#for filepath in `find $root -name "*.cm" -maxdepth $depth`; do

#     echo filepath
#     filepath=`echo $filepath | tr -s '/'`
#     echo "`basename $0` loading $filepath"
#     ((numFiles++))

     path=`dirname $filepath`
     name=`basename -s .cm $filepath`
     tmpFile=`../../cm_Data/example_data/15050090.cm`
     echo "Reading cruise $name from $path "
     echo "tmpfile $tmpFile" 
     #$RUN_PSQL -f copyFileIntoTable.sql -v tmpFile = "'$tmpFile'"\
     #-v filepath="'$filepath'" -v path="'$path'" -v name="'$name'"

done
echo "Read $numFiles files, $numDefectiveFiles of which are completely broken"

date
