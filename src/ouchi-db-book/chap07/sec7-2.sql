SHOW DATABASES;

-- DB の切り替え
USE test_db;

SELECT
	DATABASE();

-- プロンプトの設定
-- `prompt Transaction A> `
-- 注意：
-- - プロンプトにしたい文字列を '' や `` で囲わない。記号もプロンプトに含まれてしまう。
-- - `>` のあとにスペースを挿入してから enter
-- - prompt コマンドには delimiter (;) は必要ない
SHOW TABLES;

-- トランザクション分離レベルの確認
SHOW VARIABLES like 'transaction_isolation';

-- Transaction A
START TRANSACTION;

ROLLBACK;

-- ============================================================
-- 他のトランザクションでの更新がどのように見えるかの検証
-- ============================================================
-- ------------------------------------------------------------
-- シナリオ 1
-- 他のトランザクションでの更新（INSERT）が、
-- 自トランザクションでの読み込み（SELECT）でどう見えるか
-- ------------------------------------------------------------
-- Transaction A>
START TRANSACTION;

-- Transaction B>
START TRANSACTION;

INSERT INTO
	tx_test (id, name)
VALUES
	(2, 'MySQL');

COMMIT;

-- Transaction A>
SELECT
	*
FROM
	tx_test;

-- Transaction B>
START TRANSACTION;

INSERT INTO
	tx_test (id, name)
VALUES
	(3, 'PostgreSQL');

COMMIT;

-- Transaction A>
SELECT
	*
FROM
	tx_test;

-- Transaction B>
START TRANSACTION;

INSERT INTO
	tx_test (id, name)
VALUES
	(4, 'Oracle');

-- Transaction B>
-- Oracle の追加を確認
SELECT
	*
FROM
	tx_test;

-- Transaction B>
-- Oracle のレコード追加をロールバック
ROLLBACK;

-- Transaction B>
-- Oracle のレコード追加の更新をロールバックしているので消えていることを確認
SELECT
	*
FROM
	tx_test;

-- util 削除
-- DELETE FROM tx_test
-- WHERE
-- 	id = 2
-- 	OR id = 3;
-- ------------------------------------------------------------
-- シナリオ 2
-- 他のトランザクションでの更新と自トランザクションの更新はどう競合するか
-- ------------------------------------------------------------
-- Transaction A>
START TRANSACTION;

-- Transaction B>
START TRANSACTION;

-- Transaction B>
INSERT INTO
	tx_test (id, name)
VALUES
	(4, 'Oracle');

-- Transaction A>
-- Tx B でコミットしないまま同じ ID のレコードを追加しようとする
-- 50 秒ほど待つと以下のエラーになる
-- ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
INSERT INTO
	tx_test (id, name)
VALUES
	(4, 'JavaDB');

-- タイムアウト時間は以下で確認できる
-- +--------------------------+-------+
-- | Variable_name            | Value |
-- +--------------------------+-------+
-- | innodb_lock_wait_timeout | 50    |
-- +--------------------------+-------+
SHOW VARIABLES like 'innodb_lock_wait_timeout';

-- 別のコマンドでタイムアウト時間を確認
-- +-----------------------------------+
-- | @@GLOBAL.innodb_lock_wait_timeout |
-- +-----------------------------------+
-- |                                50 |
-- +-----------------------------------+
SELECT
	@@GLOBAL.innodb_lock_wait_timeout;

-- Transaction A>
-- トランザクションから抜ける
ROLLBACK;

-- Transaction B>
SELECT
	*
FROM
	tx_test;

ROLLBACK;

-- Oracle のレコードの更新がロールバックされたことを確認
SELECT
	*
FROM
	tx_test;

-- ------------------------------------------------------------
-- 稼働中のトランザクションのトランザクション分離レベルを確認する
-- ------------------------------------------------------------
-- Transaction A> : REPEATABLE READ
-- ---------------------------------------------------------------
SET TRANSACTION isolation level repeatable READ;

START TRANSACTION;

INSERT INTO
	tx_test (id, name)
VALUES
	(4, 'Oracle from Tx A');

-- Transaction B> : READ COMMITTED
-- ---------------------------------------------------------------
SET TRANSACTION isolation level READ committed;

START TRANSACTION;

INSERT INTO
	tx_test (id, name)
VALUES
	(5, 'JavaDB from Tx B');

-- 現在稼働中のトランザクションのトランザクション分離レベルを確認
-- trx_mysql_thread_id は CONNECTION_ID() と同一
-- +--------+---------------------+---------------+
-- | trx_id | trx_isolation_level | connection_id |
-- +--------+---------------------+---------------+
-- |   4655 | READ COMMITTED      |            12 |
-- |   4654 | REPEATABLE READ     |            11 |
-- +--------+---------------------+---------------+
SELECT
	trx_id,
	trx_isolation_level,
	trx_mysql_thread_id AS connection_id
FROM
	information_schema.innodb_trx;

-- Transaction A>
ROLLBACK;

-- Transaction B>
ROLLBACK;

-- ------------------------------------------------------------
-- シナリオ 3
-- トランザクション分離レベルを変えて見る
-- Transaction A> : REPEATABLE READ
-- Transaction B> : READ COMMITTED
-- （直接は関係ないけど Transaction C> : REPEATABLE READ）
-- ------------------------------------------------------------
-- Transaction A> : REPEATABLE READ
-- ---------------------------------------------------------------
-- SET TRANSACTION ISOLATION LEVEL <level>:
-- 注意：
-- - 次に開始するトランザクションの特性を変える文なのでセッション変数は上書きされない。
-- - なので SHOW VARIABLES like 'transaction_isolation'; は変わらない。
SET TRANSACTION isolation level repeatable READ;

START TRANSACTION;

-- Transaction B> : READ COMMITTED
-- ---------------------------------------------------------------
SET TRANSACTION isolation level READ committed;

START TRANSACTION;

-- （直接は関係ないけど Transaction C> : REPEATABLE READ）
-- ---------------------------------------------------------------
-- `prompt Transaction C> ` (> の後ろのスペースも忘れずに)
SHOW VARIABLES like 'transaction_isolation';

-- Transaction C: レコードの更新。Tx A, B からはどう見えるか？
-- (id, name) = (1, 'MySQL') -> (5, 'PostgreSQL') に更新
START TRANSACTION;

UPDATE tx_test
SET
	id = 5,
	name = 'PostgreSQL'
WHERE
	id = 1;

-- Transaction A> : REPEATABLE READ
-- 更新は見えない
SELECT
	*
FROM
	tx_test;

-- Transaction B> : READ COMMITTED
-- 更新は見えない
SELECT
	*
FROM
	tx_test;

-- Transaction C
COMMIT;

-- Transaction A> : REPEATABLE READ
-- 更新は見えない
SELECT
	*
FROM
	tx_test;

-- Transaction B> : READ COMMITTED
-- トランザクション中だが、更新が見えるようになる
SELECT
	*
FROM
	tx_test;

-- mysql> select id, name from tx_test;
-- +-----+--------------+
-- | id  | name         |
-- +-----+--------------+
-- |   2 | MySQL        |
-- |   3 | PostgreSQL   |
-- |   5 | PostgreSQL   |
-- | 999 | Aurora MySQL |
-- +-----+--------------+
-- Transaction A>
ROLLBACK;

-- トランザクションを抜けたので、Transaction A でも更新が見えるようになる
SELECT
	*
FROM
	tx_test;

-- Transaction B>
ROLLBACK;

-- Transaction C>
ROLLBACK;
