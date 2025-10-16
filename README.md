# DB Playground

This is a playground for me to experiment with different database technologies.

## Requirements

- Docker
- Docker Compose
- Node.js v22.16.0 or later (for Codex)
- GNU Wget 1.24.5 or later

## Commands

### PostgreSQL with Docker Compose

- Start database on background

```sh
make upd-psql
```

- Stop database

```sh
# down
make down-psql

# down with volumes
# If you want to remove volumes to rerun SQL init scripts in `/docker-entrypoint-initdb.d/*`
make downv-psql
```

- Connect to database with development user

```sh
make conn-psql
```

Make sure grants are set correctly in `psql` REPL:

```txt
playground_db=> \du
                                  List of roles
     Role name      |                         Attributes
--------------------+------------------------------------------------------------
 admin              | Superuser, Create role, Create DB, Replication, Bypass RLS
 app_dev_user       |
 app_migration_user |
 app_ro_user        |
 app_rw_user        |
 group_app_migrate  | Cannot login
 group_app_ro       | Cannot login
 group_app_rw       | Cannot login
 group_dev          | Cannot login
 owner_app          | Cannot login

playground_db=> \drg
                       List of role grants
     Role name      |     Member of     |   Options    | Grantor
--------------------+-------------------+--------------+---------
 app_dev_user       | group_dev         | INHERIT, SET | admin
 app_migration_user | group_app_migrate | INHERIT, SET | admin
 app_ro_user        | group_app_ro      | INHERIT, SET | admin
 app_rw_user        | group_app_rw      | INHERIT, SET | admin
(4 rows)
```

### MySQL with Docker Compose

- Start database on background

```sh
make upd-mysql
```

- Stop database

```sh
make down-mysql

# down with volumes
make downv-mysql
```

- Connect to database with development user

```sh
make conn-mysql
```

Make sure grants are set correctly in `mysql` REPL:

```txt
mysql> \s
--------------
mysql  Ver 8.4.6 for Linux on aarch64 (MySQL Community Server - GPL)

Connection id:          11
Current database:       playground_db
Current user:           app_dev_user@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.4.6 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 12 min 3 sec

Threads: 2  Questions: 13  Slow queries: 0  Opens: 139  Flush tables: 3  Open tables: 58  Queries per second avg: 0.017
--------------

mysql> show grants for app_dev_user;
+---------------------------------------------+
| Grants for app_dev_user@%                   |
+---------------------------------------------+
| GRANT USAGE ON *.* TO `app_dev_user`@`%`    |
| GRANT `group_dev`@`%` TO `app_dev_user`@`%` |
+---------------------------------------------+
2 rows in set (0.00 sec)

-- same as above
mysql> show grants for `app_dev_user`@'%';
+---------------------------------------------+
| Grants for app_dev_user@%                   |
+---------------------------------------------+
| GRANT USAGE ON *.* TO `app_dev_user`@`%`    |
| GRANT `group_dev`@`%` TO `app_dev_user`@`%` |
+---------------------------------------------+
2 rows in set (0.00 sec)

mysql> select current_role();
+-----------------+
| current_role()  |
+-----------------+
| `group_dev`@`%` |
+-----------------+
1 row in set (0.00 sec)
```

### on AWS with Terraform

TODO

```sh
# terraform init
# terraform apply
```
