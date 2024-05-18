-- PROJECT - WORLD LAYOFFS, DATA CLEANING in MYSQL
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Objectives:
-- 1. Check and Remove any duplicates.
-- 2. Standardize data and fix errors
-- 3. Optimize null value usage.
-- 4. Remove any unnecessary columns and rows.

-- Creating the database
CREATE DATABASE world_layoffs;
USE world_layoffs;
SELECT *
FROM layoffs;

-- Creating a staging area for data preparation
CREATE TABLE layoffs_staging
LIKE layoffs;
INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- Removing Duplicates
-- Note: Since there are no unique identifiers, using ROW NUMBER to find duplicates
WITH duplicate_cte AS
	( SELECT *,
    ROW_NUMBER () OVER ( PARTITION BY company, location, industry, total_laid_off , 
    percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS row_num
    FROM layoffs_staging)
SELECT *
FROM duplicate_cte
WHERE row_num > 2;

-- Double checking by selecting an example from the results
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Cannot delete from update a cte, so creating an another staging table by copying create statement from clipboard
CREATE TABLE `layoffs_staging2`
( `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
  
  INSERT INTO layoffs_staging2
  	SELECT *,
    ROW_NUMBER () OVER ( PARTITION BY company, location, industry, total_laid_off , 
    percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS row_num
    FROM layoffs_staging;
    
    SELECT *
    FROM layoffs_staging2;
    
    -- Deleting the duplicates from the new table
    DELETE 
    FROM layoffs_staging2
    WHERE row_num > 1;
    
    SELECT *
    FROM layoffs_staging2
    WHERE row_num > 1;
    
-- 2. Standardize data and fix errors
SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY company;

-- Noticed unnecessary spaces and hence removing them
SELECT company , TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRiM(company);

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;
-- No errors in the above column

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER by industry;

-- Noticed same industry with different names and hence updating it to become uniform
UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- Noticed a error in the country name and hence updating it to become uniform
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Updating for other countries
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE '%.';

-- Updating the date column type from text to datetime
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date` , '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Optimize null value usage.
-- Populating industry values from other similar data
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL OR industry = ''
ORDER BY industry;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';

-- For example, we identified now that airbnb is a travel industry
-- Populating for other industries
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Doing a self join to update similar industries
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- 4. Remove any unnecessary columns and rows.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Deleting rows where both total laid off and percentage are null since it'll not be useful in the EDA process and cannot be populated 
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

-- Deleting the extra column we created earlier to remove duplicates
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoffs_staging2;



