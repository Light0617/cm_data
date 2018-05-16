\timing on
\connect bathymetry 
-- select source_id, longitude, latitude
-- FROM pings
-- where longitude  BETWEEN 0 AND 5; 
-- and latitude BETWEEN 0 AND 5;

-- CREATE EXTENSION postgis;
--select longitude, latitude, 
--ST_GeomFromEWKT('SRID=32632;POINT(longitude latitude)') from pings 
-- ST_SetSRID(ST_MakePoint(longitude, latitude),4326),
-- ST_GeogFromText('SRID=4326;POINT('+longitude+' 'latitude')')
-- from pings
-- where source_id = 1 limit 20;

--SELECT ST_MakePolygon(ST_GeomFromText('LINESTRING(10 20, 20 40, 40 60, 60 80, 80 90, 10 20)'));
--SELECT ST_MakePolygon(ST_GeomFromText('LINESTRING(10 20, 20 40, 40 60, 60 80, 80 90, 10 20)'));
\echo 'value: %' :x;
SELECT ST_MakePolygon(ST_GeomFromText(:x));
--SELECT ST_MakePolygon(ST_GeomFromText('LINESTRING(10 20, 20 40, 40 60, 60 80, 80 90)'));
--SELECT ST_MakePolygon(ST_GeomFromText('LINESTRING($x)'));
commit;
