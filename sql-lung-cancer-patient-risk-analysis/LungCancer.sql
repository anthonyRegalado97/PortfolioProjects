DROP DATABASE IF EXISTS LungCancerDB;
CREATE DATABASE LungCancerDB;
USE LungCancerDB;

CREATE TABLE LungCancerPatientInfo (
	id INT PRIMARY KEY IDENTITY(1,1),
	age FLOAT NOT NULL,
	gender VARCHAR(10) NOT NULL,
	country VARCHAR(50) NOT NULl
);

CREATE TABLE LungCancerRiskFactors(
	id INT PRIMARY KEY IDENTITY(1,1),
	family_history VARCHAR(255) NOT NULL,
	smoking_status VARCHAR(255) NOT NULL,
	bmi FLOAT NOT NULL,
	cholesterol_level FLOAT NOT NULL,
	hypertension VARCHAR(10) NOT NULL,
	asthma VARCHAR(10) NOT NULL,
	cirrhosis VARCHAR(10) NOT NULL,
	other_cancer VARCHAR(10) NOT NULL
);

CREATE TABLE LungCancerDiagnosis(
	id INT PRIMARY KEY IDENTITY(1,1),
	diagnosis_date DATETIME NOT NULL,
	cancer_stage VARCHAR(10) NOT NULL,
	treatment_type VARCHAR(20) NOT NULL,
	end_treatment_date DATETIME NOT NULL,
	survived VARCHAR(10)
);

/*Download the CSV files and copy the filepath into the FROM clause or alternatively download the .xlsx
files and use the import wizard to populate the tables.*/
--BULK INSERT LungCancerDB.dbo.LungCancerPatientInfo
--FROM /*FILEPATH where you store your CSV*/
--WITH
--(
--	FORMAT = 'CSV',
--	FIRSTROW = 2,
--	FIELDTERMINATOR = ',',
--	ROWTERMINATOR = '\n'
--);

--BULK INSERT LungCancerDB.dbo.LungCancerRiskFactors
--FROM /*FILEPATH where you store your CSV*/
--WITH
--(
--	FORMAT = 'CSV',
--	FIRSTROW = 2,
--	FIELDTERMINATOR = ',',
--	ROWTERMINATOR = '\n'
--);

--BULK INSERT LungCancerDB.dbo.LungCancerDiagnosis
--FROM /*FILEPATH where you store your CSV*/
--WITH
--(
--	FORMAT = 'CSV',
--	FIRSTROW = 2,
--	FIELDTERMINATOR = ',',
--	ROWTERMINATOR = '\n'
--);

SELECT * FROM LungCancerPatientInfo;
SELECT * FROM LungCancerRiskFactors;
SELECT * FROM LungCancerDiagnosis;

/*1. List all patients over the age of 60 who are current smokers.*/
SELECT pi.id, pi.age
FROM LungCancerPatientInfo pi JOIN LungCancerRiskFactors rf
ON pi.id = rf.id
WHERE pi.age > 60 AND rf.smoking_status IN ('Current Smoker', 'Passive Smoker')
GROUP BY pi.id, pi.age
ORDER BY pi.id ASC;

/*2. Retrieve the patient IDs and their corresponding diagnosis dates, sorted by the earliest diagnosis first.*/
SELECT pi.id, d.diagnosis_date
FROM LungCancerPatientInfo pi JOIN LungCancerDiagnosis d
ON pi.id = d.id
ORDER BY d.diagnosis_date ASC;

/*3. List all patients who have a family history of cancer and a smoking status of "Current smoker." Include their BMI and diagnosis date.*/
SELECT pi.id, rf.bmi, d.diagnosis_date, rf.family_history
FROM LungCancerPatientInfo pi JOIN LungCancerRiskFactors rf
	ON pi.id = rf.id
	JOIN LungCancerDiagnosis d 
	ON rf.id = d.id
WHERE rf.family_history = 'Yes' AND rf.smoking_status = 'Current Smoker'
ORDER BY pi.id;

/*4 Count how many patients fall into each smoking status category (e.g., 'Current smoker', 'Passive smoker', 'Non-smoker').*/
SELECT smoking_status, COUNT(smoking_status) AS total
FROM LungCancerRiskFactors
GROUP BY smoking_status;

/*5. List patients whose diagnosis date is later than the average diagnosis date for all patients.*/
SELECT id, diagnosis_date
FROM LungCancerDiagnosis
WHERE diagnosis_date > (SELECT CAST(AVG(CAST(diagnosis_date AS FLOAT)) AS DATETIME)
FROM LungCancerDB..LungCancerDiagnosis);

/*NOTE: The next two result sets return 0 results. That is because the dataset is too uniform.
However, given a real world healthcare dataset, these queries run just fine and will produce the
desired results. The main purpose of these queries are to highlight SQL Server skills.*/

/*6. Calculate the average age of patients by smoking status, and then return only those groups where the average age is above 55.*/
WITH AverageAge AS (
	SELECT ROUND(AVG(age), 0) AS average_age, smoking_status
	FROM LungCancerDB..LungCancerPatientInfo pi JOIN LungCancerDB..LungCancerRiskFactors rf
	ON pi.id = rf.id
	GROUP BY smoking_status
)
SELECT * FROM AverageAge
WHERE average_age > 55;


/*7. Count the number of patients by smoking status and gender, and return only the combinations where the count is less than 1% of the total patient population.*/
WITH total AS (
	SELECT COUNT(*) as total_count
	FROM LungCancerPatientInfo pi JOIN LungCancerRiskFactors rf
	ON pi.id = rf.id
),
grouped AS (
	SELECT smoking_status, gender, COUNT(*) as group_count
	FROM LungCancerRiskFactors rf JOIN LungCancerPatientInfo pi
	ON rf.id = pi.id
	GROUP BY smoking_status, gender
)
SELECT g.smoking_status, g.gender, g.group_count
FROM grouped g JOIN total t 
ON 1=1
WHERE g.group_count < t.total_count *.01;

/*8. Which age group has the highest average cholesterol level for patients with at least one chronic condition?*/
WITH age_groups AS (
	SELECT *,
	CASE
		WHEN age BETWEEN 0 AND 17 THEN '0-17'
		WHEN age BETWEEN 18 AND 24 THEN '18-24'
		WHEN age BETWEEN 25 AND 34 THEN '25-34'
		WHEN age BETWEEN 35 AND 44 THEN '35-44'
		WHEN age BETWEEN 45 AND 54 THEN '45-54'
		WHEN age BETWEEN 55 AND 64 THEN '55-64'
		WHEN age >= 65 THEN '65+'
		ELSE 'Unknown'
	END AS AgeBucket	
	FROM LungCancerPatientInfo
),
chronic_conditions AS (
	SELECT  ag.id, cholesterol_level, AgeBucket
	FROM age_groups ag JOIN LungCancerRiskFactors rf 
	ON ag.id = rf.id
	WHERE family_history = 'Yes'
		OR smoking_status IN ('Current Smoker', 'Passive Smoker')
		OR bmi < 18.5
		OR cholesterol_level < 160
		OR hypertension = 'TRUE'
		OR asthma = 'TRUE'
		OR cirrhosis = 'TRUE'
		OR other_cancer = 'TRUE'
),
cholesterol_by_age AS (
	SELECT AgeBucket,
		AVG(cholesterol_level) AS avg_cholesterol,
		RANK() OVER (ORDER BY AVG(cholesterol_level) DESC) AS rank
	FROM chronic_conditions
	GROUP BY AgeBucket
)
SELECT *
FROM cholesterol_by_age
WHERE rank = 1;

/*9. Create a view that combines patient info, risk factors, and diagnosis details into a single unified dataset for reporting.*/
GO
CREATE VIEW lung_cancer_patient_data AS
SELECT pi.id, pi.age, pi.gender, rf.family_history, rf.smoking_status,
	rf.bmi, rf.cholesterol_level, rf.hypertension, rf.asthma, rf.cirrhosis,
	rf.other_cancer, d.diagnosis_date, d.cancer_stage, d.treatment_type, d.end_treatment_date,
	d.survived
FROM LungCancerPatientInfo pi JOIN LungCancerRiskFactors rf
	ON pi.id = rf.id
	JOIN LungCancerDiagnosis d
	ON rf.id = d.id;
GO

/*10.Using the risk_factors table, calculate the average BMI within each smoking status group, and return each 
patient’s BMI along with the group average. Then, flag whether the patient’s BMI is above their group’s average.*/
SELECT id, smoking_status, bmi,
    AVG(bmi) OVER (PARTITION BY smoking_status) AS avg_bmi_by_group,
    CASE 
        WHEN bmi > AVG(bmi) OVER (PARTITION BY smoking_status) THEN 'Above Average'
        ELSE 'Below or Equal'
    END AS bmi_flag
FROM LungCancerRiskFactors
ORDER BY id;
