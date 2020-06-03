# postfix-mysql-tls
A simple playbook installing postfix maps on mysql authenticated by tls

## Inventory

A mysql server configured using docker (no ansible stuff here because
it is a component external to our playbooks).
MySQL configuration is in [group_vars/all/mysql.yml] as that's available
to all hosts.

MySQL creates both server and client certificates, so in this example
we will reuse the client-key.pem and client-cert.pem generated from 
the MySQL server using a shared volume between two containers.
In a production environment you'd better create both certificates
using the same CA.

A postfix server, installed via ansible from a RHEL/CentOS 8
authenticating to mysql via x509.

## Configuration notes

MySQL requires the SUBJECT to start with `/`

```mysql
ALTER USER 'foo'@'%' 
    REQUIRE SUBJECT '/CN=MySQL_Server_8.0.20_Auto_Generated_Client_Certificate';
```

When using the password validator plugin

```
INSTALL COMPONENT 'file://component_validate_password';
```

you need to set a password on an entry. You can then

```
CREATE USER 'foo'@'%' IDENTIFIED BY random password;
ALTER USER 'foo'@'%' REQUIRE SUBJECT '/CN=MySQL_Server_8.0.20_Auto_Generated_Client_Certificate';

-- If you just want Client-certificate authentication, blank the password via SQL
--   and reload privilege table.
UPDATE mysql.user SET authentication_string='' WHERE user='foo' AND host='%';
FLUSH PRIVILEGES;
```

## Testing the solution

Ensure the mysql database has the table created by the script in [docker/my.cnf.d/initfiles/]

Enter the postfix container and start postfix

```
[root@6fb21c16f52e /]# postfix -c /etc/postfix/ start
postfix/postfix-script: starting the Postfix mail system

# check the `needle` entry map
[root@6fb21c16f52e /]# postmap -q needle mysql:/etc/postfix/mysql-aliases.cf 
10.0.0.1

# verify that `MISSING` does not exist
[root@6fb21c16f52e /]# postmap -q MISSING mysql:/etc/postfix/mysql-aliases.cf 
```


