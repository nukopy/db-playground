-- ======================================================================
-- トランザクション
-- ======================================================================
-- DB の作成
CREATE DATABASE test_db;

SHOW DATABASES;

-- DB の切り替え
USE test_db;

SELECT
	DATABASE();

-- トランザクションを扱えるテーブルを作成する
CREATE TABLE tx_test (
	id INT not NULL PRIMARY KEY,
	name VARCHAR(20),
	-- 様々な日時データ型を試す
	create_at_dt DATETIME(0) not NULL default CURRENT_TIMESTAMP(0),
	-- create_at_dt と同一の定義
	_create_at_dt DATETIME not NULL default current_timestamp,
	create_at_dt_detail DATETIME(6) not NULL default CURRENT_TIMESTAMP(6),
	create_at_ts timestamp not NULL default current_timestamp,
	create_at_ts_detail TIMESTAMP(6) not NULL default CURRENT_TIMESTAMP(6),
	update_at TIMESTAMP(6) not NULL default CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
) engine = innodb;

SHOW TABLES;

-- データの挿入
INSERT INTO
	tx_test (id, name)
VALUES
	(1, 'Firebird'),
	(999, 'Aurora MySQL');
