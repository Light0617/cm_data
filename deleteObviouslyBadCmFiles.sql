
-- This file is mostly not needed any more because source_ids and filenames are now
-- foreign keys to source_id_filenames, which has a primary key on both, so all error
-- cases previously examined here are redundent.
--
-- If we extend this file with further tests, then the seach for bad_pings will be useful
--
-- Still need vacuum analyze of pings

\timing on
\connect jj
SET search_path TO srtm_plus_schema,"$user",public;

INSERT INTO bad_pings
 SELECT *
  FROM pings
  WHERE source_id IN (SELECT DISTINCT source_id FROM bad_source_ids) ;

-- Get rid of pings from obviously bad files (above), before looking for more problems.
--
-- FIXME: be -VERY- sure this select has reasonable results before marking any data bad.
--
-- SELECT DISTINCT source_id FROM bad_pings ;
-- UPDATE pings
--  SET sigma_d = 9999
--   WHERE ping_id IN ( SELECT ping_id FROM bad_pings ) ;
--
-- DELETE FROM pings WHERE ping_id IN ( SELECT ping_id FROM bad_pings ) ;



-- Do not need to do these checks anymore because we checked for these problems when we
-- read CM files, but if we had further checks this would be the spot to do it.
--
-- Sanity check pings -------------------------------------------------------------------
-- FIXME:
-- FIXME: Big problem here is that edited pings get convert to GEOGRAPHY which coerces
-- FIXME:  bad lat/lon to +-180, +/- 90
-- FIXME: These are only a few of --MANY-- reasons a ping could be  bad.
-- FIXME: these are already check when we injested the CM file
-- FIXME:
INSERT INTO bad_pings
 SELECT *
  FROM pings
  WHERE
--   WHERE sigma_d != 9999 AND (
   source_id NOT BETWEEN SYMMETRIC    0 AND 65536 OR
   latitude  NOT BETWEEN SYMMETRIC  -90 AND   +90 OR
   longitude NOT BETWEEN SYMMETRIC -180 AND  +180
--   )
  ;


VACUUM ANALYZE pings ;
