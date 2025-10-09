-- ===============================================================
-- PostgreSQL 初期化スクリプト
-- 目的:
--   - 所有者ロール (owner_app)、グループロール (group_app_rw, group_app_ro)、接続ロール (app_rw_user, app_ro_user) を定義
--   - 権限の継承とデフォルト権限を設定
--   - 開発/検証環境向けに安全で再利用しやすい権限構成を作る
-- 実行者:
--   POSTGRES_USER (例: admin)
-- ===============================================================
-- 所有者ロール
create ROLE owner_app NOLOGIN;

-- プレイグラウンド用の DB を作成
create database playground_db owner owner_app;

-- PostgreSQL 15 以降では public スキーマの CREATE 権限は PUBLIC に付与されていないが、
-- 旧バージョンからアップグレードしたクラスタの場合は安全のために再設定しておく。
-- REVOKE CREATE ON SCHEMA public FROM PUBLIC;
-- REVOKE ALL ON DATABASE appdb FROM PUBLIC;  -- DBへの接続制限は継続して推奨
\c playground_db;

-- ===============================================================
-- 運用用のグループの作成
-- ===============================================================
-- ---------------------------------------------------------------
-- group for service (read and write)
-- ---------------------------------------------------------------
create ROLE group_app_rw NOLOGIN;

-- 権限付与
grant usage on SCHEMA public to group_app_rw;

grant select,
    insert,
    update,
    delete on all tables in SCHEMA public to group_app_rw;

grant usage,
    select on all SEQUENCES in SCHEMA public to group_app_rw;

-- デフォルト権限の設定
alter default privileges for ROLE owner_app in SCHEMA public
grant select,
    insert,
    update,
    delete on tables to group_app_rw;

alter default privileges for ROLE owner_app in SCHEMA public
grant usage,
    select on SEQUENCES to group_app_rw;

-- ---------------------------------------------------------------
-- group for service (read only)
-- ---------------------------------------------------------------
create ROLE group_app_ro NOLOGIN;

-- 権限付与
grant usage on SCHEMA public to group_app_ro;

grant select on all tables in SCHEMA public to group_app_ro;

-- デフォルト権限の設定
alter default privileges for ROLE owner_app in SCHEMA public
grant select on tables to group_app_ro;

-- ---------------------------------------------------------------
-- group for migration
-- ---------------------------------------------------------------
create ROLE group_app_migrate NOLOGIN;

-- public スキーマでの DDL 操作を許可
grant usage,
    create on SCHEMA public to group_app_migrate;

-- 既存オブジェクトにも広めの権限を付与
grant all privileges on all tables in SCHEMA public to group_app_migrate;

grant all privileges on all SEQUENCES in SCHEMA public to group_app_migrate;

grant all privileges on all FUNCTIONS in SCHEMA public to group_app_migrate;

-- 将来作られるオブジェクトにも DDL / DML 権限を自動付与
alter default privileges for ROLE owner_app in SCHEMA public
grant all privileges on tables to group_app_migrate;

alter default privileges for ROLE owner_app in SCHEMA public
grant all privileges on SEQUENCES to group_app_migrate;

alter default privileges for ROLE owner_app in SCHEMA public
grant all privileges on FUNCTIONS to group_app_migrate;

-- ---------------------------------------------------------------
-- group for development（開発用に色々できるグループ）
-- ---------------------------------------------------------------
create ROLE group_dev NOLOGIN;

-- 権限付与
grant usage,
    create on SCHEMA public to group_dev;

grant all privileges on all tables in SCHEMA public to group_dev;

grant all privileges on all SEQUENCES in SCHEMA public to group_dev;

grant all privileges on all FUNCTIONS in SCHEMA public to group_dev;

-- デフォルト権限の設定
alter default privileges for ROLE owner_app in SCHEMA public
grant all privileges on tables to group_dev;

alter default privileges for ROLE owner_app in SCHEMA public
grant all privileges on SEQUENCES to group_dev;

alter default privileges for ROLE owner_app in SCHEMA public
grant all privileges on FUNCTIONS to group_dev;

-- ===============================================================
-- 接続ロールの作成
-- ===============================================================
-- read and write (ロールの継承を 2 つの文に分けるバージョン)
create ROLE app_rw_user LOGIN password 'pass_app_rw_user';

grant group_app_rw to app_rw_user;

-- read only (ロールの継承を 1 文で行うバージョン)
create ROLE app_ro_user LOGIN password 'pass_app_ro_user' in ROLE group_app_ro;

-- migration
create ROLE app_migration_user LOGIN password 'pass_app_migration_user' in ROLE group_app_migrate;

-- dev
create ROLE app_dev_user LOGIN password 'pass_app_dev_user' in ROLE group_dev;
