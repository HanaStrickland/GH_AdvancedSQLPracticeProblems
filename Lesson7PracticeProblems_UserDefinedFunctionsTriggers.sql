/*
(1) Create a user-defined function that returns the name of a customer based on a CustomerID.  
    If the customer is a store, return the store name; if not, return their first and last name concatenated.
*/
CREATE FUNCTION Get_Customer_Name (@custID int)
RETURNS VARCHAR(100) AS
BEGIN

    DECLARE @CustomerName VARCHAR(100)

    ; with n as
    (
        select CustomerID, 
        case 
            when c.PersonID is null then s.Name
            else concat(p.FirstName, ' ', p.LastName) 
        end as TheCustomer
        from Sales.Customer as c
        left join Sales.Store as s
        on c.StoreID = s.BusinessEntityID
        left join Person.Person as p
        on c.PersonID = p.BusinessEntityID
    ) 
select @CustomerName = TheCustomer
From n
where CustomerID = @custID

    RETURN @CustomerName

END

-- select dbo.Get_Customer_Name(29485)


select c.CustomerID, dbo.Get_Customer_Name(c.CustomerID) as nameOfCustomer
from Sales.Customer as c




/*
(2) Create a user-defined function that returns all of a business entity's addresses. 
    Include the business entity ID, address type, both street addresses, city, state/province, postal code, and country.
*/

CREATE FUNCTION Get_Biz_Addresses (@BizEntityID int)
RETURNS TABLE
AS
RETURN


    select bea.BusinessEntityID, adt.Name as AddressType, a.AddressLine1, a.AddressLine2, a.City, psp.Name as StateOrProvince, a.PostalCode
    from Person.BusinessEntityAddress as bea
    left join Person.AddressType as adt
    on bea.AddressTypeID = adt.AddressTypeID
    left join Person.Address as a
    on bea.AddressID = a.AddressID
    left join Person.StateProvince as psp
    on a.StateProvinceID = psp.StateProvinceID
    where bea.BusinessEntityID = @BizEntityID
GO

--select * from dbo.Get_Biz_Addresses(932)


select * 
from Person.BusinessEntity be
cross apply dbo.Get_Biz_Addresses(be.BusinessEntityID) a
where be.BusinessEntityID > 900
order by be.BusinessEntityID

/*

(3) Create a trigger that automatically populates the Production.ProductListPrice history when the list price in the Production.Product table is changed. 
    The old list price row in the history table should be end-dated and a new row added with the current list price.
*/


CREATE TRIGGER trigger_insert_update_Product on Production.Product
FOR INSERT, UPDATE
AS
BEGIN

    IF UPDATE(ListPrice)

        BEGIN

                UPDATE Production.ProductListPriceHistory
                SET EndDate = GETDATE(), ModifiedDate = GETDATE()
                WHERE ProductID in (select i.ProductID FROM inserted i)
                and EndDate IS NULL
                END

        BEGIN

                INSERT INTO Production.ProductListPriceHistory
                SELECT i.ProductID, GETDATE(), NULL, i.ListPrice, GETDATE()
                FROM inserted as i

        END

END



-- UPDATE Production.Product
-- set ListPrice = 542.99
-- where ProductID = 999



--select * from Production.ProductListPriceHistory where ProductID = 1003
--select ProductID, Name, ListPrice from Production.Product where FinishedGoodsFlag = 1 and ProductID = 680

-- insert into Production.Product (Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel,ReorderPoint,StandardCost,ListPrice,DaysToManufacture,SellStartDate,rowguid,ModifiedDate)

-- VALUES ('Spiked Helmet', 'HU12345',0,1,1,1,12.99,19.99,0,GETDATE(),NEWID(),GETDATE())


