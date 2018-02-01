\connect bathymetry
CREATE TABLE pings (
		ping_id         serial primary key,
        time            int4   NOT NULL ,
        longitude       float8 NOT NULL ,
        latitude        float8 NOT NULL ,
        depth           float8 NOT NULL ,
        sigma_h         float8 NOT NULL ,
        sigma_d         float8 NOT NULL ,
        source_id       int4   NOT NULL ,
        predicted_depth float8 NOT NULL ,
		predicted_bad   float8,
		organization_id int
    );
COMMIT;
