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
    CONSTRAINT pk_Items PRIMARY KEY(ItemID)
)


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
    CONSTRAINT pk_Loans PRIMARY KEY(LoanID)
)

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
)

-- Alter Loans: Foreign Keys --
alter table Loans
    Add CONSTRAINT fk_Loans_ItemID FOREIGN KEY(ItemID) REFERENCES Items(ItemID)
alter table Loans
    Add CONSTRAINT fk_Loans_PatronID FOREIGN KEY(PatronID) REFERENCES Patron(PatronID)
        on DELETE CASCADE


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
    CONSTRAINT pk_Patron_Fees PRIMARY KEY(FeeID),
    CONSTRAINT fk_PatronFees_PatronID FOREIGN KEY(PatronID) REFERENCES Patron(PatronID)
        on DELETE CASCADE,
    CONSTRAINT fk_PatronFees_ItemID FOREIGN KEY(ItemID) REFERENCES Items(ItemID),
    CONSTRAINT fk_PatronFees_FeeTypeCode FOREIGN KEY(FeeTypeCode) REFERENCES FeeType(FeeTypeCode)
        on UPDATE CASCADE,
    CONSTRAINT ck_PatronFees_FeeAmount CHECK(FeeAmount >= 0)
    
)

-- Create FeePayments -- 
create table FeePayments
(
    FeePaymentID bigint IDENTITY (1,1),
    PaymentID int not null,
    FeeID bigint not null,
    PaymentAmount numeric(5,2),
    CreatedDateTime DATETIME not null,
    CreatedBy VARCHAR(50) not null
    CONSTRAINT pk_FeePayments PRIMARY KEY(FeePaymentID),
    CONSTRAINT fk_FeePayments_PaymentID FOREIGN KEY(PaymentID) REFERENCES Payments(PaymentID),
    CONSTRAINT fk_FeePayments_FeeID FOREIGN KEY(FeeID) REFERENCES PatronFees(FeeID),
    CONSTRAINT ck_FeePayments_PaymentAmount CHECK(PaymentAmount >= 0)
)

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

-- use master;
-- GO
-- drop DATABASE Library_System_20026_HS