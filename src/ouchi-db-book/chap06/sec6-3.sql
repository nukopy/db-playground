-- ==================================================
-- 6-3 データの更新、挿入、削除
-- ==================================================
-- UPDATE: name = 'Kioto' を name = 'Kyoto' に修正
-- --------------------------------------------------
-- name = 'Kioto' のレコードを特定
SELECT
	*
FROM
	city
WHERE
	countrycode = 'JPN'
	AND district = 'Kyoto'
	AND name = 'Kioto';

-- レコードの修正
UPDATE city
SET
	name = 'Kyoto'
WHERE
	countrycode = 'JPN'
	AND district = 'Kyoto'
	AND name = 'Kioto';

-- 修正されたことを確認
SELECT
	*
FROM
	city
WHERE
	countrycode = 'JPN'
	AND district = 'Kyoto';

-- INSERT: 愛媛県（district = 'Ehime'）の大洲市（name = 'Ozu'）を挿入
-- --------------------------------------------------
-- district = 'Ehime' のレコードを確認
SELECT
	id AS 'ID',
	name AS '都市名',
	countrycode AS '国コード',
	district AS '県名',
	population AS '人口'
FROM
	city
WHERE
	countrycode = 'JPN'
	AND district = 'Ehime';

-- 挿入
INSERT INTO
	city
VALUES
	(default, 'Ozu', 'JPN', 'Ehime', 39534);

-- 別パターン
INSERT INTO
	city (name, countrycode, district, population)
VALUES
	('Ozu', 'JPN', 'Ehim
e', 39534);

-- 全てデフォルト値を使う（最低 1 つは列リストを設定する必要がある）
INSERT INTO
	city (id)
VALUES
	(default);

-- countrycode の外部キー制約によりエラーになる
-- ERROR 1452 (23000):
-- Cannot add or update a child row:
-- a foreign key constraint fails (`world`.`city`, CONSTRAINT `city_ibfk_1` FOREIGN KEY (`CountryCode`) REFERENCES `country` (`Code`))
-- ...
-- 挿入されたレコードを確認
SELECT
	id AS 'ID',
	name AS '都市名',
	countrycode AS '国コード',
	district AS '県名',
	population AS '人口'
FROM
	city
WHERE
	countrycode = 'JPN'
	AND district = 'Ehime';

-- | ID   | 都市名    | 国コード     | 県名   | 人口   |
-- ...
-- | 4080 | Ozu       | JPN          | Ehime  |  39534 |
-- ...
-- --------------------------------------------------
-- 複数行の INSERT
-- --------------------------------------------------
-- city テーブルと定義が等しい新規テーブルを作成
CREATE TABLE citycopy like city;

-- 作成後のテーブルはレコードはなし
SELECT
	*
FROM
	citycopy;

-- countrycode = 'JPN' だけを抽出して citycopy に挿入する
INSERT INTO
	citycopy
SELECT
	*
FROM
	city
WHERE
	countrycode = 'JPN';

-- city テーブルから countrycode = 'JPN' のレコードだけが citycopy に挿入されていることを確認
SELECT
	*
FROM
	citycopy;

-- countrycode = 'USA' を 100 行だけ抽出して citycopy に挿入する
INSERT INTO
	citycopy
SELECT
	*
FROM
	city
WHERE
	countrycode = 'USA'
LIMIT
	100;

-- 確認
SELECT
	*
FROM
	citycopy
WHERE
	countrycode = 'USA';

-- 複数行の insert
INSERT INTO
	city (name, countrycode, district, population)
VALUES
	('Saijo', 'JPN', 'Ehime', 100851),
	('Shikokuchuo', 'JPN', 'Ehime', 78978),
	('Uwajima', 'JPN', 'Ehime', 65819);

-- 挿入されたことを確認
SELECT
	*
FROM
	city
WHERE
	district = 'Ehime';

-- --------------------------------------------------
-- DELETE: 愛媛県（district = 'Ehime'）の大洲市（name = 'Ozu'）のレコードを削除
-- --------------------------------------------------
-- id = 4080 のレコードを削除
DELETE FROM city
WHERE
	id = 4080;

-- 削除されたことを確認
SELECT
	id AS 'ID',
	name AS '都市名',
	countrycode AS '国コード',
	district AS '県名',
	population AS '人口'
FROM
	city
WHERE
	countrycode = 'JPN'
	AND district = 'Ehime';
