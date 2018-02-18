\connect bathymetry
-- SET search_path TO srtm_plus_schema,"$user",public;

INSERT INTO organization
VALUES (default, :org, :acc) RETURNING organization_id;
