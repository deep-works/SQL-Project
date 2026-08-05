-- SQL Project: Hospital Management analysis

create database hospital_db;
use hospital_db;

create table patients (
	patient_id int primary key,
    patient_name varchar(100),
    gender varchar(10),
    age int,
    city varchar(50),
    registration_date date
);

create table doctors (
	doctor_id int primary key,
    doctor_name varchar(100),
    specialization varchar(100),
    department varchar(100)
);

create table appointments (
	appointment_id int primary key,
    patient_id int,
    doctor_id int,
    appointment_date date,
    appointment_status varchar(20),
    consultation_fee decimal(10,2),
    foreign key (patient_id) references patients (patient_id),
    foreign key (doctor_id) references doctors (doctor_id)
);

create table admissions (
	admission_id int primary key,
    patient_id int,
    admission_date date,
    discharge_date date,
    diagnosis varchar(100),
    treatment_cost decimal (10,2),
    foreign key (patient_id) references patients (patient_id)
);

insert into patients
values
	(1, 'Rahul Sen', 'Male', 38, 'Mumbai', '2026-05-18'),
    (2, 'Sunil Chetri', 'Male', 40, 'Delhi', '2026-05-25'),
    (3, 'Amrita Patel', 'Female', 59, 'Delhi', '2026-05-26'),
    (4, 'Subho Chaterjee', 'Male', 73, 'Kolkata', '2026-06-14'),
    (5, 'Laxmi Kalyan', 'Female', 29, 'Chennai', '2026-07-07');

insert into doctors
values
	(101, 'Dr. Soumya Singh', 'Cardiology' , 'Heart Care'),
    (102, 'Dr. Kajal Mehta', 'Orthopedics', 'Bone Care'),
    (103, 'Dr. Bhima Rao', 'Neurology', 'Neuro Care'),
    (104, 'Dr. Rehan Chaterjee', 'General Medicine', 'General');
    
insert into appointments
values
	(1001, 1, 101, '2026-07-27', 'Completed', 1000),
    (1002, 2, 102, '2026-07-27', 'Completed', 800),
    (1003, 3, 104, '2026-07-28', 'Completed', 600),
    (1004, 5, 103, '2026-08-02', 'Completed', 1400),
    (1005, 2, 104, '2026-08-04', 'Completed', 600),
    (1006, 3, 103, '2026-08-06', 'Pending', 1400);
    
insert into admissions
values
	(2601, 1, '2026-05-25', '2026-06-06', 'Heart Surgery', 235000),
    (2602, 2, '2026-06-10', '2026-06-18', 'Fracture', 65000),
    (2603, 4, '2026-06-14', '2026-06-16', 'Fever', 18000),
    (2604, 1, '2026-07-04', '2026-07-07', 'Cardiac Checkup', 50000);
    

-- Total patients
select count(patient_id) as "Total Patients" from patients;

-- Total admissions
select count(admission_id) as "Total Admissions" from admissions;

-- Total appointments
select count(appointment_id) as "Total Appointments" from appointments;

-- Appointment completion rate
select (((select count(*) from appointments where appointment_status = 'Completed')
	/ (select count(*) from appointments))
    * 100) as 'Appointment Completion Rate'
from appointments
order by 'Appointment Completion Rate'
limit 1;

-- ** Appointment completion rate - also another answer is "no need of 'from appointments' statements"
select (((select count(*) from appointments where appointment_status = 'Completed')
	/ (select count(*) from appointments))
    * 100) as 'Appointment Completion Rate';
    
-- Doctor-wise patient count: Total appointments per doctor
select d.doctor_name as 'Name of the Doctor', count(a.doctor_id) as 'Total appointments per doctor'
from appointments a join doctors d
on a.doctor_id = d.doctor_id
group by d.doctor_id, d.doctor_name;

-- Doctor-wise patient count: Unique patients per doctor
select d.doctor_name as 'Name of the Doctor', count(distinct(a.patient_id)) as 'Total unique patients appointments per doctor'
from appointments a join doctors d
on a.doctor_id = d.doctor_id
group by d.doctor_id, d.doctor_name;

-- Total revenue
select ((select sum(treatment_cost) from admissions)
+ (select sum(consultation_fee) from appointments)) as 'Total Revenue';

-- Department-wise Consultatiton revenue
select d.department, sum(ap.consultation_fee) as 'Total Consultatiton revenue'
from doctors d join appointments ap
on ap.doctor_id = d.doctor_id
group by d.department;

-- ** Department wise total (consultation fee + treatment cost) revenue
-- > We can't answer this query now, because for calculate 'department-wise total revenue' from the current database is not good approach.
-- > We need a seperate table for 'Departments'

-- Average consultation fee
select avg(consultation_fee) as "Average Consultation Fee" from appointments;

-- Average treatment cost
select avg(treatment_cost) as "Average Treatment Cost" from admissions;

-- Average length of stay
select avg(datediff(discharge_date, admission_date)) as 'Average Length of Stay' from admissions;

-- Monthly Admission Trend
select year(admission_date) as "Year", month(admission_date) as "Month", count(admission_id) as "Total Admission" 
from admissions
group by month(admission_date), year(admission_date)
order by year(admission_date), month(admission_date);

-- Readmission patients details
select p.patient_name, count(a.admission_id) as "Count Admission"
from patients p join admissions a
on p.patient_id = a.patient_id
group by p.patient_id, p.patient_name
having count(a.admission_id) > 1;

-- Readmission rate
select (select count(*) from ( select patient_id from admissions group by patient_id having count(admission_id) > 1) as readmitted)
	/ (select count(distinct(patient_id)) from admissions) * 100
as 'Readmission Rate';

-- Top doctors by patient volume
select d.doctor_id, d.doctor_name, count(distinct a.patient_id) as 'Patient Count'
from doctors d join appointments a
on d.doctor_id = a.doctor_id
group by d.doctor_id, d.doctor_name
order by count(distinct a.patient_id) desc;

-- Revenue by doctors (take consultation fee only here)
select d.doctor_name, sum(a.consultation_fee) as 'Total Revenue'
from appointments a join doctors d
on d.doctor_id = a.doctor_id
group by d.doctor_id, d.doctor_name
order by sum(a.consultation_fee) desc;

-- Patient distribution by city
select city, count(patient_id) as 'Number of Patients'
from patients
group by city
order by count(patient_id) desc;

-- Average Patient Age
select avg(age) as 'Average Patient Age' from patients;

