
\timing on
\connect jj
SET search_path TO srtm_plus_schema,"$user",public;

-- Touch up cruises near international date line that often have longitudes like -182,
--  which is wrong, but we know what they mean and why that happened.
--   however e.g. lon == -1126.18522 is just plain wrong.
--
-- NBP9702_ed.cm is the worst offender (-189), but lots of files with -182
--
-- 0 <= longitude < 360 is also legal. But we don't want that bother either...
--
\set min_longitude -189
\set max_longitude +180


--
-- Assume file is bad until proven otherwise.
--
--
-- FIXME: for COMMIT to work here psql parameters must have AUTOCOMMIT=off
--
-- Need explicit COMMIT because we call this from psql, hence implicitly already in
--  transaction block and
--   an error would stop INSERT to bad list

    INSERT INTO bad_filenames VALUES (:filepath, :path, :name) ;
COMMIT;
BEGIN;

-- remainder of this file will --- NOT --- COMMIT if
--  file has zero length, or source_id is not unique or its a bad file for any reason,
--   thus keeping bad data out of pings table.

-- FIXME:
-- FIXME: why not drop edited/flagged pings and be done with it?
-- FIXME:
-- FIXME: some files like NGA/shallow3.cm have predicted = 9999
--  Failing row contains (1, -70.6655, 83.8099, -201, 0, -1, 16389, 9999).
-- FIXME:
-- FIXME: files with bad data are listed in table called bad_filenames,
-- FIXME:  but data from bad files is --- NOT --- in bad_pings
-- FIXME:

--
-- Load a "2008 CM File" in "pings" table.
--
-- It is faster to detect bad SID by reading each cm file into relatively small a table
--  than it is to search a single very large cmTable with all data just once.
--
-- NOTE: CM file loaded into a temp table so we can calculate "location" attribute using
--  POSTGIS extensions. As far as I know this can not be done during a "COPY" command
--
-- This also encapsulates physical format of CM files away from ping table.
--
-- DROP not needed as table is TEMP. It is deleted with this script finishes
--

-- NOTE: unreasonable files are not added to ping data base. These checks define what is
-- reasonable.
--
-- Pings that have been edited might very well have illegal lat, lon, depth...
--  MUST ignore data that is flagged as bad
--
-- Longitude close to dateline is a special case.
-- Variable was set above for :min_longitude (typically -185)

    CREATE TEMP TABLE cmfile (
        time            int4   NOT NULL ,
        longitude       float8 NOT NULL ,
        latitude        float8 NOT NULL ,
        depth           float8 NOT NULL ,
        sigma_h         float8 NOT NULL ,
        sigma_d         float8 NOT NULL ,
        source_id       int4   NOT NULL ,
        predicted_depth float8 NOT NULL ,

        CONSTRAINT  sigma_h_zero    CHECK ( sigma_h = 0 ),
        CONSTRAINT  time_positive   CHECK ( time >= 0 ),
        CONSTRAINT  source_id_0_64k CHECK ( source_id BETWEEN  0 AND 65536 ),
        CONSTRAINT  sigma_d_sane    CHECK ( sigma_d   BETWEEN -1 AND  9999 ),

-- Writing constraints as follows is much more legible here, but hard to read logfile
--
--         CONSTRAINT  lon_lat_depth_and_predicted_sane
--
--             CHECK ( sigma_d = 9999 OR
--                 (
--                 longitude       BETWEEN :min_longitude AND :max_longitude  AND
--                 latitude        BETWEEN    -90 AND +90          AND
--                 depth           BETWEEN -11000 AND +9000        AND
--                 predicted_depth BETWEEN -11000 AND +9000
--                 )
--             )

        CONSTRAINT lon_plus_minus_180   CHECK ( sigma_d = 9999 OR

            longitude   BETWEEN :min_longitude AND :max_longitude ),

        CONSTRAINT lat_plus_minus_90 CHECK ( sigma_d = 9999 OR

            latitude    BETWEEN -90 AND +90 ),

        CONSTRAINT depth_minus_11k_to_plus_9k CHECK ( sigma_d = 9999 OR

            depth   BETWEEN -11000 AND +9000 ),

        CONSTRAINT predicted_depth_minus_11k_to_plus_9k CHECK ( sigma_d = 9999 OR

            predicted_depth BETWEEN -11000 AND +9000
-- FIXME: many files have predicted = 9999. meant to have sigma_d = 9999 ????
OR predicted_depth = 9999
        )           -- end of CONSTRAINT predicted_depth_minus_11k_to_plus_9k

    ) ;        -- end of CREATE TEMP TABLE cmfile

COPY cmfile FROM :tmpFile WITH (DELIMITER ',') ;
--\COPY cmfile FROM PROGRAM 'cat :tmpFile|sed "s/[ \t]*$//"|tr -s "[:blank:]" ","'
--
-- Gather all source ids used in this file.
--
-- USE a function so we can raise an exception gracefully if CM file is empty or has
--  multiple source_id, in other words we except some bad files so do not blow up a
--   very long job over expected errors.
--
-- IF there is more than one source_id THEN file is defective and its data is dropped
--
-- IF the file is bad, THEN an ERROR will occur in "check_for_unique_sid()",
--  rest of transaction is ROLLBACK so
--   following DELETE will not happen,
--    so filename will remain in bad list,
--     and no bad data will not be inserted in pings or in bad_pings
--
    SELECT add_sid_and_filename ( 'cmfile' , :filepath, :path, :name) ;
--
-- IF table has valid source_id THEN rest of the file will COMMIT,
--  otherwise filename will remain in bad_filename table
--   and no pings get loaded...
--
-- File is ok, remove its name from bad list
--
    DELETE FROM bad_filenames WHERE filename = :filepath ;
--
-- Touch up longitudes around dateline
--
    UPDATE cmfile SET longitude = longitude + 360
        WHERE longitude BETWEEN :min_longitude AND -180 ;
--
-- cruises can legally report longitudes between 0 and 360, but none seem to
--  convert to +/-180, but bad cruises with a longitude like 1125 might get caught if
--   do not NOT force ANY longitude to be between -180 and 180
--
--     UPDATE cmfile SET longitude = longitude - 360
--         WHERE longitude BETWEEN +180 AND :max_longitude ;
--


-- FIXME:
-- FIXME: Drop known bad pings (sigma_d=9999) here or later?
-- FIXME: IF Dave doesn't edit in this data base, it's pointless to load edited pings.
-- FIXME:
-- FIXME: Pings with predicted = 9999 are meant to have sigma_d = 9999 ???
-- FIXME:
--
--     DELETE FROM cmfile WHERE sigma_d = 9999 OR predicted_depth = 9999;
--


    INSERT INTO pings (
--
-- NOTE: "geohash" attribute has lots of nice features! Read wikipedia entry.
--  However POSTGIS 2.0.2 distance functions do NOT seem to work on geohash attributes,
--   so it a waste of time and space. Sadly.
--
--      geohash,
--
        location,
        time, longitude, latitude, depth, sigma_h, sigma_d, source_id, predicted_depth )
    SELECT
--
--      ST_GeoHash(ST_SetSRID(ST_MakePoint(longitude::float8, latitude::float8),4326)),
--
        ST_SetSRID(ST_MakePoint(longitude, latitude),4326),
        time, longitude, latitude, depth, sigma_h, sigma_d, source_id, predicted_depth
    FROM cmfile
--  LIMIT 1 -- useful for debugging this script when copying in thousands of files
    ;

COMMIT;
