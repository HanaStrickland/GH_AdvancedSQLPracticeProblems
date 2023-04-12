-- Create a SQL statement that produces an XML document of orders and the products on each order. 
-- Include the SalesOrderID, OrderDate, DueDate, PurchaseOrderNumber, CustomerID, Subtotal, Tax, Freight, and Total. 
-- Display the Products on each order as its own node in the XML within the order – include the productID, name, quantity ordered, unitprice, and unit discount. Include a root element, and ensure that all fields are elements other than the OrderID – this should be an attribute. 
-- Make sure that each order only shows up once. Only include the 5 most recent orders.


-- (1) XML

select top 5 soh.SalesOrderID as '@SalesOrderID', OrderDate, DueDate, PurchaseOrderNumber, CustomerID, SubTotal, TaxAmt, Freight, TotalDue,
(
    select p.ProductID as '@ProductID', p.Name as ProductName, d.OrderQty, d.UnitPrice, d.UnitPriceDiscount
    from Sales.SalesOrderDetail as d
    join Production.Product as p
    on d.ProductID = p.ProductID
    where soh.SalesOrderID = d.SalesOrderID
    for XML PATH ('Product'), root('Products'), TYPE
    
)

from Sales.SalesOrderHeader as soh
order by soh.SalesOrderID desc
for XML PATH('SalesOrderID'), root('Orders')

-- (2) JSON
select top 5 soh.SalesOrderID as 'Sales.OrderID', 
OrderDate as 'Sales.OrderDate', 
DueDate as 'Sales.DueDate', 
PurchaseOrderNumber as 'Sales.PurchaseOrderNumber', 
CustomerID as 'Sales.CustomerID', 
SubTotal as 'Sales.SubTotal', 
TaxAmt as 'Sales.TaxAmount', 
Freight as 'Sales.Freight', 
TotalDue as 'Sales.TotalDue',
(
    select 
        p.ProductID as 'Product.ProductID', 
        p.Name as 'Product.ProductName',
        d.OrderQty as 'Product.OrderQty',
        d.UnitPrice as 'Product.UnitPrice',
        d.UnitPriceDiscount as 'Product.UnitPriceDiscount'
    from Sales.SalesOrderDetail as d
    join Production.Product as p
    on d.ProductID = p.ProductID
    where soh.SalesOrderID = d.SalesOrderID
    for JSON PATH 
    
) as Products

from Sales.SalesOrderHeader as soh
order by soh.SalesOrderID desc
for JSON PATH, root ('Orders')


-- (3) XML Parsing: parse all the fields in the name and employment nodes. You will end up with multiple rows.


DECLARE @XML XML = '<Resume>
  <Name>
    <Prefix>Mr.</Prefix>
    <First>Stephen</First>
    <Middle>Y </Middle>
    <Last>Jiang</Last>
    <Suffix></Suffix>
  </Name>
  <Employment>
    <StartDate>1998-03-01Z</StartDate>
    <EndDate>2000-12-30Z</EndDate>
    <OrgName>Wide World Imports</OrgName>
    <JobTitle>Sales Manager</JobTitle>
    <Responsibility> Managed a sales force of 20 sales representatives and 5 support staff distributed across 5 states. Also managed relationships with vendors for lead generation.
Lead the effort to leverage IT capabilities to improve communication with the field. Improved lead-to-contact turnaround by 15 percent. Did all sales planning and forecasting. Re-mapped territory assignments for maximum sales force productivity. Worked with marketing to map product placement to sales strategy and goals. 
Under my management, sales increased 10% per year at a minimum.
        </Responsibility>
    <FunctionCategory>Sales</FunctionCategory>
    <IndustryCategory>Import/Export</IndustryCategory>
    <Location>
      <Location>
        <CountryRegion>US </CountryRegion>
        <State>WA </State>
        <City>Renton</City>
      </Location>
    </Location>
  </Employment>
  <Employment>
    <StartDate>1992-06-14Z</StartDate>
    <EndDate>1998-06-01Z</EndDate>
    <OrgName>Fourth Coffee</OrgName>
    <JobTitle>Sales Associater</JobTitle>
    <Responsibility>Selling product to supermarkets and cafes. Worked heavily with value-add techniques to increase sales volume, provide exposure to secondary products.
Skilled at order development. Observed and built relationships with buyers that allowed me to identify opportunities for increased traffic.
        </Responsibility>
    <FunctionCategory>Sales</FunctionCategory>
    <IndustryCategory>Food and Beverage</IndustryCategory>
    <Location>
      <Location>
        <CountryRegion>US </CountryRegion>
        <State>WA </State>
        <City>Spokane</City>
      </Location>
    </Location>
  </Employment>
  <Education>
    <Level>Bachelor</Level>
    <StartDate>1986-09-15Z</StartDate>
    <EndDate>1990-05-20Z</EndDate>
    <Degree>Bachelor of Arts and Science</Degree>
    <Major>Business</Major>
    <Minor></Minor>
    <GPA>3.3</GPA>
    <GPAScale>4</GPAScale>
    <School>Louisiana Business College of New Orleans</School>
    <Location>
      <Location>
        <CountryRegion>US </CountryRegion>
        <State>LA</State>
        <City>New Orleans</City>
      </Location>
    </Location>
  </Education>
  <Address>
    <Type>Home</Type>
    <Street>30 151st Place SE</Street>
    <Location>
      <Location>
        <CountryRegion>US </CountryRegion>
        <State>WA </State>
        <City>Redmond</City>
      </Location>
    </Location>
    <PostalCode>98052</PostalCode>
    <Telephone>
      <Telephone>
        <Type>Voice</Type>
        <IntlCode>1</IntlCode>
        <AreaCode>425</AreaCode>
        <Number>555-1119</Number>
      </Telephone>
      <Telephone>
        <Type>Voice</Type>
        <IntlCode>1</IntlCode>
        <AreaCode>425</AreaCode>
        <Number>555-1981</Number>
      </Telephone>
    </Telephone>
  </Address>
  <EMail>Stephen@example.com</EMail>
  <WebSite></WebSite>
</Resume>'

select
    r.Resume.query('./Name/Prefix').value('.','varchar(20)') as Prefix,
    r.Resume.query('./Name/First').value('.','varchar(50)') as FirstName,
    r.Resume.query('./Name/Middle').value('.','varchar(1)') as MiddleInitial,
    r.Resume.query('./Name/Last').value('.','varchar(50)') as LastName,
    r.Resume.query('./Name/Suffix').value('.','varchar(20)') as Suffix,

    e.Employment.query('./StartDate').value('.','DATE') as StartDate,
    e.Employment.query('./EndDate').value('.','DATE') as EndDate,
    e.Employment.query('./OrgName').value('.','varchar(20)') as OrgName,
    e.Employment.query('./JobTitle').value('.','varchar(20)') as JobTitle,
    e.Employment.query('./Responsibility').value('.','varchar(20)') as Responsibility,
    e.Employment.query('./FunctionCategory').value('.','varchar(20)') as FunctionCategory,
    e.Employment.query('./IndustryCategory').value('.','varchar(20)') as IndustryCategory,
    l.Location.query('./CountryRegion').value('.','varchar(50)') as CountryRegion,
    l.Location.query('./State').value('.','varchar(50)') as State,
    l.Location.query('./City').value('.','varchar(50)') as City
from @XML.nodes('/Resume') r(Resume)
cross apply r.Resume.nodes('./Employment') e(Employment)
cross apply e.Employment.nodes('./Location/Location') as l(Location)


-- (4) JSON Parsing: Load the file into a new table you created.

DECLARE @JSON NVARCHAR(max) = '{"EmployeeChanges":
	[
		{"Person":{"NationalID":"30845",
				"FirstName":"David",
				"LastName":"Liu",
				"MiddleName":"J",
				"BirthDate":"1986-08-08",
				"MaritalStatus":"M",
				"Gender":"M",
				"Login":"adventure-works\\david6",
				"JobTitle":"Accounts Manager",
				"HireDate":"2012-03-03",
				"IsSalaried":true,
				"VacationHours":57,
				"SickLeaveHours":48,
				"CurrentFlag":false}},
		{"Person":{"NationalID":"363910111",
				"FirstName":"Barbara",
				"LastName":"Moreland",
				"MiddleName":"C",
				"BirthDate":"1979-02-04",
				"MaritalStatus":"M",
				"Gender":"F",
				"Login":"adventure-works\\barbara1",
				"JobTitle":"Accounts Manager",
				"HireDate":"2012-03-22",
				"IsSalaried":true,
				"VacationHours":80,
				"SickLeaveHours":49,
				"CurrentFlag":true}},
		{"Person":{"NationalID":"239356823",
				"FirstName":"Tom",
				"LastName":"Jones",
				"MiddleName":"A",
				"BirthDate":"1990-04-21",
				"MaritalStatus":"S",
				"Gender":"M",
				"Login":"adventure-works\\tom1",
				"JobTitle":"Accountant",
				"HireDate":"2018-12-01",
				"IsSalaried":true,
				"VacationHours":80,
				"SickLeaveHours":80,
				"CurrentFlag":true}},
		{"Person":{"NationalID":"399771419",
				"FirstName":"Jenny",
				"LastName":"Sommers",
				"MiddleName":"Joy",
				"BirthDate":"1997-02-18",
				"MaritalStatus":"S",
				"Gender":"F",
				"Login":"adventure-works\\jenny0",
				"JobTitle":"Help Desk Intern",
				"HireDate":"2019-01-15",
				"IsSalaried":false,
				"VacationHours":0,
				"SickLeaveHours":20,
				"CurrentFlag":true}}
	]
}'

SELECT NationalID, FirstName, LastName, MiddleName, BirthDate, MaritalStatus, Gender, LoginAdvWorks, JobTitle, HireDate, IsSalaried, VacationHours, SickLeaveHours, CurrentFlag
INTO TableEmployeeChanges
FROM OpenJson(@json, '$.EmployeeChanges')
WITH 
(
    Person NVARCHAR(MAX) '$.Person' AS JSON
) as peeps

CROSS APPLY OpenJSON(Peeps.Person)
WITH
(
    NationalID int '$.NationalID',
    FirstName varchar(50) '$.FirstName',
    LastName varchar(50) '$.LastName',
    MiddleName VARCHAR(50) '$.MiddleName',
    BirthDate DATE '$.BirthDate',
    MaritalStatus VARCHAR(1) '$.MaritalStatus',
    Gender VARCHAR(1) '$.Gender',
    LoginAdvWorks VARCHAR(100) '$.Login',
    JobTitle VARCHAR(50) '$.JobTitle',
    HireDate DATE '$.HireDate',
    IsSalaried BIT '$.IsSalaried',
    VacationHours int '$.VacationHours',
    SickLeaveHours int '$.SickLeaveHours',
    CurrentFlag BIT '$.CurrentFlag'
)

select * from TableEmployeeChanges
