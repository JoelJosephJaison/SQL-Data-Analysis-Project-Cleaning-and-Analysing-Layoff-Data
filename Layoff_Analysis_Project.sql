SELECT * FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT * FROM layoffs_staging;


-- 1. REMOVE DUPLICATES 
WITH duplicate_cte as 
(
SELECT *, row_number() OVER(
Partition by company, location,industry, total_laid_off,
 percentage_laid_off,`date`,stage,country,funds_raised_millions)
 as row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num >1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT *, row_number() OVER(
Partition by company, location,industry, total_laid_off,
 percentage_laid_off,`date`,stage,country,funds_raised_millions)
 as row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
WHERE row_num >1;

DELETE FROM layoffs_staging2
WHERE row_num >1;


-- 2. Standarize the Data

## Finding issues and noticing it 
# TRIM TAKES THE white sapces 
select company, (TRIM(company))
FROM layoffs_staging2 ;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT  Distinct Industry
FROM layoffs_staging2
ORDER BY 1;

# HEre we saw that cryto, crytocurrency were all same

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

# HERE US is repeated twice 

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

# date to different sections

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. NUll Values or Blank Values

# first I am checkig the laidoff part 

select * FROM layoffs_staging2
WHERE total_laid_off IS NULL; 

#THERE IS TOO MUCH NULL SPACES 
# BUT THERE IS SOMETHING NULL IN INDUSTRY 

select * from layoffs_staging2
WHERE industry IS NULL OR Industry = '';

select * from layoffs_staging2
WHERE company = 'Airbnb';

# NOW here when I look at AIrbnb I see two rows of data 
#and in one of the row is mentioned that the Industry is Travel 
# so it is possible to put travel as a Industry for the null values

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

select * from layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
		On t1.company = t2.company
        AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
		On t1.company = t2.company
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

select * from layoffs_staging2
WHERE company = 'Airbnb';

# here we see that we have fixed the issue with airbnb and other ones as well

select * from layoffs_staging2
WHERE industry IS NULL OR Industry = '';

# after running this we see that Bally's Interactive is this null
select * from layoffs_staging2
WHERE company LIKE 'Bally%';

# after this we see that there is only one row so basically we can not use industry from a duplicate there 

SELECT * 
FROM layoffs_staging2;


# Now lets move to the laid off part 

select * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Now the essence of this data is basically to be able to clean the data 
#so that it can be used for EDA and data modelling in the future
# BUT we see that the idea of the dataset is the laid_off itself 
# so if we are not able to populate it then it is not very helpful 
# so we have to delete these rows 

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- 4. Remove any columns that is unnecessary

# FINALLY WE HAVE TO DROP THE ROW_NUM column
#because we used it for data cleaning  
select * from layoffs_staging2;

ALTER TABLE layoffs_staging2 
DROP COLUMN row_num;

-- EDA process

SELECT * FROM layoffs_staging2;

SELECT MAX(total_laid_off), max(percentage_laid_off) FROM layoffs_staging2;

SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT company, sum(total_laid_off) FROM layoffs_staging2
GROUP BY company
ORDER by 2 DESc;

SELECT MIN(`date`), max(`date`) FROM layoffs_staging2;

SELECT industry,sum(total_laid_off) FROM layoffs_staging2
GROUP BY industry
ORDER by 2 DESc;

SELECT country,sum(total_laid_off) FROM layoffs_staging2
GROUP BY country
ORDER by 2 DESc;

SELECT Year(`date`),sum(total_laid_off) FROM layoffs_staging2
GROUP BY year(`date`)
ORDER by 1 DESc;

SELECT stage,sum(total_laid_off) FROM layoffs_staging2
GROUP BY stage
ORDER by 2 DESc;

SELECT substring(`date`,1,7) as `month`, sum(total_laid_off) FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER by 1 ;

WITH rolling_total as
(
SELECT substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER by 1 
)
SELECT `MONTH`,total_off,
 SUM(total_off) OVER(ORDER BY `MONTH`) as rolling_totals
FROM rolling_total;

#from previous code
SELECT country,sum(total_laid_off) FROM layoffs_staging2
GROUP BY country
ORDER by 2 DESc;

SELECT company, YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
ORDER BY 3 DESC;

WITH company_year(company,years, total_laid_off) as 
(
SELECT company, YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
), company_year_rank as
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) as rank_1
from company_year
WHERE years IS NOT NULL
)
SELECT * from company_year_rank
where rank_1 <= 5;

