-- SQL Project: Logistics & Shipment Analytics
create database logistics_db;
use logistics_db;

create table customers(
	customer_id int primary key,
    customer_name varchar(100),
    city varchar(50)
);

create table warehouses(
	warehouse_id int primary key,
    warehouse_name varchar(100),
    city varchar(50)
);

create table shipments(
	shipment_id int primary key,
    customer_id int,
    warehouse_id int,
    shipment_date date,
    delivery_date date,
    shipping_cost decimal(10,2),
    shipment_status varchar(30),
    delivery_partner varchar(100),
    foreign key (customer_id) references customers (customer_id),
    foreign key (warehouse_id) references warehouses (warehouse_id)
);

insert into customers
values	(1, 'Deep Saha', 'Kolkata'),
		(2, 'Rohit Gurunath Sharma', 'Mumbai'),
        (3, 'Virat Kohli', 'Delhi'),
        (4, 'Jeet', 'Kolkata'),
        (5, 'Sneha Joshi', 'Bangalore');

insert into warehouses
values	(101, 'Kolkata Warehouse', 'Kolkata'),
		(102, 'Mumbai Warehouse', 'Mumbai'),
        (103, 'Delhi Warehouse', 'Delhi'),
        (104, 'Bangalore Warehouse', 'Bangalore');

insert into shipments
values	(1001, 1, 101, '2026-07-01', '2026-07-07', 12400, 'Delivered', 'EKart'),
		(1002, 2, 102, '2026-07-04', '2026-07-07', 7880, 'Delivered', 'DHL'),
        (1003, 3, 103, '2026-07-06', '2026-07-12', 5800, 'Delivered', 'Xpress'),
        (1004, 4, 102, '2026-07-11', '2026-07-20', 16000, 'Delivered', 'Ekart'),
        (1005, 5, 104, '2026-07-16', '2026-07-23', 8500, 'Delayed', 'Red Post');

-- Total shipments
select count(shipment_id) as 'Total Shipments' from shipments;

-- Delivered shipments
select * from shipments where shipment_status = 'Delivered';

-- Delayed Shipments
select * from shipments where shipment_status = 'Delayed';

-- Delivery success rate
select	(
		( select count(shipment_id) from shipments where shipment_status = 'Delivered') 
		/ (select count(shipment_id) from shipments)
		)
		* 100 as 'Delivery Success Rate %';

-- Average Delivery Time
select avg(datediff(delivery_date, shipment_date)) as 'Average Delivery Time'
from shipments;

-- Total shipping cost
select sum(shipping_cost) as 'Total Shipping Cost' from shipments;

-- Shipping cost by warehouse
select w.warehouse_name, sum(s.shipping_cost) as 'Shipping Cost'
from warehouses w left join shipments s
on w.warehouse_id = s.warehouse_id
group by w.warehouse_id, w.warehouse_name
order by w.warehouse_name;
/* One thing to understand—not a correction— is that you're using an INNER JOIN. Therefore, a warehouse with zero shipments would not appear.
If the requirement were "Shipping cost for every warehouse, including warehouses with no shipments", you'd need a LEFT JOIN. */

-- Shipping cost by delivery partner
select delivery_partner as 'Delivery Partner Name', sum(shipping_cost) as 'Shipping Cost'
from shipments
group by delivery_partner;

-- Shipments by city (customer)
select c.city, count(s.shipment_id) as 'Count Shipments'
from customers c join shipments s
on c.customer_id = s.customer_id
group by c.city;

-- Shipments by warehouse
select w.warehouse_name, count(s.shipment_id) as 'Count Shipments'
from warehouses w join shipments s
on w.warehouse_id = s.warehouse_id
group by w.warehouse_name;

-- ****** DELIVERY PARTNER PERFORMANCE

-- Average delivery time by partner
select delivery_partner, avg(datediff(delivery_date, shipment_date)) as 'Average Delivery Time in DAYS'
from shipments
group by delivery_partner;

-- ****** WAREHOUSE UTILIZATION
-- ****** PEAK SHIPMENT COST
-- ****** MONTHLY SHIPMENT TREND

-- Customer-wise shipment
select c.customer_name, count(s.shipment_id) as 'Count Shipments', sum(s.shipping_cost) as 'Total Cost'
from customers c join shipments s
on c.customer_id = s.customer_id
group by c.customer_id, c.customer_name;

-- ****** ON TIME DELIVERY RATE
-- ****** DELAYED DELIVERY ANALYSIS

-- Cost per shipment
select shipment_id, shipping_cost
from shipments;

-- Executive Logistics Dashboard
/* An Executive Logistics Dashboard means a high-level summary of the logistics business, 
designed for managers/executives to quickly understand how shipments are performing. */
select count(shipment_id) as 'Total Shipments', 
		sum(shipping_cost) as 'Total Shipping Cost',
		avg(shipping_cost) as 'Average Shipping Cost',
        avg(datediff (delivery_date, shipment_date)) as 'Average Delivery Time in DAYS',
        count(case when shipment_status = 'Delayed' then 1 end) as 'Number of Delayed Shipments'
from shipments;
