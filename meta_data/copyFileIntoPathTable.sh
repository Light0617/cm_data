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

file='/tmp/data/sourceID_filePath'
$RUN_PSQL -f copyFileIntoPathTable.sql -v v1="'$file'"
date
