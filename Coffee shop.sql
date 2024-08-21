use coffee_sales;

Select * from coffee_shop_sales;

#DATA CLEANING

Describe coffee_shop_sales;

set sql_safe_updates = 0;

update coffee_shop_sales
set transaction_date = str_to_date(transaction_date, '%m/%d/%Y');

Alter Table coffee_shop_sales
modify column `transaction_date` DATE;

update coffee_shop_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

Alter Table coffee_shop_sales
modify column `transaction_time` time;

#TOTAL SALES ANALYSIS

select concat("$",(Round(sum(transaction_qty * unit_price)))/1000,"K") as Total_Sales
from coffee_shop_sales
where month(transaction_date) = 5;
      
SELECT  
      month(transaction_date) as month, ---- AS NUMBER OF MONTH
      round(sum(transaction_qty * unit_price)) as total_sales, 
      (sum(transaction_qty * unit_price) - lag(sum(transaction_qty * unit_price) , 1)      
      over (order by month(transaction_date))) / lag(sum(transaction_qty * unit_price) , 1) 
      over(order by month(transaction_date)) * 100 as mom_increase_percentage
      from coffee_shop_sales
      where month(transaction_date) in (4,5)
      group by month(transaction_date)
      order by month(transaction_date);
      
      
#Total ORDERS ANALYSIS

      select concat("$", (round(count(transaction_id))), "K") as total_orders 
      from coffee_shop_sales
      where month(transaction_date) = 5;
      
SELECT  
      month(transaction_date) as month, ---- AS NUMBER OF MONTH
      round(count(transaction_id)) as total_orders, 
      (count(transaction_id) - lag(count(transaction_id) , 1)      
      over (order by month(transaction_date))) / lag(count(transaction_id) , 1) 
      over(order by month(transaction_date)) * 100 as mom_increase_percentage
      from coffee_shop_sales
      where month(transaction_date) in (4,5)
      group by month(transaction_date)
      order by month(transaction_date);

#TOTAL QUANTITY ANALYSIS

select concat("$",(round(sum(transaction_qty))),"k") as total_qty
from coffee_shop_sales
where month(transaction_date) = 5;

select 
	month(transaction_date) as month,
    round(sum(transaction_qty)) as total_qty,
    (sum(transaction_qty) - lag(sum(transaction_qty),1)
    over (order by month(transaction_date))) / lag(sum(transaction_qty),1)
    over (order by month(transaction_date)) * 100 as mom_increase_percentage
    from coffee_shop_sales
    where month(transaction_date) in (4,5)
    group by month(transaction_date)
    order by month(transaction_date);
    
    
select
    concat("$",round(sum(transaction_qty * unit_price)/1000,1) , "k") as total_sales,
    concat("$",round(count(transaction_id)/1000,1), "k") as total_orders,
    concat("$",round(sum(transaction_qty)/1000,1), "k") as total_qty_sold
    from coffee_shop_sales
    where transaction_date = '2023_05_18';
    
# Sales ANALYSIS BY WEEKDAY AND WEEKEND
# weekend = sat,sun
# weekdays = mon to fri
# sun = 1
# mon = 2

select 
      case when dayofweek(transaction_date) in (1,7) then 'Weekend'
      else 'Weekday'
      end as day_type,
      concat("$",round(sum(transaction_qty * unit_price)/1000,1),'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by 
      case when dayofweek(transaction_date) in (1,7) then 'Weekend'
      else 'Weekday'
      end;

#SALES ANALYSIS BY STORE LOCATION

select 
store_location, concat('$',round(sum(transaction_qty * unit_price)/1000,1),'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by store_location
order by sum(transaction_qty * unit_price) desc;

#DAILY SALES ANALYSIS WITH AVERAGE LINE

select avg(total_sales) as avg_sales
from
	(
    select concat('$',round(sum(transaction_qty * unit_price)/1000,1),'k') as total_sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by transaction_date
    ) as inner_query;
    
select 
	day(transaction_date) as day_of_month,
    concat('$',round(sum(transaction_qty * unit_price)/1000,1),'k') as total_sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by day(transaction_date)
    order by day(transaction_date);
    
select day_of_month,
	case
		when total_sales> avg_sales then 'Above Average'
        when total_sales<avg_sales then 'Below Average'
        else 'equal to average'
        end as 'sales_status',
        total_sales
        from (
        select day(transaction_date) as day_of_month,
        concat(sum(transaction_qty * unit_price)) as total_sales,
        avg(sum(transaction_qty * unit_price)) over() as avg_sales
        from coffee_shop_sales
        where month(transaction_date) = 5
        group by day(transaction_date) )as sales_data
        order by day_of_month;

#SALES ANALYSIS BY PRODUCT CATEGORY

select product_category, concat('$',round(sum(transaction_qty * unit_price)/1000,1),'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_category
order by sum(transaction_qty * unit_price) desc;

#TOP 10 PRODUCTS BY SALES

select product_type, concat('$',round(sum(transaction_qty * unit_price)/1000,1),'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_type
order by sum(transaction_qty * unit_price) desc
limit 10;

#DAIlY SALES ANALYSIS BY HOUR AND DAY_NAME

select 
    round(sum(transaction_qty * unit_price)) as total_sales,
    count(transaction_id) as total_orders,
    sum(transaction_qty)as total_qty_sold
    from coffee_shop_sales
    where month(transaction_date) = 5 and dayofweek(transaction_date) = 2 and hour(transaction_time) = 8;
    
    select 
    hour(transaction_time) as hour,
    round(sum(transaction_qty * unit_price)) as total_sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by hour(transaction_time)
    order by hour(transaction_time);
    
    Select 
    case 
    when dayofweek(transaction_date) = 2 then 'Monday'
    when dayofweek(transaction_date) = 3 then 'Tuesday'
    when dayofweek(transaction_date) = 4 then 'Wednesday'
    when dayofweek(transaction_date) = 5 then 'Thursday'
    when dayofweek(transaction_date) = 6 then 'Friday'
    when dayofweek(transaction_date) = 7 then 'Saturday'
    else 'Sunday'
    end as Day_of_Week,
    round(sum(transaction_qty * unit_price)) as total_sales 
    from 
    coffee_shop_sales
 where month(transaction_date) = 5
 group by 
     case 
    when dayofweek(transaction_date) = 2 then 'Monday'
    when dayofweek(transaction_date) = 3 then 'Tuesday'
    when dayofweek(transaction_date) = 4 then 'Wednesday'
    when dayofweek(transaction_date) = 5 then 'Thursday'
    when dayofweek(transaction_date) = 6 then 'Friday'
    when dayofweek(transaction_date) = 7 then 'Saturday'
    else 'Sunday'
    end;