# 🦠 COVID-19 Data Exploration & Visualization

This project analyzes global COVID-19 trends using SQL and visualizes key insights in Tableau. It focuses on infection rates, death percentages, vaccination progress, and population impact across countries and continents.

## 📊 Project Overview

- **Tools Used**: SQL Server, Tableau
- **Data Sources**: `CovidDeaths` and `CovidVaccinations` tables from the `PortfolioProject1` database
- **Skills Demonstrated**:
  - Data cleaning and filtering
  - Joins and subqueries
  - Common Table Expressions (CTEs)
  - Temporary tables
  - Window functions
  - Aggregate functions
  - View creation for visualization

## 🧠 Key SQL Insights

- **Infection & Mortality Analysis**: Calculated death percentages by country and date to assess COVID-19 fatality rates.
- **Population Impact**: Measured infection rates relative to population size to identify countries with the highest exposure.
- **Vaccination Tracking**: Used window functions and CTEs to compute rolling vaccination totals and population coverage.
- **Global Summary Metrics**: Aggregated total cases and deaths to derive global death percentages.
- **View Creation**: Built a reusable SQL view (`PercentPopulationVaccinated`) to streamline Tableau integration.

## 📈 Tableau Dashboard

The Tableau dashboard visualizes:
- Infection and death trends over time
- Vaccination progress by country and continent
- Comparative analysis of population impact

> 📌 The dashboard helps communicate complex data in a clear, interactive format for non-technical audiences.


