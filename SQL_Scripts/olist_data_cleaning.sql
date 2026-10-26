select * from olist_geolocation_dataset;

delete from olist_sellers_dataset;
set sql_safe_updates = 0;


-- IMPORTING ALL THE 9 TABLES 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


select * from olist_products_dataset;
select count(*)
from olist_products_dataset;

-- IMPORTING OLIST PRODUCTS DATASET 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    product_category_name,
    @product_name_lenght,
    @product_description_lenght,
    @product_photos_qty,
    @product_weight_g,
    @product_length_cm,
    @product_height_cm,
    @product_width_cm
)
SET
    product_name_lenght = NULLIF(@product_name_lenght, ''),
    product_description_lenght = NULLIF(@product_description_lenght, ''),
    product_photos_qty = NULLIF(@product_photos_qty, ''),
    product_weight_g = NULLIF(@product_weight_g, ''),
    product_length_cm = NULLIF(@product_length_cm, ''),
    product_height_cm = NULLIF(@product_height_cm, ''),
    product_width_cm = NULLIF(@product_width_cm, '');
    ;
    
  
  -- IMPORTING OLIST SELLERS DATASET 
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist/olist_sellers_dataset.csv'
INTO TABLE olist_sellers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- SELECTING ALL 9 TABLES 

select * from olist_customers_dataset;
select * from olist_geolocation_dataset;
select * from olist_order_items_dataset;
select * from olist_order_payments_dataset;
select * from olist_order_reviews_dataset;
select * from olist_orders_dataset;
select * from olist_products_dataset;
select * from olist_sellers_dataset;
select * from product_category_name_translation;

-- cleaning for olist customer dataset 

alter table olist_customers_dataset
modify customer_zip_code_prefix int ;


-- cleaning for geolocation dataset 
select max(length(geolocation_city))
from 
olist_geolocation_dataset;

alter table olist_geolocation_dataset
modify geolocation_zip_code_prefix int,
modify geolocation_city varchar(40),
modify geolocation_state varchar(6);


-- cleaning for olist order items dataset 
select * from olist_order_items_dataset;
describe olist_order_items_dataset;

select 
max(length(order_id)),
max(length(product_id)),
max(length(seller_id))
from 
olist_order_items_dataset;

alter table olist_order_items_dataset
modify order_id varchar(35),
modify product_id varchar(35),
modify seller_id varchar(35);

-- cleaning olist order payments dataset 

select * from olist_order_payments_dataset;
describe olist_order_payments_dataset;

select max(length(order_id)),
max(length(payment_type))
from olist_order_payments_dataset;

alter table olist_order_payments_dataset
modify order_id varchar(35),
modify payment_type varchar(12);

-- CLEANING OLIST ORDER REVIEW DATASET 
select * from olist_order_reviews_dataset;
describe olist_order_reviews_dataset;

select 
max(length(review_id)),
max(length(order_id)),
max(length(review_comment_title))
from olist_order_reviews_dataset;

alter table olist_order_reviews_dataset
modify review_id varchar(32),
modify order_id varchar(33),
modify review_comment_title varchar(36),
modify review_creation_date date,
modify review_answer_timestamp time;

select * from olist_order_reviews_dataset
limit 99207, 1;

set sql_safe_updates = 0;
UPDATE olist_order_reviews_dataset
SET review_creation_date = NULL
WHERE review_creation_date = '`';

-- CLEANING OLIST ORDERS DATASET

select * from olist_orders_dataset;
describe olist_orders_dataset;

select 
max(length(order_id)),
max(length(customer_id)),
max(length(order_status))
from olist_orders_dataset;

alter table olist_orders_dataset
modify order_id varchar(33),
modify customer_id varchar(33),
modify order_status varchar(11),
modify order_purchase_timestamp datetime,
modify order_approved_at datetime,
modify order_delivered_carrier_date datetime,
modify order_delivered_customer_date datetime, 
modify order_estimated_delivery_date datetime;

-- CHANGING THE EMPTY COLUMNS TO NULL TO BE ABLE TO MODIFY THE OLIST_ORDERS DATASET TABLE TO DATETIME

update olist_orders_dataset
set
 order_approved_at =nullif(trim(order_approved_at),''),
 order_delivered_carrier_date = nullif(trim(order_delivered_carrier_date),''),
 order_delivered_customer_date = nullif(trim(order_delivered_customer_date),''),
 order_estimated_delivery_date = nullif(trim(order_estimated_delivery_date),'');
 
 -- CLEANING OLIST PRODUCTS DATASET
 
 select * from olist_products_dataset;
 describe olist_products_dataset;
 
select max(length(product_id)),
max(length(product_category_name))
from olist_products_dataset;

alter table olist_products_dataset
modify product_id varchar(33),
modify product_category_name varchar(47);

-- CLEANING OLIST SELLERS DATASETS

select * from olist_sellers_dataset;
describe olist_sellers_dataset;

select 
max(length(seller_id)),
max(length(seller_city)),
max(length(seller_state))
from  olist_sellers_dataset;

alter table olist_sellers_dataset
modify seller_id varchar(32),
modify seller_zip_code_prefix int,
modify seller_city varchar(40),
modify seller_state char(2);

-- CLEANING PRODUCT CATEGORY NAME TRANSLATION DATASET 
select * from product_category_name_translation;
describe product_category_name_translation;

-- Renaming column 
alter table product_category_name_translation
rename column ï»¿product_category_name to product_category_name;

select 
max(length(product_category_name)),
max(length(product_category_name_english))
from
product_category_name_translation;

alter table product_category_name_translation
modify product_category_name varchar(46),
modify product_category_name_english varchar(40);