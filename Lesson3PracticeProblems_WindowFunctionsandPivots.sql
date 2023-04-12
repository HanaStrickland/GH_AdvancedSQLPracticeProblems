-- Hana Strickland
-- Lesson 3 Practice Problems
-- (1) For each store, calculate the lifetime total sales, the average order total, and the total number of orders. Display each store only once. Use window functions for this.


select distinct(store.Name) as storeName,

SUM(SubTotal) OVER
    (PARTITION BY store.Name) as storeLifetimeSubTotal,

AVG(SubTotal) OVER
         (PARTITION BY store.Name) AS storeAverageSubTotal,

COUNT(SalesOrderID) OVER
    (PARTITION BY store.Name) as numOfOrders


from Sales.SalesOrderHeader as soh
join Sales.Customer as c            on soh.CustomerID = c.CustomerID
join Sales.Store as store           on c.StoreID = store.BusinessEntityID


-- (2) Rank products by total number of units sold to show which products sell best. Display the name, the total units sold, and the ranking.
; with qtyTotals as
(select  
    p.Name, sum(OrderQty) as qtyTotal

from Sales.SalesOrderDetail as sod
left join Production.Product as p           on sod.ProductID = p.ProductID
GROUP BY p.Name) 

select 
    RANK() OVER (ORDER BY t.qtyTotal desc) as unitsSoldRank,
    t.Name,    
    t.qtyTotal
from qtyTotals as t
order by unitsSoldRank 


-- (3) Display each employee’s time-off hours as a separate row – one row for vacation hours, another for sick.

; with hoursTable as 
(select BusinessEntityID, timeOffType, timeOffHours
from HumanResources.Employee
UNPIVOT
    (timeOffHours for timeOffType in (VacationHours,SickLeaveHours)) as unpvt)
select p.FirstName, p.LastName, h.timeOffType, h.timeOffHours
from Person.Person as p
join hoursTable as h            on p.BusinessEntityID = h.BusinessEntityID