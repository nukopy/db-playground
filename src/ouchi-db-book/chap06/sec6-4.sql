-- ==================================================
-- 6-4 ビュー、副問い合わせ、結合
-- ==================================================
-- ビューの作成
-- --------------------------------------------------
-- 愛媛県をまとめたビュー: city_ehime
CREATE VIEW city_ehime AS
SELECT
	id,
	name,
	population
FROM
	city
WHERE
	countrycode = 'JPN'
	AND district = 'Ehime';

-- 確認
SELECT
	*
FROM
	city_ehime;

-- 人口が 700 万人より大きい都市をまとめたビュー: large_city
CREATE VIEW large_city AS
SELECT
	id,
	name,
	population
FROM
	city
WHERE
	population > 7000000
WITH
	CHECK OPTION;

-- 確認
SELECT
	*
FROM
	large_city;

-- 日本の都市だけをまとめたビュー
CREATE VIEW city_japan AS
SELECT
	id,
	name,
	district,
	population
FROM
	city
WHERE
	countrycode = 'JPN';

-- 確認
SELECT
	*
FROM
	city_japan;

-- 副問合せ
--------------------------------------------------
-- city_japan を使って、日本の都市の内、人口が平均以上の都市数を数えてみる
SELECT
	COUNT(*)
FROM
	city_japan
WHERE
	population > (
		-- 結果がスカラ値になる
		SELECT
			AVG(population)
		FROM
			city_japan
	);

-- 日本の都道府県ごとの都市の人口の平均
SELECT
	district,
	AVG(population)
FROM
	city_japan
GROUP BY
	district;

-- 各都道府県それぞれで人口の平均を取り、各都道府県内で人口が平均より多い年をピックアップする
SELECT
	district,
	name,
	population
FROM
	city_japan AS cj1
WHERE
	population > (
		SELECT
			AVG(population)
		FROM
			city_japan AS cj2
		WHERE
			cj1.district = cj2.district
		GROUP BY
			district
	);

-- 結合 INNER JOIN, OUTER JOIN
--------------------------------------------------
-- 各国で使われている言語の表示: countrylanguage
SELECT
	*
FROM
	countrylanguage;

-- 日本で使われている言語の表示
SELECT
	*
FROM
	countrylanguage
WHERE
	countrycode = 'JPN';

-- 日本語が使われている国の表示
SELECT
	*
FROM
	countrylanguage
WHERE
	language = 'Japanese';

-- +-------------+----------+------------+------------+
-- | CountryCode | Language | IsOfficial | Percentage |
-- +-------------+----------+------------+------------+
-- | BRA         | Japanese | F          |        0.4 |
-- | GUM         | Japanese | F          |        2.0 |
-- | JPN         | Japanese | T          |       99.1 |
-- | USA         | Japanese | F          |        0.2 |
-- +-------------+----------+------------+------------+
-- 4 rows in set (0.00 sec)
-- .
-- これだけだと、GUM や BRA が度の国を指すのか分かりづらい
-- 国コードから国名を検索して追加する
-- inner join
SELECT
	cn.name,
	cl.*
FROM
	countrylanguage AS cl
	INNER JOIN country AS cn ON cl.countrycode = cn.code
WHERE
	language = 'Japanese';

-- どこの国にも使われていない人工言語 Esperanto を登録する
-- --------------------------------------------------
INSERT INTO
	country (code, name, continent)
VALUES
	("ZZZ", "EsperantoCountry", "Europe");

-- 'ZZZ' があることを確認
SELECT
	code
FROM
	country;

-- 言語として Esperanto を挿入
INSERT INTO
	countrylanguage (countrycode, language)
VALUES
	('ZZZ', 'Esperanto');

-- 確認
SELECT
	*
FROM
	countrylanguage
WHERE
	countrycode = 'ZZZ';

-- +-------------+-----------+------------+------------+
-- | CountryCode | Language  | IsOfficial | Percentage |
-- +-------------+-----------+------------+------------+
-- | ZZZ         | Esperanto | F          |        0.0 |
-- +-------------+-----------+------------+------------+
-- inner join
SELECT
	cn.name AS 'CountryName',
	cl.*
FROM
	countrylanguage AS cl
	INNER JOIN country AS cn ON cl.countrycode = cn.code
LIMIT
	10;

-- inner join で Esperanto で結合
-- 'Esperanto' に一致する行だけが抽出される
SELECT
	cn.name AS 'CountryName',
	cl.*
FROM
	countrylanguage AS cl
	INNER JOIN country AS cn ON cl.countrycode = cn.code
WHERE
	cl.language = 'Esperanto';

-- left outer join で結合
SELECT
	cl.*,
	cn.name AS 'CountryName'
FROM
	countrylanguage AS cl
	LEFT OUTER JOIN country AS cn ON cl.countrycode = cn.code;

SELECT
	cl.*,
	cn.name AS 'CountryName'
FROM
	countrylanguage AS cl
	LEFT OUTER JOIN country AS cn ON cl.countrycode = cn.code
WHERE
	cl.language = 'Nazonogengo';

-- left outer join
SELECT
	cn.name,
	cl.*
FROM
	countrylanguage AS cl
	LEFT OUTER JOIN country AS cn ON cl.countrycode = cn.code
WHERE
	language = 'Japanese';

SELECT
	cl.*,
	cn.*
FROM
	countrylanguage AS cl
	LEFT OUTER JOIN country AS cn ON cl.countrycode = cn.code
WHERE
	language = 'Japanese';

-- SELECT
-- 	cl.*,
-- 	cn.*
-- FROM
-- 	countrylanguage AS cl
-- 	LEFT OUTER JOIN country AS cn ON cl.countrycode = cn.region
-- WHERE
-- 	language = 'Japanese'\G
SELECT
	cl.*,
	cn.*
FROM
	countrylanguage AS cl
	LEFT OUTER JOIN country AS cn ON cl.countrycode = cn.region
LIMIT
	10;

-- --------------------------------------------------
-- 無理やり LEFT OUTER JOIN の例を作る
-- --------------------------------------------------
INSERT INTO
	country (code, name, region)
VALUES
	('ZZZ', 'ZZZCountry', 'JPN');

SELECT
	cl.*,
	cn.name,
	cn.region
FROM
	countrylanguage AS cl
	LEFT OUTER JOIN country AS cn ON cl.countrycode = cn.region
WHERE
	cl.countrycode = 'USA'
	OR cl.countrycode = 'JPN';
