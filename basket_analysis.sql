create Table transactions(
	product varchar(255),
	trans-id varchar(255)
	)

create Table product_freq(
	     product varchar(255),
	     freq int)

INSERT INTO product_freq (product, freq)
select product, count(*) from transactions Group by product order by count(*) desc

--selfjoin 

create Table shop_together(
		product1 varchar(255),
		product2 varchar(255),
		combo_freq int);

INSERT INTO shop_together (product1,product2,combo_freq)
select product1,product2, count(*) from full_basket Group by product1,product2 order by count(*) desc


DELETE FROM shop_together 
WHERE LOWER(product1) = LOWER(product2);

DELETE FROM shop_together 
WHERE LOWER(product1) > LOWER(product2);

Select count(*) from shop_together;

select t1.product1,t1.product2,t1.combo_freq, t1.profreq1, product_freq.freq as profreq2
from(select product1,product2,combo_freq, product_freq.freq as profreq1
	from shop_together
	Left Join product_freq
	on shop_together.product1 = product_freq.product
	) as t1
Left join product_freq
on t1.product2 = product_freq.product
limit 10;


create Table freq_table(
product1 varchar(255),
product2 varchar(255),
combo_freq int,
profreq1 int,
profreq2 int);

INSERT INTO freq_table (product1,product2,combo_freq,profreq1,profreq2)
select t1.product1,t1.product2,t1.combo_freq, t1.profreq1, product_freq.freq as profreq2
from(select product1,product2,combo_freq, product_freq.freq as profreq1
	from shop_together
	Left Join product_freq
	on shop_together.product1 = product_freq.product
	) as t1
Left join product_freq
on t1.product2 = product_freq.product;


Select count(distinct(trans_id)) as total_transact
From transactions;
--14962

--support
select product1,product2,combo_freq,profreq1,profreq2,round(((combo_freq/14962.00)*100),2) as support
from freq_table
limit 10;

--confedence
select product1,product2,combo_freq,profreq1,profreq2,
	   round(((combo_freq/14962.00)*100),2) as support,
	   (cast(combo_freq as float)/cast(profreq2 as float))*100 as cof1_2,
	   (cast(combo_freq as float)/cast(profreq1 as float))*100 as conf2_1
from freq_table
order by support desc
;

--lift
select product1,product2,combo_freq,profreq1,profreq2,
	   round(((combo_freq/14962.00)*100),2) as support,
	   (cast(combo_freq as float)/cast(profreq2 as float))*100 as cof1_2,
	   (cast(combo_freq as float)/cast(profreq1 as float))*100 as conf2_1,
	   (combo_freq/14962.00)/((profreq1/14962.00)*(profreq2/14962.00)) as lift
from freq_table
order by support desc
;

--adding to a new table
create Table FinalTable(
product1 varchar(255),
product2 varchar(255),
combo_freq int,
profreq1 int,
profreq2 int,
support	float(24),
cof1_2 float(24),
conf2_1 float(24),
lift float(24)
);

INSERT INTO FinalTable (product1,product2,combo_freq,profreq1,profreq2,support,cof1_2,conf2_1,lift)
select product1,product2,combo_freq,profreq1,profreq2,
	   round(((combo_freq/14962.00)*100),2) as support,
	   (cast(combo_freq as float)/cast(profreq2 as float))*100 as cof1_2,
	   (cast(combo_freq as float)/cast(profreq1 as float))*100 as conf2_1,
	   (combo_freq/14962.00)/((profreq1/14962.00)*(profreq2/14962.00)) as lift
from freq_table
order by support desc
;

Select * from FinalTable;

---- deleting lifts under 1 which means they are substintials and are not shopped togther
DELETE FROM finaltable 
WHERE Lift < 1;

----keeping just first 100 of supports. meaning just the pairs that are bought together in most of the total transactions.
select min(support)
from ( select support 
		FROM finaltable
		order by support desc
		limit 100) as tableT;

DELETE FROM finaltable 
WHERE support < 0.17;

