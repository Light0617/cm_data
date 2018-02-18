#! /bin/bash

# get all good pings from all good files in dir. Search "maxDepth" of sub directories
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-bathymetry}
export PGUSER=${PGUSER-btea}
export PGPASSWORD=${PGPASSWORD-my_password}

root=$1;    shift
set -e
set -u

org="NGO"
access="public"
c=$(psql -qtAX -d bathymetry -f insert_organization_table.sql  -v org="'$org'" -v acc="'$access'")
echo "$c"
