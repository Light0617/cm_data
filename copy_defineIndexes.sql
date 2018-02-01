\timing on
\connect bathymetry
SET search_path TO srtm_plus_schema,"$user",public;

-- WARNING: Index creation is very slow! Takes about 1 --- DAY --- to index 10^9 pings
--
-- FIXME: this vacuum might be a waste of time, but index might be faster with clean tbl

-- VACUUM ANALYZE pings ;

-- Index data many ways, but most importantly GIST on location.
--
-- Default B-tree index on a geometry location (BTREE) is useless,
--  it just searches sequentially.
--
-- GIST index on location understands distance.
--

-- CREATE INDEX pings_location_gist_index ON pings USING GIST (LOCATION);


--
-- Other useful and obvious indexes, these are fast and B trees -DO- work


CREATE INDEX pings_depth_btree_index ON pings (depth) ;

CREATE INDEX pings_source_id_btree_index ON pings (source_id) ;


--
-- CREATE INDEX pings_predicted_depth_btree_index ON pings (predicted_depth) ;
--
-- There are only two values for sigma_d so its pointless to index a search on that, but
--  if there was a meaningful range of values for sigma_d or sigma_h, index them.
--
-- CREATE INDEX pings_sigma_d_btree_index ON pings (sigma_d) ;
--
-- FIXME: If we ever use geohash, this index will be very useful
--
-- CREATE INDEX pings_geohash_gist_index ON pings
--  USING GIST (geohash);



-- Index NOT used until after a vacuum. Could wait for the automatically scheduled on...

-- VACUUM ANALYZE pings ;



--
-- # Cluster data on disk using location index for additional search speed.
-- # location seems natural index to cluster on as most searches will be based on location.
-- # http://workshops.boundlessgeo.com/postgis-intro/clusterindex.html
--
-- FIXME: CLUSTER is extremely slow. Maybe 3x slower than index
--
-- CLUSTER pings USING pings_location_gist_index ;
-- ANALYZE pings ;
