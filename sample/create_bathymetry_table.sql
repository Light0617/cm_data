\connect bathymetry
CREATE TABLE pings (
        time            int4   NOT NULL ,
        longitude       float8 NOT NULL ,
        latitude        float8 NOT NULL ,
        depth           float8 NOT NULL ,
        sigma_h         float8 NOT NULL ,
        sigma_d         float8 NOT NULL ,
        source_id       int4   NOT NULL ,
        predicted_depth float8 NOT NULL
    );
COMMIT;
select count(*) from pings;
COMMIT;
