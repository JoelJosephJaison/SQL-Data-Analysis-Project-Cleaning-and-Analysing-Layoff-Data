**SQL Data Analysis Project: Cleaning and Analysing Layoff Data**

**Introduction**

This project involves cleaning and analyzing a dataset containing layoff data using SQL. The main goals are to ensure data integrity, remove inconsistencies, handle missing values, and perform exploratory data analysis (EDA) to uncover patterns and insights within the dataset.

**Project Structure:**

**SQL Script:**

**Layoff_Analysis_Project.sql:** This is the primary script containing all the SQL commands for the project. It covers the entire process from data cleaning to exploratory data analysis.

**Data Cleaning Process**

1. **Remove Duplicates**: Duplicate entries were identified using a Common Table Expression (CTE) and removed to ensure unique records.
2. **Standardize Data**:
    - Whitespace was trimmed.
    - Industry and country names were standardized.
    - Dates were converted to a consistent format.
3. **Handle Null Values**:
    - Industry values were filled based on other entries from the same company.
    - Records with missing layoff data were removed.
4. **Remove Unnecessary Columns**: Temporary columns used during cleaning were dropped to finalize the dataset.

**Exploratory Data Analysis (EDA)**

The EDA phase includes several analyses:

- **Aggregate Analysis**: Identifies the maximum layoffs by company in absolute and percentage terms.
- **Company-Specific Analysis**: Ranks companies by the total number of layoffs.
- **Industry and Country Analysis**: Aggregates layoffs by industry and country to identify which sectors and regions were most affected.
- **Time-Based Analysis**: Tracks layoffs over time to spot trends and patterns.
- **Top Companies by Year**: Identifies the top 5 companies with the highest layoffs each year.

**Requirements**

- SQL Server or any SQL-compatible environment for running the provided scripts.
- A dataset containing layoff data in a tabular format.

**How to Use**

1. Clone or download the repository containing the SQL scripts.
2. Import the dataset into your SQL environment.
3. Run the scripts in the order provided to clean the data and perform analysis.
4. Review the output of each script to verify the results and insights.

**Conclusion**

This project showcases a comprehensive approach to cleaning and analysing layoff data using SQL. The steps outlined ensure that the data is reliable and provides meaningful insights into the patterns and trends within the dataset.
