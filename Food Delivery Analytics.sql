-- SQL Project: Food Delivery Analytics

create database food_delivery_db;
use food_delivery_db;

create table customers (
	customer_id int primary key,
    customer_name varchar(100),
    city varchar(50),
    signup_date date
);

create table restaurants (
	restaurant_id int primary key,
    restaurant_name varchar(100),
    cuisine varchar(50),
    city varchar(50),
    rating decimal(3, 2)
    );
    
create table delivery_partners (
	d_partner_id int primary key,
    d_partner_name varchar(100),
    vehicle_type varchar(30)
    );
    
create table orders (
	order_id int primary key,
    customer_id int,
    restaurant_id int,
    d_partner_id int,
    order_date timestamp,
    delivery_times_minutes int,
    order_amount decimal(10, 2),
    foreign key (customer_id) references customers (customer_id),
    foreign key (restaurant_id) references restaurants (restaurant_id),
    foreign key (d_partner_id) references delivery_partners (d_partner_id)
    );
    
insert into customers
values	(1, 'Deep Saha', 'Kolkata', '2026-04-18'),
		(2, 'Arittra Samanta', 'Chuchura', '2026-04-18'),
        (3, 'Anjali Prasad', 'Bandel', '2026-04-23'),
        (4, 'Shanku Bag', 'Chuchura', '2026-04-30'),
        (5, 'Priyanshu Das', 'Uttarpara', '2026-05-05'),
        (6, 'Swapnava Ghosh', 'Nabadwip', '2026-05-09');
        
insert into restaurants
values	(101, 'Adda Cafe', 'Coffee Shop', 'Chandannagar', 4.6),
		(102, 'The Serra Rooftop cafe', 'Multi-Cuisine', 'Kolkata', 4.7),
        (103, 'The Riverside', 'North indian', 'Chuchura', 4.3),
        (104, 'Kim Pou', 'Chinese', 'Kolkata', 4.2);
        
insert into delivery_partners
values	(201, 'Aman Gupta', 'Bike'),
		(202, 'Rohit Bansal', 'Scooter'),
        (203, 'Ankit Roy', 'Bike'),
        (204, 'Vikas Ghosh', 'Bicycle');
        
-- Add new column, named 'order_status' in 'orders' table
alter table orders
add order_status varchar(20);

-- change 'rating' column decimal value
alter table restaurants
modify rating decimal(2,1);

insert into orders
values	(1001, 1, 102, 202, '2026-08-01 12:40:38', 34, 1280, 'Delivered'),
		(1002, 2, 101, 204, '2026-08-01 20:10:49', 28, 485, 'Delivered'),
        (1003, 1, 103, 203, '2026-08-02 18:10:22', 107, 970, 'Return'),
        (1004, 4, 103, 201, '2026-08-03 17:25:47', 27, 890, 'Delivered'),
        (1005, 5, 104, 202, '2026-08-04 13:07:00', 76, 1895, 'Delivered'),
        (1006, 3, 101, 203, '2026-08-04 18:12:40', 42, 690, 'Delivered'),
        (1007, 2, 104, 201, '2026-08-05 18:22:53', 114, 800, 'Delivered'),
        (1008, 1, 104, 202, '2026-08-05 20:24:28', 40, 800, 'Delivered');
        
-- Total orders
select count(order_id) as 'Total Orders' from orders;

-- Total Revenue Restaurant-wise
select r.restaurant_name as "Restaurant Name", sum(o.order_amount) as 'Total Revenue' 
from orders o join restaurants r
on o.restaurant_id = r.restaurant_id
group by r.restaurant_name, r.restaurant_id;

-- Average Order Value (AOV)
-- AOV = Total Revenue / Total Number of Orders
select r.restaurant_name as 'Restaurant Name', (sum(o.order_amount)/ count(o.restaurant_id)) as 'Average Order Value' 
from orders o join restaurants r
on o.restaurant_id = r.restaurant_id
group by r.restaurant_name, r.restaurant_id;
-- Another answer using 'avg'
select r.restaurant_name as 'Restaurant Name', avg(o.order_amount) as 'Average Order Value' 
from orders o join restaurants r
on o.restaurant_id = r.restaurant_id
group by r.restaurant_name, r.restaurant_id;

-- Average Delivery time
select avg(delivery_times_minutes) as "Average Delivery Times in MINUTES" from orders;

-- Orders by Hour
select hour(order_date) as 'Order Time in HOUR', count(order_id) as 'Total Orders'
from orders
group by hour(order_date)
order by hour(order_date);

-- Peak Ordering Hour
select hour(order_date) as 'Order Time in HOUR', count(order_id) as 'Total Orders'
from orders
group by hour(order_date)
order by count(order_id) desc;

-- Revenue by restaurant
select r.restaurant_name, sum(o.order_amount) as 'Revenue Earned' 
from restaurants r join orders o
on o.restaurant_id = r.restaurant_id
group by r.restaurant_id, r.restaurant_name;

-- Revenue by city
select r.city, sum(o.order_amount) as 'Revenue Earned' 
from restaurants r join orders o
on o.restaurant_id = r.restaurant_id
group by r.city
order by r.city;

-- Top Customer by spending
select c.customer_name, sum(o.order_amount) as 'Total Spending'
from customers c join orders o
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
order by sum(o.order_amount) desc
limit 1;

-- Average restaurant reting
select avg(rating) as 'Average Restaurant rating' from restaurants;

-- Delivery partner performance
select d.d_partner_name as 'Delivery Partner Name', avg(o.delivery_times_minutes) as 'Delivery Time in MINUTES', 
avg(o.order_amount) as 'Average Order Amount', 
sum(case 
		when o.order_status = 'Delivered' then 1 else 0
	end) as 'Order Delivered', 
sum(case 
		when o.order_status = 'Return' then 1 else 0
	end) as 'Order Returned'
from delivery_partners d join orders o
where d.d_partner_id = o.d_partner_id
group by d.d_partner_id, d.d_partner_name;

-- Highest Revenue Cuisine
select r.cuisine, sum(o.order_amount) as 'Revenue'
from restaurants r join orders o
on o.restaurant_id = r.restaurant_id
group by r.cuisine
order by sum(o.order_amount) desc
limit 1;

-- *************
delete from customers
where customer_id = 6;

-- Customer retention rate
-- Retantion Rate = (Customers with more than 1 order / Total Customers) * 100
select ((select count(*) from (select customer_id from orders
		group by customer_id
        having count(order_id) > 1) as retained_customer)
        / (select count(distinct customer_id) from orders)
        * 100) as "Customer retention rate %";

-- ******REPEAT ORDER RATE
-- ******CANCELLATION RATE
-- ******DELIVERY TIME BY CITY
-- ******DELIVERY TIME BY RESTAURANT
-- ******RESTAURANT MARKET SHARE

-- Daily Revenue trend (all the restaurant total)
select date(order_date)  as 'Order Date', sum(order_amount) as 'Total Daily Revenue'
from orders
group by date(order_date);

-- Customer Lifetime Value (CLV)
-- CLV: Total amount spent by a customer over all their orders.
select c.customer_name as 'Customer Name', sum(o.order_amount) as 'Customer Lifetime Value'
from customers c join orders o
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name;

