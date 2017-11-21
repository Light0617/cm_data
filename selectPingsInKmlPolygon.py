"""
Define SQL query using polygon in the kml file being read

Need a WITH clause because to create a temp table using polygons bounding box,
and -then- examine relative handfull of things in boungind box in further detail.

What may happen without a WITH clause is a sequential scan on huge ping table
because, e.g. the ping table is indexed by depth, so and ORDER BY DESC depth
inadvertently creates a HUGE sequential scan of ping by depth, and then search by
location, instead of simply sorting output rows of SELECT as expected.
"""

# FIXME: apple scripts don't have a decent path set, so need hard coded path
# FIXME: gotta know our gmt path. Also server/host, db and user names...
# host = 'daintree.local'
host = 'localhost'
user = 'jbecker'
# user = 'jj'
dbname = user
gmtPath='/opt/local/lib/gmt4/bin/'
#!Python
# -*- coding: utf-8 -*-

"""

This is a PYTHON script. It is very easy to get confused if you are a CSH hacker.

Python scrips should NEVER have any tabs in them.
Use a language directed editor like TextWrangler to remove -ALL- tabs

BTW: SQL is also a "tabs are meaningful" language.

So get used to removing all tabs!!!

Python has wonderful interfaces to SQL and for reading and writing files

  http://www.pythonforbeginners.com/files/reading-and-writing-files-in-python
  http://zetcode.com/db/postgresqlpythontutorial/

SQL has it's problems

  http://postgresql.1045698.n5.nabble.com/How-to-stop-a-query-td1924086.html
  https://code.google.com/p/python-sqlparse/downloads/list

"""

# Grab usual file I/O and debugger stuff, along with PSYCOPG2 (SQL interface)

import sys, pdb, argparse, subprocess, psycopg2, psycopg2.extras
import sqlparse

# turn on debugger
# pdb.set_trace()

fin = fout = con = None

# Expect the unexpected. Use a "try" block and catch any exceptions of interest

try:

    # expect a single KML (not KMZ) file name with path as our argument
    # run KML file thru "gmt2kml" from GMT and keep lat-lon pairs it spits out.
    # store exit status of UNIX command from p.wait

    parser = argparse.ArgumentParser()
    parser.add_argument("kml_polygon_file",
        help="retrieve all pings inside KML polygon from SRTM_PLUS database")
# print __doc__
    args = parser.parse_args()
    file = args.kml_polygon_file

    p = subprocess.Popen(gmtPath+'kml2gmt '+file, shell=True, stdout=subprocess.PIPE)
    retval = p.wait()

    # skip the 3 header lines from kml2gmt
    tmp = p.stdout.readline()
    p.stdout.readline()
    p.stdout.readline()

    # Parse polygon in the KML in and write SQL defining a GEOGRAPHY POLYGON
    # PostGIS syntax for polygon is a mess of spaces, commas, and parenthesis

    poly = """\'POLYGON(("""+p.stdout.readline()
    for line in p.stdout.readlines():
        poly += ', '+line
    poly += """))\' ) AS poly"""

    # Rest of SQL QUERY
    #
    # Basically make a temp table that only has pings from inside polygon, that should be
    # small-ish. Then do fancy joins and other expensive queries on small temp set.

    sql = """
WITH pings_in_poly AS
  (SELECT *
  FROM srtm_plus_schema.pings AS p,
       ST_GeographyFromText (
""" \
          + poly + \
"""
  WHERE ST_Covers ( poly, p.location ) )
""" + \
"""
 SELECT time, longitude, latitude, depth, sigma_h, sigma_d, p.source_id, predicted_depth,
       depth - predicted_depth AS diff, filename
 FROM  pings_in_poly p, srtm_plus_schema.source_id_filenames f
 WHERE p.source_id = f.source_id
-- usually want next line: we are interested in pings that should have been flagged
AND p.sigma_d <> 9999
--  AND p.source_id = 17891
-- Pick one of the following ORDER BY statements to highlight certain types of bugs
-- This order by choice is useful for hunting bad pings
ORDER BY ABS (depth - predicted_depth) DESC
-- This order by choice is useful for hunting land pings
-- ORDER BY filename, time
-- Google Earth can only handle about 1000 points at a time
 LIMIT 1*1000
;
"""

#     # DEBUG: print out that mess of SQL
#     print sql
#     print sqlparse.format( sql, reindent=True, keyword_case='upper' )

    # Connect to SQL server and execute the query
    con = psycopg2.connect('host='+host +' dbname='+dbname +' user='+user)
    cur = con.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute(sql)

    # Parse query results
    #
    # col_names = [cn[0] for cn in cur.description]
    #
    # printing out the header lines is the tricky part :-)
    #
    print "\n# First pings inside search polygon, sorted by largest ABS(z-pred)..."
    fmt = '\n#%11s %12s %10s ' + '%10s %10s %10s %10s ' + '%13s %10s %10s %20s\n'
    print fmt % (
        "lon", "lat", "depth",
        "sigma_h", "sigma_d", "sid", "predicted",
        "depth-pred", "Pt_num", "time", "filename")

    # print the actually results in format gmt2kml will accept

    while True:
        row = cur.fetchone()
        if row == None:
            break
        fmt = '%12.6f %12.6f %10.0f ' + \
            '%10.0f %10.0f %10.0f %13.0f ' +\
            '%10.0f %10.0f %14.0f %s'
        print fmt % (
            row["longitude"], row["latitude"], row["depth"],
            row["sigma_h"], row["sigma_d"], row["source_id"], row["predicted_depth"],
            row["diff"], cur.rownumber, row["time"], row["filename"] )
    print

#     optionally save results in a file
#     fout = open("newfile.txt", "w")
#     fout.write("hello world in the new file\n")
#     fout.close()

    sys.exit(0)

except psycopg2.DatabaseError, e:
    print 'Error %s' % e
    sys.exit(1)

except IOError, e:
    print 'Error %s' % e
    sys.exit(1)

except TypeError, e:
    print 'Error %s' % e
    sys.exit(1)

finally:    # we are done, need to cleanup files, even if exception occurred

    if con:
        con.close()

    if fin:
        fin.close()

    if fout:
        fout.close()

    sys.exit(0)



# useful example to crib from: replace number in uid with string of that in sql
#     uid = 3
#     cur.execute("SELECT * FROM cars WHERE id=%(id)s", {'id': uid } )
#
#
#   REMEMBER that a PSYCOPG2 cursor is NOT the same thing as a PSQL cursor
#     cur = con.cursor()
#     fout = open('output.sql','w')
#     cur.copy_to(fout, 'srtm_plus_schema.filenames', sep=" | ")
#
#
#
#
#     sql = """
# \set pt 'POINT(-171.07 -31.64)'
# \set r 30000
# SELECT longitude, latitude , ST_Distance( location, ST_GeographyFromText(:'pt' ))/1000 AS km
#  FROM srtm_plus_schema.Pings
#  WHERE ST_DWithin( location, ST_GeographyFromText(:'pt'), :r )
#  ORDER BY ST_Distance( location, :'pt'  ) ;
# """
#
#
# SELECT
#   ST_Covers(geo_poly, geo_pt)               As poly_covers_pt,
#   ST_Covers(ST_Buffer(geo_pt,10), geo_pt)   As buff_10m_covers_cent
# FROM (
#   SELECT
#    ST_Buffer(ST_GeographyFromText('POINT(-99.327 31.4821)'), 300) As geo_poly,
#    ST_GeogFromText('SRID=4326;POINT(-99.33 31.483)'
#    ) As geo_pt
#  ) As foo;
