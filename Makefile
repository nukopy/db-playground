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

# ---------------------------------------------------------------
# common
# ---------------------------------------------------------------

.PHONY: down downv

down:
	docker compose down -v

downv:
	docker compose down -v
