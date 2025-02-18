/* Check the data*/

SELECT top 5 * FROM Blinkit_data 

/* COUNT THE DATA*/

SELECT COUNT(*) FROM Blinkit_data

/* Data Cleansing : Item_Fat_Content column has an issue with wrong data points*/

UPDATE Blinkit_data
SET Item_Fat_Content =
CASE WHEN Item_Fat_Content IN ('LF','low fat') THEN 'Low Fat'
	WHEN Item_Fat_Content = 'reg' THEN 'Regular'
	ELSE Item_Fat_Content
	END

/* How do I know that they have been updated?*/

SELECT DISTINCT(Item_Fat_Content) FROM Blinkit_data

/* I would like to write some KPIs : Total sales (in millions)*/

SELECT CAST(SUM(Total_Sales/1000000) AS decimal(10,2)) AS Total_Grocery_Sales_Millions FROM Blinkit_data

/* KPIs : Average sales*/

SELECT CAST((AVG(Total_Sales)) AS decimal(10,0)) AS Average_sales FROM Blinkit_data

/* KPIs: Count the total items*/

SELECT COUNT(*) as num_of_items FROM Blinkit_data

/* I would like to find total sales for Low Fat*/

SELECT CAST(SUM(Total_Sales)/1000000 AS decimal(10,2)) AS Total_LowFat_sales_Millions FROM Blinkit_data WHERE Item_Fat_Content = 'Low Fat'

/* checking sales for number based column*/

SELECT CAST(SUM(Total_Sales)/1000000 AS decimal(10,2)) AS Total_2022_sales_Millions FROM Blinkit_data WHERE Outlet_Establishment_Year = 2022

/*Find the average rating*/

SELECT CAST(AVG(Rating) AS decimal(10,2))  as Average_rating FROM Blinkit_data

/* Granular analysis : Sales by Fat Content */

SELECT Item_Fat_Content, CAST(SUM(Total_sales) AS decimal(10,2)) as Total_Sales from Blinkit_data group by Item_Fat_Content Order by Total_Sales DESC;

/* Sales by Fat_Cotent */

SELECT Item_Fat_Content, CAST(SUM(Total_sales) AS decimal(10,2)) AS Total_Grocery_Sales,
						 CAST(AVG(Total_sales) AS decimal(10,2)) as Average_Sales,
						 CAST(AVG(Rating) AS decimal(10,2))  as Average_rating,
						 COUNT(*) as num_of_items
from Blinkit_data 
group by Item_Fat_Content Order by Total_Grocery_Sales DESC;

/* Lets say only for 2020 year*/

SELECT Item_Fat_Content, CONCAT(CAST(SUM(Total_sales)/1000 AS decimal(10,2)),'K') AS Total_Grocery_Sales,
						 CAST(AVG(Total_sales) AS decimal(10,2)) as Average_Sales,
						 CAST(AVG(Rating) AS decimal(10,2))  as Average_rating,
						 COUNT(*) as num_of_items
from Blinkit_data 
WHERE Outlet_Establishment_Year = 2020
group by Item_Fat_Content Order by Total_Grocery_Sales DESC;

/* Total sales by item type*/

SELECT Item_Type, CAST(SUM(Total_sales) AS decimal(10,2)) AS Total_Grocery_Sales,
						 CAST(AVG(Total_sales) AS decimal(10,2)) as Average_Sales,
						 CAST(AVG(Rating) AS decimal(10,2))  as Average_rating,
						 COUNT(*) as num_of_items
from Blinkit_data 
group by Item_Type Order by Total_Grocery_Sales DESC;

/*Slect only top 5 from above* note : Of bottom 5 then change order to asc*/

SELECT top 5 Item_Type, CAST(SUM(Total_sales) AS decimal(10,2)) AS Total_Grocery_Sales,
						 CAST(AVG(Total_sales) AS decimal(10,2)) as Average_Sales,
						 CAST(AVG(Rating) AS decimal(10,2))  as Average_rating,
						 COUNT(*) as num_of_items
from Blinkit_data 
group by Item_Type Order by Total_Grocery_Sales DESC;

/*fat content by outlet by total sales*/

SELECT Outlet_Location_Type, Item_Fat_Content, CAST(SUM(Total_sales) AS decimal(10,2)) AS Total_Grocery_Sales,
						 CAST(AVG(Total_sales) AS decimal(10,2)) as Average_Sales,
						 CAST(AVG(Rating) AS decimal(10,2))  as Average_rating,
						 COUNT(*) as num_of_items
from Blinkit_data 
group by Outlet_Location_Type , Item_Fat_Content Order by Total_Grocery_Sales DESC;

/* How can I pivot the output of the above table?*/

SELECT Outlet_Location_Type, 
       ISNULL([Low Fat], 0) AS Low_Fat, 
       ISNULL([Regular], 0) AS Regular
FROM 
(
    SELECT Outlet_Location_Type, Item_Fat_Content, 
           CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM Blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT 
(
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;


/*Total sales by outlet establishment*/

SELECT Outlet_Establishment_Year, CAST(SUM(Total_sales) AS decimal(10,2)) AS Total_Grocery_Sales,
						 CAST(AVG(Total_sales) AS decimal(10,2)) as Average_Sales,
						 CAST(AVG(Rating) AS decimal(10,2))  as Average_rating,
						 COUNT(*) as num_of_items
from Blinkit_data 
group by Outlet_Establishment_Year Order by Outlet_Establishment_Year;

/*Percentage of sales by outlet size*/

SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;	

/* Sales Percentage by Outlet size : This can be done using Window function*/

SELECT Outlet_Size , 
		 CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage

FROM Blinkit_data
GROUP BY Outlet_Size
ORDER BY Sales_Percentage DESC


/* OR I could write with the help of a subquery */

SELECT 
    Outlet_size,
    CONCAT(
        ROUND(SUM(total_sales) * 100.0 / (SELECT SUM(total_sales) FROM Blinkit_data), 2), 
        ' %'
    ) AS sales_percentage
FROM Blinkit_data
GROUP BY Outlet_size
ORDER BY SUM(total_sales) DESC;

/* Sales by Outlet Location type */

SELECT Outlet_Location_Type, CAST(SUM(Total_sales) AS decimal(10,2)) AS Total_Grocery_Sales,
						CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage,
						 CAST(AVG(Total_sales) AS decimal(10,2)) as Average_Sales,
						 CAST(AVG(Rating) AS decimal(10,2))  as Average_rating,
						 COUNT(*) as num_of_items
from Blinkit_data 
group by Outlet_Location_Type Order by Outlet_Location_Type ;

/* TRY all metrics with Outlet type*/
SELECT Outlet_Type, CAST(SUM(Total_sales) AS decimal(10,2)) AS Total_Grocery_Sales,
						CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage,
						 CAST(AVG(Total_sales) AS decimal(10,2)) as Average_Sales,
						 CAST(AVG(Rating) AS decimal(10,2))  as Average_rating,
						 COUNT(*) as num_of_items
from Blinkit_data 
group by Outlet_Type Order by Outlet_Type ;










































































