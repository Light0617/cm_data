\timing on
\connect bathymetry
SET search_path TO srtm_plus_schema,"$user",public;

    CREATE TEMP TABLE tmp (
        source_id float8 NOT NULL ,
        file_path varchar NOT NULL
	);
COPY tmp FROM :v1 WITH (DELIMITER ' ') ;
    INSERT INTO file_paths (
        source_id, file_path)
    SELECT
        source_id, file_path
    FROM tmp
    ;
COMMIT;
