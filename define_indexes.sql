\timing on
\connect bathymetry
SET search_path TO srtm_plus_schema,"$user",public;

--CREATE INDEX pings__source_id_btree_index ON pings (source_id) ;
--CREATE INDEX pings_organization_id_btree_index ON pings (organization_id) ;
--CREATE INDEX pings__depth_btree_index ON pings (depth) ;
--CREATE INDEX pings_predicted_bad_btree_index ON pings (predicted_bad);
CREATE INDEX pings_latitude_btree_index ON pings (latitude);
CREATE INDEX pings_longitude_btree_index ON pings (longitude);
commit;
