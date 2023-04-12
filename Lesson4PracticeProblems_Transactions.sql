
BEGIN TRAN
-- (1) Increase the standard cost of the Tires and Tubes subcategory by 10%


UPDATE Production.Product
set StandardCost = (StandardCost * 1.1)
from Production.ProductSubcategory as subcat     
join Production.Product as p                           on subcat.ProductSubcategoryID = p.ProductSubcategoryID
where subcat.Name = 'Tires and Tubes'


-- (2) Update the ProductCostHistory table to reflect the change in cost for the products
-- End date the current row for the product's cost with the current date (getDate())
-- Add a new row with the updated cost, starting with the current date

-- Add end date and revise modified date for previous price
; with m as -- get max product start date
(
    select h.ProductID, max(StartDate) as maxStartDate
    from Production.ProductCostHistory as h
    join Production.Product as p                        on h.ProductID = p.ProductID
    join Production.ProductSubcategory as subcat        on p.ProductSubcategoryID = subcat.ProductSubcategoryID
    group by h.ProductID
)
update Production.ProductCostHistory
set EndDate = (GETDATE()), ModifiedDate = (GETDATE())
from Production.ProductCostHistory as h
join Production.Product as p                        on h.ProductID = p.ProductID
join Production.ProductSubcategory as subcat        on p.ProductSubcategoryID = subcat.ProductSubcategoryID
join m                                              on m.ProductID = h.ProductID
where m.maxStartDate = h.StartDate
    and subcat.Name = 'Tires and Tubes'



-- New Rows in ProductCostHistory for the price increases --
; with m as -- get max product start date
(
    select h.ProductID, max(StartDate) as maxStartDate
    from Production.ProductCostHistory as h
    join Production.Product as p                        on h.ProductID = p.ProductID
    join Production.ProductSubcategory as subcat        on p.ProductSubcategoryID = subcat.ProductSubcategoryID
    group by h.ProductID
),
mrecords AS -- get columns needed to copy Product ID, Start Date, StandardCost and Modified Date to new rows
(
    select p.ProductID, h.ModifiedDate as newStartDate, p.StandardCost as newStandardCost, h.ModifiedDate as modDate, subcat.Name as subcategoryName
    from Production.ProductCostHistory as h
    join Production.Product as p                        on h.ProductID = p.ProductID
    join Production.ProductSubcategory as subcat        on p.ProductSubcategoryID = subcat.ProductSubcategoryID
    join m                                              on m.ProductID = h.ProductID
    where m.maxStartDate = h.StartDate
    and subcat.Name = 'Tires and Tubes'
)
insert into Production.ProductCostHistory (ProductID, StartDate, StandardCost, ModifiedDate)
select ProductID, newStartDate, newStandardCost, modDate
from mrecords
where mrecords.subcategoryName = 'Tires and Tubes'     


commit





