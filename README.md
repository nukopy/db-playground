# DB Playground

This is a playground for me to experiment with different database technologies.

## Requirements

- Docker
- Docker Compose
- Node.js v22.16.0 or later (for Codex)

## Commands

### Docker Compose

- Start databases on background

```sh
docker compose up -d
```

- Stop databases

```sh
docker compose down

# If you want to remove volumes to rerun SQL init scripts in `/docker-entrypoint-initdb.d/*`
docker compose down -v
# -v: remove volumes
```

- Connect to databases with development user

```sh
docker compose exec db psql -U app_dev_user -d playground_db
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

### on AWS with Terraform

TODO

```sh
# terraform init
# terraform apply
```
