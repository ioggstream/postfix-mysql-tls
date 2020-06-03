

-- Create a user authenticated with TLS: this authenticates with all valid certificates.
-- CREATE USER 'foo'@'%' REQUIRE X509;

-- A better solution is be to specify the Subject but this doesn't seem to work for now.
--  NOTE that the SUBJECT starts with "/"
ALTER USER 'foo'@'%' REQUIRE SUBJECT '/CN=MySQL_Server_8.0.20_Auto_Generated_Client_Certificate';


-- Create the alias table.
CREATE DATABASE customer_database;
CREATE TABLE mxaliases(forw_addr varchar(48) not null, alias varchar(48) not null unique, status varchar(8) not null);
INSERT INTO mxaliases(forw_addr, alias, status) VALUES ('10.0.0.1', 'needle', 'paid');

GRANT ALL on customer_database.* TO 'foo'@'%';