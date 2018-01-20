\timing on
\connect bathymetry 
select column_name from information_schema.columns where
table_name='file_paths';

select count(*) from file_paths;
COMMIT;
