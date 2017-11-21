#! /bin/bash

# get all good pings from all good files in dir. Search "maxDepth" of sub directories

if [ "$#" != "2" ] ; then
    echo "usage: `basename $0` root maxDepth "
    echo "  example: `basename $0` /Volumes/RAID/multibeam/data/ 3"
    exit
fi
date

root=$1;    shift
depth=$1;   shift

set -e
set -u

# Set these environmental variables to override them,
# but they have safe defaults.
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-jj}
export PGUSER=${PGUSER-jj}
export PGPASSWORD=${PGPASSWORD-my_password}
# export PGOPTIONS='--client-min-messages=notice'
# RUN_PSQL="psql -e -X -a -1 --set AUTOCOMMIT=off --set ON_ERROR_STOP=off "
# FIXME: Must turn on AUTOCOMMIT for SQL script to not report warnings about no commit
# FIXME: Must turn off ON_ERROR_STOP or SQL errors will kill this bash script
RUN_PSQL="psql -X --set AUTOCOMMIT=off --set ON_ERROR_STOP=off "

t1=$(tempfile) || exit

((numFiles=0))
((numDefectiveFiles=0))

for filepath in `find $root -name "*.cm" -maxdepth $depth`; do

    # avoid very confusing, and incorrect,
    # reports of duplicate filenames caused by double slashes in filepath
    filepath=`echo $filepath | tr -s '/'`
    echo "`basename $0` loading $filepath"

    # convert cm file from white space run delimited to CSV
    #  but first, delete pesky trailing white space if any are present
    #
    # bad files containing random trash cause sed and tr to exit with non zero status
    #  other bad files are simply empty
    #   but there are lots of other ways for a file to be bad.
    #
    # COPY command in SQL is very picky, and best way to find mangled files....

    cat $filepath | sed 's/[ \t]*$//' | LC_CTYPE=C tr -s '[:blank:]' ',' > $t1;
    ((tr_err=$?))
    if [[ $tr_err -ne 0 ]]; then
        echo "$filepath is completely bogus at sed/tr step " 1>&2
        ((numDefectiveFiles++))
    else

# might want to punt ERROR messages about aborted transaction with a
#   grep -v "transaction is aborted, commands ignored until end of transaction"
        path=`dirname $filepath`
        name=`basename -s .cm $filepath`
echo "Reading cruise $name from $path "
        $RUN_PSQL -f copyFileIntoTable.sql -v tmpFile="'$t1'" \
        -v filepath="'$filepath'" -v path="'$path'" -v name="'$name'" 2>&1
        ((psql_exit_status=$?))

        if [[ $psql_exit_status -ne 0 ]]; then
# FIXME: isn't psql supposed to return non zero if there was an error? Why always get 0?
            echo "copyFileIntoTable.sql returned: $psql_exit_status"
            echo "$filepath is bogus at load into ping table step" 1>&2
            ((numDefectiveFiles++))
        fi
    fi

    ((numFiles++))
    if [ $numFiles = "-1" ]; then
      echo "DEBUG: bailing early from `basename $0`";
      break ;
    fi

done

echo "Read $numFiles files, $numDefectiveFiles of which are completely broken"

rm -f "$t1" || exit

date
