import psycopg2
# load the psycopg extras module
import psycopg2.extras
try:
    conn=psycopg2.connect("dbname='PGDATABASE-bathymetry' user='PGUSER-btea' password='PGPASSWORD-my_password'")
except:
    print "I am unable to connect to the database."


# get all good pings from all good files in dir. Search "maxDepth" of sub directories
'''
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
	if (($i % 2 == 0)) 
	then
		x="$x, $var"
	else
		x="$x $var"
	fi
	# store first point
	if (($i == 1)) 
	then
		first_point=$x  
	fi

	i=$(($i + 1))	
done
echo "10 20, 20 40, 40 60, 60 80, 80 90, 10 20"
x="LINESTRING($x, $first_point)"
echo "x=$x"
#$RUN_PSQL -f geo.sql;
$RUN_PSQL -f geo.sql -v x=$x;
#$RUN_PSQL -f test.sql;
date
'''
