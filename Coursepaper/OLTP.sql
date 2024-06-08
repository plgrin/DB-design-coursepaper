--Tables
CREATE TABLE Customers (
    CustomerID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    LicenseNumber VARCHAR(50) NOT NULL
);

CREATE TABLE CarTypes (
    TypeID SERIAL PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL
);

CREATE TABLE Cars (
    CarID SERIAL PRIMARY KEY,
    TypeID INT NOT NULL,
    LicenseNumber VARCHAR(50) NOT NULL,
    Make VARCHAR(50),
    Model VARCHAR(50),
    Year INT,
    FOREIGN KEY (TypeID) REFERENCES CarTypes(TypeID)
);

CREATE TABLE Locations (
    LocationID SERIAL PRIMARY KEY,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(50),
    State VARCHAR(50)
);

CREATE TABLE Bookings (
    BookingID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    CarID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    PickUpLocation INT NOT NULL,
    DropOffLocation INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (CarID) REFERENCES Cars(CarID),
    FOREIGN KEY (PickUpLocation) REFERENCES Locations(LocationID),
    FOREIGN KEY (DropOffLocation) REFERENCES Locations(LocationID)
);

CREATE TABLE Payments (
    PaymentID SERIAL PRIMARY KEY,
    BookingID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate DATE NOT NULL,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

CREATE TABLE Maintenance (
    MaintenanceID SERIAL PRIMARY KEY,
    CarID INT NOT NULL,
    MaintenanceDate DATE NOT NULL,
    Details VARCHAR(255),
    FOREIGN KEY (CarID) REFERENCES Cars(CarID)
);

CREATE TABLE CustomerHistory (
    HistoryID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    BookingID INT NOT NULL,
    PaymentID INT NOT NULL,
    Action VARCHAR(255),
    ActionDate TIMESTAMP NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID),
    FOREIGN KEY (PaymentID) REFERENCES Payments(PaymentID)
);

--Indexes
CREATE INDEX idx_customer_email ON Customers (Email);
CREATE INDEX idx_car_license ON Cars (LicenseNumber);
CREATE INDEX idx_booking_dates ON Bookings (StartDate, EndDate);
CREATE INDEX idx_payment_date ON Payments (PaymentDate);

--Queries for Main Screens
--Query for Customer Information
SELECT * FROM Customers WHERE CustomerID = 1;

--Query for Available Cars
SELECT * FROM Cars 
WHERE CarID NOT IN (
    SELECT CarID FROM Bookings 
    WHERE StartDate <= '2023-06-20' AND EndDate >= '2023-07-21'
);

--Query for Booking Details
SELECT b.*, c.Name AS CustomerName, car.Make, car.Model 
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Cars car ON b.CarID = car.CarID
WHERE b.BookingID = 1;

--Functions and Procedures
--Function to Create a Booking
CREATE OR REPLACE FUNCTION CreateBooking (
    p_CustomerID INT,
    p_CarID INT,
    p_StartDate DATE,
    p_EndDate DATE,
    p_PickUpLocation INT,
    p_DropOffLocation INT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Bookings (CustomerID, CarID, StartDate, EndDate, PickUpLocation, DropOffLocation)
    VALUES (p_CustomerID, p_CarID, p_StartDate, p_EndDate, p_PickUpLocation, p_DropOffLocation);

    INSERT INTO CustomerHistory (CustomerID, BookingID, Action, ActionDate)
    VALUES (p_CustomerID, currval('Bookings_BookingID_seq'), 'Booking Created', NOW());
END;
$$ LANGUAGE plpgsql;

--Function to Process Payment
CREATE OR REPLACE FUNCTION ProcessPayment (
    p_BookingID INT,
    p_Amount DECIMAL,
    p_PaymentDate DATE
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Payments (BookingID, Amount, PaymentDate)
    VALUES (p_BookingID, p_Amount, p_PaymentDate);

    INSERT INTO CustomerHistory (CustomerID, BookingID, PaymentID, Action, ActionDate)
    SELECT b.CustomerID, p_BookingID, currval('Payments_PaymentID_seq'), 'Payment Processed', NOW()
    FROM Bookings b
    WHERE b.BookingID = p_BookingID;
END;
$$ LANGUAGE plpgsql;

--Triggers
--Trigger to Update Customer History on Booking Update
CREATE OR REPLACE FUNCTION trg_UpdateBooking()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO CustomerHistory (CustomerID, BookingID, Action, ActionDate)
    VALUES (NEW.CustomerID, NEW.BookingID, 'Booking Updated', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER UpdateBookingTrigger
AFTER UPDATE ON Bookings
FOR EACH ROW EXECUTE FUNCTION trg_UpdateBooking();

--Roles and Rights
CREATE ROLE RentalAdmin;
CREATE ROLE RentalUser;
-- RentalAdmin permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO RentalAdmin;

-- RentalUser permissions
GRANT SELECT ON ALL TABLES IN SCHEMA public TO RentalUser;



