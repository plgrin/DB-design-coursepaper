-- Function to load data from CSV files into the database
CREATE OR REPLACE FUNCTION load_data(
    customers_path TEXT,
    cartypes_path TEXT,
    cars_path TEXT,
    locations_path TEXT,
    bookings_path TEXT,
    payments_path TEXT,
    maintenance_path TEXT,
    customerhistory_path TEXT
)
RETURNS VOID AS $$
BEGIN
    -- Create temp table to load CSV data temporarily
    CREATE TEMP TABLE temp_customers (
        CustomerID INT,
        Name VARCHAR(255),
        Email VARCHAR(255),
        Phone VARCHAR(20),
        Address VARCHAR(255),
        LicenseNumber VARCHAR(50)
    );

    EXECUTE FORMAT('COPY temp_customers(CustomerID, Name, Email, Phone, Address, LicenseNumber) FROM %L DELIMITER '','' CSV HEADER', customers_path);

    -- Insert data into the Customers table, avoiding duplicates
    INSERT INTO Customers (CustomerID, Name, Email, Phone, Address, LicenseNumber)
    SELECT CustomerID, Name, Email, Phone, Address, LicenseNumber
    FROM temp_customers
    ON CONFLICT (CustomerID) DO NOTHING;

    -- Repeat for other tables
    CREATE TEMP TABLE temp_cartypes (
        TypeID INT,
        TypeName VARCHAR(50)
    );

    EXECUTE FORMAT('COPY temp_cartypes(TypeID, TypeName) FROM %L DELIMITER '','' CSV HEADER', cartypes_path);

    INSERT INTO CarTypes (TypeID, TypeName)
    SELECT TypeID, TypeName
    FROM temp_cartypes
    ON CONFLICT (TypeID) DO NOTHING;

    CREATE TEMP TABLE temp_cars (
        CarID INT,
        TypeID INT,
        LicenseNumber VARCHAR(50),
        Make VARCHAR(50),
        Model VARCHAR(50),
        Year INT
    );

    EXECUTE FORMAT('COPY temp_cars(CarID, TypeID, LicenseNumber, Make, Model, Year) FROM %L DELIMITER '','' CSV HEADER', cars_path);

    INSERT INTO Cars (CarID, TypeID, LicenseNumber, Make, Model, Year)
    SELECT CarID, TypeID, LicenseNumber, Make, Model, Year
    FROM temp_cars
    ON CONFLICT (CarID) DO NOTHING;

    CREATE TEMP TABLE temp_locations (
        LocationID INT,
        Address VARCHAR(255),
        City VARCHAR(50),
        State VARCHAR(50)
    );

    EXECUTE FORMAT('COPY temp_locations(LocationID, Address, City, State) FROM %L DELIMITER '','' CSV HEADER', locations_path);

    INSERT INTO Locations (LocationID, Address, City, State)
    SELECT LocationID, Address, City, State
    FROM temp_locations
    ON CONFLICT (LocationID) DO NOTHING;

    CREATE TEMP TABLE temp_bookings (
        BookingID INT,
        CustomerID INT,
        CarID INT,
        StartDate DATE,
        EndDate DATE,
        PickUpLocation INT,
        DropOffLocation INT
    );

    EXECUTE FORMAT('COPY temp_bookings(BookingID, CustomerID, CarID, StartDate, EndDate, PickUpLocation, DropOffLocation) FROM %L DELIMITER '','' CSV HEADER', bookings_path);

    INSERT INTO Bookings (BookingID, CustomerID, CarID, StartDate, EndDate, PickUpLocation, DropOffLocation)
    SELECT BookingID, CustomerID, CarID, StartDate, EndDate, PickUpLocation, DropOffLocation
    FROM temp_bookings
    ON CONFLICT (BookingID) DO NOTHING;

    CREATE TEMP TABLE temp_payments (
        PaymentID INT,
        BookingID INT,
        Amount DECIMAL(10, 2),
        PaymentDate DATE
    );

    EXECUTE FORMAT('COPY temp_payments(PaymentID, BookingID, Amount, PaymentDate) FROM %L DELIMITER '','' CSV HEADER', payments_path);

    INSERT INTO Payments (PaymentID, BookingID, Amount, PaymentDate)
    SELECT PaymentID, BookingID, Amount, PaymentDate
    FROM temp_payments
    ON CONFLICT (PaymentID) DO NOTHING;

    CREATE TEMP TABLE temp_maintenance (
        MaintenanceID INT,
        CarID INT,
        MaintenanceDate DATE,
        Details VARCHAR(255)
    );

    EXECUTE FORMAT('COPY temp_maintenance(MaintenanceID, CarID, MaintenanceDate, Details) FROM %L DELIMITER '','' CSV HEADER', maintenance_path);

    INSERT INTO Maintenance (MaintenanceID, CarID, MaintenanceDate, Details)
    SELECT MaintenanceID, CarID, MaintenanceDate, Details
    FROM temp_maintenance
    ON CONFLICT (MaintenanceID) DO NOTHING;

    CREATE TEMP TABLE temp_customerhistory (
        HistoryID INT,
        CustomerID INT,
        BookingID INT,
        PaymentID INT,
        Action VARCHAR(255),
        ActionDate TIMESTAMP
    );

    EXECUTE FORMAT('COPY temp_customerhistory(HistoryID, CustomerID, BookingID, PaymentID, Action, ActionDate) FROM %L DELIMITER '','' CSV HEADER', customerhistory_path);

    INSERT INTO CustomerHistory (HistoryID, CustomerID, BookingID, PaymentID, Action, ActionDate)
    SELECT HistoryID, CustomerID, BookingID, PaymentID, Action, ActionDate
    FROM temp_customerhistory
    ON CONFLICT (HistoryID) DO NOTHING;

    -- Drop the temp tables
    DROP TABLE IF EXISTS temp_customers;
    DROP TABLE IF EXISTS temp_cartypes;
    DROP TABLE IF EXISTS temp_cars;
    DROP TABLE IF EXISTS temp_locations;
    DROP TABLE IF EXISTS temp_bookings;
    DROP TABLE IF EXISTS temp_payments;
    DROP TABLE IF EXISTS temp_maintenance;
    DROP TABLE IF EXISTS temp_customerhistory;
END;
$$ LANGUAGE plpgsql;

-- Call the function for Dataset 1
SELECT load_data(
    '/study/ehu/year2/sem4/database/Coursepaper/dataset1/customers.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset1/car_types.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset1/cars.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset1/locations.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset1/bookings.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset1/payments.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset1/maintenance.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset1/customer_history.csv'
);

-- Call the function for Dataset 2
SELECT load_data(
    '/study/ehu/year2/sem4/database/Coursepaper/dataset2/customers.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset2/car_types.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset2/cars.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset2/locations.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset2/bookings.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset2/payments.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset2/maintenance.csv',
    '/study/ehu/year2/sem4/database/Coursepaper/dataset2/customer_history.csv'
);
