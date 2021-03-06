/*Primarni tabulka*/
CREATE TABLE t_tereza_trojanova_project_sql_primary_test (
	SELECT
		cp.value AS 'payroll_value',
		cp.value_type_code,
		cpvt.name AS 'value',
		cp.industry_branch_code,
		cpib.name AS 'industry_name',
		cp.payroll_year,
		cp.unit_code,
		cpu.name AS 'unit_name',	
		cpr.value AS 'price_value',
		cpr.category_code,
		cpc.name AS 'category_name'
	FROM czechia_payroll cp
	JOIN czechia_payroll_value_type cpvt ON cpvt.code = cp.value_type_code
	JOIN czechia_payroll_industry_branch cpib ON cpib.code = cp.industry_branch_code
	JOIN czechia_payroll_unit cpu ON cpu.code = cp.unit_code
	JOIN czechia_price cpr ON YEAR(cpr.date_from)= cp.payroll_year
	JOIN czechia_price_category cpc ON cpr.category_code = cpc.code
);


/*Tabulka dodatecnych informaci*/

CREATE TABLE t_tereza_trojanova_project_sql_secondary_final (
	SELECT
		c.country, 
		c.abbreviation, 
		e.`year`, 
		e.GDP, 
		e.gini
	FROM countries c
	LEFT JOIN economies e ON c.country = e.country
	WHERE e.`year` BETWEEN 2006 AND 2018
);


/*OTAZKA 1: Rostou v prubehu let mzdy ve vsech odvetvich, nebo v nekterych klesaji?*/

SELECT * FROM (
	SELECT 
		y.*, 
		ROUND ((salary - previous_year_salary)/salary*100,2) AS salary_growth
	FROM ( 
		SELECT 
			x.*,
			LAG(salary,1) OVER ( 
				ORDER BY industry_branch_code, year) AS previous_year_salary
		FROM ( 
			SELECT 
				payroll_year AS 'year',
				industry_branch_code,
				industry_name,
				payroll_value AS salary
			FROM t_tereza_trojanova_project_sql_primary_final tttpspf
			WHERE value_type_code = '5958'
			GROUP BY industry_branch_code, payroll_year 
			ORDER BY industry_branch_code, payroll_year) x) y) z
WHERE year != 2006
	AND salary_growth < 0
;


/*OTAZKA 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období 
 * v dostupných datech cen a mezd?*/


SELECT
	x.*,
	(avg_salary*12/avg_price) AS yearly_amount #vysledek, mnozstvi v kg/l za rok
FROM(
	SELECT
		payroll_year AS 'year', 
		AVG(payroll_value) AS avg_salary,
		category_name, 
		AVG(price_value) AS avg_price
	FROM t_tereza_trojanova_project_sql_primary_final tttpspf
	WHERE value_type_code = 5958	#prumerna hruba mzda
		AND payroll_value IS NOT NULL 
		AND category_code IN (114201, 111301) #mleko a chleb
		AND payroll_year IN (2006, 2018) #prvni a posledni srovnatelne obdobi
	GROUP BY payroll_year, category_code
	ORDER BY payroll_year, category_code) x
;


/*OTAZKA 3: Ktera kategorie potravin zdrazuje nejpomaleji 
 * (je u ni nejnizsi percentualni mezirocni narust)? 
*/

CREATE TABLE t_ukol_3 AS SELECT
	tt.category_name,
	tt.category_code, 
	tt.payroll_year AS 'year', 
	tt.price_value AS ppu, 			#ppu = price per unit
	cpc.price_value AS amount,
	cpc.price_unit AS unit
FROM t_tereza_trojanova_project_sql_primary_final tt
JOIN czechia_price_category cpc 
	ON cpc.code = tt.category_code 
GROUP BY category_code, payroll_year  
ORDER BY category_code, payroll_year
;


SELECT z.* 
FROM (
	SELECT 
		y.*,
		AVG (price_growth) OVER (PARTITION BY category_name) AS avg_price_growth
	FROM (
		SELECT 
			x.*,
			ROUND ((ppu-previous_year_ppu)/ppu*100,2) AS price_growth
		FROM (
			SELECT 
				category_name,
				year,
				amount,
				unit,
				ppu, 
				LAG(ppu, 1) OVER (
					ORDER BY category_name, year) AS previous_year_ppu  
			FROM t_ukol_3) x
			WHERE year != 2006) y
	GROUP BY category_name
	ORDER BY avg_price_growth) z
WHERE avg_price_growth>0
; 





/*
OTAZKA 4: Existuje rok, ve kterem byl mezirocni narust cen potravin 
vyrazne vyssi nez rust mezd (vetsi nez 10 %)?*/

SELECT 
	z.*,
	ROUND((previous_year_avg_selling_price-avg_selling_price)/avg_selling_price*100,2) AS price_growth  
FROM ( 
	SELECT 
		y.*,
		LAG(avg_selling_price,1) OVER (
			ORDER BY year) AS 'previous_year_avg_selling_price' 
	FROM ( 
		SELECT 
				x.*
			FROM (
				SELECT 
					payroll_year AS 'year', 
					ROUND(AVG(price_value) OVER (PARTITION BY payroll_year),2) AS 'avg_selling_price'
				FROM t_tereza_trojanova_project_sql_primary_final tttpspf
				ORDER BY payroll_year) x) y) z
			GROUP BY year
			ORDER BY price_growth DESC
;	

/*OTAZKA 5: Ma vyska HDP vliv na zmeny ve mzdach a cenach potravin? Neboli, pokud HDP vzroste vyrazneji v jednom roce, 
projevi se to na cenach potravin ci mzdach ve stejnem nebo nasledujicim roce vyraznejsim rustem?*/

/*a) Mezirocni narust HDP serazeny od nejvetsiho po nejmensi*/

SELECT 
	x.*,
	ROUND((GDP - previous_year_GDP)/previous_year_GDP*100, 2) AS 'growth_rate'  
FROM 
(SELECT 
	`year`, 
	GDP,
	LAG(GDP,1) OVER ( 
		ORDER BY `year`) AS 'previous_year_GDP'	 
FROM t_tereza_trojanova_project_sql_secondary_final tttpssf
WHERE abbreviation = 'CZ' AND year >= 2006
ORDER BY `year`) x 
ORDER BY growth_rate DESC
;


/*b) Průměrné mzdy a ceny potravin v jednotlivých letech*/

SELECT 
	payroll_year as "year", 
	price_value as "average_selling_price",
	payroll_value as "average_salary" 
FROM t_tereza_trojanova_project_sql_primary_final tttpspf
WHERE value_type_code in (5958) 
GROUP BY payroll_year 
ORDER BY payroll_year ASC
; 
