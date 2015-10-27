-- 1 up
create table if not exists tenant (
  uuid  binary(16) PRIMARY KEY NOT NULL,
  name VARCHAR(50) NOT NULL,
  ctime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE INDEX(name)
);
-- 1 down
drop table tenant;


-- 2 up
create table if not exists vslb (
  uuid  binary(16) PRIMARY KEY NOT NULL,
  name varchar(60) NOT NULL,
  address varchar(60) NOT NULL,
  ctime TIMESTAMP,
  mtime TIMESTAMP,
  tenant_uuid binary(16) NOT NULL,
  UNIQUE INDEX (tenant_uuid, name),
  #UNIQUE INDEX (address),
  CONSTRAINT fk__vslb__tenant_uuid FOREIGN KEY (tenant_uuid) REFERENCES tenant(uuid)
);
-- 2 down
drop table if exists vslb;


-- 3 up
create table if not exists serverpool (
  uuid  binary(16) PRIMARY KEY NOT NULL,
  name varchar(20) NOT NULL,
  ctime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  json text NOT NULL,
  tenant_uuid binary(16) NOT NULL,
  UNIQUE INDEX (tenant_uuid,name),
  CONSTRAINT fk__serverpool__tenant_uuid FOREIGN KEY (tenant_uuid) REFERENCES tenant(uuid)
);
-- 3 down
drop table if exists serverpool;


-- 4 up
create table if not exists vip (
  uuid    SERIAL PRIMARY KEY,
  name  varchar(60) NOT NULL,
  tenant_uuid binary(16) NOT NULL,
  vslb_uuid binary(16) NOT NULL,
  serverpool_uuid binary(16) NOT NULL,
  json  text NOT NULL,
  ctime TIMESTAMP,
  mtime TIMESTAMP,
  UNIQUE INDEX (tenant_uuid, name),
  CONSTRAINT fk__vip__tenant_uuid FOREIGN KEY (tenant_uuid) REFERENCES tenant(uuid),
  CONSTRAINT fk__vip__vslb_uuid FOREIGN KEY (vslb_uuid) REFERENCES vslb(uuid),
  CONSTRAINT fk__vip__serverpool_uuid FOREIGN KEY (serverpool_uuid) REFERENCES serverpool(uuid)
);
-- 4 down
drop table if exists vip;
