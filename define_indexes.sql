\timing on
\connect bathymetry
SET search_path TO srtm_plus_schema,"$user",public;

-- CREATE INDEX pings_source_id_btree_index ON pings (source_id) ;

CREATE INDEX pings_depth_btree_index ON pings (depth) ;

commit;
