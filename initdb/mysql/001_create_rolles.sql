-- ===============================================================
-- MySQL 初期化スクリプト
-- 目的:
--   - PostgreSQL 版と同等のロール/ユーザー構成を MySQL 8.0 で再現
--   - 役割ごとの権限付与と接続ユーザーの関連付けを実現
-- 実行者:
--   MySQL 管理ユーザー (例: root)
-- ===============================================================
-- 所有者ロール (MySQL では DB 所有者の概念がないため、全権限を付与するロールとして扱う)
create ROLE `owner_app`;

-- ref: MySQL 5.7 -> 8.0 collation (照合順序) https://speakerdeck.com/fujiwara3/offers-web-performance-tuning
create database `playground_db` character set utf8mb4 collate utf8mb4_0900_ai_ci;

-- MySQL では全テーブル/ビュー/ストアドオブジェクトをまとめて扱うため、先に USE しておく
use `playground_db`;

grant all privileges on `playground_db`.* to `owner_app` with
grant option;

-- ===============================================================
-- ロールの作成
-- ===============================================================
-- ---------------------------------------------------------------
-- 読み書き用ロール
-- ---------------------------------------------------------------
-- ロール作成
create ROLE `group_app_rw`;

-- ロールへ権限付与
grant select,
  insert,
  update,
  delete on `playground_db`.* to `group_app_rw`;

-- ---------------------------------------------------------------
-- 読み取り専用ロール
-- ---------------------------------------------------------------
-- ロール作成
create ROLE `group_app_ro`;

-- ロールへ権限付与
grant select on `playground_db`.* to `group_app_ro`;

-- ---------------------------------------------------------------
-- マイグレーション用ロール
-- ---------------------------------------------------------------
-- ロール作成
create ROLE `group_app_migrate`;

-- ロールへ権限付与
grant all privileges on `playground_db`.* to `group_app_migrate`;

-- ---------------------------------------------------------------
-- 開発用ロール
-- ---------------------------------------------------------------
-- ロール作成
create ROLE `group_dev`;

-- ロールへ権限付与
grant all privileges on `playground_db`.* to `group_dev`;

-- ===============================================================
-- 接続ユーザーの作成 (デフォルトで付与されるロールを明示)
-- ===============================================================
-- ---------------------------------------------------------------
-- app_rw_user
-- ---------------------------------------------------------------
-- ユーザ作成
create USER `app_rw_user` @`%` identified BY 'pass_app_rw_user';

-- ユーザへロール付与
grant `group_app_rw` to `app_rw_user` @`%`;

-- MySQL では role を grant しただけではロールは有効化されない。
-- デフォルトで付与されるロールを明示するために、set default ROLE を使用する。
set default ROLE `group_app_rw` to `app_rw_user` @`%`;

-- ---------------------------------------------------------------
-- app_ro_user
-- ---------------------------------------------------------------
-- ユーザ作成
create USER `app_ro_user` @`%` identified BY 'pass_app_ro_user';

-- ユーザへロール付与
grant `group_app_ro` to `app_ro_user` @`%`;

set default ROLE `group_app_ro` to `app_ro_user` @`%`;

-- ---------------------------------------------------------------
-- app_migration_user
-- ---------------------------------------------------------------
-- ユーザ作成
create USER `app_migration_user` @`%` identified BY 'pass_app_migration_user';

-- ユーザへロール付与
grant `group_app_migrate` to `app_migration_user` @`%`;

set default ROLE `group_app_migrate` to `app_migration_user` @`%`;

-- ---------------------------------------------------------------
-- app_dev_user
-- ---------------------------------------------------------------
-- ユーザ作成
create USER `app_dev_user` @`%` identified BY 'pass_app_dev_user';

grant `group_dev` to `app_dev_user` @`%`;

set default ROLE `group_dev` to `app_dev_user` @`%`;
