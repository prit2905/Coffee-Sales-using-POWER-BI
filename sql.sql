select * from coffee ;

--------------------------------------------------------------------------------------------------
-- Update the transaction_time format from string t
update coffee set transaction_time = str_to_date(transaction_time , '%H:%i:%s') ;
--------------------------------------------------------------------------------------------------
SET SQL_SAFE_UPDATES = 1;
describe coffee ;

--------------------------------------------------------------------------------------------------
-- To add total Sales column 
alter table coffee add column Total_sales double ;
update coffee set Total_sales = transaction_qty * unit_price ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- Total sales 

select 
	month(transaction_date) as monthh ,
    round(sum(transaction_qty * unit_price),2) as sales 
from coffee 
group by month(transaction_date);

--------------------------------------------------------------------------------------------------
-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
with cte as(
select 
	month(transaction_date) as monthh ,
    round(sum(total_sales),2) as sales ,
    lag(round(sum(total_sales),2),1,0) over(order by month(transaction_date)) as pm
from coffee
 group by month(transaction_date))
 select * , concat(round((sales-pm)/pm*100,2),"%") as MOM_inc_per  from cte ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- TOTAL ORDERS
select 
	month(transaction_date) as monthh , 
    count(transaction_id) as total_orders 
from coffee 
group by 1 ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
with cte as(
select 
	month(transaction_date) as monthh ,
    count(transaction_id) as total_orders ,
    lag(count(transaction_id),1,0) over(order by month(transaction_date)) as pm_orders
from coffee
 group by month(transaction_date))
 select * , concat(round((total_orders-pm_orders)/pm_orders*100,2),"%") as MOM_inc_per  from cte ;
 --------------------------------------------------------------------------------------------------
 
 --------------------------------------------------------------------------------------------------
-- TOTAL QUANTITY SOLD
select
	month(transaction_date) as mon , 
    sum(transaction_qty) as total_qty_sold 
from coffee 
group by 1 ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
with cte as(
select 
	month(transaction_date) as monthh ,
    sum(transaction_qty) as total_qty_sold ,
    lag(sum(transaction_qty),1,0) over(order by month(transaction_date)) as pm_qty_sold
from coffee
 group by month(transaction_date))
 select * , concat(round((total_qty_sold-pm_qty_sold)/pm_qty_sold*100,2),"%") as MOM_inc_per  from cte ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
select 
	round(sum(Total_sales),2) as total_sale , 
    count(transaction_id) as total_orders , 
    sum(transaction_qty) as total_qty_sold 
from coffee 
where transaction_date="2023-05-18" ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- DAILY SALES FOR MONTH SELECTED
with cte as(
select 
	day(transaction_date) as dayy , 
    round(sum(total_sales),2) as total_sale,
    round(avg(sum(Total_sales)) over(),2)  as avgg
from coffee 
where month(transaction_date) = 5 
group by day(transaction_date))
select * ,  case when Total_sale > avgg then "above_avg" else "below_sales" end as av from cte ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- SALES BY WEEKDAY / WEEKEND:
with cte as (
select 
	* , 
    case 
		when dayofweek(transaction_date) = 1 or dayofweek(transaction_date) = 7 
        then "weekend" 
        else "weekday" 
	end as daytype 
from coffee )
select daytype , round(sum(total_sales),2) as sales from cte group by 1 ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- SALES BY STORE LOCATION
select 
	store_location , 
    round(sum(total_sales),2) as sales 
from coffee 
where month(transaction_date) = 5 
group by 1 ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- SALES BY PRODUCT CATEGORY
select 
	product_category , 
    round(sum(total_sales),2) as sales 
from coffee 
where month(transaction_date) = 5 
group by 1 ;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- SALES BY PRODUCTS (TOP 10)
select 
	product_type , 
    round(sum(total_sales),2) as sales 
from coffee 
where month(transaction_date) = 5 
group by 1 
order by sales desc 
limit 10;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- SALES BY DAY | HOUR 
select 
	round(sum(Total_sales),2) as total_sale , 
    count(transaction_id) as total_orders , 
    sum(transaction_qty) as total_qty_sold 
from coffee 
where month(transaction_date)=5 and hour(transaction_time) = 8 and dayofweek(transaction_date)=3;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
select 
	hour(transaction_time) as hr , 
    round(sum(Total_sales),2) as sales 
from coffee 
where month(transaction_date)=5 
group by 1 
order by hr ;
--------------------------------------------------------------------------------------------------

