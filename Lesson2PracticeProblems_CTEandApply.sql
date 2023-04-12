-- (1) Create a listing of current employees, their names, job titles, years employed, and their current pay rate

select
    e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle, DATEDIFF(year,HireDate,getdate()) yearsEmployed, current_rate_table.Rate as CurrentPayRate
from HumanResources.Employee as e
left join Person.Person as p
on e.BusinessEntityID = p.BusinessEntityID
left join 
(-- table gets BusinessEntityID, Latest Rate Change Date and Pay Rate
    select  eph.BusinessEntityID, eph.RateChangeDate, eph.Rate
    from HumanResources.EmployeePayHistory as eph
    cross apply (select eph2.BusinessEntityID as max_id, max(eph2.RateChangeDate) as latestRateChange
            from HumanResources.EmployeePayHistory as eph2
            where eph.BusinessEntityID = eph2.BusinessEntityID
            group by eph2.BusinessEntityID
)   as max_table
    where eph.RateChangeDate = max_table.latestRateChange
) as current_rate_table
on current_rate_table.BusinessEntityID = e.BusinessEntityID
where CurrentFlag = 1
;




-- (2) For internet sales made to Alberta, Canada, list the name of the customer and order information about the first order each customer made.

-- (a) Subquery
select p.FirstName, p.LastName,
    soh.*
from Sales.SalesOrderHeader as soh
join (select CustomerID, min(SalesOrderID) as firstOrderID
        from Sales.SalesOrderHeader
        group by CustomerID) as FirstOrderTable
on soh.SalesOrderID = FirstOrderTable.firstOrderID
left join Person.Address as a
on soh.ShipToAddressID = a.AddressID
left join Person.StateProvince as sp
on a.StateProvinceID = sp.StateProvinceID
left join Sales.Customer as c
on soh.CustomerID = c.CustomerID
left join Person.Person as p
on c.PersonID = p.BusinessEntityID
WHERE
    sp.Name = 'Alberta'
    and soh.OnlineOrderFlag = 1;




-- (b) Apply
select p.FirstName, p.LastName, soh.*
from Sales.SalesOrderHeader as soh
cross apply (select CustomerID, min(SalesOrderID) as firstOrderID
            from Sales.SalesOrderHeader as soh2
            where soh2.CustomerID = soh.CustomerID
            group by CustomerID
) as caFirstOrderTable
left join Person.Address as a
on soh.ShipToAddressID = a.AddressID
left join Person.StateProvince as sp
on a.StateProvinceID = sp.StateProvinceID
left join Sales.Customer as c
on soh.CustomerID = c.CustomerID
left join Person.Person as p
on c.PersonID = p.BusinessEntityID
WHERE
    sp.Name = 'Alberta'
    and soh.OnlineOrderFlag = 1
    and soh.SalesOrderID = caFirstOrderTable.firstOrderID;


-- In Class Solution
select p.FirstName, p.LastName, soh.*
from Sales.SalesOrderHeader as soh
left join Person.Address as a
on soh.ShipToAddressID = a.AddressID
left join Person.StateProvince as sp
on a.StateProvinceID = sp.StateProvinceID
left join Sales.Customer as c
on soh.CustomerID = c.CustomerID
left join Person.Person as p
on c.PersonID = p.BusinessEntityID
cross apply (select top 1 SalesOrderID, orderdate, Subtotal 
            from Sales.SalesOrderHeader 
            where CustomerID = soh.CustomerID and OnlineOrderFlag = 1 order by OrderDate) caFirstOrderTable

WHERE
    sp.Name = 'Alberta'
    and soh.SalesOrderID = caFirstOrderTable.SalesOrderID;

-- (c) CTE
with cte_firstOrderTable AS 
(
    select CustomerID, min(SalesOrderID) as firstOrderID
    from Sales.SalesOrderHeader
    group by CustomerID
)
select p.FirstName, p.LastName,
    soh.*
from Sales.SalesOrderHeader as soh
join cte_firstOrderTable
on soh.SalesOrderID = cte_firstOrderTable.firstOrderID
left join Person.Address as a
on soh.ShipToAddressID = a.AddressID
left join Person.StateProvince as sp
on a.StateProvinceID = sp.StateProvinceID
left join Sales.Customer as c
on soh.CustomerID = c.CustomerID
left join Person.Person as p
on c.PersonID = p.BusinessEntityID
WHERE
    sp.Name = 'Alberta'
    and soh.OnlineOrderFlag = 1



