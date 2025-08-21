-- DATA CLEANING PROJECT

SELECT *
FROM layoffs;

-- STEPS 
-- 1. Remove Duplicate data where there are no primary ids or keys.
-- 2. Standardize the Data (sort of issues of the data like spellings,spaces etc.)
-- 3. Look at NULL/Blank values
-- 4. Remove columns that are unnecessary (but care in real workplace it sometimes isnt good to remove from raw data set)

-- Can implement a staging table incase we remove a neccessary column. So the original data can be there for backup.

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT*
FROM layoffs;

-- 1. Remove duplicate data
-- FINDING DUPLICATES

SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- The row_num that are not 1 are duplicates

-- Can double check with company  

SELECT*
FROM layoffs_staging
WHERE company = 'Casper';

-- Need to delete duplicates, cant delete from CTE since cant update a CTE, so have to generate a new table to delete it

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT*
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. Standardizing data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Variant words of the crypto industry can be problematic for EDA projects so need to update it to just one variant

SELECT*
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Checking for other anomalies of the columns

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- If we want to do time series, need to change date to date format as it is in text format in the raw data

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

-- Still shows as text for date column in schema, so can change data type but only on staging table.


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. NULL/Blanks values
 
 SELECT*
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL ;
 
 SELECT *
 FROM layoffs_staging2
 WHERE industry IS NULL
 OR industry = '';
 
 SELECT *
 FROM layoffs_staging2
 WHERE company = 'Airbnb';
 
 
 -- Filling in blanks with information that we find from other rows that should be in the rows that are blank/NULL
 
 UPDATE layoffs_staging2
 SET industry = NULL
 WHERE industry = '';
 
 SELECT*
 FROM layoffs_staging2 t1
 JOIN layoffs_staging2 t2
	ON t1.company = t2.company
 WHERE t1.company IS NULL 
 AND t2.industry IS NOT NULL ;
 
 
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.company = t2.company
WHERE t1.company IS NULL 
AND t2.industry IS NOT NULL;



-- DELETING unnecessary rows

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT*
FROM layoffs_staging2;


SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
                        percentage_laid_off, `date`, stage, country, funds_raised_millions
         ) AS row_num2
  FROM layoffs_staging2
) AS sub
WHERE row_num2 > 1;

ALTER TABLE layoffs_staging2 ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

DELETE FROM layoffs_staging2
WHERE id IN (
  SELECT id FROM (
    SELECT id,
           ROW_NUMBER() OVER (
             PARTITION BY company, location, industry, total_laid_off,
                          percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num2
    FROM layoffs_staging2
  ) AS ranked
  WHERE row_num2 > 1
);

ALTER TABLE layoffs_staging2 DROP COLUMN id;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT*
FROM layoffs_staging2;

