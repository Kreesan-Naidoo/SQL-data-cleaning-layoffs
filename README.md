# SQL Data Cleaning - Global layoffs (2020 -2023)

--Project Overview\
This project demonstrates end-to-end data cleaning using MySQL on a real-world dataset tracking company layoffs globally between 2020 and 2023. The goal was to transform a messy, raw dataset into a clean, analysis-ready table by systematically identifying and resolving data quality issues.

-- Tools Used

MySQL — data cleaning and transformation\
SQL techniques — CTEs, Window Functions, ROW_NUMBER(), JOINs, STR_TO_DATE(), ALTER TABLE


-- Dataset

Source: Kaggle — Layoffs Dataset\
Records: Global company layoffs across multiple industries and countries\
Period covered: 2020 – 2023\
Key fields: Company, Location, Industry, Total Laid Off, Percentage Laid Off, Date, Stage, Country, Funds Raised


-- Data Cleaning Steps
1. Created a Staging Table
A staging table (layoffs_staging) was created as a copy of the raw data to preserve the original dataset and allow safe manipulation throughout the cleaning process.
2. Removed Duplicate Records
Used ROW_NUMBER() with PARTITION BY across all relevant columns to identify and remove exact duplicate rows. Since there were no primary keys in the raw data, this window function approach was required to flag duplicates before deletion.

3. Standardised Data

Trimmed leading/trailing whitespace from the company column using TRIM()
Standardised industry naming — multiple variations of "Crypto" (e.g. "Crypto Currency", "CryptoCurrency") were unified to a single value
Cleaned inconsistent country entries (e.g. "United States." → "United States")
Converted the date column from TEXT format to proper DATE format using STR_TO_DATE() and ALTER TABLE

4. Handled NULL and Blank Values

Identified rows with NULL or blank industry values
Used a self-JOIN to populate missing industry values where the same company appeared in other rows with a valid industry — avoiding unnecessary data loss
Deleted rows where both total_laid_off and percentage_laid_off were NULL, as these records provided no analytical value

5. Removed Unnecessary Columns

Dropped the row_num helper column after duplicate removal was complete


-- Related Project\
This cleaned dataset was then used for Exploratory Data Analysis (EDA) to uncover layoff trends across industries and time periods.\
View the EDA project : SQL-exploratory-data-analysis
