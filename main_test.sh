#! /bin/bash

# Recommended way to call this to catch all the errors and warnings
#
#   bash main.sh > createDb.err.log 2>&1

set -e
set -u

# Set these environmental variables to override them,
# but they have safe defaults.
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-jbecker}
export PGUSER=${PGUSER-jbecker}
# export PGPASSWORD=${PGPASSWORD-my_password}
RUN_PSQL="psql -e -X --set AUTOCOMMIT=on  --set ON_ERROR_STOP=off "

echo "`date` : `basename $0` starting..."
rm -f createDb.log

echo "`date` : `basename $0` defining tables..."
purge
$RUN_PSQL -f defineTables.sql                                   >> createDb.log 2>&1

echo "`date` : `basename $0` loading cmFiles into ping table..."
# dir="/Volumes/RAID/multibeam/data/public/lakes"   ; depth=1
# dir="/Volumes/RAID/multibeam/data/public/SIO_multi/DRFT08RR.cm" ; depth=1
# dir="/Volumes/RAID/multibeam/data/private/3DGBR/" ; depth=2
# dir="/Volumes/RAID/multibeam/data/public"         ; depth=3
dir="/Volumes/RAID/multibeam/data"                  ; depth=3
purge
copyAllFilesIntoTable.sh $dir $depth                            >> createDb.log 2>&1

echo "`date` : `basename $0` indexing tables..."
purge
$RUN_PSQL -f defineIndexes.sql                                  >> createDb.log 2>&1

echo "`date` : `basename $0` finding obviously bad pings..."
purge
$RUN_PSQL -f deleteObviouslyBadCmFiles.sql                      >> createDb.log 2>&1

echo "`date` : ...`basename $0` finished creating data base"



echo "`date` : `basename $0` writing to /tmp the \"huge\" used by SRTM15 scripts..." \
 | tee -a createDb.log 2>&1
# "huge wants space delimiter, not the usual comma
purge
($RUN_PSQL <<SQL
 COPY
  ( SELECT longitude, latitude, depth, source_id
     FROM srtm_plus_schema.pings
      WHERE sigma_d != 9999 )
 TO PROGRAM 'gzip > /tmp/huge.xyzi.gz'
 WITH (DELIMITER ' ') ;
SQL
)                                                               >> createDb.log 2>&1



# back up the schema with all the ping we just loaded

echo "`date` : `basename $0` backing up schema with all DB to /tmp..."
#
# pg_dump mydb >  db.sql
# psql -d mydb -f db.sql
#
# Do not want to change ownership on restore, --no-owner, and only want SRTM schema
(pg_dump jbecker --no-owner --schema=srtm_plus_schema --verbose | \
    gzip -c  > /tmp/srtm_plus_schema.pg_dump.gz)                >> createDb.log 2>&1

# output of pg_dump is just ASCII sql commands, so just read into new db with psql
#
# NOTE: must use a valid user on DESTINATION machine, not the source!
# psql -d jbecker < gzip -cd < srtm_plus_schema.pg_dump.gz
# gzip -cd < srtm_plus_schema.pg_dump.gz | psql -d jbecker



echo -e "\n\n`date` : `basename $0` list of bad files\n\n" | tee -a createDb.log 2>&1
#
($RUN_PSQL --set ON_ERROR_STOP=on -e -c \
"SELECT filename AS bad_files FROM srtm_plus_schema.bad_filenames ORDER BY filename ;")\
 | tee -a createDb.log 2>&1



echo -e "\n\n\n`date` : `basename $0` display of slowest steps" >> createDb.log 2>&1
echo -e '          ms\t     sec\t     min\t      hr'            >> createDb.log 2>&1
grep ms createDb.log  > /tmp/$$.crap
cat /tmp/$$.crap | \
 awk '{ printf "%12s\t%8d\t%8d\t%8.2e\n", $2, $2/1000, ($2+60000/2)/60000, $2/3600000 }'\
  | sort -n | tail -10                                          >> createDb.log 2>&1
rm /tmp/$$.crap

echo "`date` : `basename $0` all done"


# FIXME: these searches do NOT work, but serve as starting for this sort of thing
# keyWord="bogus"
# grep $keyWord createDb.log | awk '{ print $1 }' > badFilesList
# bash examineBadFiles.sh badFilesList $keyWord | tee -a createDb.log 2>&1
#
