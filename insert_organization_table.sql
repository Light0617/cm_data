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
INSERT INTO organization
VALUES (default, :org, :acc);
select max(organization_id) from organization;
COMMIT;
