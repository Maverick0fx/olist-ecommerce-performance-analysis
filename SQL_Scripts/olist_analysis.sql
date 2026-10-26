-- SELECTING ALL 9 TABLES 
delimiter // 
create procedure all_olist_tables()
begin
select * from olist_customers_dataset AS customers;
select * from olist_geolocation_dataset as geo;
select * from olist_order_items_dataset as order_items;
select * from olist_order_payments_dataset as order_payments;
select * from olist_order_reviews_dataset as order_reviews;
select * from olist_orders_dataset as orders;
select * from olist_products_dataset as products;
select * from olist_sellers_dataset as sellers;
select * from product_category_name_translation as translation;
end//
delimiter ;

-- TOTAL CUSTOMERS

select count(distinct customer_unique_id) as total_customers
from olist_customers_dataset;

-- TOTAL ORDERS 
select count(distinct order_id) as total_orders
from olist_orders_dataset;

-- TOTAL PRODUCTS
select count(distinct product_id) as total_products
from olist_products_dataset;

-- TOTAL SELLERS 
select count(distinct seller_id) as total_sellers
from olist_sellers_dataset;

-- TOTAL ITEMS SOLD
select count(order_item_id) as total_item_sold
from olist_order_items_dataset;

-- TOTAL REVENUE 

select concat(round(sum(price)/1000000,1),"M") as total_revenue
from olist_order_items_dataset;

-- TOTAL FREIGHT

select
concat(round(sum(freight_value)/1000000,1),"M") as total_freight
from olist_order_items_dataset;

-- TOTAL ORDER VALUE
select concat(round(sum(price+freight_value)/1000000,1),"M") as total_order_value
from olist_order_items_dataset;

-- AVG ORDER VALUE 
select round(sum(price+freight_value)/count(distinct order_id),1) as avg_order_value
from olist_order_items_dataset;

-- TOTAL ORDERS BY STATUS 
select 
order_status,
count(distinct order_id) total_orders
from 
olist_orders_dataset
group by order_status
order by total_orders;

-- REVENUE BY MONTH 

select 
round(sum(price),1) as total_revenue,
Year(order_purchase_timestamp) as `year`,
month(o.order_purchase_timestamp) as month_no,
monthname(o.order_purchase_timestamp) as month_name

from 
olist_orders_dataset as o
left join olist_order_items_dataset as oi
on o.order_id = oi.order_id
group by 
`year`,
month_no,
month_name
order by 
`year`,
month_no,
month_name;

call all_olist_tables();

-- ORDERS BY MONTH
select 
count(distinct order_id) as total_orders,
Year(order_purchase_timestamp) as `year`,
month(order_purchase_timestamp) as month_no,
monthname(order_purchase_timestamp) as month_name

from olist_orders_dataset
group by 
`year`,
month_no,
month_name
order by 
`year`,
month_no;

-- REVENUE BY PRODUCT CATEGORY 

select 
round(sum(price),1) as total_revenue,
coalesce(pc.product_category_name_english,p.product_category_name, 'Unknown') as product_category
from 
olist_order_items_dataset as oi
left join olist_products_dataset as p
on oi.product_id = p.product_id
left join product_category_name_translation as pc 
on p.product_category_name = pc.product_category_name
group by 
product_category 
order by 
total_revenue desc;

-- TOP 10 PRODUCTS CATEGORY BY REVENUE 

select 
row_number() over(order by sum(oi.price) desc) as num,
round(sum(oi.price),1) as total_revenue,
coalesce(pc.product_category_name_english,p.product_category_name, 'Unknown') as product_category
from 
olist_order_items_dataset as oi
left join olist_products_dataset as p
on oi.product_id = p.product_id
left join product_category_name_translation as pc 
on p.product_category_name = pc.product_category_name
group by 
product_category 
limit 10;

-- TOP 10 SELLER CITY BY REVENUE
call all_olist_tables();

select 
round(sum(price),1) as total_revenue,
s.seller_city
from olist_sellers_dataset as s
left join olist_order_items_dataset as oi
on s.seller_id = oi.seller_id
group by s.seller_city
order by total_revenue desc
limit 10;

-- SALES BY CUSTOMER STATE

select 
c.customer_state,
count(distinct o.order_id) as orders,
round(sum(oi.price),1) as revenue

from 
olist_customers_dataset as c
left join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join olist_order_items_dataset as oi 
on o.order_id = oi.order_id
group by c.customer_state
order by revenue desc;

-- PAYMENT ANALYSIS

--  PAYMENT METHOD ANALYSIS
select 
payment_type,
count(order_id) as transactions,
round(sum(payment_value),1) as payment_value
from olist_order_payments_dataset
group by payment_type
order by payment_value desc ;

-- PAYMENT INSTALLMENTS ANALYSIS
SELECT 
payment_installments,
count(order_id) as transactions,
round(sum(payment_value),1) as payment_value
from olist_order_payments_dataset
group by payment_installments
order by 
payment_installments,
payment_value desc ;

							-- DELIVERY OPERATIONS KPI

-- AVG APPROVAL TIME 
call all_olist_tables();

select 
round(
		avg(
			timestampdiff(hour, order_purchase_timestamp, order_approved_at)
    ),
    1)as avg_approval_hours
from olist_orders_dataset
where order_approved_at is not null;

-- AVG PROCESSING TIME 

select 
round(
		avg(
			timestampdiff(hour, order_approved_at, order_delivered_carrier_date)
    ),
    1)as avg_processing_hours
from olist_orders_dataset
where  order_approved_at is not null
and 
order_delivered_carrier_date is not null;

-- AVERAGE DELIVERY TIME 

select 
round(
		avg(
			timestampdiff(hour, order_delivered_carrier_date, order_delivered_customer_date)/24
    ),
    1)as avg_delivery_days
from olist_orders_dataset
where order_delivered_carrier_date is not null
and 
order_delivered_customer_date is not null;

-- AVG FULFILMENT TIME 
select
round(
		avg(
			timestampdiff(hour, order_purchase_timestamp, order_delivered_customer_date)/24
    ),
    1)as avg_fulfilment_days
from olist_orders_dataset
where order_purchase_timestamp is not null
and 
order_delivered_customer_date is not null;

-- DELIVERY TIME
call all_olist_tables();

select 
case when 
order_estimated_delivery_date >= order_delivered_customer_date 
then "Ontime"
when order_delivered_customer_date > order_estimated_delivery_date
then "Late" 
else "Unknown"
End as delivery_status,
count(distinct order_id) as orders

from 
olist_orders_dataset
where order_estimated_delivery_date is not null 
and 
order_delivered_customer_date is not null
group by delivery_status
order by
orders desc ;


-- ONTIME DELIVERY PERCENTAGE

select 
round(
100* sum(
		case when order_estimated_delivery_date >= order_delivered_customer_date 
		then 1
		else 0
		End)/	
	count(distinct order_id),
1) as ontime_delivery_percentage
from 
olist_orders_dataset
where order_estimated_delivery_date is not null 
and 
order_delivered_customer_date is not null;

call all_olist_tables();

-- DELIVERY VARIANCE DAYS

select
round(
	avg(
		datediff(order_delivered_customer_date,order_estimated_delivery_date)
	),1 
)as avg_delivery_variance_days
from olist_orders_dataset;


-- REPEAT CUSTOMERS

select count(total_orders) AS repeat_customers 

from 
(
select 
c.customer_unique_id,
count(distinct o.order_id) as total_orders
from olist_customers_dataset as c 
left join 
olist_orders_dataset as o 
on c.customer_id = o.customer_id
group by c.customer_unique_id
having total_orders > 1
order by total_orders desc) t
;

-- REPEAT CUSTOMERS RATE 


select count(total_orders)/
(
	select count(distinct customer_unique_id) from olist_customers_dataset
)*100 as repeat_customer_rate 

from 
(
select 
c.customer_unique_id,
count(distinct o.order_id) as total_orders
from olist_customers_dataset as c 
left join 
olist_orders_dataset as o 
on c.customer_id = o.customer_id
group by c.customer_unique_id
having total_orders > 1
order by total_orders desc) t
;

-- AVERAGE REVIEWS 
call all_olist_tables();

select 
avg(review_score) as avg_review
from olist_order_reviews_dataset
where review_score is not null;

-- REVIEWS BY SCORE
select
review_score,
count(review_score) as review_score
from olist_order_reviews_dataset
group by review_score
order by review_score desc;

-- REVIEWS BY CATEGORY 
call all_olist_tables();

select 
coalesce(pc.product_category_name_english, nullif(p.product_category_name,''), "unknown") as category,
avg(r.review_score) as avg_review
from 
olist_order_reviews_dataset as r
left join olist_order_items_dataset as oi
on r.order_id = oi.order_id
left join olist_products_dataset as p 
on oi.product_id = p.product_id
left join product_category_name_translation as pc
on p.product_category_name = pc.product_category_name
group by category
order by avg_review Desc;

select distinct p.product_category_name from 
 olist_products_dataset as p
 left join
 product_category_name_translation as pc 
 on p.product_category_name = pc.product_category_name
 where pc.product_category_name is null;
 
 SELECT
    @@hostname AS host,
    @@port AS port,
    USER() AS user,
    DATABASE() AS database_name;
