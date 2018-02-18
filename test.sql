\timing on
\connect bathymetry 
select source_id, longitude, latitude
FROM pings
where longitude  BETWEEN 0 AND 5; 
and latitude BETWEEN 0 AND 5;
commit;
