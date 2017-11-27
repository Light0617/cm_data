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


#tmpFile=`../../cm_Data/example_data/15050090.cm`

for filepath in `find $root -name "*.cm"`; do

     echo $filepath
     break
#     path=`dirname $filepath`
#     name=`basename -s .cm $filepath`
#     tmpFile=`../../cm_Data/example_data/15050090.cm`
#     echo "Reading cruise $name from $path "
#     echo "tmpfile $tmpFile" 
     #$RUN_PSQL -f copyFileIntoTable.sql -v tmpFile = "'$tmpFile'"\
     #-v filepath="'$filepath'" -v path="'$path'" -v name="'$name'"

done
echo "Read $numFiles files, $numDefectiveFiles of which are completely broken"

date
