\connect bathymetry
CREATE TABLE file_paths (
        source_id float8 NOT NULL ,
        file_path varchar NOT NULL
    );
COMMIT;
select count(*) from file_paths;
COMMIT;



