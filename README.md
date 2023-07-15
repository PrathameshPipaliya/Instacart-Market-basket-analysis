---

Instacart Market Basket Analysis
Image source: deetaanalytics.com blogNowadays most retail companies, Youtube, Amazon, Netflix, and so many companies are using market basket analysis to provide the best meaningful recommendations to customers to increase engagement or better sales. Market basket analysis is a powerful tool to convert transactional data into combinational product recommendations based on selected products. In this analysis, we'll find out how to perform market basket analysis by using the Instacart dataset.

---

What is market basket Analysis?
Market Basket Analysis is about finding frequently purchased items and providing recommendations based on an item that makes the most probable combination with the item which is purchased.

---

How is Market Basket Analysis Used in Different Industries?
Retail: By knowing the most commonly purchased items and providing the best combo offers and keeping products handy based on combinations
E-commerce: By proving recommendations based on the product page which is viewed by customers and providing similar items section
Food Industry: one can provide combo offers based on the maximum number of purchased items
OTT Platforms & Social media: we can suggest similar types of content based on users liking for the genre
Telecommunication: we can offer customers combo offers based on packages that go together

---

Problem Statement
The objective of this analysis is to perform a market basket analysis on the Instacart dataset. Market basket analysis involves analyzing customer purchase patterns and identifying associations between products frequently bought together. The goal is to derive actionable insights that can be used for product recommendations, cross-selling strategies, and inventory optimization.

---

Dataset
There is below tables which are used in analyzing this dataset
Each entity Customer, Product, Order, Aisle, etc has an associated unique id.
Most of the files and variable names are self-explanatory.
aisles.csv contains the aisle id and the products present in the aisle. For example, Pasta sauce, fresh pasta, etc.
Department.csv contains the name of all the departments and the department id. For example, Frozen, Bakery, Alcohol, etc.
Order_products.csv specifies which products were purchased in each order. order_products__prior.csv contains previous order contents for all customers. 'reordered' indicates that the customer has a previous order that contains the product. Note that some orders will have no reordered items. You may predict an explicit 'None' value for orders with no reordered items.
Orders.csv tells to which set (prior, train, test) an order belongs. You are predicting reordered items only for the test set orders. 'order_dow' is the day of the week.
Product.csv file contains the product id, product name, department id, and aisle id.

---

Exploratory Data Analysis
I have done exploratory data analysis using python jupyter notebook which includes finding shape and null data and knowing our dataset.
importing relevant libraries
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
loading our relational data tables
aisle=pd.read_csv("aisles.csv")
aisle.head()
department=pd.read_csv("departments.csv")
department.head()
products=pd.read_csv("products.csv")
products.head()
orders=pd.read_csv("orders.csv")
orders.head()
opp=pd.read_csv("order_products__prior.csv")
opp.head()
I have done shape analysis and also found the details of non-null values for the tables below

We can see that there are no null values in the aisle, products, and department tables. so, let's check for orders and the order_products_prior table

Here we can observe that there are no null values in any table except the orders table's days_since_prior_order_table.
so, let's check the orders table for a relation between null values and other parameters

Here I have observed that the null value in days_since_prior_order is for each user's first order place.

---

Visual Analysis
Here we can observe that the maximum number of orders contains 5–6 products in their orders.
There is a very low chance of having more than 20 products in the cart of any order

From the above plot, we can infer that the 10th hour of the day and the 15–16th hour of the day has peak time for orders.
From the above plot, we can access customer rush in the hours of the day.

Here is the plot for orders placed according to the day of the week. we can observe that there is a higher number of orders on the 0th and 1st day of the week.

From the above plot, we can observe peaks on a weekly basis and a monthly basis.
There is a higher number of orders at a lower number of days_since_prior_order, which means there is more number of users who are used to order a regular basis.
On the basis of peaks in the plot, we can conclude that there are some items that are purchased on a monthly and weekly basis.

---

Market Basket Analysis using MySQL
As part of our market basket analysis, our first task is to find out product which is most frequent in each order. 

SELECT opp.product_id, p.product_name,count(distinct order_id) as frequency
FROM instacart_market_basket_analysis.order_products_prior opp
join products p on p.product_id = opp.product_id
group by product_id
order by frequency desc;
Here we can observe that the most ordered product is banana and organic banana. Here we can also observe that most of the products are vegetables and fruits and along with that most of the products are organic type.
As we know that users may purchase vegetables and fruits more frequently but may not purchase them always in combination.
Let us find products that are purchased on a weekly basis and also reordered.

select o.user_id, opp.product_id, p.product_name, count(o.order_id) as No_of_orders from order_products_prior opp
inner join orders o on o.order_id=opp.order_id
inner join products p on opp.product_id = p.product_id
where o.days_since_prior_order=7 and opp.reordered=1
group by o.user_id, opp.product_id
order by o.user_id, No_of_orders desc;
On the basis of products purchased on a weekly basis, I have observed that fruits, and flavored items like milk, ice cream, etc. are more frequent in users' baskets.

with counter as
(select user_id, count(order_id) as ocnt from orders
group by user_id),
base as (
select o.user_id, opp.product_id, count(o.order_id) as cnt from order_products_prior opp
join orders o on o.order_id = opp.order_id
group by o.user_id, opp.product_id
),
main as(
select user_id, product_id, cnt, dense_rank() over(partition by user_id order by cnt desc) as rnk from base
where cnt >1
)
select main.user_id, main.product_id, p.product_name, main.cnt, (main.cnt/c.ocnt) as freq_in_order,main.rnk  from main
join products p on main.product_id = p.product_id
join counter c on c.user_id = main.user_id
order by main.user_id, main.rnk ;
Here we can find the probability of a product having in the order for a particular user. here we can see that soda and original beef jerky have a very high probability of being in order for a user with user_id=1.
so based on the probability we can also suggest a product for the particular user.
Here probability is counted by using the below formulae:
P(product in order of user)=number of times product in user's order/ number of orders placed by a user.

with prod_count as
(SELECT opp.product_id, p.product_name,count(distinct order_id) as cnt FROM instacart_market_basket_analysis.order_products_prior opp
join products p on p.product_id = opp.product_id
group by product_id
order by cnt desc),
order_count as(
select count(distinct order_id) as ocnt from orders)
select p.product_id, p.product_name, p.cnt, o.ocnt,(p.cnt/o.ocnt) as prob_of_item_in_order  from prod_count p,order_count o
Here I have found the probability for each product to be in the order as prob_of_item_in_order. so, it shows the probability of the product being in order placed by any customers.
Probability can be given by:
P(Product in the order)= number of times product in the order/ number of orders

with table1 as (
select opp.order_id , opp.product_id, p.product_name, p.department_id 
from order_products_prior opp 
join products p on opp.product_id = p.product_id
order by opp.order_id,opp.product_id),
table2 as (
select opp.order_id, opp.product_id, p.product_name,p.department_id 
from order_products_prior opp 
join products p on opp.product_id = p.product_id), 
final as (
select t1.order_id,t1.product_id as p_id1,
t1.product_name as pname1,t1.department_id as dep1,
t2.product_id as p_id2,t2.product_name as pname2,
t2.department_id as dep2 
from table1 t1, table2 t2 
where t1.order_id = t2.order_id and t1.product_id < t2.product_id 
order by t1.order_id,t1.product_id,t2.product_id)
select p_id1,pname1, dep1, p_id2, pname2, dep2,
count(distinct order_id) AS cnt,
case 
when dep1 = dep2 then 1 
else 0 
end as depsame 
from final 
group by final.p_id1,final.p_id2 
order by cnt desc;
In this query, we have found a combination of products that are purchased together more frequently, and we can see that most fruits are purchased together
we can see that there is a banana along with milk purchased frequently and that we can find result relevant to our daily life.

Now, let us find the recommendations of products for the product picked by the customer.
CREATE  VIEW ranking AS
with table1 as (
select opp.order_id , opp.product_id, p.product_name, p.department_id 
from order_products_prior opp 
join products p on opp.product_id = p.product_id
order by opp.order_id,opp.product_id),
table2 as (
select opp.order_id, opp.product_id, p.product_name,p.department_id 
from order_products_prior opp 
join products p on opp.product_id = p.product_id), 
final as (
select t1.order_id,t1.product_id as p_id1,
t1.product_name as pname1,t1.department_id as dep1,
t2.product_id as p_id2,t2.product_name as pname2,
t2.department_id as dep2 
from table1 t1, table2 t2 
where t1.order_id = t2.order_id and t1.product_id < t2.product_id 
order by t1.order_id,t1.product_id,t2.product_id), 
base as (
select p_id1,pname1, dep1, p_id2, pname2, dep2,
count(distinct order_id) AS cnt,
case 
when dep1 = dep2 then 1 
else 0 
end as depsame 
from final 
group by final.p_id1,final.p_id2 
order by cnt desc), 
ranker as (
select p_id1, pname1, dep1, p_id2, pname2, dep2, depsame, cnt, row_number() OVER (PARTITION BY p_id1 ORDER BY cnt desc)  as rnk 
from base) 
select p_id1, pname1, dep1, p_id2, pname2, dep2, depsame, cnt, rnk 
from ranker
where rnk < 50;
with sug1 as(
select p_id1 as product_id, pname1 as product_name, dep1 as department, 
p_id2 as suggestion1_id, pname2 as suggestion1_name, dep2 as suggestion1_dep
from ranking
where rnk=1
),
rankers as (
select p_id1, pname1,dep1, p_id2, pname2,dep2, depsame, row_number() over(partition by p_id1, depsame order by cnt) as ranked
from ranking 
where rnk>1
),
sug2 as (
select p_id1, pname1, dep1,
p_id2 as suggestion2_id, pname2 as suggestion2_name, dep2 as suggestion2_dep
from rankers 
where depsame=1 and ranked=1
),
sug3 as(
select p_id1, pname1, dep1,
p_id2 as suggestion3_id, pname2 as suggestion3_name, dep2 as suggestion3_dep
from rankers 
where depsame=1 and ranked=2
),
sug4 as(
select p_id1, pname1, dep1,
p_id2 as suggestion4_id, pname2 as suggestion4_name, dep2 as suggestion4_dep
from rankers 
where depsame=0 and ranked=1
),
sug5 as(
select p_id1, pname1, dep1,
p_id2 as suggestion5_id, pname2 as suggestion5_name, dep2 as suggestion5_dep
from rankers 
where depsame=0 and ranked=2
)
select s1.product_id, s1.product_name, s1.department, 
s1.suggestion1_id, s1.suggestion1_name, s1.suggestion1_dep,
s2.suggestion2_id, s2.suggestion2_name, s2.suggestion2_dep,
s3.suggestion3_id, s3.suggestion3_name, s3.suggestion3_dep,
s4.suggestion4_id, s4.suggestion4_name, s4.suggestion4_dep,
s5.suggestion5_id, s5.suggestion5_name, s5.suggestion5_dep
from sug1 s1
left join sug2 s2 on s1.product_id = s2.p_id1
left join sug3 s3 on s1.product_id = s3.p_id1
left join sug4 s4 on s1.product_id = s4.p_id1
left join sug5 s5 on s1.product_id = s5.p_id1;
Here we have given recommendations for each product and provided 5 recommendations as we have seen earlier that most customers have 5 products in an order.
Here suggestion1 is the maximum number of times given product_id has been purchased together.
Suggestion2 and suggestion3 are products that are from the same department and but they purchased with the product in first and second priority with the given product_id.
suggestion4 and suggestion5 are products that are not from the given products department, but if a customer purchases a product from another department, these products would be their top choices.

---

Conclusion and Future Work
In this blog, we have seen the market basket analysis based on the number of orders and products available in it. we can do further analysis based on Apriori or FP growth algorithm and develop a Machine Learning model for market basket analysis.
Based on the analysis, we can suggest the retailer, maintain the inventory based on our recommended combination of products available in the orders.
We can suggest designing a layout such that products and recommended products can be easily available to find by customers.
There can be a weekly and monthly rush for items, so be prepared for the inventory and better service to customers.
customers are purchasing organic products more frequently compared to others, so maintain availability and different varieties of organic items.
We have observed there are few peak hours for the sale, so plan accordingly for that time.

---

References
"The Instacart Online Grocery Shopping Dataset 2017", Accessed from https://www.instacart.com/datasets/grocery-shopping-2017 
scaler.com
https://towardsdatascience.com/a-gentle-introduction-on-market-basket-analysis-association-rules-fa4b986a40ce
https://www.analyticsvidhya.com/blog/2021/10/a-comprehensive-guide-on-market-basket-analysis/
