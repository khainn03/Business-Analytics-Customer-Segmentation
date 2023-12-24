# Business Analytics and Customer Segmentation

## Overview
This repository contains SQL scripts aimed at analyzing critical statistics of a business, with a specific focus on customer segmentation. The goal is to provide a clear and organized summary of key business metrics and segment customers based on their purchasing behavior.

## Key Features
- Overall Statistics: Calculates overall statistics for the entire dataset, including the total number of clients, sales, transactions, and items sold.
  + Average Transaction Value (ATV) and Units per Transaction (UPT): Computes the average transaction value and units per transaction.
  + Number of Transactions with More than 2 Items: Identifies transactions with more than two items.
- Segmentation: Segments customers into different categories based on their total revenue, such as Platinum, Gold, Silver, Clienteling, and Others.
- Currency Conversion: Note that the dataset is in VND (Vietnamese Dong) currency. To align with segmentation requirements in USD currency, all monetary calculations involve dividing by 23.360.


## Script Structure
The SQL script is structured as follows:
- Total Statistics Section: Computes overall statistics for the dataset.
- Segmentation Table: Categorizes customers into different segments based on their total revenue.
- Total Amounts: Creates temporary tables for total statistics.
- Segment-Specific Temporary Tables: Creates temporary tables for each customer segment (Platinum, Gold, Silver, Clienteling, Others).
- Final Result: Combines the results for each segment into a final output table.


## Excel Output
An Excel spreadsheet showcasing the desired output view of the SQL script has been uploaded to the repository. You can download it here https://github.com/khainn03/Business-Analytics-Customer-Segmentation/blob/main/Test-Assesment.xlsx




