/*
Utilizing the Library database (either your own or the Instructor answers:

Ensure each table has a clustered index
For bridge tables, make the clustered index be the two foreign keys that make up the 'original' primary key
Each table should still have a primary key constraint
Include unique indexes where appropriate
Index foreign keys as appropriate
Think through common search scenarios within the database and add at least 5 non-clustered indexes to assist with searches in the system
Include at least one filtered index
Include at least one columnstore index
Submit one sql file containing all the indexes. If it is easier, resubmit the db create script with the changes & additions
*/

-- Bridge tables: PatronFees, FeePaymets, Loans
-- filtered index: see Patron
-- Columnstore: see Payments
-- nonclustered indexes for searching: 1) AuthorFirstName, 2) AuthorLastName, 3) AuthorFirstName_AuthorLastName, 4) FirstName_LastName, 5) BirthDate

use master;
GO
drop DATABASE Library_System_20026_HS


use master;
GO
-- create the database

CREATE DATABASE Library_System_20026_HS
GO

Use Library_System_20026_HS
Go


-- Create Items --
create SEQUENCE seq_ItemID
start with 1
increment by 1
go

create table Items
(
    ItemID BIGINT default next value for seq_ItemID,
    BarcodeID VARCHAR(20) not null,
    Title VARCHAR(100) not null,
    ItemDescription VARCHAR(1000),
    YearPublished SMALLINT not null,
    AuthorLastName VARCHAR(50),
    AuthorFirstName VARCHAR(50),
    CallNumber VARCHAR(10),
    ReplacementCost NUMERIC(6,2),
    CategoryID TINYINT not null,                    
    ItemStatusCode CHAR(1) not null,             
    ItemTypeCode CHAR(1) not null,                
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null,
    ModifiedDateTime DATETIME not null,
    ModifiedBy VARCHAR(50) not null
    CONSTRAINT pk_Items PRIMARY KEY(ItemID),
    CONSTRAINT uk_Items_BarCodeID UNIQUE(BarcodeID)
)

create NONCLUSTERED INDEX IX_Items_AuthorFirstName
on dbo.Items(AuthorFirstName)

create NONCLUSTERED INDEX IX_Items_AuthorLasttName
on dbo.Items(AuthorLastName)

create NONCLUSTERED INDEX IX_Items_AuthorFirstName_LastName
on dbo.Items(AuthorFirstName,AuthorLastName)


-- Create ItemStatus --
create table ItemStatus
(
    ItemStatusCode  CHAR(1) not null,
    ItemStatusName VARCHAR(20) not null,
    IsActive BIT not null,
    InactiveDateTime DATETIME,
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null,
    ModifiedDateTime DATETIME not null,
    ModifiedBy VARCHAR(50) not null
    CONSTRAINT pk_ItemStatus PRIMARY KEY(ItemStatusCode),
    CONSTRAINT uk_ItemStatusName UNIQUE(ItemStatusName)
)

-- Created ItemType --

create table ItemType
(
    ItemTypeCode  CHAR(1) not null,
    ItemTypeName VARCHAR(20) not null,
    DefaultLoanPeriodInWeeks TINYINT not null,
    RenewalsAllowed BIT not null,
    RenewalPeriodInWeeks TINYINT not null,
    ItemTypeLimitPerCheckout TINYINT,
    ItemTypeLimitPerCard TINYINT,
    LateFeeAmountPerDay NUMERIC(4,2),
    LateFeeMaxAmount NUMERIC(4,2),
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null,
    ModifiedDateTime DATETIME not null,
    ModifiedBy VARCHAR(50) not null
    CONSTRAINT pk_ItemType PRIMARY KEY(ItemTypeCode),
    CONSTRAINT uk_ItemTypeName UNIQUE(ItemTypeName)
)

-- Create Category --
create table Category
(
    CategoryID TINYINT IDENTITY(1,1),
    CategoryName VARCHAR(50) not null,
    IsActive BIT not null,
    InactiveDateTime DATETIME,
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null,
    ModifiedDateTime DATETIME not null,
    ModifiedBy VARCHAR(50) not null
    CONSTRAINT pk_Category PRIMARY KEY(CategoryID),
    CONSTRAINT uk_CategoryName UNIQUE(CategoryName)
)

-- Alter Items: Foreign Keys --
alter table Items
    Add CONSTRAINT fk_Items_CategoryID FOREIGN KEY(CategoryID) REFERENCES Category(CategoryID)
        on UPDATE CASCADE
alter table Items
    Add CONSTRAINT fk_Items_ItemStatusCode FOREIGN KEY(ItemStatusCode) REFERENCES ItemStatus(ItemStatusCode)
        on UPDATE CASCADE
alter table Items
    Add CONSTRAINT fk_Items_ItemTypeCode FOREIGN KEY(ItemTypeCode) REFERENCES ItemType(ItemTypeCode)
        on UPDATE CASCADE

-- Foreign Key Indexes
create index IX_Items_CategoryID on Items(CategoryID)
create index ix_Items_ItemStatusCode on Items(ItemStatusCode)
create index ix_Items_ItemTypeCode on Items(ItemTypeCode)

-- Create Loans --
create table Loans
(
    LoanID BIGINT IDENTITY(1,1),
    ItemID BIGINT not null,
    PatronID BIGINT not null,
    CheckoutDateTime DATETIME not null,
    DueDate DATE not null,
    ReturnDate DATE not null,
    RenewalCount TINYINT not null,
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null,
    ModifiedDateTime DATETIME not null,
    ModifiedBy VARCHAR(50) not null
    CONSTRAINT pk_Loans PRIMARY KEY NONCLUSTERED (LoanID)
)
create UNIQUE CLUSTERED INDEX 
    IX_Loans_PatronID_ItemID on dbo.Loans(PatronID,ItemID) -- Should put the key you think will be used more first; therefore PatronID should probably be done before ItemID

create index ix_Loans_ItemID_PatronID on Loans(ItemID,PatronID) -- index b/c clustered index was sorted on PatronID

-- filtered index 
create index ix_Loans_CheckoutItems on Loans(PatronID,ItemID)
where ReturnDate IS NULL

-- Create Patron --
create SEQUENCE seq_PatronID
start with 1
increment by 1
go

create table Patron
(
    PatronID BIGINT default next value for seq_PatronID,
    BarcodeID VARCHAR(20) not null,
    FirstName VARCHAR(50) not null,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) not null,
    Suffix VARCHAR(20),
    BirthDate date not null,
    Address VARCHAR(50),
    City VARCHAR(30),
    StateProvince CHAR(2),
    ZipCode VARCHAR(10),
    ParentGuardianID BIGINT,
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null,
    ModifiedDateTime DATETIME not null,
    ModifiedBy VARCHAR(50) not null
    CONSTRAINT pk_Patron PRIMARY KEY(PatronID)
    CONSTRAINT fk_Loans_ParentGuardianID FOREIGN KEY (ParentGuardianID) REFERENCES Patron(PatronID),
    constraint uk_Patron_BarcodeID UNIQUE(BarcodeID)
)

create index ix_Patron_ParentGuardianID on Patron(ParentGuardianID)

create NONCLUSTERED index IX_Patron_HasParentGuardian
on dbo.Patron (PatronID)
INCLUDE (FirstName,LastName)
where ParentGuardianID is not null

create NONCLUSTERED INDEX IX_Patron_FirstName_LastName
on Patron(FirstName,LastName)

create NONCLUSTERED INDEX IX_Patron_BirthDate
on Patron(BirthDate) -- patrons get something special on their birthdays

-- Alter Loans: Foreign Keys --
alter table Loans
    Add CONSTRAINT fk_Loans_ItemID FOREIGN KEY(ItemID) REFERENCES Items(ItemID)
alter table Loans
    Add CONSTRAINT fk_Loans_PatronID FOREIGN KEY(PatronID) REFERENCES Patron(PatronID)
        on DELETE CASCADE

create index ix_Loans_ItemID on Loans(ItemID)
create index ix_Loans_PatronID on Loans(PatronID)

-- Create PaymentMethod --
create table PaymentMethod
(
    PaymentMethodID TINYINT not null,
    PaymentMethodName VARCHAR(30) not null,
    IsActive BIT not null,
    InactiveDateTime DATETIME not null,
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null,
    ModifiedDateTime DATETIME not null,
    ModifiedBy VARCHAR(50) not null
    CONSTRAINT pk_PaymentMethod PRIMARY KEY(PaymentMethodID),
    CONSTRAINT uk_PaymentMethodName UNIQUE(PaymentMethodName)
)


-- Create Payments --
create table Payments
(
    PaymentID int IDENTITY (1,1),
    PatronID BIGINT not null,
    DatePaid date not null,
    AmountPaid NUMERIC (5,2) not null,
    PaymentMethodID TINYINT not null,
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null
    CONSTRAINT pk_Payments PRIMARY KEY(PaymentID),
    CONSTRAINT fk_Payments_PatronID FOREIGN KEY (PatronID) REFERENCES Patron(PatronID)
        on DELETE CASCADE,
    CONSTRAINT fk_Payments_PaymentMethodID FOREIGN KEY(PaymentMethodID) References PaymentMethod(PaymentMethodID)
        on UPDATE CASCADE,
    CONSTRAINT ck_Payments_AmountPaid CHECK(AmountPaid >= 0)
)

create COLUMNSTORE index IX_PaymentMethod
on dbo.Payments(PaymentMethodID)

create index ix_Payments_PatronID on Payments(PatronID)
create index ix_Payments_PaymentMethodID on Payments(PaymentMethodID)


-- Create FeeType --
create TABLE FeeType
(
    FeeTypeCode char(2) not null,
    FeeTypeName VARCHAR(30) not null,
    IsActive BIT not null,
    InactiveDateTime DATETIME,
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null,
    ModifiedDateTime DATETIME not null,
    ModifiedBy VARCHAR(50) not null
    CONSTRAINT pk_FeeType PRIMARY KEY(FeeTypeCode),
    CONSTRAINT uk_FeeTypeName unique(FeeTypeName)
)

-- Create PatronFees --
create table PatronFees
(
    FeeID  BIGINT IDENTITY (1,1),
    PatronID BIGINT not null,
    ItemID bigint not null,
    FeeTypeCode CHAR(2) not null,
    DataAssessed date not null,
    FeeAmount numeric(4,2) not null,
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null
    CONSTRAINT pk_PatronFees PRIMARY KEY NONCLUSTERED (FeeID),
    CONSTRAINT fk_PatronFees_PatronID FOREIGN KEY(PatronID) REFERENCES Patron(PatronID)
        on DELETE CASCADE,
    CONSTRAINT fk_PatronFees_ItemID FOREIGN KEY(ItemID) REFERENCES Items(ItemID),
    CONSTRAINT fk_PatronFees_FeeTypeCode FOREIGN KEY(FeeTypeCode) REFERENCES FeeType(FeeTypeCode)
        on UPDATE CASCADE,
    CONSTRAINT ck_PatronFees_FeeAmount CHECK(FeeAmount >= 0)
)

create CLUSTERED INDEX -- remove UNIQUE because you could be late on the same book multiple imes
    IX_PatronFees_PatronID_ItemID_FeeTypeCode on dbo.PatronFees(PatronID,ItemID,FeeTypeCode)
create index ix_PatronFees_ItemID on PatronFees(ItemID,PatronID,FeeTypeCode)
create index ix_PatronFees_FeeTypeCode on PatronFees(FeeTypeCode) include (ItemID,PatronID)

-- Create FeePayments -- 
create table FeePayments
(
    FeePaymentID bigint IDENTITY (1,1),
    PaymentID int not null,
    FeeID bigint not null,
    PaymentAmount numeric(5,2),
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null
    CONSTRAINT pk_FeePayments PRIMARY KEY NONCLUSTERED (FeePaymentID),
    CONSTRAINT fk_FeePayments_PaymentID FOREIGN KEY(PaymentID) REFERENCES Payments(PaymentID),
    CONSTRAINT fk_FeePayments_FeeID FOREIGN KEY(FeeID) REFERENCES PatronFees(FeeID),
    CONSTRAINT ck_FeePayments_PaymentAmount CHECK(PaymentAmount >= 0)
)
create UNIQUE CLUSTERED INDEX
    IX_FeePayments_PaymentID_FeeID on dbo.FeePayments(PaymentID,FeeID)
create index ix_FeePayments_FeeId on FeePayments(FeeID,PaymentID)

-- Create Confiruation --
create table Configuration
(
    ConfigurationID smallint IDENTITY(1,1),
    ConfigurationName VARCHAR(30) not null,
    ConfigurationDescription VARCHAR(100),
    ConfigurationValue VARCHAR(20),
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null,
    ModifiedDateTime DATETIME not null,
    ModifiedBy VARCHAR(50) not null
    CONSTRAINT pk_Configuration_ConfigurationID PRIMARY KEY(ConfigurationID),
    CONSTRAINT uk_ConfigurationName unique(ConfigurationName)
)