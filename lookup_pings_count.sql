\timing on
\connect bathymetry 
-- 55124 /geosat2/cm_data_topo1/data/public/SIO/200102030.cm
--select column_name from information_schema.columns where table_name='pings1';
-- ALTER TABLE pings RENAME TO pings1;
--select * from pings where source_id = 55124;
-- select count(*) from pings;
select * from organization;
COMMIT;
