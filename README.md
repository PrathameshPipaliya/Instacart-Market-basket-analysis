
**Instacart Market Basket Analysis**

most retail companies, Youtube, Amazon, Netflix, and so many companies are using market basket analysis to provide the best meaningful recommendations to customers to increase engagement or better sales. Market basket analysis is a powerful tool to convert transactional data into combinational product recommendations based on selected products. In this analysis, we'll find out how to perform market basket analysis by using the Instacart dataset.

---

**What is market basket Analysis?**

Market Basket Analysis is about finding frequently purchased items and providing recommendations based on an item that makes the most probable combination with the item which is purchased.

---

**How is Market Basket Analysis Used in Different Industries?**

**Retail:** By knowing the most commonly purchased items and providing the best combo offers and keeping products handy based on combinations

**E-commerce:** By proving recommendations based on the product page which is viewed by customers and providing similar items section

**Food Industry:** one can provide combo offers based on the maximum number of purchased items

**OTT Platforms & Social media:** we can suggest similar types of content based on users liking for the genre

**Telecommunication:** we can offer customers combo offers based on packages that go together

---

**Problem Statement**

The objective of this analysis is to perform a market basket analysis on the Instacart dataset. Market basket analysis involves analyzing customer purchase 
patterns and identifying associations between products frequently bought together. The goal is to derive actionable insights that can be used for product recommendations, cross-selling strategies, and inventory optimization.

---

**Dataset**

There is below tables which are used in analyzing this dataset

Each entity Customer, Product, Order, Aisle, etc has an associated unique id.

Most of the files and variable names are self-explanatory.

aisles.csv contains the aisle id and the products present in the aisle. For example, Pasta sauce, fresh pasta, etc.

Department.csv contains the name of all the departments and the department id. For example, Frozen, Bakery, Alcohol, etc.

Order_products.csv specifies which products were purchased in each order. order_products__prior.csv contains previous order contents for all customers. 
'reordered' indicates that the customer has a previous order that contains the product. Note that some orders will have no reordered items. You may predict an explicit 'None' value for orders with no reordered items.

Orders.csv tells to which set (prior, train, test) an order belongs. You are predicting reordered items only for the test set orders. 'order_dow' is the day of the week.

Product.csv file contains the product id, product name, department id, and aisle id.

---
**Exploratory Data Analysis**
Please Refer attached file

---
**Visual Analysis**

![download](https://github.com/PrathameshPipaliya/Instacart-Market-basket-analysis/assets/119769729/61dc65d0-4868-4d23-b6ee-eae3c610e352)

Here we can observe that the maximum number of orders contains 5–6 products in their orders.
There is a very low chance of having more than 20 products in the cart of any order

![Sheet 1](https://github.com/PrathameshPipaliya/Instacart-Market-basket-analysis/assets/119769729/df82ac24-9913-40d8-ab2a-25783c01c74f)
From the above plot, we can infer that the 10th hour of the day and the 15–16th hour of the day has peak time for orders.
From the above plot, we can access customer rush in the hours of the day.

![Sheet 2](https://github.com/PrathameshPipaliya/Instacart-Market-basket-analysis/assets/119769729/0dd600eb-e6fe-4018-9b9d-047410e33706)

Here is the plot for orders placed according to the day of the week. we can observe that there is a higher number of orders on the 0th and 1st day of the week.

![Sheet 3](https://github.com/PrathameshPipaliya/Instacart-Market-basket-analysis/assets/119769729/73d38518-0ef8-4ca4-a06e-99ff6ef154b0)

From the above plot, we can observe peaks on a weekly basis and a monthly basis.
There is a higher number of orders at a lower number of days_since_prior_order, which means there is more number of users who are used to order a regular basis.
On the basis of peaks in the plot, we can conclude that there are some items that are purchased on a monthly and weekly basis.

---
**Market Basket Analysis using MySQL**
Please Refer attached file

---
**Conclusion and Future Work**

In this blog, we have seen the market basket analysis based on the number of orders and products available in it. we can do further analysis based on Apriori or FP growth algorithm and develop a Machine Learning model for market basket analysis.

Based on the analysis, we can suggest the retailer, maintain the inventory based on our recommended combination of products available in the orders.

We can suggest designing a layout such that products and recommended products can be easily available to find by customers.

There can be a weekly and monthly rush for items, so be prepared for the inventory and better service to customers.

customers are purchasing organic products more frequently compared to others, so maintain availability and different varieties of organic items.

We have observed there are few peak hours for the sale, so plan accordingly for that time.

---

**References**

"The Instacart Online Grocery Shopping Dataset 2017", Accessed from https://www.instacart.com/datasets/grocery-shopping-2017 

https://scaler.com

https://towardsdatascience.com/a-gentle-introduction-on-market-basket-analysis-association-rules-fa4b986a40ce

https://www.analyticsvidhya.com/blog/2021/10/a-comprehensive-guide-on-market-basket-analysis/
