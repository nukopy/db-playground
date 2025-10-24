-- ==================================================
-- 6-2 データの集約
-- ==================================================
SELECT
	district AS '都道府県',
	COUNT(*) AS '都市数',
	SUM(population) AS '合計人口'
FROM
	city
WHERE
	countrycode = 'JPN'
GROUP BY
	district
HAVING
	SUM(population) >= 1000000
ORDER BY
	SUM(population) DESC;
