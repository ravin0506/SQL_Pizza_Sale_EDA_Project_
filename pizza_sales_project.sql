create database db_pizzasales
use db_pizzasales
select * from order_details
select * from orders
select * from pizza_types
select * from pizzas

--Basic Problems
--1.Retrieve the total number of orders placed.
select count(order_id)as totalorders from orders

--2.Calculate the total revenue generated from pizza sales.
select round(sum(od.quantity*p.price),2) as total_revenue
from order_details od
left join pizzas p on
od.pizza_id=p.pizza_id

--3 Identify the highest-priced pizza.
select top 1 t.name,p.price
from pizza_types t
left join pizzas p
on t.pizza_type_id=p.pizza_type_id
order by p.price desc

--4 Identify the most common pizza size ordered.
select p.size,count(od.quantity) order_count
from order_details od 
left join pizzas p
on od.pizza_id=p.pizza_id
group by p.size
order by order_count desc

--5 List the top 5 most ordered pizza types along with their quantities.

select top 5 pt.name,sum(od.quantity) qty_ord
from order_details od
left join pizzas p on
od.pizza_id=p.pizza_id
join pizza_types pt on
pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by qty_ord desc

--Intermediate problem
--1.Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category,sum(od.quantity) ord_qty_category
from pizzas pz
left join pizza_types pt 
on pz.pizza_type_id=pt.pizza_type_id
left join order_details od
on pz.pizza_id=od.pizza_id
group by pt.category
order by ord_qty_category desc

--2 Determine the distribution of orders by hour of the day.
select datepart(HOUR,o.[time]) hr_of_the_day ,count(od.order_id) orders_per_hr
from order_details od
left join orders o 
on od.order_id=o.order_id
group by datepart(HOUR,o.[time])  
order by datepart(HOUR,o.[time])

--3 Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) pizza_type_comes_under_category from pizza_types
group by category

--4 Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(order_qty_per_day) avg_qty_perday from
(select o.[date],sum(od.quantity) order_qty_per_day
from order_details od
left join orders o
on od.order_id=o.order_id
group by o.[date]) as order_qty_datewise

--5 Determine the top 3 most ordered pizza types based on revenue.

select top 3 pt.name,round(sum(p.price*od.quantity),0) revenue
from order_details od
left join pizzas p 
on od.pizza_id=p.pizza_id
left join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by revenue desc

--Advance
--1 Calculate the percentage contribution of each pizza type to total revenue.
select pt.name,round(sum(od.quantity*p.price)/(select sum(p.price*od.quantity)
													from order_details od 
													left join pizzas p 
													on od.pizza_id=p.pizza_id),2)*100 revenue_percentage
from order_details od
left join pizzas p
on od.pizza_id=p.pizza_id
left join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by revenue_percentage  desc

--2 Analyze the cumulative revenue generated over time.
select [date], sum(revenue_by_date) over(order by [date]) as cum_revenue
from
(select o.[date],sum(od.quantity*p.price) revenue_by_date
from order_details od
left join pizzas p
on od.pizza_id=p.pizza_id
left join orders o
on od.order_id=o.order_id
group by o.[date]) as sales

--3 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name,revenue,rev_rnk from 
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rev_rnk
from
(select pt.category,pt.name,sum(od.quantity*p.price) revenue
from order_details od
left join pizzas p
on od.pizza_id=p.pizza_id
left join pizza_types pt
on pt.pizza_type_id=p.pizza_type_id
group by pt.category,pt.name) as table_A) as table_B
where rev_rnk <=3

