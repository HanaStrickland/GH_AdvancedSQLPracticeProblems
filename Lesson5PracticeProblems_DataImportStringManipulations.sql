-- Read all instructions
-- Import the csv file using the method of your choice. The file is also located on the server at D:\Backups\Archive\Adv_SQL\Lesson 5 Practice Problems.csv
-- Use SQL to split the address apart
-- Update the correct address type with the updated address
-- Either backup the original data into a separate table or use a transaction for this
-- Commit the changes to the database

BEGIN TRAN
Select @@TranCount

;with newAddressTable as
(
    select Business_Entity_ID, Store_Name, Address_Type, Address_1, 
    SUBSTRING(City_State_Postal,1, (CHARINDEX(',', City_State_Postal)) - 1) as City_Name,
    Reverse(SUBSTRING(REVERSE(City_State_Postal),(CHARINDEX(' ',REVERSE(City_State_Postal))+1),((CHARINDEX(',',REVERSE(City_State_Postal))-8)))) as State_Province,
    Reverse(SUBSTRING(REVERSE(City_State_Postal),1,(CHARINDEX(' ',REVERSE(City_State_Postal))-1))) as Zip_Code    
    from dbo.NewAddresses
),
newAddressTableWithStateName AS
(
    select 
        new1.Business_Entity_ID, new1.Store_Name, new1.Address_Type,new1.Address_1, new1.City_Name, StateProvince.StateProvinceID as State_Province_ID, new1.State_Province, new1.Zip_Code
    from Person.StateProvince as StateProvince
    join newAddressTable as new1                    on new1.State_Province = StateProvince.Name
)
UPDATE 
    Person.Address
SET
    AddressLine1 = new.Address_1,
    City = new.City_Name,
    StateProvinceID = new.State_Province_ID,
    PostalCode = new.Zip_Code,
    ModifiedDate = GETDATE()
from Person.BusinessEntityAddress as bea
join Sales.Store as s                           on bea.BusinessEntityID = s.BusinessEntityID
join Person.AddressType as t                        on bea.AddressTypeID = t.AddressTypeID
join Person.Address as a                            on bea.AddressId = a.AddressId
join Person.StateProvince as sp                     on a.StateProvinceID = sp.StateProvinceID
join newAddressTableWithStateName as new                         on bea.BusinessEntityID = new.Business_Entity_ID
WHERE
    bea.BusinessEntityID = new.Business_Entity_ID
    and t.Name = Address_Type



COMMIT
Select @@TranCount