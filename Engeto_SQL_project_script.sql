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
		c.avg_height, 
		c.calling_code, 
		c.capital_city, 
		c.continent, 
		c.currency_name, 
		c.religion, 
		c.currency_code, 
		c.domain_tld, 
		c.elevation, 
		c.north, south, 
		c.west, 
		c.east, 
		c.government_type, 
		c.independence_date, 
		c.iso_numeric, 
		c.landlocked, 
		c.life_expectancy, 
		c.national_symbol, 
		c.national_dish, 
		c.population_density, 
		c.population, 
		c.region_in_world, 
		c.surface_area, 
		c.yearly_average_temperature, 
		c.median_age_2018, 
		c.iso2, 
		c.iso3,
		e.`year`, 
		e.GDP, 
		e.gini, 
		e.taxes, 
		e.fertility, 
		e.mortaliy_under5
	FROM countries c
	LEFT JOIN economies e ON c.country = e.country
);


/*OTAZKA 1: Rostou v prubehu let mzdy ve vsech odvetvich, nebo v nekterych klesaji?*/

SELECT 
	payroll_value,
	industry_branch_code,
	industry_name,
	payroll_year
FROM t_tereza_trojanova_project_sql_primary_final tttpspf
WHERE value_type_code = '5958'
GROUP BY industry_branch_code, payroll_year 
ORDER BY industry_branch_code, payroll_year  
;


/*OTAZKA 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období 
 * v dostupných datech cen a mezd?*/


SELECT
	payroll_year AS 'year',
	payroll_value AS 'avg_salary', 
	price_value AS 'avg_selling price',
	round (payroll_value/price_value,2) AS 'max_amount',
	category_name 
FROM t_tereza_trojanova_project_sql_primary_final tttpspf
WHERE category_code IN (114201, 111301) 
	AND value_type_code IN (5958) 
	AND payroll_year IN (2006,2018)
GROUP BY category_code, payroll_year  
ORDER BY category_code, payroll_year
;


/*OTAZKA 3: Ktera kategorie potravin zdrazuje nejpomaleji 
 * (je u ni nejnizsi percentualni mezirocni narust)? 
*/




/*
OTAZKA 4: Existuje rok, ve kterem byl mezirocni narust cen potravin 
vyrazne vyssi nez rust mezd (vetsi nez 10 %)?*/

SELECT 
	x.*,
	ROUND ((average_selling_price-previous_year_avg_selling_price)/average_selling_price*100, 2) AS 'price_growth'
FROM (
	SELECT 
		payroll_year AS 'year', 
		price_value AS 'average_selling_price',
		LAG(price_value,1) OVER (
			ORDER BY payroll_year) AS 'previous_year_avg_selling_price' 
	FROM t_tereza_trojanova_project_sql_primary_final tttpspf
	GROUP BY payroll_year 
	ORDER BY payroll_year) x
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

