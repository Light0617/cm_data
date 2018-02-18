\timing on
\connect bathymetry 
select source_id, longitude, latitude
FROM pings
where longitude  BETWEEN 0 AND 5; 
and latitude BETWEEN 0 AND 5;
commit;
--select column_name from information_schema.columns where table_name='pings';
-- ALTER TABLE pings RENAME TO pings1;
--select * from file_paths where file_path like '%3DGBR%'; --54697
--select * from pings where (source_id = 10000 or source_id = 32784 or source_id = 54697) and time < 10;
--select count(*) from pings;
--select organization_id from organization where name = 'NGA' and access_method = 'public';
--select * from pings where organization_id = 12; 
--select * from pings where organization_id in 
--(select organization_id from organization where name = 'NGA' and access_method = 'public');
-- 22726.770 ms
--select pings.* from pings join organization on pings.organization_id = organization.organization_id
--where name = 'NGA' and access_method = 'public';
--21597.567
--WHERE longitude  BETWEEN 0 AND 5 and
--latitude BETWEEN 0 AND 5;


--select * from pings where source_id = 10000;
--select * from organization;
