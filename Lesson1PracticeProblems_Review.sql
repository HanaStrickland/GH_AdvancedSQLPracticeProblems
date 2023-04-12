-- (1) Create a query of sales orders that occurred on 10/1/2020. 
--Include the order number and date, if the order was an online order, the customer’s first and last name, and the name of the company the order was for.

select SalesOrderID, convert(date,OrderDate) as Order_Date,
FirstName, LastName, store.Name as store_name,

case when OnlineOrderFlag = 1 then 'IsOnline'
else 'NotOnline'
end as IsOnlineOrder

from Sales.SalesOrderHeader as sorder
left join Sales.Customer as customer            on sorder.CustomerID = customer.CustomerID
left join Person.Person as person               on person.BusinessEntityID = customer.PersonID
left JOIN Sales.Store as store                  on store.BusinessEntityID = customer.StoreID

where Convert(date,OrderDate) = '2020-10-01'; -- can also use cast(orderdate as date)



-- (2) Create a query that lists the components currently necessary to build the produce 'ML Road Frame-W - Yellow, 38' (ProductID 822). 
--Include the name of both the product and the component, as well as the quantities. 



select p.Name as product_name, c.Name as component_name,
    PerAssemblyQty
from Production.BillOfMaterials as b
left join Production.Product as p           on b.ProductAssemblyID = p.ProductID -- Get Product Names
left join Production.Product as c           on b.ComponentID = c.ProductID        -- Get Component Names
where ProductAssemblyID = 822
and EndDate is null; -- remove parts not currently necessary 





-- (3) Create a query that displays customers with lifetime sales of $9,000 or more. 
--Display the total sales, the total tax, and the total freight. If the customer is a store, display the store name; otherwise display the customer’s name. 
--Sort by the customer’s name.

select sales.*,

case when s.Name is null then CONCAT(p.FirstName + ' ', p.LastName)
else s.Name
end as the_customer

from (select CustomerID, sum(SubTotal) as subtotal, sum(TaxAmt) as taxamount, sum(Freight) as freight, sum(TotalDue) as totaldue
    from Sales.SalesOrderHeader
    group by CustomerID
    having sum(SubTotal)>9000) as sales
left join Sales.Customer as c               on sales.CustomerID = c.CustomerID -- link order and customer
left join Person.Person as p                on c.PersonID = p.BusinessEntityID  -- link people
left join Sales.Store as s                  on c.StoreID = s.BusinessEntityID -- link stores
order by the_customer;



