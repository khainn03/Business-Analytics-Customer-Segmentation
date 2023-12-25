-- Calculate overall statistics
#Total number of clients
SELECT COUNT(DISTINCT MemberAccountCode) AS total_no_clients
FROM transactions;

#Total sales
#All monetary calculations involve dividing by 23.360
#This is because the data is in Vietnamese Dong (VND) and the segmentation requirements is in USD. The exchange rate is 1 USD = 23.360 VND.
SELECT SUM(SalesAmt) / 23360 AS total_sales
FROM transactions;

#Total number of transactions
SELECT COUNT(DISTINCT Invoice) AS total_no_transactions
FROM transactions;

#Total number of items sold
SELECT SUM(SalesQty) AS total_items_sold
FROM transactions;

#Number of transactions with more than 2 items
SELECT COUNT(*)
FROM (SELECT Invoice, COUNT(ItemName) AS no_transactions
      FROM transactions
      GROUP BY Invoice
      HAVING COUNT(ItemName) >= 2) AS transactions_with_more_than_2_items;

#Average transaction value (ATV)
SELECT (SUM(SalesAmt)) / 23360 / COUNT(DISTINCT Invoice) AS atv
FROM transactions;

#Unit per transaction (UPT)
SELECT (SUM(SalesQty) / COUNT(DISTINCT Invoice)) AS upt
FROM transactions;

-- Categorize customers into segments based on their total revenue
#Segmentation table
SELECT MemberAccountCode,
       SUM(SalesAmt) / 23360 AS revenue,
       CASE
	   WHEN SUM(SalesAmt) / 23360 > 50000 THEN "Platinum"
	   WHEN SUM(SalesAmt) / 23360 BETWEEN 25000 AND 49999 THEN "Gold"
	   WHEN SUM(SalesAmt) / 23360 BETWEEN 10000 AND 24999 THEN "Silver"
	   WHEN SUM(SalesAmt) / 23360 BETWEEN 3000 AND 9999 THEN "Clienteling"
	   ELSE "Others" END AS 'Segmentation'
FROM transactions
GROUP BY MemberAccountCode;

-- Calculate statistics for each segment
# Total statistics
	# Total Statistics Header: Establishes the header for the summary table 'Total' by selecting the columns in desired order
	# Subquery A: Aggregates statistics for the 'Total' segment.
	# Subquery B: Counts total transactions with more than 2 items.
	# JOIN Operation: Joins the results of Subqueries A and B to create the 'Total' temporary table.
	# Result (Final Temporary Table 'Total'): The result is a temporary table named `Total` that includes a header row labeled 'Total' and corresponding statistics.
	#This modular approach is applied for other segmentations as well.
CREATE TEMPORARY TABLE Total AS (SELECT A.Segmentation,
					A.total_no_clients,
					A.total_sales,
					A.total_no_transactions,
					A.total_items_sold,
					B.no_transactions,
					A.atv,
					A.upt
				 FROM (SELECT 'Total'                                           AS Segmentation,
					      COUNT(DISTINCT MemberAccountCode)                 AS total_no_clients,
					      SUM(SalesAmt) / 23360                             AS total_sales,
					      COUNT(DISTINCT Invoice)                           AS total_no_transactions,
					      SUM(SalesQty)                                     AS total_items_sold,
					      (SUM(SalesAmt)) / 23360 / COUNT(DISTINCT Invoice) AS atv,
					      (SUM(SalesQty) / COUNT(DISTINCT Invoice))         AS upt
				       FROM transactions) AS A
					  JOIN (SELECT "Total" AS Segmentation, COUNT(*) AS no_transactions
						FROM (SELECT Invoice, COUNT(ItemName) AS no_items
						      FROM transactions
						      GROUP BY Invoice
						      HAVING COUNT(ItemName) >= 2) AS transactions_with_more_than_2_items) AS B
					       ON A.Segmentation = B.Segmentation);

# Platinum segment statistics
CREATE TEMPORARY TABLE Platinum AS (SELECT A.Segmentation,
					   A.total_no_clients,
					   A.total_sales,
					   A.total_no_transactions,
					   A.total_items_sold,
					   B.no_transactions,
					   A.atv,
					   A.upt
				    FROM (SELECT 'Platinum'                                        AS Segmentation,
						 COUNT(DISTINCT MemberAccountCode)                 AS total_no_clients,
						 SUM(SalesAmt) / 23360                             AS total_sales,
						 COUNT(DISTINCT Invoice)                           AS total_no_transactions,
						 SUM(SalesQty)                                     AS total_items_sold,
						 (SUM(SalesAmt)) / 23360 / COUNT(DISTINCT Invoice) AS atv,
						 (SUM(SalesQty) / COUNT(DISTINCT Invoice))         AS upt
					  FROM transactions
					  WHERE MemberAccountCode IN (SELECT MemberAccountCode
								      FROM transactions
								      GROUP BY MemberAccountCode
								      HAVING SUM(SalesAmt) / 23360 >= 50000)) AS A
					     JOIN (SELECT "Platinum" AS Segmentation, COUNT(*) AS no_transactions
						   FROM (SELECT Invoice, COUNT(ItemName) AS no_items
							 FROM transactions
							 WHERE MemberAccountCode IN (SELECT MemberAccountCode
										     FROM transactions
										     GROUP BY MemberAccountCode
										     HAVING SUM(SalesAmt) / 23360 >= 50000)
							 GROUP BY Invoice
							 HAVING COUNT(ItemName) >= 2) AS transactions_with_more_than_2_items) AS B
						  ON A.SEGMENTATION = B.SEGMENTATION);

# Gold segment statistics
CREATE TEMPORARY TABLE Gold AS (SELECT A.Segmentation,
				       A.total_no_clients,
				       A.total_sales,
				       A.total_no_transactions,
				       A.total_items_sold,
				       B.no_transactions,
				       A.atv,
				       A.upt
				FROM (SELECT 'Gold'                                            AS Segmentation,
					     COUNT(DISTINCT MemberAccountCode)                 AS total_no_clients,
					     SUM(SalesAmt) / 23360                             AS total_sales,
					     COUNT(DISTINCT Invoice)                           AS total_no_transactions,
					     SUM(SalesQty)                                     AS total_items_sold,
					     (SUM(SalesAmt)) / 23360 / COUNT(DISTINCT Invoice) AS atv,
					     (SUM(SalesQty) / COUNT(DISTINCT Invoice))         AS upt
				      FROM transactions
				      WHERE MemberAccountCode IN (SELECT MemberAccountCode
								  FROM transactions
								  GROUP BY MemberAccountCode
								  HAVING SUM(SalesAmt) / 23360 BETWEEN 25000 AND 49999)) AS A
					 JOIN (SELECT "Gold" AS Segmentation, COUNT(*) AS no_transactions
					       FROM (SELECT Invoice, COUNT(ItemName) AS no_items
						     FROM transactions
						     WHERE MemberAccountCode IN (SELECT MemberAccountCode
										 FROM transactions
										 GROUP BY MemberAccountCode
										 HAVING SUM(SalesAmt) / 23360 BETWEEN 25000 AND 49999)
						     GROUP BY Invoice
						     HAVING COUNT(ItemName) >= 2) AS transactions_with_more_than_2_items) AS B
					      ON A.SEGMENTATION = B.SEGMENTATION);

# Silver segment statistics
CREATE TEMPORARY TABLE Silver AS (SELECT A.Segmentation,
					 A.total_no_clients,
					 A.total_sales,
					 A.total_no_transactions,
					 A.total_items_sold,
					 B.no_transactions,
					 A.atv,
					 A.upt
				  FROM (SELECT 'Silver'                                          AS Segmentation,
					       COUNT(DISTINCT MemberAccountCode)                 AS total_no_clients,
					       SUM(SalesAmt) / 23360                             AS total_sales,
					       COUNT(DISTINCT Invoice)                           AS total_no_transactions,
					       SUM(SalesQty)                                     AS total_items_sold,
					       (SUM(SalesAmt)) / 23360 / COUNT(DISTINCT Invoice) AS atv,
					       (SUM(SalesQty) / COUNT(DISTINCT Invoice))         AS upt
					FROM transactions
					WHERE MemberAccountCode IN (SELECT MemberAccountCode
								    FROM transactions
								    GROUP BY MemberAccountCode
								    HAVING SUM(SalesAmt) / 23360 BETWEEN 10000 AND 24999)) AS A
					   JOIN (SELECT "Silver" AS Segmentation, COUNT(*) AS no_transactions
						 FROM (SELECT Invoice, COUNT(ItemName) AS no_items
						       FROM transactions
						       WHERE MemberAccountCode IN (SELECT MemberAccountCode
										   FROM transactions
										   GROUP BY MemberAccountCode
										   HAVING SUM(SalesAmt) / 23360 BETWEEN 10000 AND 24999)
						       GROUP BY Invoice
						       HAVING COUNT(ItemName) >= 2) AS transactions_with_more_than_2_items) AS B
						ON A.SEGMENTATION = B.SEGMENTATION);

# CT segment statistics
CREATE TEMPORARY TABLE CT AS (SELECT A.Segmentation,
				     A.total_no_clients,
				     A.total_sales,
				     A.total_no_transactions,
				     A.total_items_sold,
				     B.no_transactions,
				     A.atv,
				     A.upt
			      FROM (SELECT 'CT'                                              AS Segmentation,
					   COUNT(DISTINCT MemberAccountCode)                 AS total_no_clients,
					   SUM(SalesAmt) / 23360                             AS total_sales,
					   COUNT(DISTINCT Invoice)                           AS total_no_transactions,
					   SUM(SalesQty)                                     AS total_items_sold,
					   (SUM(SalesAmt)) / 23360 / COUNT(DISTINCT Invoice) AS atv,
					   (SUM(SalesQty) / COUNT(DISTINCT Invoice))         AS upt
				    FROM transactions
				    WHERE MemberAccountCode IN (SELECT MemberAccountCode
								FROM transactions
								GROUP BY MemberAccountCode
								HAVING SUM(SalesAmt) / 23360 BETWEEN 3000 AND 9999)) AS A
				       JOIN (SELECT "CT" AS Segmentation, COUNT(*) AS no_transactions
					     FROM (SELECT Invoice, COUNT(ItemName) AS no_items
						   FROM transactions
						   WHERE MemberAccountCode IN (SELECT MemberAccountCode
									       FROM transactions
									       GROUP BY MemberAccountCode
									       HAVING SUM(SalesAmt) / 23360 BETWEEN 3000 AND 9999)
						   GROUP BY Invoice
						   HAVING COUNT(ItemName) >= 2) AS transactions_with_more_than_2_items) AS B
					    ON A.SEGMENTATION = B.SEGMENTATION);

# Other segment statistics
CREATE TEMPORARY TABLE Others AS (SELECT A.Segmentation,
					 A.total_no_clients,
					 A.total_sales,
					 A.total_no_transactions,
					 A.total_items_sold,
					 B.no_transactions,
					 A.atv,
					 A.upt
				  FROM (SELECT 'Others'                                          AS Segmentation,
					       COUNT(DISTINCT MemberAccountCode)                 AS total_no_clients,
					       SUM(SalesAmt) / 23360                             AS total_sales,
					       COUNT(DISTINCT Invoice)                           AS total_no_transactions,
					       SUM(SalesQty)                                     AS total_items_sold,
					       (SUM(SalesAmt)) / 23360 / COUNT(DISTINCT Invoice) AS atv,
					       (SUM(SalesQty) / COUNT(DISTINCT Invoice))         AS upt
					FROM transactions
					WHERE MemberAccountCode IN (SELECT MemberAccountCode
								    FROM transactions
								    GROUP BY MemberAccountCode
								    HAVING SUM(SalesAmt) / 23360 < 3000)) AS A
					   JOIN (SELECT "Others" AS Segmentation, COUNT(*) AS no_transactions
						 FROM (SELECT Invoice, COUNT(ItemName) AS no_items
						       FROM transactions
						       WHERE MemberAccountCode IN (SELECT MemberAccountCode
										   FROM transactions
										   GROUP BY MemberAccountCode
										   HAVING SUM(SalesAmt) / 23360 < 3000)
						       GROUP BY Invoice
						       HAVING COUNT(ItemName) >= 2) AS transactions_with_more_than_2_items) AS B
						ON A.SEGMENTATION = B.SEGMENTATION);

# Combine the results of all segmentations and the total statistics into a final output table
SELECT *
FROM Total
UNION
SELECT *
FROM Platinum
UNION
SELECT *
FROM Gold
UNION
SELECT *
FROM Silver
UNION
SELECT *
FROM CT
UNION
SELECT *
FROM Others;


