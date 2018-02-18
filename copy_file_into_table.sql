\timing on
\connect bathymetry
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

    CREATE TEMP TABLE tmp (
        time            int4   NOT NULL ,
        longitude       float8 NOT NULL ,
        latitude        float8 NOT NULL ,
        depth           float8 NOT NULL ,
        sigma_h         float8 NOT NULL ,
        sigma_d         float8 NOT NULL ,
        source_id       int4   NOT NULL ,
        predicted_depth float8 NOT NULL
	);
COPY tmp FROM :v1 WITH (DELIMITER ' ') ;
    INSERT INTO pings (
        time, longitude, latitude, depth, sigma_h, sigma_d, source_id, predicted_depth)
    SELECT
        time, longitude, latitude, depth, sigma_h, sigma_d, source_id, predicted_depth
    FROM tmp
    ;
UPDATE pings SET organization_id = :v2 where source_id  = (select min(source_id) from tmp);
COMMIT;
