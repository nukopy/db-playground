-- ======================================================================
-- ロックタイムアウト、デッドロックを起こす
-- ======================================================================
-- プロンプトの設定
-- `prompt Tx A> `
-- `prompt Tx B> `
-- ----------------------------------------------------------------------
-- タイムアウトを起こしてみる
-- ----------------------------------------------------------------------
-- Tx A
-- ロックタイムアウトを 5 秒に設定（デフォルトは 50 秒）
SET
	innodb_lock_wait_timeout = 5;

-- タイムアウト時間が更新されたことを確認
-- +--------------------------+-------+
-- | Variable_name            | Value |
-- +--------------------------+-------+
-- | innodb_lock_wait_timeout | 5     |
-- +--------------------------+-------+
-- 1 row in set (0.00 sec)
SHOW VARIABLES like 'innodb_lock_wait_timeout';

-- Tx B
-- +--------------------------+-------+
-- | Variable_name            | Value |
-- +--------------------------+-------+
-- | innodb_lock_wait_timeout | 50    |
-- +--------------------------+-------+
-- デフォルトは 50 秒。
-- variables はセッションで有効な設定なのでこちらは Tx A の影響を受けない。
SHOW VARIABLES like 'innodb_lock_wait_timeout';

-- Tx A
START TRANSACTION;

-- Tx B
START TRANSACTION;

-- Tx B で先にデータ更新
INSERT INTO
	tx_test (id, name)
VALUES
	(4, 'Oracle');

-- Tx A
-- Tx B と同じ ID のレコードの insert を試みる
-- 5 秒後にロックタイムアウトエラー
-- Tx B がロックを握り続けている
-- ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
INSERT INTO
	tx_test (id, name)
VALUES
	(4, 'JavaDB');

-- Tx A
ROLLBACK;

-- Tx B
ROLLBACK;

-- ----------------------------------------------------------------------
-- タイムアウトを起こしてみる
-- ----------------------------------------------------------------------
-- Tx A
CREATE TABLE txa (
	id INT not NULL PRIMARY KEY,
	name VARCHAR(20),
	created_at TIMESTAMP(6) not NULL default CURRENT_TIMESTAMP(6),
	updated_at TIMESTAMP(6) not NULL default CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
) engine = innodb;

-- Tx B
CREATE TABLE txb (
	id INT not NULL PRIMARY KEY,
	name VARCHAR(20),
	created_at TIMESTAMP(6) not NULL default CURRENT_TIMESTAMP(6),
	updated_at TIMESTAMP(6) not NULL default CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
) engine = innodb;

-- Tx A
-- テーブル一覧。txa, txb がどちらのトランザクションからも見えている。
-- +-------------------+
-- | Tables_in_test_db |
-- +-------------------+
-- | tx_test           |
-- | txa               |
-- | txb               |
-- +-------------------+
SHOW TABLES;

-- Tx B
-- テーブル一覧。txa, txb がどちらのトランザクションからも見えている。
-- +-------------------+
-- | Tables_in_test_db |
-- +-------------------+
-- | tx_test           |
-- | txa               |
-- | txb               |
-- +-------------------+
SHOW TABLES;

-- Tx A
SET
	innodb_lock_wait_timeout = 50;

SHOW VARIABLES like 'innodb_lock%';

START TRANSACTION;

-- Tx B
START TRANSACTION;

-- Tx A
-- Tx A がテーブル txa のロックを取得
INSERT INTO
	txa (id, name)
VALUES
	(1, 'Firebird');

-- Tx B
-- Tx B がテーブル txb のロックを取得
INSERT INTO
	txb (id, name)
VALUES
	(1, 'MySQL');

-- Tx A
-- Tx B によってロック済みのテーブル txb へ insert
INSERT INTO
	txb (id, name)
VALUES
	(1, 'Firebird');

-- Tx B (Tx A の上記クエリがタイムアウトする前に実行)
-- デッドロックが起きる
-- ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
-- Tx B の全ての変更がロールバックされる
INSERT INTO
	txa (id, name)
VALUES
	(1, 'MySQL');

-- Tx A
ROLLBACK;

-- Tx B
ROLLBACK;
