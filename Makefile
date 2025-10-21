# ---------------------------------------------------------------
# PostgreSQL
# ---------------------------------------------------------------

.PHONY: up-psql upd-psql down-psql downv-psql

up-psql:
	docker compose up db-postgresql

upd-psql:
	docker compose up db-postgresql -d

down-psql:
	docker compose down db-postgresql

downv-psql:
	docker compose down db-postgresql -v

# 開発用ユーザで接続
conn-psql:
	docker compose exec db-postgresql psql -U app_dev_user -d playground_db

# ---------------------------------------------------------------
# MySQL
# ---------------------------------------------------------------

.PHONY: up-mysql upd-mysql down-mysql downv-mysql

up-mysql:
	docker compose up db-mysql

upd-mysql:
	docker compose up db-mysql -d

down-mysql:
	docker compose down db-mysql

downv-mysql:
	docker compose down db-mysql -v

# 開発用ユーザで接続
conn-mysql:
	docker compose exec db-mysql mysql -u app_dev_user -ppass_app_dev_user playground_db

# bash に接続
conn-mysql-bash:
	docker compose exec db-mysql bash

# example databases を作成
DOWNLOAD_URL_SAKILA_DB := https://downloads.mysql.com/docs/sakila-db.tar.gz
DOWNLOAD_URL_WORLD_DB := https://downloads.mysql.com/docs/world-db.tar.gz
.PHONY: download-example-dbs setup-example-dbs create-sakila-db create-world-db

download-example-dbs:
	echo "Downloading sakila database..."
	wget $(DOWNLOAD_URL_SAKILA_DB) -O ref/sakila-db.tar.gz
	tar -xzf ref/sakila-db.tar.gz -C ref/

	echo "Downloading world database..."
	wget $(DOWNLOAD_URL_WORLD_DB) -O ref/world-db.tar.gz
	tar -xzf ref/world-db.tar.gz -C ref/

# ref: https://dev.mysql.com/doc/refman/8.0/ja/mysql-batch-commands.html
create-sakila-db:
	docker compose exec -T db-mysql mysql -u app_dev_user -ppass_app_dev_user playground_db < ref/sakila-db/sakila-schema.sql
	docker compose exec -T db-mysql mysql -u app_dev_user -ppass_app_dev_user playground_db < ref/sakila-db/sakila-data.sql

create-world-db:
	docker compose exec -T db-mysql mysql -u app_dev_user -ppass_app_dev_user playground_db < ref/world-db/world.sql

setup-example-dbs:
	make create-sakila-db
	make create-world-db

# ---------------------------------------------------------------
# common
# ---------------------------------------------------------------

.PHONY: down downv

down:
	docker compose down -v

downv:
	docker compose down -v
