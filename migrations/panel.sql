-- 1 up
create table if not exists tenant (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  ctime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE INDEX(name)
);
-- 1 down
drop table tenant;


-- 2 up
create table if not exists serverpool (
  id    SERIAL PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  name varchar(20) NOT NULL,
  ctime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  json text NOT NULL,
  UNIQUE INDEX (tenant_id,name),
  CONSTRAINT fk-serverpool-tenant_id FOREIGN KEY (tenant_id) REFERENCES tenant(id)
);
-- 2 down
drop table if exists vip;

-- 3 up
create table if not exists vip (
  id    SERIAL PRIMARY KEY,
  name varchar(60) NOT NULL,
  tenant_id BIGINT UNSIGNED NOT NULL,
  serverpool_id BIGINT UNSIGNED NOT NULL,
  json text NOT NULL,
  ctime TIMESTAMP,
  mtime TIMESTAMP,
  UNIQUE INDEX (tenant_id, name),
  CONSTRAINT fk-vip-tenant_id FOREIGN KEY (tenant_id) REFERENCES tenant(id),
  CONSTRAINT fk-vip-serverpool_id FOREIGN KEY (serverpool_id) REFERENCES serverpool(id)
);
-- 3 down
drop table if exists vip;
