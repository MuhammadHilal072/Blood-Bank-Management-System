--   BLOOD BANK MANAGEMENT SYSTEM

DROP DATABASE IF EXISTS BloodBankDB;
CREATE DATABASE BloodBankDB;
USE BloodBankDB;


-- TABLE 1: PERSON 
CREATE TABLE PERSON (
    SSN        VARCHAR(15)  PRIMARY KEY,
    Name       VARCHAR(100) NOT NULL,
    Address    VARCHAR(200),
    Gender     CHAR(1)      CHECK (Gender IN ('M','F')),
    Birth_Date DATE         NOT NULL
);

-- TABLE 2: BLOOD_TYPE
CREATE TABLE BLOOD_TYPE (
    BloodType_ID VARCHAR(5) PRIMARY KEY,
    Type_Name    VARCHAR(5) NOT NULL UNIQUE
);

-- TABLE 3: DONOR
CREATE TABLE DONOR (
    SSN          VARCHAR(15) PRIMARY KEY,
    CNIC         VARCHAR(15) NOT NULL UNIQUE,
    BloodType_ID VARCHAR(5)  NOT NULL,
    FOREIGN KEY (SSN)          REFERENCES PERSON(SSN)      ON DELETE CASCADE,
    FOREIGN KEY (BloodType_ID) REFERENCES BLOOD_TYPE(BloodType_ID)
);

-- TABLE 4: DONOR_PHONE
CREATE TABLE DONOR_PHONE (
    SSN   VARCHAR(15) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    PRIMARY KEY (SSN, Phone),
    FOREIGN KEY (SSN) REFERENCES DONOR(SSN) ON DELETE CASCADE
);

-- TABLE 5: STORAGE_UNIT
CREATE TABLE STORAGE_UNIT (
    Storage_ID    INT         PRIMARY KEY AUTO_INCREMENT,
    Location      VARCHAR(50),
    Capacity      INT         NOT NULL CHECK (Capacity > 0),
    Current_Count INT         NOT NULL DEFAULT 0,
    Temperature_C DECIMAL(4,1) NOT NULL CHECK (Temperature_C BETWEEN 2.0 AND 6.0)
);

-- TABLE 6: STAFF 
CREATE TABLE STAFF (
    SSN  VARCHAR(15) PRIMARY KEY,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Doctor','Technician','Receptionist')),
    FOREIGN KEY (SSN) REFERENCES PERSON(SSN) ON DELETE CASCADE
);

-- TABLE 7: DOCTOR 
CREATE TABLE DOCTOR (
    SSN            VARCHAR(15) PRIMARY KEY,
    Specialization VARCHAR(100),
    FOREIGN KEY (SSN) REFERENCES STAFF(SSN) ON DELETE CASCADE
);

-- TABLE 8: TECHNICIAN
CREATE TABLE TECHNICIAN (
    SSN       VARCHAR(15) PRIMARY KEY,
    Expertise VARCHAR(100),
    FOREIGN KEY (SSN) REFERENCES STAFF(SSN) ON DELETE CASCADE
);

-- TABLE 9: RECEPTIONIST
CREATE TABLE RECEPTIONIST (
    SSN   VARCHAR(15) PRIMARY KEY,
    Shift VARCHAR(20) CHECK (Shift IN ('Morning','Evening','Night')),
    FOREIGN KEY (SSN) REFERENCES STAFF(SSN) ON DELETE CASCADE
);

-- TABLE 10: DONATION
CREATE TABLE DONATION (
    Donation_ID   INT          PRIMARY KEY AUTO_INCREMENT,
    Donor_SSN     VARCHAR(15)  NOT NULL,
    Staff_SSN     VARCHAR(15)  NOT NULL,
    Donation_Date DATE         NOT NULL,
    Volume_ml     DECIMAL(6,2) NOT NULL CHECK (Volume_ml BETWEEN 350 AND 550),
    FOREIGN KEY (Donor_SSN) REFERENCES DONOR(SSN),
    FOREIGN KEY (Staff_SSN) REFERENCES STAFF(SSN)
);

-- TABLE 11: BLOOD_UNIT
CREATE TABLE BLOOD_UNIT (
    Unit_ID         INT         PRIMARY KEY AUTO_INCREMENT,
    Donation_ID     INT         NOT NULL,
    BloodType_ID    VARCHAR(5)  NOT NULL,
    Collection_Date DATE        NOT NULL,
    Expiry_Date     DATE        NOT NULL,
    Status          VARCHAR(15) NOT NULL DEFAULT 'Available'
                    CHECK (Status IN ('Available','Used','Expired','Reserved')),
    Storage_ID      INT         NOT NULL,
    FOREIGN KEY (Donation_ID)  REFERENCES DONATION(Donation_ID),
    FOREIGN KEY (BloodType_ID) REFERENCES BLOOD_TYPE(BloodType_ID),
    FOREIGN KEY (Storage_ID)   REFERENCES STORAGE_UNIT(Storage_ID)
);

-- TABLE 12: HOSPITAL
CREATE TABLE HOSPITAL (
    Hospital_ID INT          PRIMARY KEY AUTO_INCREMENT,
    Name        VARCHAR(150) NOT NULL,
    Address     VARCHAR(200),
    Contact     VARCHAR(20)
);

-- TABLE 13: BLOOD_REQUEST
CREATE TABLE BLOOD_REQUEST (
    Request_ID        INT         PRIMARY KEY AUTO_INCREMENT,
    Hospital_ID       INT         NOT NULL,
    BloodType_ID      VARCHAR(5)  NOT NULL,
    Quantity_Required INT         NOT NULL CHECK (Quantity_Required > 0),
    Request_Date      DATE        NOT NULL,
    Status            VARCHAR(15) NOT NULL DEFAULT 'Pending'
                      CHECK (Status IN ('Pending','Approved','Fulfilled','Rejected')),
    Approved_By       VARCHAR(15),
    FOREIGN KEY (Hospital_ID)  REFERENCES HOSPITAL(Hospital_ID),
    FOREIGN KEY (BloodType_ID) REFERENCES BLOOD_TYPE(BloodType_ID),
    FOREIGN KEY (Approved_By)  REFERENCES DOCTOR(SSN)
);

-- TABLE 14: PATIENT
CREATE TABLE PATIENT (
    Patient_ID   INT          PRIMARY KEY AUTO_INCREMENT,
    Hospital_ID  INT          NOT NULL,
    Name         VARCHAR(100) NOT NULL,
    BloodType_ID VARCHAR(5)   NOT NULL,
    FOREIGN KEY (Hospital_ID)  REFERENCES HOSPITAL(Hospital_ID),
    FOREIGN KEY (BloodType_ID) REFERENCES BLOOD_TYPE(BloodType_ID)
);

-- TABLE 15: TRANSFUSION
CREATE TABLE TRANSFUSION (
    Transfusion_ID   INT         PRIMARY KEY AUTO_INCREMENT,
    Patient_ID       INT         NOT NULL,
    Unit_ID          INT         NOT NULL UNIQUE,
    Doctor_SSN       VARCHAR(15) NOT NULL,
    Transfusion_Date DATE        NOT NULL,
    FOREIGN KEY (Patient_ID)  REFERENCES PATIENT(Patient_ID),
    FOREIGN KEY (Unit_ID)     REFERENCES BLOOD_UNIT(Unit_ID),
    FOREIGN KEY (Doctor_SSN)  REFERENCES DOCTOR(SSN)
);

-- TABLE 16: BLOOD_COMPATIBILITY
CREATE TABLE BLOOD_COMPATIBILITY (
    Donor_BT     VARCHAR(5) NOT NULL,
    Recipient_BT VARCHAR(5) NOT NULL,
    PRIMARY KEY (Donor_BT, Recipient_BT),
    FOREIGN KEY (Donor_BT)     REFERENCES BLOOD_TYPE(BloodType_ID),
    FOREIGN KEY (Recipient_BT) REFERENCES BLOOD_TYPE(BloodType_ID)
);


-- Insertion into tables 


-- BLOOD_TYPE
INSERT INTO BLOOD_TYPE VALUES
('BT1', 'A+'),
('BT2', 'A-'),
('BT3', 'B+'),
('BT4', 'B-'),
('BT5', 'AB+'),
('BT6', 'AB-'),
('BT7', 'O+'),
('BT8', 'O-');


-- BLOOD_COMPATIBILITY
INSERT INTO BLOOD_COMPATIBILITY VALUES
-- O- is universal donor
('BT8','BT1'), ('BT8','BT2'), ('BT8','BT3'), ('BT8','BT4'),
('BT8','BT5'), ('BT8','BT6'), ('BT8','BT7'), ('BT8','BT8'),
-- O+ can donate to all Rh+ types
('BT7','BT1'), ('BT7','BT3'), ('BT7','BT5'), ('BT7','BT7'),
-- A- can donate to A+, A-, AB+, AB-
('BT2','BT1'), ('BT2','BT2'), ('BT2','BT5'), ('BT2','BT6'),
-- A+ can donate to A+, AB+
('BT1','BT1'), ('BT1','BT5'),
-- B- can donate to B+, B-, AB+, AB-
('BT4','BT3'), ('BT4','BT4'), ('BT4','BT5'), ('BT4','BT6'),
-- B+ can donate to B+, AB+
('BT3','BT3'), ('BT3','BT5'),
-- AB- can donate to AB+, AB-
('BT6','BT5'), ('BT6','BT6'),
-- AB+ can only donate to AB+
('BT5','BT5');


-- PERSON
INSERT INTO PERSON (SSN, Name, Address, Gender, Birth_Date) VALUES
('111-22-3333', 'Ahmed Khan',     'House 5, Mardan',         'M', '1990-04-15'),
('222-33-4444', 'Sara Yousaf',    'Street 9, Peshawar',      'F', '1995-07-20'),
('333-44-5555', 'Bilal Nawaz',    'Block A, Swabi',          'M', '1988-11-03'),
('444-55-6666', 'Amna Tariq',     'Flat 2, Nowshera',        'F', '2000-01-28'),
('555-66-7777', 'Usman Ali',      'Mohalla X, Mardan',       'M', '1997-06-12'),
('601-00-0001', 'Dr. Hina Shah',  'Staff Colony, Mardan',    'F', '1980-03-10'),
('601-00-0002', 'Dr. Tariq Mir',  'Sector B, Peshawar',      'M', '1975-09-22'),
('601-00-0003', 'Zafar Hussain',  'Phase 1, Mardan',         'M', '1985-05-18'),
('601-00-0004', 'Nadia Rafiq',    'Town X, Swabi',           'F', '1992-08-30'),
('601-00-0005', 'Rehan Qureshi',  'Near Chowk, Mardan',      'M', '1988-12-01');


-- DONOR
INSERT INTO DONOR (SSN, CNIC, BloodType_ID) VALUES
('111-22-3333', '3630212345671', 'BT1'),
('222-33-4444', '3630198765432', 'BT3'),
('333-44-5555', '3630234567890', 'BT7'),
('444-55-6666', '3630256781234', 'BT2'),
('555-66-7777', '3630267894321', 'BT5');


-- DONOR_PHONE
INSERT INTO DONOR_PHONE (SSN, Phone) VALUES
('111-22-3333', '03001234567'),
('111-22-3333', '03219876543'),
('222-33-4444', '03121122334'),
('333-44-5555', '03334455667'),
('444-55-6666', '03451122334'),
('555-66-7777', '03009988776');


-- STAFF
INSERT INTO STAFF (SSN, Role) VALUES
('601-00-0001', 'Doctor'),
('601-00-0002', 'Doctor'),
('601-00-0003', 'Technician'),
('601-00-0004', 'Technician'),
('601-00-0005', 'Receptionist');


-- DOCTOR
INSERT INTO DOCTOR (SSN, Specialization) VALUES
('601-00-0001', 'Hematology'),
('601-00-0002', 'Transfusion Medicine');


-- TECHNICIAN
INSERT INTO TECHNICIAN (SSN, Expertise) VALUES
('601-00-0003', 'Blood Processing'),
('601-00-0004', 'Lab Analysis');


-- RECEPTIONIST
INSERT INTO RECEPTIONIST (SSN, Shift) VALUES
('601-00-0005', 'Morning');


-- STORAGE_UNIT
INSERT INTO STORAGE_UNIT (Location, Capacity, Current_Count, Temperature_C) VALUES
('Fridge A1', 50, 1, 4.0),
('Fridge A2', 40, 1, 3.5),
('Fridge B1', 60, 1, 4.5),
('Fridge B2', 45, 1, 3.8),
('Fridge C1', 55, 1, 4.2);


-- DONATION
INSERT INTO DONATION (Donor_SSN, Staff_SSN, Donation_Date, Volume_ml) VALUES
('111-22-3333', '601-00-0003', '2025-01-10', 450.00),
('222-33-4444', '601-00-0003', '2025-02-15', 500.00),
('333-44-5555', '601-00-0004', '2025-03-05', 400.00),
('444-55-6666', '601-00-0004', '2025-03-20', 475.00),
('555-66-7777', '601-00-0003', '2025-04-01', 350.00);


-- BLOOD_UNIT     -- Expiry of Blood = 42 days
INSERT INTO BLOOD_UNIT (Donation_ID, BloodType_ID, Collection_Date, Expiry_Date, Status, Storage_ID) VALUES
(1, 'BT1', '2025-01-10', '2025-02-21', 'Available', 1),
(2, 'BT3', '2025-02-15', '2025-03-29', 'Available', 2),
(3, 'BT7', '2025-03-05', '2025-04-16', 'Available', 3),
(4, 'BT2', '2025-03-20', '2025-05-01', 'Available', 4),
(5, 'BT5', '2025-04-01', '2025-05-13', 'Available', 5);


-- HOSPITAL
INSERT INTO HOSPITAL (Name, Address, Contact) VALUES
('Mardan Medical Complex',  'GT Road, Mardan',            '0937-200200'),
('Lady Reading Hospital',   'Phase 5, Peshawar',          '091-9210320'),
('Swabi District Hospital', 'Main Bazar, Swabi',          '0938-500123'),
('Nowshera Civil Hospital', 'Nowshera City',              '0923-610456'),
('KTH Hospital',            'University Road, Peshawar',  '091-9216460');


-- BLOOD_REQUEST
INSERT INTO BLOOD_REQUEST (Hospital_ID, BloodType_ID, Quantity_Required, Request_Date, Status, Approved_By) VALUES
(1, 'BT1', 3, '2025-04-05', 'Approved',  '601-00-0001'),
(2, 'BT3', 5, '2025-04-06', 'Pending',    NULL),
(3, 'BT7', 2, '2025-04-07', 'Approved',  '601-00-0002'),
(4, 'BT2', 4, '2025-04-08', 'Fulfilled', '601-00-0001'),
(5, 'BT5', 1, '2025-04-09', 'Rejected',  '601-00-0002');


-- PATIENT 
INSERT INTO PATIENT (Hospital_ID, Name, BloodType_ID) VALUES
(1, 'Khalid Mehmood', 'BT1'),
(2, 'Rukhsana Bibi',  'BT3'),
(3, 'Faisal Iqbal',   'BT7'),
(4, 'Zainab Noor',    'BT2'),
(5, 'Hamza Saeed',    'BT5');


-- TRANSFUSION               -- Unit must be 'Available' and blood type must be compatible
INSERT INTO TRANSFUSION (Patient_ID, Unit_ID, Doctor_SSN, Transfusion_Date) VALUES
(1, 1, '601-00-0001', '2025-04-10'),
(2, 2, '601-00-0002', '2025-04-11'),
(3, 3, '601-00-0001', '2025-04-12'),
(4, 4, '601-00-0002', '2025-04-13'),
(5, 5, '601-00-0001', '2025-04-14');


-- Mark transfused units as Used
UPDATE BLOOD_UNIT SET Status = 'Used' WHERE Unit_ID IN (1, 2, 3, 4, 5);


--   END OF SCRIPT
