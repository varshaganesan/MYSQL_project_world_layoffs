-- PROJECT - World Layoffs - Exploratory Data Analysis
-- Exploring trends and patterns in global company layoffs to identify key insights
USE world_layoffs;
SELECT *
FROM layoffs_staging2;

-- 1. Find the maximum no. laid off in a single day
SELECT MAX(total_laid_off) AS max_layoff_num
FROM layoffs_staging2;
-- ANS : 12,000

-- 2. Find the maximum and minimum percentage laid off in a single day
SELECT MAX(percentage_laid_off) AS max_layoff_percent, MIN(percentage_laid_off) AS min_layoff_percent
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;
-- ANS : Max = 1 , MIN = 0

-- 3. Find the companies which laid of the most people with 100 percentage in a single day
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
-- ANS : company = Katerra , Percentage laid off = 1, total laid off in a single day = 2434

-- 4. Find the top 5 companies with the highest number of total_layoffs
SELECT company, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY sum_laid_off DESC
LIMIT 5;
-- ANS : Amazon with total sum of 18150 , Google, Meta, Salesforce and Microsoft

-- 5. Find the top 5 countries with the highest number of total_layoffs
SELECT country, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY sum_laid_off DESC
LIMIT 5;
-- ANS : USA , India , Netherlands , Sweden and Brazil. We can do the same to find out the most impacted industry which is consumer and reatil

-- 6. Looking at the number of total_layoffs by year. Shows progressive increase in the total layoffs year after year
SELECT YEAR(`date`) AS layoff_year, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging2
GROUP BY layoff_year
ORDER BY layoff_year;

-- 7. Identifying the progression of layoffs over month using rolling sum
WITH month_cte AS
	(SELECT SUBSTRING(`date`, 1,7) AS layoff_month, SUM(total_laid_off) AS sum_laid_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
    GROUP BY layoff_month
	ORDER BY layoff_month)
SELECT layoff_month, sum_laid_off , SUM(sum_laid_off) OVER (ORDER BY layoff_month ASC) AS rolling_total_layoffs
FROM month_cte
ORDER BY layoff_month ASC;

-- 8. Identifying the top 5 companies with highest number of layoffs every year and ranking them
WITH 
top_company_cte AS
	(SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS sum_laidoff
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)),
company_year_rank AS
	(SELECT company, years, sum_laidoff , 
    DENSE_RANK () OVER (PARTITION BY years ORDER BY sum_laidoff DESC) AS ranking
    FROM top_company_cte)
SELECT company, years, sum_laidoff , ranking
FROM company_year_rank
WHERE ranking <= 5 AND years IS NOT NULL
ORDER BY years ASC, sum_laidoff DESC;







