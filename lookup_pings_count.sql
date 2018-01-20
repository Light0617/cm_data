\timing on
\connect bathymetry 
select column_name from information_schema.columns where
table_name='pings';

select * from pings where source_id = 54297;
-- select count(*) from pings;
COMMIT;
