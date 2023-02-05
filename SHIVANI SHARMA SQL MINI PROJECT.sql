#Data Dictionary:
#Sl No	Column Name	Column Description
#1	Player	Name of the player and country the player belongs to
#2	Span	The duration of years between which the player was active 
#3	Mat	No of matches played by the player
#4	Inn	No of innings played by the player
#5	NO	No of matches the player was NOT OUT by the end of the match.
#6	Runs	Total number of runs scored by the player
#7	HS	Highest Score of the player
#8	Avg	Average runs scored by the player in all the matches
#9	100	No of centuries scored by the player
#10	50	No of fifties scored by the player
#11	0	No of Duck outs of the player
#12	Player Profile	Link to the profiles of the players

#Tasks to be performed:
#1.	Import the csv file to a table in the database.
 use supply_chain_project;
#2.	Remove the column 'Player Profile' from the table.
ALTER TABLE icc_test_batting_figures
DROP COLUMN player_profile ;
desc icc_test_batting_figures;
#3.	Extract the country name and player names from the given data and store it in separate columns for further usage.
with temp as 
(SELECT player, INSTR(player, "(") as p1
FROM icc_test_batting_figures)
select player, p1, substr(player, 1, p1-1) as Player_name,substr(player, p1 +1 ,length(player)-1) as Country_name
from temp;

alter table icc_test_batting_figures  add player_names varchar(50);
alter table icc_test_batting_figures add Country_names varchar(50);

update icc_test_batting_figures 
set player_names =substr(player, 1,INSTR(player, "(")-1) ;

update icc_test_batting_figures 
set country_names=substr(player,INSTR(player, "(") +1 ,length(player)+1);

#4.	From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.
with temp2 as
(select span, instr(span,"-") as p2
from icc_test_batting_figures)
select substr(span,1,p2-1) as start_year, substr(span,p2+1,length(span)) as end_year
from temp2;

alter table icc_test_batting_figures  add start_year int ;
alter table icc_test_batting_figures  add end_year int ;

update icc_test_batting_figures 
set start_year=substr(span,1,instr(span,"-")-1);

update icc_test_batting_figures 
set end_year= substr(span,instr(span,"-")+1,length(span));

desc icc_test_batting_figures;

#5.	The column 'HS' has the highest score scored by the player so far in any given match. The column also has details if the player 
    #had completed the match in a NOT OUT status. Extract the data and store the highest runs and the NOT OUT status in different columns.
  select player_names, hs,
  case
      when hs like '%*' then 'NOT OUT'
      else 'OUT'
end as status
FROM icc_test_batting_figures;

alter table icc_test_batting_figures add status_not_out varchar(50);

update icc_test_batting_figures
set status_not_out= case 
when hs like'%*' then 'NOT OUT'
ELSE 'OUT'
END ;

SELECT status_not_out from icc_test_batting_figures;


  
#6.	Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using 
    #the selection criteria of those who have a good average score across all matches for India.
    select player_names, span, avg 
    from icc_test_batting_figures
    where span like "%2019%" and country_names like '%india%'
    order by avg desc
    limit 6;
    
#7.	Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using the selection 
    #criteria of those who have the highest number of 100s across all matches for India.
   
     select player_names, span, 100_century
     from icc_test_batting_figures
     where span like "%2019%" and country_names like'%india%'
     order by  100_century desc
     limit 6;
    
   
#8.	Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players using 2 selection criteria 
    #of your own for India.
    select player_names, runs, inn
    from icc_test_batting_figures
    where country_names like "%india%" and span like "%2019%" and (mat>40)
    order by runs desc
    limit 6;

 
#9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, considering the players who were active in the year of 2019, create a set of batting 
    #order of best 6 players using the selection criteria of those who have a good average score across all matches for South Africa.
    create view batting_order_goodavgscorers_SA as
	select player_names, avg
    from icc_test_batting_figures
    where span like '%2019%' and country_names like '%SA%' 
    order by avg desc
    limit 6;

    select * from batting_order_goodavgscorers_SA;
  
    
#10.Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, considering the players who were active in the year of 2019, 
    #create a set of batting order of best 6 players using the selection criteria of those who have highest number of 100s across all matches for South Africa.
    
    create view batting_order_highestcenturyscorers_SA as
	select player_names, 100_century
    from icc_test_batting_figures
    where span like '%2019%' and country_names like '%SA%' 
    order by 100_century desc
    limit 6;
    
    select * from batting_order_highestcenturyscorers_SA;

#11 Using the data given, Give the number of player_played for each country.
select country_names, count(player_names) as player_played
from icc_test_batting_figures
group by country_names
order by player_played desc;

#12.Using the data given, Give the number of player_played for Asian and Non-Asian continent

WITH TEMP AS
(SELECT country_names, player_names,
CASE
    WHEN country_names in ('INDIA)','ICC/INDIA)','SL)','PAK)','ICC/PAK)','BDESH)','ICC/SL)','INDIA/PAK)','AFG)','3) (PAK)')THEN 'ASIAN'
    ELSE 'NON-ASIAN'
END AS Continent
FROM icc_test_batting_figures)
SELECT continent,count(continent) as player_played
from temp 
group by continent;


#PART - B 


#1.	Company sells the product at different discounted rates. Refer actual product price in product table and selling price in the order item table. 
#Write a query to find out total amount saved in each order then display the orders from highest to lowest amount saved. 
with temp as
(select od.orderid, od.productid, p.unitprice as actual_product_price, od.unitprice as sellingprice, (p.unitprice-od.unitprice) as difference_amount,od.quantity
from orderitem od
left join product p
on od.productid=p.id)
select orderid,sum(difference_amount*quantity) as total_amount_saved
from temp
group by orderid
order by total_amount_saved desc;

#There are distinct 830 orderid and each orderid has different number of products being ordered, every product has a actual product price and a selling price. 
#The temp table displays all the products being ordered in each orderid. 

#2.	Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick: 
#a. List few products that he should choose based on demand.

select od.productid,p.productname, sum(od.quantity) as demand 
from orderitem od
left join product p
on p.id=od.productid
group by productid
order by demand desc
limit 10;

#b. Who will be the competitors for him for the products suggested in above questions.
with temp as
(select od.productid,p.productname, sum(od.quantity) as demand 
from orderitem od
left join product p
on p.id=od.productid
group by productid
order by demand desc
limit 10)
select p.supplierid, companyname
from temp
left join product p
on p.id= temp.productid
join supplier s
on s.id=p.supplierid ;

#3.	Create a combined list to display customers and suppliers details considering the following criteria 
#●	Both customer and supplier belong to the same country
#●	Customer who does not have supplier in their country
#●	Supplier who does not have customer in their country


#ANSWER 3
create view customer_and_supplier as
select o.id as orderid_1,  od.productid, p.supplierid, c.country as customer_country, s.country as supplier_counrty,
concat(c.firstname," ",c.lastname) as costumer_name, o.customerid,c.city as costumer_city, c.phone as costumer_contact,
s.companyname, s.contactname,s.contacttitle,s.city as supplier_city, s.phone as supplier_contact
from orders o
join orderitem od
on o.id=od.orderid
join product p
on p.id=od.productid
join customer c
on c.id=o.customerid
join supplier s
on s.id=p.supplierid;
#ANSWERA. Both customer and supplier belong to the same country
select costumer_name, customer_country, companyname, supplier_counrty
from customer_and_supplier
where customer_country=supplier_counrty;

#ANSWER 3B. Customer who does not have supplier in their country

select costumer_name, customer_country, companyname, supplier_counrty
from customer_and_supplier
where customer_country not in 
(select country from supplier);

#ANSWER 3C. Supplier who does not have customer in their country

select costumer_name, customer_country, companyname, supplier_counrty
from customer_and_supplier
where supplier_counrty not in 
(select country from customer);


#4.	Every supplier supplies specific products to the customers. Create a view of suppliers and total sales made by their products 
# and write a query on this view to find out top 2 suppliers (using windows function) in each country by total sales done by the products.

create view supplier__sales as
(select s.id,s.companyname,s.country,sum(o.unitprice*o.quantity) totamt
from supplier s join product p on s.id=p.supplierid
join orderitem o on p.id=o.productid group by companyname);

select * from
(select id,companyname,country,totamt,rank()over(partition by country order by totamt desc) rnk from supplier__sales) t
where rnk in(1,2)
order by rnk;

#5.	Find out for which products, UK is dependent on other countries for the supply. 
#List the countries which are supplying these products in the same list.

#ANSWER 5. These are products that customers in uk buy but which are not sold by suppliers in uk, rather other country's 
#suppliers supply them to uk customers.
select distinct p.productname,od.productid, c.country as customer_country, p.supplierid, s.country as supplier_country
from orderitem od
join orders o
on o.id=od.orderid
join customer c
on c.id=o.customerid
join product p
on p.id=od.productid
join supplier s
on s.id=p.supplierid
where c.country='uk' and s.country !='uk';

#List the countries which are supplying these products in the same list.

select distinct s.country as supplier_country
from orderitem od
join orders o
on o.id=od.orderid
join customer c
on c.id=o.customerid
join product p
on p.id=od.productid
join supplier s
on s.id=p.supplierid
where c.country='uk' and s.country !='uk';
#6.	Create two tables as ‘customer’ and ‘customer_backup’ as follow - 
#‘customer’ table attributes -
#Id, FirstName,LastName,Phone
#‘customer_backup’ table attributes - 
#Id, FirstName,LastName,Phone

#Create a trigger in such a way that It should inseicc_test_batting_figures rt the details into the  ‘customer_backup’ table when you delete the record from the ‘customer’ table automatically.
create table customer_1
(id int,
Firstname varchar(30),
Lastname varchar(30),
phone varchar(30));

insert into customer_1 values
(101,'rajndra','sharma',9425717163),
(102,'roopa','sharma',8888778977),
(103,'sonakshi','pal',9778566666),
(104,'shivani','sharma',8319655989),
(105,'prabhanshu','sharma',7805020065);


create table customer_backup
(id int,
Firstname varchar(30),
Lastname varchar(30),
phone varchar(30));

-- creating the trigger
create trigger backup_file
after delete 
on customer_1
for each row
insert into customer_backup values (old.id, old.firstname, old.lastname, old.phone);

delete from customer_1 where id=102;

select * from customer_1;
select * from customer_backup;