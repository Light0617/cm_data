#! /bin/bash

# get all good pings from all good files in dir. Search "maxDepth" of sub directories
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-bathymetry}
export PGUSER=${PGUSER-btea}
export PGPASSWORD=${PGPASSWORD-my_password}
RUN_PSQL="psql -X --set AUTOCOMMIT=off --set ON_ERROR_STOP=off "
set -e
set -u

i=0
x=$1
for var in "$@"
do
	if (($i == 0)) 
		then 
			i=$(($i + 1))
			continue
	fi
    echo "$var";
	if (($i % 2 == 0)) 
		then
			x="$x,$var"
		else
			x="$x $var"
	fi
	i=$(($i + 1))	
done
echo "x= $x"
$RUN_PSQL -f test.sql -v x=$x;
#$RUN_PSQL -f test.sql;
date
