# Telecom-Customer-Churn-Analysis
Tools Used: Excel · MySQL · Tableau  Dataset: IBM Telco Customer Churn — 7,043 customers, 21 columns. Dataset used: https://www.kaggle.com/datasets/blastchar/telco-customer-churn.   Tableau Dashboard: https://public.tableau.com/app/profile/santanu.banerjee/viz/TelecomCustomerChurnAnalysis_17817754352570/AnalysisDashboard

## Business Question

> Which customer segments have the highest churn risk, and what pricing or product interventions can reduce churn at scale?

---

## Dataset Overview

| Field | Details |
|---|---|
| Rows | 7,043 customers |
| Source | IBM Sample Dataset via Kaggle |
| Original columns | CustomerID, Gender, SeniorCitizen, Partner, Dependents, Tenure, PhoneService, MultipleLines, InternetService, OnlineSecurity, OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies, Contract, PaperlessBilling, PaymentMethod, MonthlyCharges, TotalCharges, Churn |
| Engineered columns | Churn_Flag, Tenure_Band, Monthly_Charge_Band, Lifetime_Value |
| Target variable | Churn (Yes / No) → converted to Churn_Flag (1 / 0) |

---

## What I Did

### Step 1 — Data Cleaning & Feature Engineering (Excel)
- Replaced blank TotalCharges values (tenure = 0 customers) with 0
- Converted TotalCharges from text to numeric using Text to Columns
- Created 4 new calculated columns:

| Column | Logic |
|---|---|
| Churn_Flag | IF(Churn="Yes", 1, 0) — enables direct churn rate calculation |
| Tenure_Band | 0–12 Months / 13–24 Months / 25–48 Months / 49+ Months |
| Monthly_Charge_Band | Low (<$30) / Medium ($30–$60) / High ($60–$90) / Very High (>$90) |
| Lifetime_Value | Tenure × MonthlyCharges — used for win-back campaign targeting |

- Imported clean CSV into MySQL using a Python script (bypassing MySQL Workbench import wizard due to encoding issues on Mac)

### Step 2 — Database Setup (MySQL)
- Created `Project3` database and `telco_churn` table with 25 typed columns
- Verified all 7,043 rows loaded correctly via SELECT COUNT(*)
- Structured all queries with inline comments explaining business logic

### Step 3 — Analysis (MySQL)
Ran structured SQL queries across 9 analytical layers — overall summary, contract type, internet service, phone service, payment method, tenure band, monthly charge band, contract × internet combination, window function ranking, and CTE risk profiling.

### Step 4 — Visualization (Tableau)
- Connected cleaned CSV to Tableau Public
- Created calculated field: `SUM([Churn_Flag]) / COUNT([Customer_Id]) * 100` for churn rate
- Built 5 sheets: KPIs, Contract bar chart, Internet Service bar chart, Tenure Band bar chart, Scatter Plot (Avg Monthly Charges vs Avg Tenure)
- Scatter plot uses Internet Service as color, Churn as shape, and COUNT(CustomerID) as size
- Added reference lines at $60 (High charge zone) and 25 months (Early tenure zone) to create risk quadrants
- Assembled into a single dashboard with Contract, Internet Service, and Tenure Band filters
- Published to Tableau Public

---

## Analysis & Insights

### 1. Overall Summary

```sql
SELECT COUNT(*) AS total_customers, SUM(churn_flag) AS total_churned,
       ROUND(SUM(churn_flag)*100/COUNT(*), 2) AS churn_rate,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges,
       ROUND(AVG(tenure), 1) AS avg_tenure_months
FROM telco_churn;
```

| Metric | Value |
|---|---|
| Total Customers | 7,043 |
| Total Churned | 1,869 |
| Overall Churn Rate | 26.54% |
| Avg Monthly Charges | $64.76 |
| Avg Tenure | 32.4 months |

**Insight:** A 26.54% churn rate means more than 1 in 4 customers is leaving. At an average monthly charge of $64.76 and average tenure of 32.4 months, the business is losing significant lifetime value per churned customer. Understanding which segments drive this loss is the core of this analysis.

---

### 2. Churn by Contract Type

```sql
SELECT contract, COUNT(*) AS customers, SUM(churn_flag) AS total_churn,
       ROUND(SUM(churn_flag)*100/COUNT(*), 2) AS churn_rate,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM telco_churn
GROUP BY contract ORDER BY churn_rate DESC;
```

| Contract Type | Customers | Churn Rate | Avg Monthly Charges |
|---|---|---|---|
| Month-to-month | 3,875 | 42.71% | $66.40 |
| One year | 1,473 | 11.27% | $65.05 |
| Two year | 1,695 | 2.83% | $60.77 |

**Insight:** Month-to-month customers churn at 42.71% — nearly 4× the rate of one-year contracts and 15× the rate of two-year contracts. Contract type is the single most powerful lever for reducing churn. Locking customers into longer contracts is the most direct intervention available.

---

### 3. Churn by Internet Service

```sql
SELECT internet_service, COUNT(*) AS customers, SUM(churn_flag) AS total_churn,
       ROUND(SUM(churn_flag)*100/COUNT(*), 2) AS churn_rate,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM telco_churn
GROUP BY internet_service ORDER BY churn_rate DESC;
```

| Internet Service | Churn Rate | Avg Monthly Charges |
|---|---|---|
| Fiber optic | 41.89% | $91.50 |
| DSL | 18.96% | $42.68 |
| No internet service | 7.41% | $20.97 |

**Insight:** Fiber Optic customers churn at 41.89% despite — or perhaps because of — paying the highest average monthly charge of $91.50. This combination of high price and high churn strongly suggests a service quality or value perception problem with Fiber Optic, not a pricing problem. DSL customers, paying less than half as much, churn at less than half the rate.

---

### 4. Churn by Phone Service

```sql
SELECT phone_service, COUNT(*) AS customers, SUM(churn_flag) AS total_churn,
       ROUND(SUM(churn_flag)*100/COUNT(*), 2) AS churn_rate,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM telco_churn
GROUP BY phone_service ORDER BY churn_rate DESC;
```

**Insight:** Phone service has almost no impact on churn — Yes (26.71%) vs No (24.93%). This rules out phone service as a meaningful churn driver and focuses attention on internet service type and contract structure instead.

---

### 5. Churn by Payment Method

```sql
SELECT payment_method, COUNT(*) AS customers, SUM(churn_flag) AS total_churn,
       ROUND(SUM(churn_flag)*100/COUNT(*), 2) AS churn_rate,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM telco_churn
GROUP BY payment_method ORDER BY churn_rate DESC;
```

| Payment Method | Churn Rate | Avg Monthly Charges |
|---|---|---|
| Electronic check | 45.29% | $76.26 |
| Mailed check | 19.11% | $43.92 |
| Bank transfer (automatic) | 16.71% | $67.15 |
| Credit card (automatic) | 15.24% | $66.80 |

**Insight:** Electronic check customers churn at 45.29% — the highest of any payment method and significantly above automatic payment methods (16–17%). This is not purely a price issue: mailed check customers pay only $43.92/month on average yet still churn at 19.11%, suggesting price alone is not the primary churn driver. Automatic payment methods (bank transfer and credit card) both have substantially lower churn, suggesting that payment friction and commitment level influence churn behavior.

**Deep dive — Electronic Check × Internet Service:**
Fiber Optic customers paying by electronic check churn at 53.23% — the highest single combination by payment method. The same pattern repeats for mailed check customers: Fiber Optic leads at 42.64%. Internet service quality is the dominant factor regardless of payment method.

---

### 6. Churn by Tenure Band

```sql
SELECT tenure_band, COUNT(*) AS customers, SUM(churn_flag) AS total_churn,
       ROUND(SUM(churn_flag)*100/COUNT(*), 2) AS churn_rate,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM telco_churn
GROUP BY tenure_band ORDER BY churn_rate DESC;
```

| Tenure Band | Customers | Churned | Churn Rate | Avg Monthly Charges |
|---|---|---|---|---|
| 0–12 Months | 2,186 | 1,037 | 47.44% | $56.10 |
| 13–24 Months | 1,024 | 294 | 28.71% | $61.36 |
| 25–48 Months | 1,594 | 325 | 20.39% | $65.93 |
| 49+ Months | 2,239 | 213 | 9.51% | $73.95 |

**Insight:** The first 12 months is the critical risk window — nearly 1 in 2 new customers churns. Churn rate drops sharply with tenure: 47.44% in year one vs 9.51% for customers beyond 4 years. Paradoxically, long-tenure customers pay the highest average monthly charges but have the lowest churn — suggesting that loyalty is driven by switching costs, familiarity, and satisfaction, not price sensitivity. Retention efforts should be heavily front-loaded in the first 12 months.

**0–12 Month Cohort by Internet Service:**
Fiber optic leads churn even within the highest-risk early tenure group, confirming that the Fiber Optic service quality issue is not a long-term adjustment — it drives churn from day one.

---

### 7. Churn by Monthly Charge Band

```sql
SELECT monthly_charge_band, COUNT(*) AS customers, SUM(churn_flag) AS total_churn,
       ROUND(SUM(churn_flag)*100/COUNT(*), 2) AS churn_rate,
       ROUND(AVG(tenure), 1) AS avg_tenure
FROM telco_churn
GROUP BY monthly_charge_band ORDER BY churn_rate DESC;
```

| Charge Band | Customers | Churn Rate | Avg Tenure |
|---|---|---|---|
| High ($60–$90) | 2,392 | 33.74% | 29.9 months |
| Very High (>$90) | 1,744 | 32.86% | 44.8 months |
| Medium ($30–$60) | 1,254 | 26.08% | 24.3 months |
| Low (<$30) | 1,653 | 9.80% | 29.0 months |

**Insight:** High and Very High charge customers churn at similar rates (33–34%), suggesting a pricing ceiling effect — beyond $60/month, additional charges do not meaningfully increase churn further, but the churn rate remains elevated. Within the High ($60–$90) band, Fiber Optic customers churn at 51.52%, confirming the service quality narrative.

---

### 8. Contract × Internet Service Combination

```sql
SELECT contract, internet_service, COUNT(*) AS customers,
       ROUND(SUM(churn_flag)*100/COUNT(*), 2) AS churn_rate,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
FROM telco_churn
GROUP BY contract, internet_service ORDER BY churn_rate DESC;
```

**Top combinations:**
- Month-to-month + Fiber optic → **54.61% churn rate** (highest)
- Two year + No internet service → **0.78% churn rate** (lowest)

**Insight:** The 54.61% vs 0.78% gap represents a 70× difference in churn risk between the worst and best contract × internet combinations. This is the sharpest finding in the entire dataset and the most direct target for intervention.

---

### 9. Window Function — Customer Lifetime Value Ranking

```sql
SELECT customer_id, contract, tenure, monthly_charges, lifetime_value,
       RANK() OVER (PARTITION BY contract ORDER BY lifetime_value DESC)
       AS value_rank_in_contract
FROM telco_churn WHERE churn_flag = 1
ORDER BY contract, value_rank_in_contract;
```

**Insight:** Among churned customers, tenure ranges from 71 months to just 1 month, with lifetime values from $7,462.10 down to $618.75. The window function ranks each churned customer by their value within their contract type — identifying the highest-value lost customers as the priority targets for win-back campaigns. A churned Two-year contract customer with 71 months of tenure represents a very different recovery opportunity than a month-to-month customer who left after 1 month.

---

### 10. CTE — Top 10 Highest-Risk Customer Profiles

```sql
WITH churn_profile AS (
  SELECT contract, internet_service, tenure_band, COUNT(*) AS customers,
         ROUND(SUM(churn_flag)*100.0/COUNT(*), 2) AS churn_rate,
         ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges
  FROM telco_churn
  GROUP BY contract, internet_service, tenure_band
  HAVING COUNT(*) >= 10
),
risk_labelled AS (
  SELECT *,
    CASE
      WHEN churn_rate >= 50 THEN 'Critical'
      WHEN churn_rate >= 35 THEN 'High'
      WHEN churn_rate >= 20 THEN 'Medium'
      ELSE 'Low'
    END AS risk_tier
  FROM churn_profile
)
SELECT * FROM risk_labelled ORDER BY churn_rate DESC LIMIT 10;
```

| Rank | Profile | Customers | Churn Rate | Risk Tier |
|---|---|---|---|---|
| 1 | Month-to-month + Fiber optic + 0–12 Months | 916 | 70.20% | Critical |
| 2 | Month-to-month + Fiber optic + 13–24 Months | 425 | 50.59% | Critical |
| 3 | Month-to-month + Fiber optic + 25–48 Months | 521 | 43.38% | High |
| 4 | Month-to-month + DSL + 0–12 Months | 690 | 42.46% | High |
| 5 | Month-to-month + Fiber optic + 49+ Months | 266 | 29.32% | Medium |
| 6 | Month-to-month + DSL + 13–24 Months | 232 | 23.71% | Medium |
| 7 | Month-to-month + No Internet + 0–12 Months | 388 | 22.68% | Medium |
| 8 | One year + Fiber optic + 25–48 Months | 154 | 20.13% | Medium |
| 9 | One year + Fiber optic + 49+ Months | 355 | 18.87% | Low |
| 10 | One year + Fiber optic + 13–24 Months | 23 | 17.39% | Low |

**Insight:** The top profile — Month-to-month + Fiber Optic + 0–12 Months — has 916 customers churning at 70.20%. This is not a niche segment: 916 customers is substantial, and 7 in 10 are leaving. This single profile accounts for a disproportionate share of total churn and is the highest-priority intervention target in the entire business.

---

## Key Findings Summary

| # | Finding |
|---|---|
| 1 | Overall churn rate is 26.54% — 1,869 out of 7,043 customers left |
| 2 | Month-to-month contracts churn at 42.71% vs 2.83% for two-year — a 15× gap |
| 3 | Fiber Optic customers churn at 41.89% despite paying the highest average charges ($91.50) — a service quality problem |
| 4 | Electronic check users churn at 45.29% — automatic payment methods cut churn to 15–17% |
| 5 | First 12 months is peak churn risk at 47.44% — nearly 1 in 2 new customers leaves |
| 6 | Customers beyond 49 months churn at only 9.51% despite paying more — loyalty drives retention, not price |
| 7 | Month-to-month + Fiber Optic = 54.61% churn rate — the single most dangerous combination |
| 8 | Two year + No internet service = 0.78% churn rate — the safest combination |
| 9 | Month-to-month + Fiber Optic + 0–12 Months = 70.20% churn rate (Critical tier) — 916 customers affected |
| 10 | Churned customers include high-value accounts with up to $7,462 lifetime value — significant win-back opportunity |

---

## Conclusion & Recommendations

The core finding is that churn is driven by **three compounding risk factors**: Month-to-Month contract type, Fiber Optic internet service, and early tenure (0–12 months). When all three are present simultaneously, churn reaches 70.20% — a Critical risk tier. Addressing even one of these three factors in a customer's profile significantly reduces their churn probability.

**Recommendation 1 — Incentivize contract upgrades within the first 3 months**
Month-to-month customers in their first 12 months are the highest-risk group. Offering a targeted discount (e.g. 15–20% off) to upgrade to a 1-year contract within the first 3 months could cut their churn rate from 42.71% toward the one-year rate of 11.27% — a potential reduction of 31 percentage points.

**Recommendation 2 — Investigate and fix Fiber Optic service quality**
Fiber Optic consistently appears as the highest-churn internet service across every segment — payment method, tenure band, charge band, and contract type. This is not a pricing issue; it is a service quality or expectation management issue. A customer satisfaction audit of Fiber Optic subscribers is needed before any pricing intervention.

**Recommendation 3 — Incentivize automatic payment method adoption**
Electronic check users churn at 45.29% vs 15–17% for automatic payment methods. Offering a small monthly discount (e.g. $5/month) for switching to auto-pay could both reduce churn and improve payment reliability simultaneously.

**Recommendation 4 — Launch targeted win-back campaigns for high-value churned customers**
The window function ranking identifies churned customers by lifetime value within each contract type. Customers with lifetime values above $5,000 (long-tenure, high-charge accounts) are the priority win-back targets — they represent the greatest revenue recovery opportunity per outreach effort.

**Recommendation 5 — Front-load retention investment in the first 12 months**
At 47.44% churn, the 0–12 month cohort is where the majority of churn loss occurs. Proactive check-ins, onboarding support, and service quality reviews at the 3-month and 6-month marks could significantly reduce first-year churn.

---

## Dashboard

### Tableau Dashboard
![Tableau Dashboard](Tableau%20Dashboard.png)

[View Live on Tableau Public](#) ← replace with your link

### Clean Data Preview
![Clean Data](Clean%20Data.png)

---

## Repository Structure

```
telecom-churn-analysis/
│
├── sql/
│   └── telco_churn.sql           ← MySQL queries with inline comments
│
├── Tableau Dashboard.png         ← dashboard screenshot
├── Clean Data.png                ← cleaned dataset preview
└── README.md                     ← this file
```

---

## Dataset Source

[IBM Telco Customer Churn — Kaggle](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)

---

*Project by Santanu — BBA Graduate, aspiring Business Analyst*  
*Skills demonstrated: Excel feature engineering · MySQL querying · Window functions · CTE with risk tiering · Tableau scatter plot visualization · Telecom churn analysis*
