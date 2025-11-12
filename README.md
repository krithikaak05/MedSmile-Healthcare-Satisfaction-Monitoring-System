# 🏥 MedSmile: Healthcare Satisfaction Monitoring System  
*A Data Warehouse and BI Solution for Patient Satisfaction and Hospital Performance Analysis*  

![Python](https://img.shields.io/badge/ETL-Talend-blue?logo=apache&logoColor=white)  
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-darkblue?logo=postgresql&logoColor=white)  
![PowerBI](https://img.shields.io/badge/Visualization-PowerBI-yellow?logo=powerbi&logoColor=black)  
![Status](https://img.shields.io/badge/Project-Completed-brightgreen)

---

## 🚀 Project Overview
**MedSmile** is a comprehensive **Healthcare Data Warehouse System** designed to consolidate patient satisfaction, hospital ratings, and performance data from multiple sources.  
The project enables healthcare organizations to perform **advanced analytics, OLAP operations, and KPI tracking** to improve patient experience and hospital efficiency.

> 🎯 **Goal:** Centralize healthcare performance and patient feedback data into a unified, interactive platform to support informed decision-making.

---

## 📦 Table of Contents
- [🎯 Problem Definition](#-problem-definition)
- [🏢 Operational Business Context](#-operational-business-context)
- [🧮 Data Model](#-data-model)
- [🗄️ Data Warehouse Design](#️-data-warehouse-design)
- [⚙️ ETL Process (Talend)](#%EF%B8%8F-etl-process-talend)
- [📊 OLAP Operations](#-olap-operations)
- [📈 Dashboard & KPIs](#-dashboard--kpis)
- [🧰 Tools & Technologies](#-tools--technologies)
- [🗂️ Project Structure](#️-project-structure)
- [👩‍💻 Authors](#-authors)
- [📄 References](#-references)

---

## 🎯 Problem Definition
Healthcare organizations often struggle with **fragmented patient satisfaction and hospital performance data** scattered across multiple systems.  
This fragmentation limits administrators from:
- Understanding patient experiences  
- Comparing performance across facilities  
- Making data-driven operational decisions  

**MedSmile** resolves this by integrating all data sources into a **centralized data warehouse** that supports efficient analysis, reporting, and transparency.

---

## 🏢 Operational Business Context

| Domain | Description |
|--------|--------------|
| **Hospital Operations** | Centralized tracking of admissions, emergency services, and compliance metrics |
| **Patient Management** | Aggregated satisfaction surveys and hospital ratings for performance evaluation |
| **Patient Engagement** | Continuous feedback loops for improving care and reducing readmission rates |
| **Healthcare Reporting** | Transparent dashboards for internal stakeholders and regulators |

---

## 🧮 Data Model

### **Relational Model**
1. **Hospital_Details** (`PatientID`, `FacilityID`, `Facility_Name`, `City`, `State`, `HospitalOwnership`, `HospitalType`)  
2. **Location** (`LocationID`, `City`, `County`, `State`, `Zipcode`, `Address`, `Facility_Name`)  
3. **Patient_Details** (`PatientID`, `Patient_Type`, `Insurance_Type`)  
4. **Survey_Details** (`SurveyID`, `PatientID`, `HCAHPSMeasureID`, `HCAHPS_Question`, `PatientSurveyStarRating`, `SurveyResponseRatePercent`, `NumberofCompletedSurveys`)  
5. **Emergency_Services** (`ServiceID`, `ServiceType`, `Availability`, `ResponseTime`, `Capacity`)

### **Data Source**
- Primary data sourced from **Kaggle**:  
  [US Hospital Customer Satisfaction (2016–2020)](https://www.kaggle.com/datasets/abrambeyer/us-hospital-customer-satisfaction-20162020)

---

## 🗄️ Data Warehouse Design

### **Star Schema**
Central fact table linked to multiple dimensions:

**Fact Table: `Survey_Fact`**
- Keys: `SurveyFactID (PK)`, `SurveyID`, `PatientID`, `LocationID`, `ServiceID`, `FacilityID`
- Measures:  
  - `AvgPatientSurveyStarRating` *(Semi-additive)*  
  - `AvgSurveyResponseRatePercent` *(Semi-additive)*  
  - `TotalCompletedSurveys` *(Semi-additive)*

**Dimensions**
- `Hospital_Dimension` – Facility details  
- `Survey_Dimension` – Survey responses  
- `Location_Dimension` – Geographic details  
- `Patient_Dimension` – Patient demographics  
- `Emergency_Service_Dimension` – Availability & response times  

### **SCD Implementation**
- **Type 1 Slowly Changing Dimension** applied to Hospital attributes (`Facility_Name`, `HospitalType`, `HospitalOwnership`)  
  → Old data overwritten with current information.

---

## ⚙️ ETL Process (Talend)
Data integration and loading performed using **Talend Open Studio**.

**Steps:**
1. **Load Dimensions:**  
   Each source table loaded into its corresponding dimension table.  
   - Example: `Hospital_Details → Hospital_Dimension` (65,524 inserts, 11 updates)
2. **Transformations:**  
   - Trim strings  
   - Replace `YES/NO` → `1/0`  
   - Handle nulls (`NULL → 0`)  
   - Type conversion (String → Integer)
3. **Load Fact Table:**  
   - Joined from all dimension tables  
   - Loaded into `Survey_Fact` via Talend `tMap` component  
4. **Calculated Measures:**  
   - `TotalCompletedSurveys`  
   - `AveragePatientSurveyStarRating`

---

## 📊 OLAP Operations

| Operation | Purpose |
|------------|----------|
| **ROLL-UP (State, FacilityID)** | Analyze average survey ratings by hospital and state |
| **DRILL-ACROSS** | Correlate survey completion and satisfaction |
| **SLICE** | Identify underperforming hospitals (`StarRating < 3`, `ResponseRate < 50`) |
| **DRILL-DOWN** | Examine emergency response times per facility |
| **DICE** | Analyze facilities by state or ownership type |
| **ROLL-UP (Year)** | Track satisfaction trends over time |

---

## 📈 Dashboard & KPIs

**KPIs**
1. 🩺 **Average Patient Survey Star Rating** — Mean satisfaction across facilities  
2. 😊 **Positive Feedback %** — Proportion of positive survey responses  
3. 📊 **Total Surveys Completed** — Engagement indicator  
4. ⚙️ **Weighted Response Rate** — Adjusted by survey type and feedback volume  
5. 🏆 **Facility Satisfaction Score** — Weighted combination of star rating × survey volume  

**Visualizations**
- Bar charts: Survey scores by patient & insurance type  
- Donut charts: Feedback distribution by facility  
- State maps: Facility coverage by region  
- Slicers: Filter by **State** or **Hospital Ownership**  

> The dashboard allows interactive exploration of satisfaction trends and hospital performance metrics.

---

## 🧰 Tools & Technologies
- **ETL:** Talend Open Studio  
- **Database:** PostgreSQL  
- **Visualization:** Power BI  
- **Modeling:** ERD & Star Schema (Conceptual, Logical, Physical)  
- **OLAP Queries:** SQL ROLLUP, DRILLDOWN, SLICE, DICE operations  

---

## 🗂️ Project Structure
```plaintext
.
├── Milestone7_Group17_OnPremise.pdf     # Project documentation and schema
├── README.md                            # Project overview (this file)
└── (Optional) PowerBI Dashboard visuals
