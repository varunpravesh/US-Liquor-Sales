# US Liquor Sales Analysis

## Project Overview
This project involves high-level analysis of 20 million rows of liquor sales data across the United States. The data was stored in Amazon S3, cleaned and standardized using Snowflake, 
and then visualized through Power BI for insights.

## Steps Involved

### Data Storage
- The first step is to upload the sales dataset into an S3 bucket.
- You can either upload the entire file at once or split it into smaller chunks—ideally around 200–250MB each for optimal Snowflake performance. Breaking the file into multiple parts
  enables parallel processing, significantly improving both upload speed and data processing efficiency.

### Data Processing
- To perform any processing in Snowflake, the data must first be loaded from its storage location—in this case, Amazon S3.
- Start by creating a new database or using an existing one, and define a table with appropriate column names and data types.
- After creating the table, all thats left is to bring in the data from S3 bucket. To read data from an S3 bucket, the security and access management policies on the bucket must allow Snowflake to access the bucket.
  Configure an AWS IAM user with the required permissions to access your S3 bucket. This one-time setup involves establishing access permissions on a bucket and associating the required permissions with an IAM user.
  You can then access an external (i.e. S3) stage that points to the bucket with the AWS key and secret key.
- Once the data is successfully imported into the table we've previously created, the next step would be to clean and standardize the data making it ready for analysis.

### Data Analysis
- The final step involves bringing the data into Power BI for analysis. To avoid generating a large .pbix file, it's recommended to connect using DirectQuery mode instead of Import mode.
- With DirectQuery, Power Query's cleaning and transformation options are quite limited. To minimize errors and ensure smooth performance, it's best to handle all data cleaning and transformations beforehand
  in the database (in this case, Snowflake).
- If your analysis involves complex date/time functions, consider creating a dedicated Date table within the database itself and then importing it into Power BI.

<hr style="height: 5px; border: none; background-color: #333;" />

See how to split the dataset into smaller chunks [Python Script](split_files.py).<br>
Creating table and connceting to S3 bucket [SQL Workbook](<LiquorTable Creation.sql>)<br>
Cleaning and standardizing the data [SQL Workbook](<LiquorTable DataStandardization.sql>)<br>

Download the dataset here [Dataset](https://www.kaggle.com/datasets/residentmario/iowa-liquor-sales/data)


