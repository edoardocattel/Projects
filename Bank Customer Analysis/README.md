**Bank Customer Analysis**

Project Description:

The company Banking Intelligence aims to develop a supervised machine learning model to predict the future behaviors of its customers, based on transactional data and product ownership characteristics. The purpose of the project is to create a denormalized table with a series of indicators (features) derived from the tables available in the database, representing customers’ behaviors and financial activities.

Objective:

Our goal is to create a feature table for training machine learning models, enriching customer data with various indicators calculated from their transactions and owned accounts. The final table will be keyed by customer ID and will contain both quantitative and qualitative information.

Added Value:

The denormalized table will allow extraction of advanced behavioral features for training supervised machine learning models, providing numerous benefits for the company:

* Customer behavior prediction: By analyzing transactions and product ownership, it is possible to identify behavioral patterns useful to predict future actions such as purchasing new products or closing accounts.

* Churn reduction: Using behavioral indicators, a model can be built to identify customers at risk of leaving, enabling timely interventions by the marketing team.

* Improved risk management: Segmentation based on financial behaviors helps identify high-risk customers and optimize credit and risk strategies.

* Personalized offers: Extracted features can be used to tailor product and service offers based on individual customers’ habits and preferences, thereby increasing customer satisfaction.

* Fraud prevention: Through analysis of transaction types and amounts, the model can detect behavioral anomalies indicative of fraud, improving security and prevention strategies.

These advantages will lead to overall improvements in business operations, enabling greater efficiency in customer management and sustainable business growth.

Database Structure:

The database (which you can download here) consists of the following tables:

* Customer: contains personal information about customers (e.g., age).

* Account: contains information about accounts owned by customers.

* Account_type: describes the different types of accounts available.

* Transaction_type: contains the types of transactions that can occur on accounts.

* Transactions: contains details of transactions made by customers on various accounts.

Behavioral Indicators to Calculate:

Indicators will be calculated for each individual customer (referred to by customer_id) and include:

Basic Indicators:

* Customer age (from the customer table).

Transaction Indicators:

* Number of outgoing transactions across all accounts.

* Number of incoming transactions across all accounts.

* Total amount transacted outgoing across all accounts.

* Total amount transacted incoming across all accounts.

Account Indicators:

* Total number of accounts owned.

* Number of accounts owned by type (one indicator per account type).

* Transaction Indicators by Account Type

* Number of outgoing transactions by account type (one indicator per account type).

* Number of incoming transactions by account type (one indicator per account type).

* Amount transacted outgoing by account type (one indicator per account type).

* Amount transacted incoming by account type (one indicator per account type).

Plan for Creating the Denormalized Table

Join Tables:

To build the final table, a series of joins between the tables available in the database will be necessary.

Calculate Indicators:

Behavioral indicators will be calculated using aggregation operations (SUM, COUNT) to obtain the required totals.

