/*Primární tabulka*/
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


/*Tabulka dodateèných informací*/

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


/*Rostou v prùbìhu let mzdy ve všech odvìtvích, nebo v nìkterých klesají?*/

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



/*Kolik je možné si koupit litrù mléka a kilogramù chleba za první a poslední srovnatelné období 
 * v dostupných datech cen a mezd?*/

SELECT *
FROM t_tereza_trojanova_project_sql_primary_final tttpspf
WHERE category_code IN (114201, 111301)
ORDER BY category_code DESC
;


















