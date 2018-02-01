\connect bathymetry
drop table organization;
CREATE TABLE organization (
		organization_id serial primary key,
        name varchar(255) NOT NULL,
		access_method varchar(255) NOT NULL
    );
COMMIT;
--select count(*) from organization;
