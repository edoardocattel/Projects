Project Description
The company Banking Intelligence aims to develop a supervised machine learning model to predict the future behaviors of its customers, based on transactional data and product ownership characteristics. The purpose of the project is to create a denormalized table with a series of indicators (features) derived from the tables available in the database, representing customers’ behaviors and financial activities.

Objective
Our goal is to create a feature table for training machine learning models, enriching customer data with various indicators calculated from their transactions and owned accounts. The final table will be keyed by customer ID and will contain both quantitative and qualitative information.

Added Value
The denormalized table will allow extraction of advanced behavioral features for training supervised machine learning models, providing numerous benefits for the company:

Customer behavior prediction: By analyzing transactions and product ownership, it is possible to identify behavioral patterns useful to predict future actions such as purchasing new products or closing accounts.

Churn reduction: Using behavioral indicators, a model can be built to identify customers at risk of leaving, enabling timely interventions by the marketing team.

Improved risk management: Segmentation based on financial behaviors helps identify high-risk customers and optimize credit and risk strategies.

Personalized offers: Extracted features can be used to tailor product and service offers based on individual customers’ habits and preferences, thereby increasing customer satisfaction.

Fraud prevention: Through analysis of transaction types and amounts, the model can detect behavioral anomalies indicative of fraud, improving security and prevention strategies.

These advantages will lead to overall improvements in business operations, enabling greater efficiency in customer management and sustainable business growth.

Database Structure
The database (which you can download here) consists of the following tables:

Customer: contains personal information about customers (e.g., age).

Account: contains information about accounts owned by customers.

Account_type: describes the different types of accounts available.

Transaction_type: contains the types of transactions that can occur on accounts.

Transactions: contains details of transactions made by customers on various accounts.

Behavioral Indicators to Calculate
Indicators will be calculated for each individual customer (referred to by customer_id) and include:

Basic Indicators

Customer age (from the customer table).

Transaction Indicators

Number of outgoing transactions across all accounts.

Number of incoming transactions across all accounts.

Total amount transacted outgoing across all accounts.

Total amount transacted incoming across all accounts.

Account Indicators

Total number of accounts owned.

Number of accounts owned by type (one indicator per account type).

Transaction Indicators by Account Type

Number of outgoing transactions by account type (one indicator per account type).

Number of incoming transactions by account type (one indicator per account type).

Amount transacted outgoing by account type (one indicator per account type).

Amount transacted incoming by account type (one indicator per account type).

Plan for Creating the Denormalized Table

Join Tables
To build the final table, a series of joins between the tables available in the database will be necessary.

Calculate Indicators
Behavioral indicators will be calculated using aggregation operations (SUM, COUNT) to obtain the required totals.
#FASE DESCRITTIVA
show databases like '%banca%';
use banca;
show tables;
describe cliente;
describe conto;
describe tipo_conto;
describe tipo_transazione;
describe transazioni;
select count(*) from cliente;
select count(*) from conto;
select count(*) from tipo_conto;
select count(*) from tipo_transazione;
select count(*) from transazioni;
select * from cliente limit 10;
select * from cliente group by id_cliente, nome, cognome, data_nascita having count(*) > 1;
select * from conto limit 10;
select * from conto group by id_conto, id_cliente, id_tipo_conto having count(*) > 1;
select * from tipo_conto;
select * from tipo_transazione;
select * from transazioni limit 10;
select * from transazioni group by data, id_tipo_trans, importo, id_conto having count(*) > 1;

#CREAZIONE TABELLA
create table ID_Cliente(
id_cliente int primary key,
età int
);
insert into ID_Cliente (id_cliente, età)
select id_cliente, timestampdiff(year, data_nascita, curdate())
from cliente;

#NUMERO TOTALE DI CONTI POSSEDUTI
set sql_safe_updates = 0;
alter table ID_Cliente
add column totale_conti int default 0;
update ID_Cliente id
left join (
	select cli.id_cliente, 
		count(con.id_conto) as totale_conti
	from cliente cli
	left join conto con
	on cli.id_cliente = con.id_cliente
	group by cli.id_cliente
) as sub on id.id_cliente = sub.id_cliente
set id.totale_conti = coalesce(sub.totale_conti, 0);
select * from ID_Cliente;

#NUMERO DI CONTI POSSEDUTI PER TIPOLOGIA
select * from tipo_conto;
alter table ID_Cliente
add column conto_base int default 0,
add column conto_business int default 0,
add column conto_privati int default 0,
add column conto_famiglie int default 0;
update ID_Cliente id
left join (
	select con.id_cliente,
		sum(case when con.id_tipo_conto = 0 then 1 else 0 end) as conto_base,
		sum(case when con.id_tipo_conto = 1 then 1 else 0 end) as conto_business,
		sum(case when con.id_tipo_conto = 2 then 1 else 0 end) as conto_privati,
		sum(case when con.id_tipo_conto = 3 then 1 else 0 end) as conto_famiglie
	from conto con
	group by con.id_cliente
) as sub on id.id_cliente = sub.id_cliente
set id.conto_base = coalesce(sub.conto_base, 0),
	id.conto_business = coalesce(sub.conto_business, 0),
	id.conto_privati = coalesce(sub.conto_privati, 0),
	id.conto_famiglie = coalesce(sub.conto_famiglie, 0);
select * from ID_Cliente limit 10;

#NUMERO DI TRANSAZIONI IN USCITA
select * from tipo_transazione;
select * from transazioni limit 10;
alter table ID_Cliente
add column tot_transazioni_uscita int default 0;
update ID_Cliente id
left join (
	select con.id_cliente,
		count(*) as tot_transazioni_uscita
	from transazioni trans
    inner join conto con on trans.id_conto = con.id_conto
    inner join tipo_transazione tipotrans on trans.id_tipo_trans = tipotrans.id_tipo_transazione
    where tipotrans.segno = '-'
    group by con.id_cliente
) as sub on id.id_cliente = sub.id_cliente
set id.tot_transazioni_uscita = coalesce(sub.tot_transazioni_uscita, 0);
select * from ID_Cliente limit 10;

#NUMERO DI TRANSAZIONI IN ENTRATA
alter table ID_Cliente
add column tot_transazioni_entrata int default 0;
update ID_Cliente id
left join (
	select con.id_cliente,
		count(*) as tot_transazioni_entrata
	from transazioni trans
    inner join conto con on trans.id_conto = con.id_conto
    inner join tipo_transazione tipotrans on trans.id_tipo_trans = tipotrans.id_tipo_transazione
    where tipotrans.segno = '+'
    group by con.id_cliente
) as sub on id.id_cliente = sub.id_cliente
set id.tot_transazioni_entrata = coalesce(sub.tot_transazioni_entrata, 0);
select * from ID_Cliente limit 10;

#IMPORTO TOTALE TRANSATO IN USCITA
alter table ID_Cliente
modify column tot_importo_uscita decimal(20,14) default 0;
update ID_Cliente id
left join (
	select con.id_cliente,
		sum(trans.importo) as tot_importo_uscita
	from transazioni trans
    inner join conto con on trans.id_conto = con.id_conto
    inner join tipo_transazione tipotrans on trans.id_tipo_trans = tipotrans.id_tipo_transazione
    where tipotrans.segno = '-'
    group by con.id_cliente
) as sub on id.id_cliente = sub.id_cliente
set id.tot_importo_uscita = coalesce(sub.tot_importo_uscita, 0);
select * from ID_Cliente limit 10;

#IMPORTO TOTALE TRANSATO IN ENTRATA
alter table ID_Cliente
add column tot_importo_entrata decimal(20,14) default 0;
update ID_Cliente id
left join (
	select con.id_cliente,
		sum(trans.importo) as tot_importo_entrata
	from transazioni trans
    inner join conto con on trans.id_conto = con.id_conto
    inner join tipo_transazione tipotrans on trans.id_tipo_trans = tipotrans.id_tipo_transazione
    where tipotrans.segno = '+'
    group by con.id_cliente
) as sub on id.id_cliente = sub.id_cliente
set id.tot_importo_entrata = coalesce(sub.tot_importo_entrata, 0);
select * from ID_Cliente limit 10;

#NUMERO DI TRANSAZIONI IN USCITA PER TIPOLOGIA DI CONTO
alter table ID_Cliente
modify column conto_base_uscite int default 0,
modify column conto_business_uscite int default 0,
modify column conto_privati_uscite int default 0,
modify column conto_famiglie_uscite int default 0;
update ID_Cliente id
left join (
	select con.id_cliente,
		sum(case when con.id_tipo_conto = 0 then 1 else 0 end) as conto_base_uscite,
        sum(case when con.id_tipo_conto = 1 then 1 else 0 end) as conto_business_uscite,
        sum(case when con.id_tipo_conto = 2 then 1 else 0 end) as conto_privati_uscite,
        sum(case when con.id_tipo_conto = 3 then 1 else 0 end) as conto_famiglie_uscite
	from transazioni trans
    inner join conto con on trans.id_conto = con.id_conto
    inner join tipo_transazione tipotrans on trans.id_tipo_trans = tipotrans.id_tipo_transazione
    where tipotrans.segno = '-'
    group by con.id_cliente, con.id_tipo_conto
    order by con.id_cliente, con.id_tipo_conto
) as sub on id.id_cliente = sub.id_cliente
set id.conto_base_uscite = coalesce(sub.conto_base_uscite, 0),
	id.conto_business_uscite = coalesce(sub.conto_business_uscite, 0),
    id.conto_privati_uscite = coalesce(sub.conto_privati_uscite, 0),
    id.conto_famiglie_uscite = coalesce(sub.conto_famiglie_uscite, 0);
select * from ID_Cliente limit 10;

#NUMERO DI TRANSAZIONI IN ENTRATA PER TIPOLOGIA DI CONTO
alter table ID_Cliente
add column conto_base_entrate int default 0,
add column conto_business_entrate int default 0,
add column conto_privati_entrate int default 0,
add column conto_famiglie_entrate int default 0;
update ID_Cliente id
left join (
	select con.id_cliente,
		sum(case when con.id_tipo_conto = 0 then 1 else 0 end) as conto_base_entrate,
        sum(case when con.id_tipo_conto = 1 then 1 else 0 end) as conto_business_entrate,
        sum(case when con.id_tipo_conto = 2 then 1 else 0 end) as conto_privati_entrate,
        sum(case when con.id_tipo_conto = 3 then 1 else 0 end) as conto_famiglie_entrate
	from transazioni trans
    inner join conto con on trans.id_conto = con.id_conto
    inner join tipo_transazione tipotrans on trans.id_tipo_trans = tipotrans.id_tipo_transazione
    where tipotrans.segno = '+'
    group by con.id_cliente, con.id_tipo_conto
    order by con.id_cliente, con.id_tipo_conto
) as sub on id.id_cliente = sub.id_cliente
set id.conto_base_entrate = coalesce(sub.conto_base_entrate, 0),
	id.conto_business_entrate = coalesce(sub.conto_business_entrate, 0),
    id.conto_privati_entrate = coalesce(sub.conto_privati_entrate, 0),
    id.conto_famiglie_entrate = coalesce(sub.conto_famiglie_entrate, 0);
select * from ID_Cliente limit 10;

#IMPORTO TRANSATO IN USCITA PER TIPOLOGIA DI CONTO
alter table ID_Cliente
add column conto_base_importo_uscite decimal(20,14) default 0,
add column conto_business_importo_uscite decimal(20,14) default 0,
add column conto_privati_importo_uscite decimal(20,14) default 0,
add column conto_famiglie_importo_uscite decimal(20,14) default 0;
update ID_Cliente id
left join (
	select con.id_cliente,
		sum(case when con.id_tipo_conto = 0 then trans.importo else 0 end) as conto_base_importo_uscite,
        sum(case when con.id_tipo_conto = 1 then trans.importo else 0 end) as conto_business_importo_uscite,
        sum(case when con.id_tipo_conto = 2 then trans.importo else 0 end) as conto_privati_importo_uscite,
        sum(case when con.id_tipo_conto = 3 then trans.importo else 0 end) as conto_famiglie_importo_uscite
	from transazioni trans
    inner join conto con on trans.id_conto = con.id_conto
    inner join tipo_transazione tipotrans on trans.id_tipo_trans = tipotrans.id_tipo_transazione
    where tipotrans.segno = '-'
    group by con.id_cliente, con.id_tipo_conto
    order by con.id_cliente, con.id_tipo_conto
) as sub on id.id_cliente = sub.id_cliente
set id.conto_base_importo_uscite = coalesce(sub.conto_base_importo_uscite, 0),
	id.conto_business_importo_uscite = coalesce(sub.conto_business_importo_uscite, 0),
    id.conto_privati_importo_uscite = coalesce(sub.conto_privati_importo_uscite, 0),
    id.conto_famiglie_importo_uscite = coalesce(sub.conto_famiglie_importo_uscite, 0);
select * from ID_Cliente limit 10;

#IMPORTO TRANSATO IN ENTRATA PER TIPOLOGIA DI CONTO
alter table ID_Cliente
add column conto_base_importo_entrate decimal(20,14) default 0,
add column conto_business_importo_entrate decimal(20,14) default 0,
add column conto_privati_importo_entrate decimal(20,14) default 0,
add column conto_famiglie_importo_entrate decimal(20,14) default 0;
update ID_Cliente id
left join (
	select con.id_cliente,
		sum(case when con.id_tipo_conto = 0 then trans.importo else 0 end) as conto_base_importo_entrate,
        sum(case when con.id_tipo_conto = 1 then trans.importo else 0 end) as conto_business_importo_entrate,
        sum(case when con.id_tipo_conto = 2 then trans.importo else 0 end) as conto_privati_importo_entrate,
        sum(case when con.id_tipo_conto = 3 then trans.importo else 0 end) as conto_famiglie_importo_entrate
	from transazioni trans
    inner join conto con on trans.id_conto = con.id_conto
    inner join tipo_transazione tipotrans on trans.id_tipo_trans = tipotrans.id_tipo_transazione
    where tipotrans.segno = '+'
    group by con.id_cliente, con.id_tipo_conto
    order by con.id_cliente, con.id_tipo_conto
) as sub on id.id_cliente = sub.id_cliente
set id.conto_base_importo_entrate = coalesce(sub.conto_base_importo_entrate, 0),
	id.conto_business_importo_entrate = coalesce(sub.conto_business_importo_entrate, 0),
    id.conto_privati_importo_entrate = coalesce(sub.conto_privati_importo_entrate, 0),
    id.conto_famiglie_importo_entrate = coalesce(sub.conto_famiglie_importo_entrate, 0);
select * from ID_Cliente limit 10;
set sql_safe_updates = 1;

#MODIFICHE FINALI
alter table ID_Cliente modify column tot_transazioni_uscita int after età;
alter table ID_Cliente modify column tot_transazioni_entrata int after tot_transazioni_uscita;
alter table ID_Cliente modify column tot_importo_uscita decimal(20,14) after tot_transazioni_entrata;
alter table ID_Cliente modify column tot_importo_entrata decimal(20,14) after tot_importo_uscita;

select * from ID_Cliente;
