-- =============================================
-- MedSmile: Healthcare Satisfaction Monitoring System
-- PostgreSQL Data Warehouse Schema
-- =============================================

-- Database Setup
-- CREATE DATABASE medsmile;
-- \c medsmile;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS survey_fact CASCADE;
DROP TABLE IF EXISTS survey_dimension CASCADE;
DROP TABLE IF EXISTS emergency_service_dimension CASCADE;
DROP TABLE IF EXISTS patient_dimension CASCADE;
DROP TABLE IF EXISTS location_dimension CASCADE;
DROP TABLE IF EXISTS hospital_dimension CASCADE;
DROP TABLE IF EXISTS emergency_services CASCADE;
DROP TABLE IF EXISTS survey_details CASCADE;
DROP TABLE IF EXISTS patient_details CASCADE;
DROP TABLE IF EXISTS location_details CASCADE;
DROP TABLE IF EXISTS hospital_details CASCADE;

-- =============================================
-- SOURCE TABLES
-- =============================================

-- Hospital Details
-- Primary Keys: PatientID, FacilityID
CREATE TABLE hospital_details (
    patientid INTEGER NOT NULL,
    facilityid INTEGER NOT NULL,
    facility_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address VARCHAR(200) NOT NULL,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    county VARCHAR(50) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zipcode VARCHAR(10) NOT NULL,
    hospitalownership VARCHAR(50) NOT NULL,
    hospitaltype VARCHAR(50) NOT NULL,
    PRIMARY KEY (patientid, facilityid)
);

-- Location Details
-- Primary Key: LocationID
CREATE TABLE location_details (
    locationid INTEGER PRIMARY KEY NOT NULL,
    city VARCHAR(50) NOT NULL,
    county VARCHAR(50) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zipcode VARCHAR(10) NOT NULL,
    address VARCHAR(200) NOT NULL,
    facility_name VARCHAR(100) NOT NULL
);

-- Patient Details
-- Primary Key: PatientID
CREATE TABLE patient_details (
    patientid INTEGER PRIMARY KEY NOT NULL,
    patient_type VARCHAR(50) NOT NULL,
    insurance_type VARCHAR(50) NOT NULL
);

-- Survey Details
-- Primary Key: SurveyID
-- Foreign Key: PatientID
CREATE TABLE survey_details (
    surveyid VARCHAR(50) PRIMARY KEY NOT NULL,
    patientid INTEGER NOT NULL,
    hcahpsmeasureid VARCHAR(50) NOT NULL,
    hcahps_question TEXT NOT NULL,
    hcahps_answer TEXT NOT NULL,
    patientsurveystarrating VARCHAR(10) NOT NULL,
    surveyresponseratepercent VARCHAR(10) NOT NULL,
    numberofcompletedsurveys VARCHAR(10) NOT NULL,
    CONSTRAINT fk_patient_survey FOREIGN KEY (patientid) REFERENCES patient_details(patientid)
);

-- Emergency Services
-- Primary Key: ServiceID
CREATE TABLE emergency_services (
    serviceid INTEGER PRIMARY KEY NOT NULL,
    servicetype VARCHAR(50) NOT NULL,
    availability VARCHAR(20) NOT NULL,
    responsetime INTEGER NOT NULL,
    capacity INTEGER NOT NULL
);

-- =============================================
-- DIMENSION TABLES
-- =============================================

-- Hospital Dimension
-- Implements SCD Type 1
-- Primary Key: FacilityID
CREATE TABLE hospital_dimension (
    facilityid INTEGER PRIMARY KEY NOT NULL,
    facility_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(2) NOT NULL,
    hospitalownership VARCHAR(50) NOT NULL,
    hospitaltype VARCHAR(50) NOT NULL
);

-- Location Dimension
-- Primary Key: LocationID
CREATE TABLE location_dimension (
    locationid SERIAL PRIMARY KEY NOT NULL,
    city VARCHAR(50) NOT NULL,
    county VARCHAR(50) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zipcode VARCHAR(10) NOT NULL,
    address VARCHAR(200) NOT NULL,
    facility_name VARCHAR(100) NOT NULL
);

-- Patient Dimension
-- Primary Key: PatientID
CREATE TABLE patient_dimension (
    patientid INTEGER PRIMARY KEY NOT NULL,
    patient_type VARCHAR(50) NOT NULL,
    insurance_type VARCHAR(50) NOT NULL
);

-- Survey Dimension
-- Primary Key: SurveyID
-- Foreign Keys: FacilityID, LocationID, PatientID, ServiceID
CREATE TABLE survey_dimension (
    surveyid VARCHAR(50) PRIMARY KEY NOT NULL,
    hcahpsmeasureid VARCHAR(50) NOT NULL,
    hcahps_question TEXT NOT NULL,
    hcahps_answer TEXT NOT NULL,
    patientsurveystarrating INTEGER NOT NULL,
    surveyresponsepercent NUMERIC(5,2) NOT NULL,
    numberofcompletedsurveys INTEGER NOT NULL,
    locationid INTEGER NOT NULL,
    facilityid INTEGER NOT NULL,
    patientid INTEGER NOT NULL,
    serviceid INTEGER NOT NULL
);

-- Emergency Services Dimension
-- Primary Key: ServiceID
CREATE TABLE emergency_service_dimension (
    serviceid INTEGER PRIMARY KEY NOT NULL,
    servicetype VARCHAR(50) NOT NULL,
    availability BOOLEAN NOT NULL,
    responsetime INTEGER NOT NULL,
    capacity INTEGER NOT NULL
);

-- =============================================
-- FACT TABLE
-- =============================================

-- Survey Fact Table
-- Primary Key: SurveyFactID
-- Foreign Keys: SurveyID, PatientID, LocationID, FacilityID, ServiceID
-- Measures: AverageStarRating, ResponseCompleteRate, TotalSurveyScore, WeightedResponseRate
CREATE TABLE survey_fact (
    surveyfactid SERIAL PRIMARY KEY NOT NULL,
    surveyid VARCHAR(50) NOT NULL,
    patientid INTEGER NOT NULL,
    locationid INTEGER NOT NULL,
    serviceid INTEGER NOT NULL,
    facilityid INTEGER NOT NULL,
    averagestarrating NUMERIC(10,2),
    responsecompleterate NUMERIC(10,2),
    totalsurveyscore NUMERIC(10,2),
    weightedresponserate NUMERIC(10,2),
    CONSTRAINT fk_survey FOREIGN KEY (surveyid) REFERENCES survey_dimension(surveyid),
    CONSTRAINT fk_patient FOREIGN KEY (patientid) REFERENCES patient_dimension(patientid),
    CONSTRAINT fk_location FOREIGN KEY (locationid) REFERENCES location_dimension(locationid),
    CONSTRAINT fk_facility FOREIGN KEY (facilityid) REFERENCES hospital_dimension(facilityid),
    CONSTRAINT fk_service FOREIGN KEY (serviceid) REFERENCES emergency_service_dimension(serviceid)
);

-- =============================================
-- ANALYTICAL QUERIES
-- =============================================

-- Query 1: Check Foreign Key Relationships
SELECT 
    h.facility_name, 
    s.hcahps_question
FROM hospital_details h
JOIN survey_details s ON h.facilityid = s.facilityid
LIMIT 2;

-- Query 2: Survey Count by Hospital
SELECT 
    h.facility_name, 
    COUNT(s.surveyid) AS numberofsurveys
FROM hospital_details h
LEFT JOIN survey_details s ON h.facilityid = s.facilityid
GROUP BY h.facility_name
LIMIT 2;

-- =============================================
-- DATA VALIDATION QUERIES
-- =============================================

-- Source Table Row Counts
SELECT 'hospital_details' AS table_name, COUNT(*) AS row_count FROM hospital_details
UNION ALL
SELECT 'location_details', COUNT(*) FROM location_details
UNION ALL
SELECT 'patient_details', COUNT(*) FROM patient_details
UNION ALL
SELECT 'survey_details', COUNT(*) FROM survey_details
UNION ALL
SELECT 'emergency_services', COUNT(*) FROM emergency_services;

-- Dimension Table Row Counts
SELECT 'hospital_dimension' AS table_name, COUNT(*) AS row_count FROM hospital_dimension
UNION ALL
SELECT 'location_dimension', COUNT(*) FROM location_dimension
UNION ALL
SELECT 'patient_dimension', COUNT(*) FROM patient_dimension
UNION ALL
SELECT 'survey_dimension', COUNT(*) FROM survey_dimension
UNION ALL
SELECT 'emergency_service_dimension', COUNT(*) FROM emergency_service_dimension;

-- Fact Table Row Count
SELECT 'survey_fact' AS table_name, COUNT(*) AS row_count FROM survey_fact;

-- Foreign Key Integrity Check
SELECT 
    COUNT(DISTINCT sf.facilityid) AS facilities_in_fact,
    COUNT(DISTINCT hd.facilityid) AS facilities_in_dimension,
    COUNT(DISTINCT sf.surveyid) AS surveys_in_fact,
    COUNT(DISTINCT sd.surveyid) AS surveys_in_dimension
FROM survey_fact sf
LEFT JOIN hospital_dimension hd ON sf.facilityid = hd.facilityid
LEFT JOIN survey_dimension sd ON sf.surveyid = sd.surveyid;

-- =============================================
-- END OF SCHEMA
-- =============================================