 -- 1. Who is the senior most employee based on job title?
 
 select * from employee
 Order by levels desc
 limit 1;

 -- 2. Which countries has the most invoices?
 
 select count(*) as c, billing_country
 from invoice
 group by billing_country
 order by c desc;
 
 -- 3. What are the top 3 values of total invoice?
 
 select total from invoice
 order by total desc
 limit 3;
 
 -- 4. Which city has the best customers?
 
 select sum(total) as invoice_total, billing_city
 from invoice
 group by billing_city
 order by invoice_total desc
 
 -- 5. Who is the best customer?
 
 select customer.customer_id, customer.first_name, customer.last_name, sum (invoice.total) as total
 from customer
 join invoice on
 customer.customer_id = invoice.customer_id
 group by customer.customer_id
 order by total desc
 limit 1
 
 -- 6. Write a query to return the email, firstname, lastname and genre of all of rock music listeners.
 -- Return your list orderes alphabetically by email starting with A.
 
 select distinct email,first_name, last_name
 from customer
 join invoice on customer.customer_id = invoice.customer_id
 join invoice_line on invoice.invoice_id = invoice_line.invoice_id
 where track_id in
 ( select track_id from track
 Join genre on track.genre_id = genre.genre_id
 where genre.name like 'Rock') 
 Order by email
 
 -- 7. Write a query that returns the artist name and total track count of the top 10 rock brands?
 
 select artist.artist_id, artist.name, count (artist.artist_id) as Number_of_Songs
 from track
 Join album on album.album_id = track.album_id
 Join artist on artist.artist_id =  album.artist_id
 Join genre on genre.genre_id = track.genre_id
 where genre.name like 'Rock'
 Group by artist.artist_id
 Order by Number_of_Songs desc
 Limit 10
 
 -- 8. Return all the track names that have a song length longer than the everage song length.
 -- Return the name and milliseconds for each track, order by the song length with the longest songs listed first.
 
 select name, milliseconds
 from track
 where milliseconds >
 (select AVG(milliseconds) as Avg_Track_Length
 from track)
 Order by milliseconds desc
 
 -- 9. Find how much amount spent by each customer on artists? Write a query to return
 -- customer name, artist name and total spent?
 
 with Best_Selling_Artist as
 ( select artist.artist_id as Artist_id, artist.name as Artist_name,
  sum(invoice_line.unit_price * invoice_line.quantity) as Total_Sales
  from invoice_line
  Join track on track.track_id = invoice_line.track_id
  Join album on album.album_id = track.album_id
  Join artist on artist.artist_id = album.artist_id
  Group by 1
  Order by 3 desc
  limit 1
 )
 
 Select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity)as Amount_Spent
 from invoice i
 Join customer c on c.customer_id = i.customer_id
 Join invoice_line il on il.invoice_id = i.invoice_id
 Join track t on t.track_id = il.track_id
 Join album alb on alb.album_id = t.album_id
 Join Best_Selling_Artist bsa on bsa.artist_id = alb.artist_id
 group by 1,2,3,4
 order by 5 desc
 
 -- 10. Write a query that returns the country along with the top customer and how much they spent.
 -- For countries where the top amount spent is shared, provise all customer who speant this amount.
 
 with recursive
 customer_with_country as (
 select customer.customer_id, first_name, last_name, billing_country, sum(total)as Total_Spending
 from invoice
 Join customer on customer.customer_id = invoice.customer_id
 group by 1,2,3,4
 order by 2,3 desc),
 
 country_max_spending as(
 select billing_country, max(Total_Spending) as max_spending
 from customer_with_country
 group by billing_country)
 
 select cc.billing_country, cc.Total_Spending, cc.first_name, cc.last_name
 from customer_with_country cc
 Join country_max_spending ms on cc.billing_country = ms.billing_country
 where cc.total_spending = ms.max_spending
 order by 1;