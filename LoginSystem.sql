CREATE DATABASE IF NOT EXISTS `LoginSystem`;
USE `LoginSystem`;

DROP TABLE IF EXISTS `TrainSchedules`;
DROP TABLE IF EXISTS `Reservations`;
DROP TABLE IF EXISTS `TransitLines`;
DROP TABLE IF EXISTS `Trains`;
DROP TABLE IF EXISTS `Stations`;
DROP TABLE IF EXISTS `Users`;
DROP TABLE IF EXISTS `Replies`;
DROP TABLE IF EXISTS `Customers`;
DROP TABLE IF EXISTS `Employees`;

-- Create Users Table
CREATE TABLE Users (
    `username` varchar(30) NOT NULL,
    `password` varchar(30) NOT NULL,
	`role` ENUM('customer', 'employee', 'admin') NOT NULL,
    PRIMARY KEY (`username`)
);
INSERT INTO `Users` (`username`, `password`, `role`) VALUES 
    ('admin', 'admin$', 'admin');

-- Create Trains Table
CREATE TABLE Trains (
    `TrainID` INT NOT NULL,
    `TrainName` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`TrainID`)
);
INSERT INTO `Trains` VALUES 
    (1001, 'Express A'), 
    (1002, 'Express B'), 
    (1003, 'Local C'),
    (1004, 'Express D'), 
    (1005, 'Local E'),
    (1006, 'Express F'),
    (1007, 'Intercity G'), 
    (1008, 'Rapid H');
    
CREATE TABLE Stations (
    `StationID` INT NOT NULL,
    `StationName` VARCHAR(100) NOT NULL,
    `City` VARCHAR(50) NOT NULL,
    `State` CHAR(2) NOT NULL,
    PRIMARY KEY (`StationID`)
);
INSERT INTO `Stations` VALUES 
    (1, 'Penn Station', 'New York', 'NY'), 
    (2, 'Union Station', 'Washington', 'DC'), 
    (3, 'Central Station', 'Chicago', 'IL'),
    (4, 'Grand Central', 'New York', 'NY'), 
    (5, 'Market Street Station', 'Philadelphia', 'PA'), 
    (6, 'Union Station', 'Boston', 'MA'),
    (7, 'Midtown Station', 'San Francisco', 'CA'), 
    (8, 'O’Hare International', 'Chicago', 'IL');

-- Create TransitLines Table
CREATE TABLE TransitLines (
    `LineID` INT NOT NULL AUTO_INCREMENT,
    `LineName` VARCHAR(100) NOT NULL,
    `TrainID` INT NOT NULL,
    `OriginStationID` INT NOT NULL,
    `DestinationStationID` INT NOT NULL,
    `Stops` INT NOT NULL,
    `Fare` DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (`LineID`),
    FOREIGN KEY (`TrainID`) REFERENCES Trains(`TrainID`),
    FOREIGN KEY (`OriginStationID`) REFERENCES Stations(`StationID`),
    FOREIGN KEY (`DestinationStationID`) REFERENCES Stations(`StationID`)
);
INSERT INTO TransitLines (
    LineName, TrainID, OriginStationID, DestinationStationID, Stops, Fare
) VALUES 
    ('Northeast Corridor', 1001, 1, 2, 5, 50.00),
    ('Coastal Express', 1002, 2, 3, 4, 60.00),
    ('Pacific Express', 1004, 4, 5, 6, 55.00), 
    ('West Coast Express', 1005, 5, 6, 3, 65.00),
    ('Midwest Line', 1006, 6, 7, 4, 70.00),
    ('Southern Express', 1007, 7, 8, 5, 75.00),
    ('Northern Line', 1008, 8, 4, 7, 80.00);

-- Create TrainSchedules Table
CREATE TABLE TrainSchedules (
    `ScheduleID` INT NOT NULL AUTO_INCREMENT,
    `LineID` INT NOT NULL,
    `Departure` DATETIME NOT NULL,
    `Arrival` DATETIME NOT NULL,
    `TravelTime` INT NOT NULL, 
    PRIMARY KEY (`ScheduleID`),
    FOREIGN KEY (`LineID`) REFERENCES TransitLines(`LineID`)
);
INSERT INTO TrainSchedules (
    LineID, Departure, Arrival, TravelTime
) VALUES 
    (1, '2024-12-01 08:00:00', '2024-12-01 10:00:00', 120),
    (2, '2024-12-02 14:00:00', '2024-12-02 16:30:00', 150),
    (3, '2024-12-05 15:00:00', '2024-12-05 17:30:00', 150),
    (4, '2024-12-06 16:00:00', '2024-12-06 18:30:00', 150),
    (5, '2024-12-07 18:00:00', '2024-12-07 20:00:00', 120);
    
CREATE TABLE Customers (
    `CustomerID` INT AUTO_INCREMENT PRIMARY KEY,
    `LastName` VARCHAR(50) NOT NULL,
    `FirstName` VARCHAR(50) NOT NULL,
    `Email` VARCHAR(100) UNIQUE NOT NULL,
    `Username` VARCHAR(30) UNIQUE NOT NULL,
    `Password` VARCHAR(30) NOT NULL
);
INSERT INTO `Customers` (`LastName`, `FirstName`, `Email`, `Username`, `Password`) VALUES 
    ('Smith', 'John', 'john.smith@example.com', 'johns', 'cust1$'),
    ('Doe', 'Jane', 'jane.doe@example.com', 'janed', 'cust2$'),
    ('Johnson', 'Emily', 'emily.johnson@example.com', 'emilyj', 'cust3$'),
    ('Davis', 'Michael', 'michael.davis@example.com', 'michaeld', 'cust4$'),
    ('Taylor', 'Rachel', 'rachel.taylor@example.com', 'rachelt', 'cust5$');


CREATE TABLE Employees (
    `EmployeeID` INT AUTO_INCREMENT PRIMARY KEY,
    `SSN` VARCHAR(11) UNIQUE NOT NULL,
    `LastName` VARCHAR(50) NOT NULL,
    `FirstName` VARCHAR(50) NOT NULL,
    `Username` VARCHAR(30) UNIQUE NOT NULL,
    `Password` VARCHAR(30) NOT NULL
);
INSERT INTO `Employees` (`SSN`, `LastName`, `FirstName`, `Username`, `Password`) VALUES 
    ('123-45-6789', 'Walker', 'Anna', 'annaw', 'emp1$'),
    ('987-65-4321', 'Evans', 'Samuel', 'samuele', 'emp2$'),
    ('567-89-1234', 'White', 'Chris', 'chrisw', 'emp3$'),
    ('876-54-3210', 'Lewis', 'Sophia', 'sophial', 'emp4$'),
    ('345-67-8901', 'Harris', 'Daniel', 'danielh', 'emp5$');


INSERT INTO `Users` (`username`, `password`, `role`)
SELECT `Username`, `Password`, 'customer' AS `role` FROM `Customers`
UNION
SELECT `Username`, `Password`, 'employee' AS `role` FROM `Employees`;

CREATE TABLE Reservations (
    `ReservationID` INT AUTO_INCREMENT PRIMARY KEY,
    `CustomerID` INT NOT NULL,
    `LineID` INT NOT NULL,
    `OriginStationID` INT NOT NULL,
    `DestinationStationID` INT NOT NULL,
    `DepartureDateTime` DATETIME NOT NULL,
    `ReservationDate` DATE NOT NULL,
    `TotalFare` DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (`CustomerID`) REFERENCES Customers(`CustomerID`),
    FOREIGN KEY (`LineID`) REFERENCES TransitLines(`LineID`),
    FOREIGN KEY (`OriginStationID`) REFERENCES Stations(`StationID`),
    FOREIGN KEY (`DestinationStationID`) REFERENCES Stations(`StationID`)
);
INSERT INTO `Reservations` (`CustomerID`, `LineID`, `OriginStationID`, `DestinationStationID`, `DepartureDateTime`, `ReservationDate`, `TotalFare`) VALUES 
    (1, 1, 1, 2, '2024-12-01 09:30:00', '2024-11-29', 50.00),
    (2, 2, 2, 3, '2024-12-02 14:30:00', '2024-11-30', 60.00),
    (3, 3, 3, 4, '2024-12-03 10:30:00', '2024-12-01', 70.00),
    (4, 4, 4, 5, '2024-12-04 15:00:00', '2024-12-02', 75.00),
    (5, 5, 5, 6, '2024-12-05 16:00:00', '2024-12-03', 80.00);


CREATE TABLE Replies (
    `ReplyID` INT AUTO_INCREMENT PRIMARY KEY,
    `CustomerID` INT NOT NULL,
    `EmployeeID` INT NOT NULL,
    `Message` TEXT NOT NULL,
    `ReplyDate` DATETIME NOT NULL,
    FOREIGN KEY (`CustomerID`) REFERENCES Customers(`CustomerID`),
    FOREIGN KEY (`EmployeeID`) REFERENCES Employees(`EmployeeID`)
);
INSERT INTO `Replies` (`CustomerID`, `EmployeeID`, `Message`, `ReplyDate`) VALUES 
    (1, 1, 'Can I get a refund for my reservation?', '2024-11-29 10:00:00'),
    (2, 2, 'How do I change my train schedule?', '2024-11-30 11:30:00'),
    (3, 3, 'Is there a discount for senior citizens?', '2024-12-01 14:00:00'),
    (4, 4, 'I would like to know about train delays.', '2024-12-02 09:15:00'),
    (5, 5, 'What is the maximum luggage allowance?', '2024-12-03 13:45:00');
