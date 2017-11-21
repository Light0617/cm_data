#! /bin/bash
#
# FIXME: When called from Automator, there will not be any PATH set :-(
# FIXME: need to set all the paths and environment variables we use :-(
#
# set paths for UNIX cmds, python, SQL, GMT, and this file
PATH=/bin:/usr/bin:/sbin:/usr/sbin:$PATH                        export PATH
PATH=/opt/local/bin:$PATH                                       export PATH
PATH=/Applications/Postgres.app/Contents/Versions/9.3/bin:$PATH export PATH
PATH=/opt/local/lib/gmt4/bin:$PATH                              export PATH
#
# FIXME: can not set this path too?
# PATH=~/Desktop/loadPostGis_rev_7:$PATH                            export PATH
#
# FIXME: To debug this mess uncomment these 3 lines
# echo $PATH
# which psql python gmt2kml kml2gmt selectPingsInKmlPolygon
# exit 0
#

# Python script we call needs these variables to run SQL query
#  You could override them, but they have safe defaults.
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-jj}
export PGUSER=${PGUSER-jj}
export PGPASSWORD=${PGPASSWORD-my_password}
RUN_PSQL="psql -X --set AUTOCOMMIT=off --set ON_ERROR_STOP=off "


# --------- Rest of script is just what you would expect ------

# open the kmz/kml file we are given, assume a polygon, find pings in polygon, show in GE

if [ "$#" != "1" ] ; then
    echo "usage: `basename $0` kml (or kmz) "
    echo "  example: `basename $0` foo.kmz"
    echo "  example: `basename $0` foo.kml"
    exit
fi
date

file=$1; shift

root=`dirname "$file"`
stem=${file%.*}
stem=`basename "$stem"`

mkdir -p "$root"/kml ; mkdir -p "$root"/cm

t1="/tmp/$(basename $0).$$.kml"
t2="/tmp/$(basename $0).$$.gmt"
t3="/tmp/$(basename $0).$$.pings.kml"

# need leading # in debug output so gmt2kml will treat those lines as comments
echo "# `date` `basename $0` processing $file" > "$t2"

# convert kmz to kml
cp "$file" $t1   # we want to delete the tmp, -NOT- the source
if [[ "$file" == *.kmz ]]; then tar --to-stdout -xf "$file" > $t1; fi
mv "$file" "$root/kml"

# convert kml to SQL query and then convert that back to kml
python ~/Desktop/loadPostGis_rev_7/selectPingsInKmlPolygon.py "$t1" >> "$t2"
gmt2kml "-T$stem.pings" -As \
    -L2:depth,6:predicted,7:depth-pred,4:sigma_d,5:SID,1:lat,0:lon,9:time,10:file \
    "$t2">"$t3"

# save results, and clean up

rm "$t1"
mv "$t2" "$root/cm/$stem.txt"
mv "$t3" "$root/kml/$stem.pings.kml"

# show pings in Google Earth

open "$root/kml/$stem.pings.kml"

exit 0
