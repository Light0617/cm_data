
\timing on
\connect jj

-- FIXME: need to set permission for schema and its contents.
-- FIXME: display old search path before we overwrite it
-- FIXME: adding something to search path takes this much code???
-- FIXME: show all schemas?
--
-- Plan A: try to remember to delete -all- old left over tables (~ 1 TB)...
--
-- DROP TABLE IF EXISTS very long list of filenames...
--
-- DROP INDEX IF EXISTS very long list of indexes like pings_location_gist_index ...
--
--
-- Plan B: Create schema (a collection of tables).
--
--  Gather all data in a single schema for easy deletion,
--  and place our schema at start of our search path.
-- Index NOT used until after a vacuum. COULD wait for automatically scheduled on...
--
-- SELECT schema_name FROM information_schema.schemata ;
-- SHOW search_path ;
--
DROP SCHEMA IF EXISTS srtm_plus_schema CASCADE;
CREATE SCHEMA srtm_plus_schema;
SET search_path TO srtm_plus_schema,"$user",public;
SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT LIKE '%pg_%' ;
--
-- These extensions also get deleted when schema is dropped
-- Add GIS extensions
--
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS btree_gist ;



-- Define tables that map SID -actually used- to files -actually used-
-- In past many tables believed to be used, didn't get in to SRTM
--  and files thought to be not used ended up in bathy...
--
-- Every cruise should have a unique "source id"
--  but a cruise might be so big it is in multiple files.
--   so it's not a guaranteed bug if two files to share an sid, but that's very likely.
--
-- However, a single file should only have 1 source id in it.

CREATE TABLE filenames (
 filename           TEXT    NOT NULL PRIMARY KEY,
 path               TEXT    NOT NULL,
 name               TEXT    NOT NULL UNIQUE
) ;

CREATE TABLE source_ids (
 source_id          int4    NOT NULL PRIMARY KEY CHECK ( source_id > 0 )
) ;

-- Maps source id to one or more filenames

CREATE TABLE source_id_filenames (
 source_id          int4    NOT NULL REFERENCES source_ids,
 filename           TEXT    NOT NULL REFERENCES filenames ,
 PRIMARY KEY (source_id, filename)
) ;

-- Define table with all pings. e.g 600 -MILLION- pings all in one table.
-- Use efficient representations of location for fast searching on lat/lon.
-- Use source_id_filenames relation to map sid in pings to one or more filenames.

CREATE TABLE pings (
-- longitudes are switched from 0 thru 360 to +/-180 degrees
-- first 3 fields are added by using a data base...
 ping_id            SERIAL  PRIMARY KEY,
 location           GEOGRAPHY(POINT,4326)  NOT NULL,
--  geohash            TEXT    NOT NULL,
 time               int4    NOT NULL,
 longitude          float8  NOT NULL,
 latitude           float8  NOT NULL,
 depth              float8  NOT NULL,
 sigma_h            float8  NOT NULL,
 sigma_d            float8  NOT NULL,
 source_id          int4    NOT NULL,
 predicted_depth    float8  NOT NULL
) ;


--
-- Define tables for rows with bad pings; aka latitude above 90.
-- Pings in bad ping table will be, or have been deleted from pings table.
-- Create a list of known bad files and bad source id.
--
CREATE TABLE bad_filenames  ( LIKE filenames  INCLUDING ALL ) ;
-- FIXME: these two are currently not used.
CREATE TABLE bad_pings      ( LIKE pings      INCLUDING ALL ) ;
CREATE TABLE bad_source_ids ( LIKE source_ids INCLUDING ALL ) ;
--
--
-- Define functions needed to load filenames and source_ids
--
-- If file has zero, or more than one source_id then it is obviously bad.

CREATE OR REPLACE FUNCTION add_sid_and_filename
    ( _tbl varchar, filename TEXT, path TEXT, name TEXT )
    RETURNS varchar
    LANGUAGE PLPGSQL AS $$
    DECLARE numSid int4; file_sid int4; sql varchar;
    BEGIN
--
-- "STRICT INTO" makes sure there is -exactly- one source_id; anything else is exception
--
-- If source_id was not unique in this FILE
--  OR if the file is empty
--   then following insert does not get executed
--
        EXECUTE 'SELECT DISTINCT source_id FROM ' || _tbl || ';' INTO STRICT file_sid ;
--
-- This FILE is ok, but data in the file might be redundent...
--  also..
--
-- If source_id is already used, then get a NOT UNIQUE exception from table definition
-- If filename is already used, then get a NOT UNIQUE exception from table definition
--
        RAISE NOTICE 'source_id: % name: % path: %' , file_sid, name, path ;
        INSERT INTO source_ids VALUES (file_sid) ;
        INSERT INTO filenames  VALUES (filename, path, name) ;
        INSERT INTO source_id_filenames (filename, source_id) VALUES (filename, file_sid);
        RETURN ' ' || file_sid || ' ' || filename ;
    EXCEPTION
        WHEN NO_DATA_FOUND  THEN RAISE '% is empty, or can not be read' , filename ;
        WHEN TOO_MANY_ROWS  THEN RAISE '% has more than one source_id' , filename ;
        WHEN OTHERS         THEN RAISE '% %', SQLERRM, SQLSTATE;
    END;
$$ ;

-- FIXME: this is a example from web about using format()
--         sql := 'SELECT DISTINCT source_id FROM ' || _tbl || ';' ;
--         sql := 'SELECT count(*) FROM ' || _tbl || ' WHERE ' || _col || '=$1' ;
--         sql := format('SELECT count(*) FROM %I WHERE %I = $1', _tbl, _col);
