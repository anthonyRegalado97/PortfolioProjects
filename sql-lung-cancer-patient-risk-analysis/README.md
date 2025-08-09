# 🧠 Patient Risk Factor SQL Analysis

This project analyzes patient health data using SQL to identify high-risk individuals, 
explore demographic trends, and apply advanced techniques like window functions and subqueries and CTEs.

## 📁 Files

- `LungCancer.sql`: Full SQL script with table creation, data import references, and analysis queries.
- `data/`: Contains Excel and CSV versions of the source tables:
  - `LungCancerPatientInfo`
  - `LungCancerRiskFactors`
  - `LungCancerDiagnosis`

## 📊 How to Use

1. Load the CSV files into your SQL environment (e.g., SQLite, PostgreSQL, MySQL).
2. Use the `CREATE TABLE` statements in `LungCancer.sql` to define the schema.
3. Run the queries to explore insights like:
   - Patients with multiple risk factors
   - BMI trends by smoking status
   - Diagnosis timing and treatment outcomes

## 🛠️ Techniques Used

- Window functions (`RANK`, `AVG OVER`)
- Conditional logic (`CASE`)
- Joins and subqueries
- View creation for reporting

## 📌 Notes

- Data is synthetic and for educational purposes.
- Excel files are included for exploration or visualization.
