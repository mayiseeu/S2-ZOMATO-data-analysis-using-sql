SELECT * FROM GOLDUSERS_SIGNUP
SELECT * FROM PRODUCT
SELECT * FROM SALES
SELECT * FROM USERS
ALTER TABLE SALES
RENAME COLUMN CREATED_DATE TO TRANSACTION_DATE

-- Q1 .Total amount spend by each customer on product
--SOLUTION

SELECT SA.USERID,SUM(PR.PRICE) AS TOTAL_PRICE
FROM SALES SA
JOIN PRODUCT PR ON PR.PRODUCT_ID=SA.PRODUCT_ID
GROUP BY SA.USERID
ORDER BY TOTAL_PRICE

--Q2.HOW Many days Each customer visited zomato
--SOLUTION

SELECT USERID,COUNT(TRANSACTION_DATE) AS DAY
FROM SALES
GROUP BY USERID

--Q3.What is the first product bought by each customer
--SOLUTION

SELECT * FROM(SELECT *,RANK()OVER (PARTITION BY USERID ORDER BY  TRANSACTION_DATE) RNK
FROM
(SELECT SA.USERID,PR.PRICE,PR.PRODUCT_NAME,PR.PRODUCT_ID,SA.TRANSACTION_DATE
FROM SALES SA
JOIN PRODUCT PR ON PR.PRODUCT_ID=SA.PRODUCT_ID)A)B
WHERE RNK=1

--Q.4 What is the most purchased item on the menu and how many times was it purchased by all customer?
--SOLUTION

--THIS IS THE FIRST PART OF THE PROBLEM

--solution
SELECT count(product_id),product_id
FROM SALES 
 GROUP BY product_id
 order by count(product_id) desc
limit 1
--final
SELECT userid,count(product_id),product_id

FROM SALES
 GROUP BY userid,product_id
 order by count(product_id)  desc
 

---


 


--SECOND PART OF THE PROBLEM
--final
SELECT userid,count(product_id),product_id

FROM SALES
where product_id in(SELECT product_id

FROM SALES
 GROUP BY userid,product_id
 order by count(product_id)  desc
				   limit 1)
 GROUP BY userid,product_id
 order by count(product_id)  desc
 
---

--q self made question that take out the data of  userid ,productname ,price,trasnsactiondate of the product which has bought maximum time
--you cannot take out the data of that column by which column you are joining the two table
--solution
--
SELECT product_id
FROM SALES 
 GROUP BY product_id
 order by count(product_id) desc
limit 1
--
select transaction_date
from sales
where 
product_id iN(SELECT product_id
FROM SALES 
 GROUP BY product_id
 order by count(product_id) desc
limit 1)
group by product_id
--final 
select userid,product_name,price,transaction_date
from sales sa
join product pr on pr.product_id=sa.product_id
where transaction_date in(select transaction_date
from sales
where 
product_id iN(SELECT product_id
FROM SALES 
 GROUP BY product_id
 order by count(product_id) desc
limit 1))


---Q.5 Which item is most popular for each of the customer

--solution
select b.userid,b.product_id
from
(select a.*,
rank() over(partition by userid order by cprid desc) rnk
from
(SELECT userid,count(product_id)as cprid,product_id 
FROM SALES 
group by userid,product_id
order by cprid desc)a)b
where rnk =1

--Q6.which item was purchased first by the customer after they became a member?

select * from goldusers_signup
select * from sales


--
select sa.userid, transaction_date,gold_signup_date
from sales sa
join goldusers_signup gs on gs.userid=sa.userid and transaction_date>=gold_signup_date
--

select *
from
(select *,rank() over (partition by userid order by product_id) rnk
from
(select sa.userid, transaction_date,gold_signup_date ,sa.product_id
from sales sa
join goldusers_signup gs on gs.userid=sa.userid and transaction_date>=gold_signup_date)a)b
where rnk = 1

select *
from
(select *,rank() over (partition by userid order by product_id desc) rnk
from
(select sa.userid, transaction_date,gold_signup_date ,sa.product_id
from sales sa
join goldusers_signup gs on gs.userid=sa.userid and transaction_date>=gold_signup_date)a)b
where rnk =1


--Qb.7  which item was purchased just before the custmer became a member?


select *
from
(select *,rank() over (partition by userid order by transaction_date desc) rnk
from
(select sa.userid, transaction_date,gold_signup_date ,sa.product_id
from sales sa
join goldusers_signup gs on gs.userid=sa.userid and transaction_date<gold_signup_date)a)b
where rnk =1

--Qb8 What is the total orders and amount spent for each member before they became a member?

select userid,count(transaction_date),sum(price)
from
(select a.*,price
from
(select sa.userid, transaction_date,gold_signup_date ,sa.product_id
from sales sa
join goldusers_signup gs on gs.userid=sa.userid and transaction_date<=gold_signup_date)a 
join product pr on pr.product_id=a.product_id)b
group by userid

--Qb9IF BUYING EACH PRODUCT GENERATES POINTS FOR EG 5RS=2 ZOMATO POINT AND EACH PRODUCT
 --HAS DIFFERENT PURCHASING POINTS FOR EG FOR P1 5RS =1 ZOMATO POINT , FOR P2 10RS =5ZOMATO
 --POINT AND P3 5RS =1 ZOMATO POINT
 --CALCULATE POINTS COLLECTED BY EACH CUSTOMER AND FOR WHICH PRODUCT MOST POINTS HAVE BEEN GIVEN TILL NOW

--solution
--p1 rs5 =1
--p2 rs 2=1
--p3 rs5=1
select userid,sa.product_id,product_name,price,case when product_name= 'p1' then price/5 when product_name='p2' then price/2 when product_name='p3' then price/5 else 0 end as points
from sales sa
join product pr on pr.product_id=sa.product_id
--

select userid,product_id,product_name ,sum(price) as sumofprice,sum(points) as sumofpoints
from
(select userid,sa.product_id,product_name,price,case when product_name= 'p1' then price/5 when product_name='p2' then price/2 when product_name='p3' then price/5 else 0 end as points
from sales sa
join product pr on pr.product_id=sa.product_id ) 
group by 
userid,product_id,product_name
order by
userid

--
select userid,sum(sumofprice) as totalsumofprice ,sum(sumofpoints)as totalsumofpoints
from
(select userid,product_id,product_name ,sum(price) as sumofprice,sum(points) as sumofpoints
from
(select userid,sa.product_id,product_name,price,case when product_name= 'p1' then price/5 when product_name='p2' then price/2 when product_name='p3' then price/5 else 0 end as points
from sales sa
join product pr on pr.product_id=sa.product_id ) 
group by 
userid,product_id,product_name
order by
userid)a
group by userid
--
-- 1point = 2.5rs
-- giving cashback
select b.*,floor(totalsumofpoints*2.5) as cashback
from
(select userid,sum(sumofprice) as totalsumofprice ,sum(sumofpoints)as totalsumofpoints
from
(select userid,product_id,product_name ,sum(price) as sumofprice,sum(points) as sumofpoints
from
(select userid,sa.product_id,product_name,price,case when product_name= 'p1' then price/5 when product_name='p2' then price/2 when product_name='p3' then price/5 else 0 end as points
from sales sa
join product pr on pr.product_id=sa.product_id ) 
group by 
userid,product_id,product_name
order by
userid)a
group by userid)b

--q.10--in the first one year after a customer joins the gold program(including their joining date ) 
 --irrespective of what the customer has purchased they earn 5 zomato points for every 10 rs spent
 --who earned more 1 or 3 and what was their points earning in their first year.
 --solution
 -- 1 zomato point = 0.5
 
 
 select a.*,totalprice*0.5 as cashback
 from(select userid,transaction_date,count(transaction_date) as totalitempurchase,sum(price) as totalprice,gold_signup_date
from
(select a.*,price
from
(select sa.userid, transaction_date,gold_signup_date ,sa.product_id
from sales sa
join goldusers_signup gs on gs.userid=sa.userid and transaction_date >=gold_signup_date and transaction_date <=gold_signup_date+365)a 
join product pr on pr.product_id=a.product_id)b
group by userid,transaction_date,gold_signup_date)a
 
--Q11 RANK ALL THE TRANSACTIONS OF THE CUSTOMERS

select *,rank()over(partition by userid order by transaction_date) from sales
 
 
