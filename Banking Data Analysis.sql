-- SQL project: Banking Data Analysis

create database bank_db;
use bank_db;

create table customers (
	customer_id int primary key,
    customer_name varchar(100),
    gender varchar(10),
    city varchar(50),
    account_open_date date
);

create table accounts (
	account_id int primary key,
    customer_id int,
    account_type varchar(30),
    branch_name varchar(100),
    opening_balance decimal(12, 2),
    foreign key (customer_id)
		references customers (customer_id)
	);

create table transactions (
	transaction_id int primary key,
    account_id int,
    transaction_date timestamp,
    transaction_type varchar(20),
    amount decimal(12, 2),
    foreign key (account_id)
		references accounts (account_id)
);

insert into customers
values	(1, 'Rahul Sharma', 'Male', 'Mumbai', '2023-01-10'),
		(2, 'Priya Verma', 'Female', 'Delhi', '2023-02-18'),
        (3, 'Amit Patel', 'Male', 'Pune', '2023-05-12'),
        (4, 'Deep Saha', 'Male', 'Kolkata', '2022-06-13'),
        (5, 'Sneha Joshi', 'Female', 'Delhi', '2023-05-12');

insert into accounts
values	(101, 4, 'Savings', 'Kolkata', 20000),
		(102, 1, 'Savings', 'Mumbai', 50000),
        (103, 2, 'Savings', 'Delhi', 35000),
        (104, 3, 'Savings', 'Pune', 100000),
        (105, 5, 'Current', 'Delhi', 50000);

insert into transactions
values	(1001, 101, '2026-06-05 11:15:00', 'Deposit', 15000),
		(1002, 104, '2026-06-05 12:30:00', 'Withdrawal', 5000),
        (1003, 105, '2026-06-06 14:18:00', 'Deposit', 200000),
        (1004, 102, '2026-06-07 12:25:00', 'Withdrawal', 40000),
        (1005, 101, '2026-06-08 15:40:00', 'Withdrawal', 10000),
        (1006, 103, '2026-06-09 10:59:00', 'Deposit', 8000);


-- Total transaction amount
select sum(amount) as 'Total Transaction Amount' from transactions;

-- Total deposits
select sum(amount) as 'Total Deposit' from transactions
where transaction_type = 'Deposit';

-- Total withdrawals
select sum(amount) as 'Total Withdrawals' from transactions
where transaction_type = 'Withdrawal';

-- Net cash flow
select account_id, sum(amount) as "Net cash flow" from transactions
where transaction_date between '2026-06-01' and '2026-06-30'
group by account_id;
 
-- Add new column 'current_balance' in 'accounts' table
alter table accounts
add column current_balance decimal(12, 2);

-- Average transaction amount per account
select account_id, avg(amount) as "Average Transaction Amount" from transactions
group by account_id;

-- Average transaction amount
select avg(amount) as "Average Transaction Amount" from transactions;

-- Current account balance after transactions
UPDATE accounts a
SET current_balance = a.opening_balance + COALESCE(
    (
        SELECT SUM(
            CASE 
                WHEN transaction_type = 'Deposit'  THEN amount
                WHEN transaction_type = 'Withdrawal' THEN -amount
            END
        )
        FROM transactions t
        WHERE t.account_id = a.account_id
    ),0
);

-- Daily transaction valume
select date(transaction_date) as 'Daily Transaction Date', count(transaction_id) as "Daily Transaction Volume" 
from transactions group by date(transaction_date);

-- Branch-wise transactions
select a.branch_name, count(t.transaction_id) as 'Branch-wise Total Transaction'
from accounts a join transactions t
on a.account_id = t.account_id group by a.branch_name;

-- Account type analysis
select account_type, count(account_type) as 'Count' from accounts group by account_type;

-- Top customer by transaction value. In a single transaction.
select c.customer_name, t.amount from customers c join accounts a
on c.customer_id = a.customer_id
join transactions t
on a.account_id = t.account_id
order by t.amount desc
limit 1;

-- Top customer by transaction value. with all the transactions.
select c.customer_name, sum(t.amount) as 'Total Transaction Amount' from customers c join accounts a
on c.customer_id = a.customer_id
join transactions t
on a.account_id = t.account_id
group by c.customer_name
order by sum(t.amount) desc
limit 1;

-- Most active customer. It's mean which customer transaction's count is highest.
select c.customer_name, count(t.transaction_id) as 'Total Transactions Count' 
from customers c join accounts a
on c.customer_id = a.customer_id
join transactions t
on a.account_id = t.account_id
group by c.customer_id
order by count(t.transaction_id) desc
limit 1;

-- Dormant account: is a bank account that has had no customer initiated transactions for a long period of time.
select a.account_id, c.customer_name
from accounts a join customers c
on a.customer_id = c.customer_id
left join transactions t
on a.account_id = t.account_id
where t.account_id is null;

-- High value transaction
select a.account_id, c.customer_name, t.transaction_type, t.amount
from accounts a join customers c
on a.customer_id = c.customer_id
join transactions t
on a.account_id = t.account_id
order by t.amount desc
limit 1;

-- High value transaction. [using MAX()]
select a.account_id, c.customer_name, t.transaction_type, t.amount
from accounts a join customers c
on a.customer_id = c.customer_id
join transactions t
on a.account_id = t.account_id
where t.amount = (select max(amount) from transactions);

-- Deposit vs Withdrawal ratio (ratio of number of transactions)
select 
	sum(case when transaction_type = "Deposit" then 1 else 0 end) as 'Deposits',
	sum(case when transaction_type = "Withdrawal" then 1 else 0 end) as 'Withdrawals'
from transactions;

-- Deposit vs Withdrawal ratio (ratio of total deposit amount and total withdrawal amount)
select 
	sum(case when transaction_type = "Deposit" then amount else 0 end) as 'Total Deposits',
	sum(case when transaction_type = "Withdrawal" then amount else 0 end) as 'Total Withdrawals'
from transactions;

-- FRAUD DETECTION ALERTS **********

-- Average balance by branch
select branch_name, avg(opening_balance) as 'Average Balance'
from accounts group by branch_name order by branch_name asc;

-- Customer growth [New customer open account in bank]
select date_format(account_open_date, '%Y-%m') as 'Month', count(customer_id) as "New Customer"
from customers
group by date_format(account_open_date, '%Y-%m')
order by date_format(account_open_date, '%Y-%m');

-- TRANSACTION SUCCESS RATE *********

-- Peak transaction hours
select hour(transaction_date) as "Transaction Hour", count(*) as 'Total Transaction'
from transactions
group by hour(transaction_date)
order by count(*) desc;

