-- create movie rental database
create database movie_rental;


-- use movie database 
use movie_rental ;

create table Movies
(Movie_id int primary key,
Title varchar(100),
Release_year int,
Genre varchar(100),
Rental_rate decimal(5,2));

create table Customers
(Customer_id int primary key,
Name varchar(100),
Phone varchar(10),
Membership_date date);

create table Rentals
(Rental_id int primary key,
Customer_id int,
 Movie_id int, 
 Rental_date date,
 Return_date date, 
 foreign key (customer_id) references customers(customer_id),
 foreign key (movie_id) references movies(movie_id));
 
 
create table Payments
(Payment_id int primary key,
Rental_id int,
Payment_Date date,
amount decimal(6,2),
 foreign key (rental_id) references Rentals(rental_id));
 
insert into movies
(Movie_id,Title, Release_year,Genre,Rental_rate) values
(1,"Vikram Veda","2022","Action Thriller",120.00),
(2,"Bahubali 2","2017","Epic",150.00),
(3,"The Avengers","2012","Superhero",250.00),
(4,"The Age Of Ultron","2015","Superhero",150.00),
(5,"Avengers Endgame","2019","Superhero",200.00),
(6,"Salaar","2023","Action Thriller",120.00),
(7,"KGF","2022","Action Thriller",200.00),
(8,"Pushpa 2","2024","Action Thriller",250.00),
(9,"Ala vaikunthpurramuloo","2020","Drama",140.00),
(10,"Surya The Soldier","2018","Action",150.00);


insert into customers values
(101,"Amit sharma","8945685854","2023-1-10"),
(102,"Priya verma","9866422245","2023-2-15"),
(103,"Rahul joshi","9875469352","2023-3-20"),
(104,"Riya patil","6589465238","2023-4-4"),
(105,"Rakesh gupta","8523697415","2023-5-1"),
(106,"Tejas chude","7894563219","2023-6-12"),
(107,"John Doe","6549871235","2023-7-15"),
(108,"Anil patel","7894567854","2023-8-16"),
(109,"Jacob smith","6547891234","2023-9-5"),
(110,"sunil narayan","1478523698","2023-10-9");

insert into rentals
(Rental_id,Customer_id,Movie_id,Rental_date,Return_date) 
values
(1001,101,1,"2026-4-8","2024-5-10"),
(1002,102,3,"2022-5-7","2024-5-11"),
(1003,103,2,"2025-6-9",null),
(1004,104,5,"2020-7-10","2024-7-13"),
(1005,105,1,"2023-8-11","2024-8-14"),
(1006,106,4,"2024-9-26",null),
(1007,107,7,"2019-10-21","2024-10-27"),
(1008,108,3,"2017-11-16","2024-11-30"),
(1009,109,6,"2025-12-29","2024-12-4"),
(1010,110,3,"2026-3-6","2024-4-6");

insert into payments values
(1,1001,"2022-4-9",150.00),
(2,1002,"2022-5-16",200.00),
(3,1003,"2022-4-8",190.00),
(4,1004,"2022-5-4",300.00),
(5,1005,"2022-7-9",400.00),
(6,1006,"2022-9-8",800.00),
(7,1007,"2022-4-7",700.00),
(8,1008,"2022-8-5",400.00),
(9,1009,"2022-11-5",500.00),
(10,1010,"2022-12-5",800.00);

select*from movies;
select*from customers;
select*from rentals;
select*from payments;

-- 1.  List all movies currently rented out (not yet returned)
select title,name,rental_date 
from rentals join movies on
rentals.movie_id = movies.movie_id 
join customers on rentals.customer_id = customers.customer_id
where rentals.return_date is null;


-- 1.  List all movies currently rented out (not yet returned) but in subquery 
select (select title from movies where movies.movie_id = rentals.movie_id) as title ,
(select name from customers where customers.customer_id = rentals.customer_id) as name, 
rental_date from rentals where return_date is null;


-- 2. Find the top 5 most rented movies of all time. 
select title, count(rental_id) as total_rentals 
from movies join rentals on 
rentals.movie_id = movies.movie_id 
group by title 
order by total_rentals desc
limit 5;

-- 2. Find the top 5 most rented movies of all time. based on sub query 
select title,
(select count(rental_id) from rentals where movies.movie_id = rentals.movie_id ) 
as total_rentals
from movies order by total_rentals desc limit 5 ;

-- 3. Calculate the total revenue generated from movie rentals per month. 
select date_format(payment_date,"%m") as month ,
sum(amount) as total_revenue 
from payments group by month;

-- 4. Identify customers who have rented the most movies.
select name, count(rental_id) as movies_rented 
from rentals 
join customers on 
rentals.customer_id = customers.customer_id
group by name;

-- 4. Identify customers who have rented the most movies. based on subquery
select name,
(select count(rental_id) from rentals where rentals.customer_id = customers.customer_id) 
as movie_rented from customers;

-- 5. Find the average rental duration for each movie.
select title, avg(datediff(return_date,rental_date)) as avg_days 
from movies join rentals 
on rentals.movie_id = movies.movie_id 
where rentals.return_date is not null 
group by title;


--  6. List customers with overdue rentals
select title,name,rental_date from  rentals
join customers on 
rentals.customer_id = customers.customer_id join 
movies on rentals.movie_id = movies.movie_id 
where return_date is null and 
datediff(curdate(),rental_date)>7;


--  7. Calculate the number of rentals per genre.
select genre,count(rental_id) as total_rentals
from movies join rentals on 
movies.movie_id = rentals.movie_id 
group by genre order by total_rentals desc;


--  8. Find movies that have never been rented. 
select title from movies 
left join rentals on 
movies.movie_id = rentals.movie_id 
where rentals.rental_id is null;


--  9. Identify the most profitable movie (highest total rental revenue)
select title,sum(amount) as total_revenue 
from movies join rentals on 
movies.movie_id = rentals.movie_id 
join payments on 
rentals.rental_id = payments.rental_id
group by title 
order by total_revenue desc 
limit 1;

select title, 
(select sum(amount) from payments where rental_id in 
(select rental_id from rentals where rentals.movie_id = movies.movie_id)) as total_revenue 
from movies order by total_revenue desc limit 1; 


-- 10. Find the busiest day of the week for rentals.
select dayname(rental_date) as day_name,
count(*) as total_rentals 
from rentals 
group by day_name 
order by total_rentals desc
limit 1;


select*from movies;
select*from customers;
select*from rentals;
select*from payments;