# Blood Bank Management System

A Blood Bank Management System manages the complete lifecycle of blood, from collection through donation to blood transfer, within a healthcare environment. This project has two parts: a working front-end demo and a full relational database design.

**Live demo:** https://muhammadhilal072.github.io/Blood-Bank-Management-System/

## Part 1: Web demo (`index.html`)

A single-page app built with HTML, CSS, and JavaScript. Data is saved in your browser using `localStorage`, so there is no server or database behind it.

- **Donor registration:** name, age, gender, blood group, phone, and last donation date, with a table of registered donors and a delete button
- **Blood inventory:** add units for each of the 8 blood groups (A+, A-, B+, B-, O+, O-, AB+, AB-) and view current stock
- **Blood requests:** record patient requests with blood group, units, and contact, with a request history table

## Part 2: Database design (`blood_bank_schema.sql`)

A relational schema with 16 tables:

| Area   | Tables |
| People | `PERSON`, `DONOR`, `DONOR_PHONE`, `PATIENT` |
| Staff  | `STAFF`, `DOCTOR`, `TECHNICIAN`, `RECEPTIONIST` |
| Blood  | `BLOOD_TYPE`, `BLOOD_COMPATIBILITY`, `BLOOD_UNIT`, `STORAGE_UNIT` |
| Operations | `DONATION`, `BLOOD_REQUEST`, `TRANSFUSION`, `HOSPITAL` |

The file also includes sample `INSERT` statements. All data in it is fictional.

## Tech
HTML, CSS, JavaScript (`localStorage`), SQL (MySQL)

## How to run

**Web demo:** open `index.html` in your browser. No install needed.

**Database:** run `blood_bank_schema.sql` in MySQL or MySQL Workbench.

## Note
The web demo and the SQL schema are separate. Connecting them with a backend (Node.js and Express) is a planned next step.

## Author
Muhammad Hilal