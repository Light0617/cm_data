\connect bathymetry
CREATE TABLE file_paths (
        source_id int4 NOT NULL ,
        file_path varchar(255) NOT NULL
    );
COMMIT;
select count(*) from file_paths;
COMMIT;



