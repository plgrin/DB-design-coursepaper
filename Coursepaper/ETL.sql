-- Extract and Transform Customers (SCD Type 2)
WITH src AS (
    SELECT
        c.CustomerID,
        c.Name,
        c.Email,
        c.Phone,
        c.Address,
        c.LicenseNumber,
        CURRENT_DATE AS StartDate,
        CAST('9999-12-31' AS DATE) AS EndDate,
        TRUE AS IsCurrent
    FROM
        Customers c  
),
ins AS (
    INSERT INTO DimCustomer (CustomerID, Name, Email, Phone, Address, LicenseNumber, StartDate, EndDate, IsCurrent)
    SELECT
        src.CustomerID,
        src.Name,
        src.Email,
        src.Phone,
        src.Address,
        src.LicenseNumber,
        src.StartDate,
        src.EndDate,
        src.IsCurrent
    FROM src
    LEFT JOIN DimCustomer dc ON src.CustomerID = dc.CustomerID AND dc.IsCurrent = TRUE
    WHERE dc.CustomerKey IS NULL
    RETURNING *
)
UPDATE DimCustomer
SET EndDate = CURRENT_DATE - INTERVAL '1 day', IsCurrent = FALSE
FROM ins
WHERE DimCustomer.CustomerID = ins.CustomerID AND DimCustomer.IsCurrent = TRUE;


-- Extract and Load Car Types
INSERT INTO DimCarType (TypeID, TypeName)
SELECT
    ct.TypeID,
    ct.TypeName
FROM
    CarTypes ct
LEFT JOIN DimCarType dct ON ct.TypeID = dct.TypeID
WHERE dct.CarTypeKey IS NULL;


-- Extract and Load Cars
INSERT INTO DimCar (CarID, TypeID, LicenseNumber, Make, Model, Year)
SELECT
    c.CarID,
    c.TypeID,
    c.LicenseNumber,
    c.Make,
    c.Model,
    c.Year
FROM
    Cars c  
LEFT JOIN DimCar dc ON c.CarID = dc.CarID
WHERE dc.CarKey IS NULL;

-- Extract and Load Locations
INSERT INTO DimLocation (LocationID, Address, City, State)
SELECT
    l.LocationID,
    l.Address,
    l.City,
    l.State
FROM
    Locations l 
LEFT JOIN DimLocation dl ON l.LocationID = dl.LocationID
WHERE dl.LocationKey IS NULL;


-- Extract and Load Dates
INSERT INTO DimDate (DateKey, Date, Year, Quarter, Month, Day, Week, IsWeekend)
SELECT
    EXTRACT(EPOCH FROM d::DATE)::INT AS DateKey,
    d::DATE AS Date,
    EXTRACT(YEAR FROM d) AS Year,
    EXTRACT(QUARTER FROM d) AS Quarter,
    EXTRACT(MONTH FROM d) AS Month,
    EXTRACT(DAY FROM d) AS Day,
    EXTRACT(WEEK FROM d) AS Week,
    CASE WHEN EXTRACT(ISODOW FROM d) IN (6, 7) THEN TRUE ELSE FALSE END AS IsWeekend
FROM
    generate_series('2020-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) d
LEFT JOIN DimDate dd ON EXTRACT(EPOCH FROM d::DATE)::INT = dd.DateKey
WHERE dd.DateKey IS NULL;


-- Extract and Load Bookings
INSERT INTO FactBookings (BookingID, CustomerKey, CarKey, StartDateKey, EndDateKey, PickUpLocationKey, DropOffLocationKey)
SELECT
    b.BookingID,
    dc.CustomerKey,
    dcar.CarKey,
    dd1.DateKey,
    dd2.DateKey,
    dl1.LocationKey,
    dl2.LocationKey
FROM
    Bookings b  
JOIN DimCustomer dc ON b.CustomerID = dc.CustomerID AND dc.IsCurrent = TRUE
JOIN DimCar dcar ON b.CarID = dcar.CarID
JOIN DimDate dd1 ON EXTRACT(EPOCH FROM b.StartDate::DATE)::INT = dd1.DateKey
JOIN DimDate dd2 ON EXTRACT(EPOCH FROM b.EndDate::DATE)::INT = dd2.DateKey
JOIN DimLocation dl1 ON b.PickUpLocation = dl1.LocationID
JOIN DimLocation dl2 ON b.DropOffLocation = dl2.LocationID
LEFT JOIN FactBookings fb ON b.BookingID = fb.BookingID
WHERE fb.BookingID IS NULL;


-- Extract and Load Payments
INSERT INTO FactPayments (PaymentID, BookingKey, Amount, PaymentDateKey)
SELECT
    p.PaymentID,
    fb.BookingKey,
    p.Amount,
    dd.DateKey
FROM
    Payments p  
JOIN FactBookings fb ON p.BookingID = fb.BookingID
JOIN DimDate dd ON EXTRACT(EPOCH FROM p.PaymentDate::DATE)::INT = dd.DateKey
LEFT JOIN FactPayments fp ON p.PaymentID = fp.PaymentID
WHERE fp.PaymentID IS NULL;
