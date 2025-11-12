# 🏥 MedSmile: Healthcare Satisfaction Monitoring System  
*A Data Warehouse & BI Solution for Patient Experience and Hospital Performance*  

![Talend](https://img.shields.io/badge/ETL-Talend-blue)  
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-darkblue?logo=postgresql&logoColor=white)  
![PowerBI](https://img.shields.io/badge/Visualization-PowerBI-yellow?logo=powerbi&logoColor=black)  
![Status](https://img.shields.io/badge/Project-On--Premise-brightgreen)  

---

## 🚀 Project Overview
**MedSmile** is an on-premise **Healthcare Satisfaction Monitoring System** that integrates patient surveys, hospital ratings, and operational metrics into a centralized **PostgreSQL data warehouse**.

The system supports:
- Consolidated reporting across hospitals and locations  
- OLAP-style analysis (roll-up, drill-down, slice, dice)  
- Interactive dashboards for patient satisfaction and hospital performance  

> 🎯 **Goal:** Provide healthcare administrators with a unified, on-premise analytics platform to improve patient experience and facility performance.

---

## 📦 Table of Contents
- [🎯 Problem Definition](#-problem-definition)  
- [🏢 Operational Business Context](#-operational-business-context)  
- [🧮 Data Model](#-data-model)  
- [🗄️ Data Warehouse Design (On-Premise)](#️-data-warehouse-design-on-premise)  
- [⚙️ ETL Process (Talend → PostgreSQL)](#️-etl-process-talend--postgresql)  
- [📊 OLAP Operations](#-olap-operations)  
- [📈 Dashboard & KPIs](#-dashboard--kpis)  
- [🧰 Tools & Technologies](#-tools--technologies)  
- [🗂️ Project Structure](#️-project-structure)  
- [👩‍💻 Authors](#-authors)  
- [📄 References](#-references)  

---

## 🎯 Problem Definition
Healthcare organizations collect data from many sources:

- Patient satisfaction surveys  
- Facility ratings and performance metrics  
- Emergency services and capacity information  

However, this data is **fragmented across different systems**, making it hard to:

- Get a holistic view of patient experience  
- Compare hospital performance across locations  
- Identify underperforming facilities  
- Support data-driven operational decisions  

**MedSmile** addresses this by building an **on-premise data warehouse** that consolidates all relevant data into a single source of truth.

---

## 🏢 Operational Business Context

- **Hospital Operations**  
  Centralized access to facility ownership, type, emergency services, and performance helps optimize staffing, capacity, and service availability.

- **Patient Management**  
  Aggregated survey responses and ratings support monitoring of care quality, readmissions, and overall patient satisfaction.

- **Patient Engagement**  
  Feedback captured through structured surveys enables targeted improvements in patient communication, comfort, and service quality.

- **Healthcare Reporting**  
  Consistent, transparent reporting to internal stakeholders and regulators is supported by unified, auditable data.

> 💾 This is an **on-premise project** deployed on a **PostgreSQL database**.  
> All ETL, storage, and analytics run within a controlled environment, supporting stricter data governance and healthcare compliance requirements.

---

## 🧮 Data Model

### 🔹 Source Data
- 4 main source tables (numeric + string data types), plus emergency services:
  1. `Hospital_Details`
  2. `Location`
  3. `Patient_Details`
  4. `Survey_Details`
  5. `Emergency_Services`

- Primary data is sourced from Kaggle, with some columns generated manually:
  - [US Hospital Customer Satisfaction (2016–2020)](https://www.kaggle.com/datasets/abrambeyer/us-hospital-customer-satisfaction-20162020)

### 🔹 Relational Model (OLTP)
- **Hospital_Details**(`PatientID`, `FacilityID`, `Facility_Name`, `Phone_Number`, `Address`, `Street`, `City`, `County`, `State`, `Zipcode`, `HospitalOwnership`, `HospitalType`)  
- **Location**(`LocationID`, `City`, `County`, `State`, `Zipcode`, `Address`, `Facility_Name`)  
- **Patient_Details**(`PatientID`, `Patient_Type`, `Insurance_Type`)  
- **Survey_Details**(`SurveyID`, `PatientID`, `HCAHPSMeasureID`, `HCAHPS_Question`, `HCAHPS_Answer`, `PatientSurveyStarRating`, `SurveyResponseRatePercent`, `NumberofCompletedSurveys`)  
- **Emergency_Services**(`ServiceID`, `ServiceType`, `Availability`, `ResponseTime`, `Capacity`)  

---

## 🗄️ Data Warehouse Design (On-Premise)

The MedSmile data warehouse is implemented as a **star schema hosted in an on-premise PostgreSQL instance**.

### ⭐ Fact Table: `Survey_Fact`
- **Keys:**
  - `SurveyFactID` (surrogate PK)  
  - `SurveyID`, `PatientID`, `LocationID`, `ServiceID`, `FacilityID` (FKs to dimensions)
- **Measures (Semi-additive):**
  - `AvgPatientSurveyStarRating`  
  - `AvgSurveyResponseRatePercent`  
  - `TotalCompletedSurveys`  

### 🔹 Dimension Tables
1. **Hospital_Dimension**  
   (`FacilityID`, `Facility_Name`, `Phone_Number`, `Address`, `City`, `State`, `HospitalOwnership`, `HospitalType`)

2. **Survey_Dimension**  
   (`SurveyID`, `HCAHPSMeasureID`, `HCAHPS_Question`, `HCAHPS_Answer`, `PatientSurveyStarRating`, `SurveyResponseRatePercent`, `NumberofCompletedSurveys`, `LocationID`, `FacilityID`, `PatientID`, `ServiceID`)

3. **Location_Dimension**  
   (`LocationID`, `City`, `County`, `State`, `Zipcode`, `Address`, `Facility_Name`)

4. **Patient_Dimension**  
   (`PatientID`, `Patient_Type`, `Insurance_Type`)

5. **Emergency_Services_Dimension**  
   (`ServiceID`, `ServiceType`, `Availability`, `ResponseTime`, `Capacity`)

### 🕒 Slowly Changing Dimensions
- **SCD Type 1** implemented for:
  - `Facility_Name`  
  - `HospitalType`  
  - `HospitalOwnership`  
- Old values are overwritten with new data (no history kept) to always show the **current** facility attributes.

---

## ⚙️ ETL Process (Talend → PostgreSQL)

All ETL is implemented in **Talend Open Studio**, targeting the **on-premise PostgreSQL warehouse** via JDBC.

### 1️⃣ Dimension Loading
- Source tables are cleaned and loaded into their corresponding dimension tables:
  - `HospitalDetails → Hospital_Dimension`
  - `LocationTable → Location_Dimension`
  - `PatientDetails → Patient_Dimension`
  - `SurveyDetailsTable → Survey_Dimension`
  - `EmergencyServicesTable → Emergency_Services_Dimension`
- Transformations:
  - Trimming quotes and whitespace
  - Converting `"YES"/"NO"` to `1/0`
  - Replacing `NULL/blank` values with `0` when appropriate
  - Data type conversions (String → INT for numeric survey fields)

### 2️⃣ Fact Table ETL
- Data from all dimensions is joined in Talend using `tMap`
- The combined dataset is loaded into `Survey_Fact` in PostgreSQL
- Calculated measures such as:
  - `TotalCompletedSurveys`
  - `AveragePatientSurveyStarRating`

> 🧩 The ETL workflow is fully **on-premise**: Talend connects directly to PostgreSQL; no cloud services are used.

---

## 📊 OLAP Operations

Typical OLAP-style analyses supported by the warehouse:

1. **Average survey rating by hospital & state**  
   - ROLL-UP on (`State`, `FacilityID`) by `Avg(PatientSurveyStarRating)`

2. **Survey completion vs star rating**  
   - DRILL-ACROSS between completion counts and rating averages

3. **Underperforming hospitals**  
   - SLICE where `PatientSurveyStarRating < 3` AND `SurveyResponseRatePercent < 50`

4. **Emergency service availability by state & facility**  
   - ROLL-UP on (`State`, `FacilityID`) with `COUNT(ServiceID)`

5. **Survey trends by time** (e.g., quarter or year)  
   - DRILLDOWN on (`Quarter`, `FacilityID`) or (`Year`, `FacilityID`) with `Avg(SurveyResponseRatePercent)` or `Avg(PatientSurveyStarRating)`

6. **Completed surveys by city and hospital type**  
   - ROLL-UP on (`City`, `HospitalType`) with `SUM(TotalCompletedSurveys)`

---

## 📈 Dashboard & KPIs

An **interactive dashboard** (e.g., Power BI) is built on top of the PostgreSQL warehouse.

### Key KPIs
1. ⭐ **Average Star Rating** across all facilities  
2. 😊 **Positive Survey Percentage** (share of positive feedback)  
3. 🧾 **Total Completed Surveys**  
4. 📬 **Weighted Response Rate** (adjusted for feedback volume/survey type)  
5. 🏆 **Facility Satisfaction Score**  
   - Weighted combination of star ratings × survey counts

--

## 🧰 Tools & Technologies

| Category | Tool | Usage |
|----------|------|-------|
| ETL / Integration | **Talend Open Studio** | Extract, transform, and load from sources into DW |
| Database (On-Premise) | **PostgreSQL** | Central data warehouse & OLAP engine |
| Visualization | **Power BI** | Interactive dashboard and KPI reporting |
| Data Modeling | ERD, Star Schema | Conceptual & logical modeling of warehouse |
| OLAP / SQL | PostgreSQL SQL | ROLLUP, DRILLDOWN, SLICE, DICE operations |

---

## 🗂️ Project Structure

```plaintext
.
├── Milestone7_Group17_OnPremise.pdf    # Full project report & design document
└── README.md                           # Project overview (this file)
