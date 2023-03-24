drop table if exists  goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');


drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'brownie',980),
(2,'pizza',870),
(3,'burger',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--1.total amt each customer spent
select a.userid,sum(b.price) as total_amt from sales a inner join product b on a.product_id=b.product_id
group by a.userid

--2.days each customer visited
select userid,count(created_date) visited_days from sales
group by userid

--3.first product purchased by each customer
select * from
(select * ,rank() over (partition by userid order by created_date) rnk from sales)a where rnk=1

--4.most purchased item and how many times purchased
--select product_id,count(product_id)cnt from sales group by product_id order by count(product_id) desc
select userid,count(product_id)cnt from sales where product_id=
(select top 1 product_id from sales group by product_id order by count(product_id)desc)
group by userid

--5.which item is most popular for each customer
select * from 
(select * ,rank() over(partition by userid order by cnt desc)rnk from
(select userid,product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk = 1

--6.first item purchased after becoming a member
select * from
(select c.*,rank() over(partition by userid order by created_date) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date)c)d
where rnk =1;

--7.last item purchased before becoming a member
select * from
(select c.*,rank() over(partition by userid order by created_date desc) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date)c)d
where rnk =1;

--8.total orders and total amt spend before becoming a member
select userid,count(created_date) as total_orders,sum(price) as total_amount from
(select c.*,price from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date)c inner
join product d on c.product_id=d.product_id)e
group by userid;

--9.if customer buying product generates points eg.5rs=2 zomato points and each product has different purchasing points
--for eg pizza rs5=1 zomato ,brownie rs10=5 zomato, bu8rger 5rs=1 zomato points

--calculate total points for each customer and for which product most points were given till now
select userid,sum(total_points)as total_points_earned from
(select e.*, amt/points as total_points from
(select d.*,  case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5
else 0 end as points from
(select c.userid,c.product_id,sum(price) as amt from
(select a.userid,a.product_id,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f
group by userid;

--if u want to check how much rewards or cashback is earned (5rs=2zomato points ie 1zomato=2.5rs)

select userid,sum(total_points)*2.5 as total_money_earned from
(select e.*, amt/points as total_points from
(select d.*,  case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5
else 0 end as points from
(select c.userid,c.product_id,sum(price) as amt from
(select a.userid,a.product_id,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f
group by userid;

select * from
(select * ,rank() over(order by total_points_earned desc) rnk from
(select product_id,sum(total_points)as total_points_earned from
(select e.*, amt/points as total_points from
(select d.*,  case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.userid,c.product_id,sum(price) as amt from
(select a.userid,a.product_id,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f
group by product_id)g)h where rnk =1;

--10.in the first yr after becoming glod member each customer earn 5 points for every 10rs now who earned more 1 or 3.how much they have earned
select c .*, d.price*0.5 total_Points_earned from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date and created_date<=dateadd(year,1,gold_signup_date))c
inner join product d on c.product_id=d.product_id;

--11.rank all the transcation
select* ,rank() over(partition by userid order by created_date) rnk from sales









































































