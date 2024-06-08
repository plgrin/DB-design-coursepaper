-- Dimension Tables
CREATE TABLE DimCustomer (
    CustomerKey SERIAL PRIMARY KEY,
    CustomerID INT,
    Name VARCHAR(255),
    Email VARCHAR(255),
    Phone VARCHAR(20),
    Address VARCHAR(255),
    LicenseNumber VARCHAR(50),
    StartDate DATE,
    EndDate DATE,
    IsCurrent BOOLEAN
);

CREATE TABLE DimCarType (
    CarTypeKey SERIAL PRIMARY KEY,
    TypeID INT UNIQUE,
    TypeName VARCHAR(50)
);

CREATE TABLE DimCar (
    CarKey SERIAL PRIMARY KEY,
    CarID INT,
    TypeID INT,
    LicenseNumber VARCHAR(50),
    Make VARCHAR(50),
    Model VARCHAR(50),
    Year INT,
    FOREIGN KEY (TypeID) REFERENCES DimCarType(TypeID)
);

CREATE TABLE DimDate (
    DateKey SERIAL PRIMARY KEY,
    Date DATE,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT,
    Week INT,
    IsWeekend BOOLEAN
);

CREATE TABLE DimLocation (
    LocationKey SERIAL PRIMARY KEY,
    LocationID INT,
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50)
);

-- Fact Tables
CREATE TABLE FactBookings (
    BookingKey SERIAL PRIMARY KEY,
    BookingID INT,
    CustomerKey INT,
    CarKey INT,
    StartDateKey INT,
    EndDateKey INT,
    PickUpLocationKey INT,
    DropOffLocationKey INT,
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
    FOREIGN KEY (CarKey) REFERENCES DimCar(CarKey),
    FOREIGN KEY (StartDateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (EndDateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (PickUpLocationKey) REFERENCES DimLocation(LocationKey),
    FOREIGN KEY (DropOffLocationKey) REFERENCES DimLocation(LocationKey)
);

CREATE TABLE FactPayments (
    PaymentKey SERIAL PRIMARY KEY,
    PaymentID INT,
    BookingKey INT,
    Amount DECIMAL(10,2),
    PaymentDateKey INT,
    FOREIGN KEY (BookingKey) REFERENCES FactBookings(BookingKey),
    FOREIGN KEY (PaymentDateKey) REFERENCES DimDate(DateKey)
);
