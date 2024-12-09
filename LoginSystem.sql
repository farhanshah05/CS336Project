CREATE DATABASE IF NOT EXISTS `LoginSystem`;
USE `LoginSystem`;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS `TrainStops`;
DROP TABLE IF EXISTS `TrainSchedules`;
DROP TABLE IF EXISTS `TransitLines`;
DROP TABLE IF EXISTS `Trains`;
DROP TABLE IF EXISTS `Stations`;
DROP TABLE IF EXISTS `Users`;
DROP TABLE IF EXISTS `Customers`;
DROP TABLE IF EXISTS `Employees`;
DROP TABLE IF EXISTS `Conversations`;
DROP TABLE IF EXISTS `Messages`;

-- Create Users Table
CREATE TABLE Users (
    `username` VARCHAR(30) NOT NULL,
    `password` VARCHAR(30) NOT NULL,
    `role` ENUM('customer', 'employee', 'admin') NOT NULL,
    PRIMARY KEY (`username`)
);

-- Create Trains Table
CREATE TABLE Trains (
    `TrainID` INT NOT NULL,
    `TrainName` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`TrainID`)
);

-- Create Stations Table
CREATE TABLE Stations (
    `StationID` INT NOT NULL,
    `StationName` VARCHAR(100) NOT NULL,
    `City` VARCHAR(50) NOT NULL,
    `State` CHAR(2) NOT NULL,
    PRIMARY KEY (`StationID`)
);

-- Create TransitLines Table
CREATE TABLE TransitLines (
    `LineID` INT NOT NULL AUTO_INCREMENT,
    `LineName` VARCHAR(100) NOT NULL,
    `TrainID` INT NOT NULL,
    PRIMARY KEY (`LineID`),
    FOREIGN KEY (`TrainID`) REFERENCES Trains(`TrainID`)
);

-- Create TrainSchedules Table
CREATE TABLE TrainSchedules (
    `ScheduleID` INT NOT NULL AUTO_INCREMENT,
    `LineID` INT NOT NULL,
    PRIMARY KEY (`ScheduleID`),
    FOREIGN KEY (`LineID`) REFERENCES TransitLines(`LineID`)
);

-- Create TrainStops Table
CREATE TABLE TrainStops (
    `StopID` INT NOT NULL AUTO_INCREMENT,
    `ScheduleID` INT NOT NULL,
    `StationID` INT NOT NULL,
    `ArrivalTime` DATETIME NOT NULL,
    `DepartureTime` DATETIME NOT NULL,
    PRIMARY KEY (`StopID`),
    FOREIGN KEY (`ScheduleID`) REFERENCES TrainSchedules(`ScheduleID`),
    FOREIGN KEY (`StationID`) REFERENCES Stations(`StationID`)
);

-- Create Customers Table
CREATE TABLE Customers (
    `CustomerID` INT AUTO_INCREMENT PRIMARY KEY,
    `LastName` VARCHAR(50) NOT NULL,
    `FirstName` VARCHAR(50) NOT NULL,
    `Email` VARCHAR(100) UNIQUE NOT NULL,
    `Username` VARCHAR(30) UNIQUE NOT NULL,
    `Password` VARCHAR(30) NOT NULL
);

-- Create Employees Table
CREATE TABLE Employees (
    `EmployeeID` INT AUTO_INCREMENT PRIMARY KEY,
    `SSN` VARCHAR(11) UNIQUE NOT NULL,
    `LastName` VARCHAR(50) NOT NULL,
    `FirstName` VARCHAR(50) NOT NULL,
    `Username` VARCHAR(30) UNIQUE NOT NULL,
    `Password` VARCHAR(30) NOT NULL
);

-- Create Conversations Table
CREATE TABLE Conversations (
    `ConversationID` INT AUTO_INCREMENT PRIMARY KEY,
    `CustomerID` INT NOT NULL,
    `EmployeeID` INT NOT NULL,
    `StartDate` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `Status` ENUM('open', 'closed') DEFAULT 'open',
    FOREIGN KEY (`CustomerID`) REFERENCES Customers(`CustomerID`),
    FOREIGN KEY (`EmployeeID`) REFERENCES Employees(`EmployeeID`)
);

-- Create Messages Table
CREATE TABLE Messages (
    `MessageID` INT AUTO_INCREMENT PRIMARY KEY,
    `ConversationID` INT NOT NULL,
    `SenderID` INT NOT NULL,
    `ReceiverID` INT NOT NULL,
    `Message` TEXT NOT NULL,
    `Timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ConversationID`) REFERENCES Conversations(`ConversationID`)
);

-- Create Reservations Table
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

-- Insert manually constructed data into Users table
INSERT INTO Users (username, password, role) VALUES
    -- Customers
    ('johns', 'cust1$', 'customer'),
    ('janed', 'cust2$', 'customer'),
    ('emilyj', 'cust3$', 'customer'),
    ('michaeld', 'cust4$', 'customer'),
    ('rachelt', 'cust5$', 'customer'),
    -- Employees
    ('annaw', 'emp1$', 'employee'),
    ('samuele', 'emp2$', 'employee'),
    ('chrisw', 'emp3$', 'employee'),
    ('sophial', 'emp4$', 'employee'),
    ('danielh', 'emp5$', 'employee'),
    -- Admin
    ('admin', 'admin$', 'admin');

-- Insert Sample Data for Trains
INSERT INTO Trains VALUES 
    (1001, 'Express A'), 
    (1002, 'Express B'), 
    (1003, 'Local C'),
    (1004, 'Regional D'),
    (1005, 'Commuter E');

-- Insert Sample Data for Stations
INSERT INTO Stations VALUES 
    (1, 'Penn Station', 'New York', 'NY'), 
    (2, 'Union Station', 'Washington', 'DC'), 
    (3, 'Central Station', 'Chicago', 'IL'),
    (4, 'Grand Central', 'New York', 'NY'),
    (5, 'South Station', 'Boston', 'MA'),
    (6, 'Market Street Station', 'Philadelphia', 'PA'),
    (7, 'Midtown Station', 'San Francisco', 'CA'),
    (8, 'O’Hare International', 'Chicago', 'IL');

-- Insert Sample Data for TransitLines
INSERT INTO TransitLines (LineName, TrainID) VALUES 
    ('Northeast Corridor', 1001),
    ('Coastal Express', 1002),
    ('Midwest Local', 1003),
    ('Pacific Route', 1004),
    ('City Commuter', 1005);

-- Insert Sample Data for TrainSchedules
INSERT INTO TrainSchedules (LineID) VALUES 
    (1), (2), (3), (4), (5);

-- Insert Sample Data for Customers
INSERT INTO Customers (LastName, FirstName, Email, Username, Password) VALUES 
    ('Smith', 'John', 'john.smith@example.com', 'johns', 'cust1$'),
    ('Doe', 'Jane', 'jane.doe@example.com', 'janed', 'cust2$'),
    ('Johnson', 'Emily', 'emily.johnson@example.com', 'emilyj', 'cust3$'),
    ('Davis', 'Michael', 'michaeldavis@example.com', 'michaeld', 'cust4$'),
    ('Taylor', 'Rachel', 'racheltaylor@example.com', 'rachelt', 'cust5$');

-- Insert Sample Data for TrainStops
INSERT INTO TrainStops (ScheduleID, StationID, ArrivalTime, DepartureTime) VALUES 
    (1, 1, '2024-12-01 08:00:00', '2024-12-01 08:10:00'),
    (1, 2, '2024-12-01 10:00:00', '2024-12-01 10:15:00'),
    (1, 5, '2024-12-01 13:00:00', '2024-12-01 13:10:00'),
    (2, 3, '2024-12-02 09:00:00', '2024-12-02 09:10:00'),
    (2, 4, '2024-12-02 11:00:00', '2024-12-02 11:15:00'),
    (2, 6, '2024-12-02 14:00:00', '2024-12-02 14:20:00'),
    (3, 7, '2024-12-03 08:30:00', '2024-12-03 08:40:00'),
    (3, 8, '2024-12-03 11:00:00', '2024-12-03 11:15:00'),
    (4, 1, '2024-12-04 07:00:00', '2024-12-04 07:15:00'),
    (4, 2, '2024-12-04 10:00:00', '2024-12-04 10:15:00'),
    (4, 7, '2024-12-04 14:00:00', '2024-12-04 14:10:00'),
    (5, 6, '2024-12-05 06:00:00', '2024-12-05 06:10:00'),
    (5, 8, '2024-12-05 09:00:00', '2024-12-05 09:15:00');

-- Insert Sample Data for Employees
INSERT INTO Employees (SSN, LastName, FirstName, Username, Password) VALUES 
    ('123-45-6789', 'Walker', 'Anna', 'annaw', 'emp1$'),
    ('987-65-4321', 'Evans', 'Samuel', 'samuele', 'emp2$'),
    ('567-89-1234', 'White', 'Chris', 'chrisw', 'emp3$'),
    ('876-54-3210', 'Lewis', 'Sophia', 'sophial', 'emp4$'),
    ('345-67-8901', 'Harris', 'Daniel', 'danielh', 'emp5$');

-- Insert Sample Data for Conversations
INSERT INTO Conversations (CustomerID, EmployeeID, Status) VALUES
    (1, 1, 'open'),
    (2, 2, 'open'),
    (3, 3, 'closed'),
    (4, 4, 'open'),
    (5, 5, 'closed');

-- Insert Sample Data for Messages
INSERT INTO Messages (ConversationID, SenderID, ReceiverID, Message, Timestamp) VALUES
    (1, 1, 101, 'Can I get a refund for my ticket?', '2024-12-01 08:00:00'),
    (1, 101, 1, 'Sure, please provide your ticket details.', '2024-12-01 08:05:00'),
    (2, 2, 102, 'How do I reschedule my train?', '2024-12-02 14:00:00'),
    (2, 102, 2, 'You can reschedule online or I can assist you.', '2024-12-02 14:10:00'),
    (3, 3, 103, 'Is there a discount for students?', '2024-12-03 09:00:00'),
    (3, 103, 3, 'Yes, we offer 10%.', '2024-12-03 09:05:00'),
    (4, 4, 104, 'Are there any train delays for tomorrow?', '2024-12-04 10:00:00'),
    (4, 104, 4, 'Currently, there are no delays.', '2024-12-04 10:10:00'),
    (5, 5, 105, 'What is the luggage allowance?', '2024-12-05 11:00:00'),
    (5, 105, 5, 'You can carry up to 50lbs.', '2024-12-05 11:05:00');


-- Insert Sample Data into Reservations Table
INSERT INTO Reservations (CustomerID, LineID, OriginStationID, DestinationStationID, DepartureDateTime, ReservationDate, TotalFare) VALUES
    (1, 1, 1, 2, '2024-12-01 08:00:00', '2024-11-29', 50.00),
    (2, 1, 1, 5, '2024-12-01 10:00:00', '2024-11-30', 75.00),
    (3, 2, 3, 6, '2024-12-02 09:00:00', '2024-11-29', 65.00),
    (4, 3, 7, 8, '2024-12-03 14:30:00', '2024-12-01', 80.00),
    (5, 4, 4, 5, '2024-12-04 10:00:00', '2024-12-02', 55.00),
    (2, 5, 6, 7, '2024-12-05 11:00:00', '2024-12-03', 90.00),
    (3, 2, 2, 8, '2024-12-06 08:30:00', '2024-12-03', 100.00),
    (1, 1, 2, 4, '2024-12-07 07:00:00', '2024-12-04', 120.00),
    (4, 3, 3, 6, '2024-12-08 09:00:00', '2024-12-05', 45.00),
    (5, 5, 5, 7, '2024-12-09 15:00:00', '2024-12-06', 85.00);
