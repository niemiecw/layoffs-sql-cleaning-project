select*
from layoffs;

create table layoffs_staging
like layoffs;

select*
from layoffs_staging;

insert layoffs_staging
select * 
from layoffs;

-- Remove duplicats

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

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


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- Standardizing data

SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = trim(company); 

SELECT distinct industry
FROM layoffs_staging2;


UPDATE layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

SELECT distinct country, trim(trailing '.' from country)
FROM layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

SELECT `date`
FROM layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;


SELECT *
FROM layoffs_staging2
where total_laid_off is NULL
and percentage_laid_off is NULL;

update layoffs_staging2
set industry = null
where industry = '';


SELECT *
FROM layoffs_staging2
where industry is NULL
or industry = '';

SELECT *
FROM layoffs_staging2
where company = 'Airbnb';


SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
  AND t1.location = t2.location
WHERE (t1.industry IS NULL or t1.industry = '')
  AND t2.industry IS NOT NULL;


update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
WHERE t1.industry IS NULL 
  AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2;

DELETE
FROM layoffs_staging2
where total_laid_off is NULL
and percentage_laid_off is NULL;

alter table layoffs_staging2
drop column row_num;
