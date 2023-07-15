# As part of our market basket analysis, our first task is to find out product which is most frequent in each order.

SELECT opp.product_id, p.product_name,count(distinct order_id) as frequency
FROM instacart_market_basket_analysis.order_products_prior opp
join products p on p.product_id = opp.product_id
group by product_id
order by frequency desc;

#we can observe that the most ordered product is banana and organic banana. 
#we can also observe that most of the products are vegetables and fruits and along with that most of the products are organic type.
#As we know that users may purchase vegetables and fruits more frequently but may not purchase them always in combination.

#Let us find products that are purchased on a weekly basis and also reordered.

select o.user_id, opp.product_id, p.product_name, count(o.order_id) as No_of_orders from order_products_prior opp
inner join orders o on o.order_id=opp.order_id
inner join products p on opp.product_id = p.product_id
where o.days_since_prior_order=7 and opp.reordered=1
group by o.user_id, opp.product_id
order by o.user_id, No_of_orders desc;

#On the basis of products purchased on a weekly basis, I have observed that fruits, and flavored items like milk, ice cream, etc. are more frequent in users' baskets.

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

#Here we can find the probability of a product having in the order for a particular user. here we can see that soda and original beef jerky have a very high probability of being in order for a user with user_id=1.
#so based on the probability we can also suggest a product for the particular user.

#Here probability is counted by using the below formulae:
#P(product in order of user)=number of times product in user's order/ number of orders placed by a user.

with prod_count as
(SELECT opp.product_id, p.product_name,count(distinct order_id) as cnt FROM instacart_market_basket_analysis.order_products_prior opp
join products p on p.product_id = opp.product_id
group by product_id
order by cnt desc),
order_count as(
select count(distinct order_id) as ocnt from orders)
select p.product_id, p.product_name, p.cnt, o.ocnt,(p.cnt/o.ocnt) as prob_of_item_in_order  from prod_count p,order_count o;

#Here I have found the probability for each product to be in the order as prob_of_item_in_order. so, it shows the probability of the product being in order placed by any customers.
#Probability can be given by: P(Product in the order)= number of times product in the order/ number of orders

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

#In this query, we have found a combination of products that are purchased together more frequently, and we can see that most fruits are purchased together
#we can see that there is a banana along with milk purchased frequently and that we can find result relevant to our daily life.

#Now, let us find the recommendations of products for the product picked by the customer.

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

#Here we have given recommendations for each product and provided 5 recommendations as we have seen earlier that most customers have 5 products in an order.
#Here suggestion1 is the maximum number of times given product_id has been purchased together.
#Suggestion2 and suggestion3 are products that are from the same department and but they purchased with the product in first and second priority with the given product_id.
#suggestion4 and suggestion5 are products that are not from the given products department, but if a customer purchases a product from another department, these products would be their top choices.
