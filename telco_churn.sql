-- First, we will create the database and table and import the data 
create database Project3;

use Project3;

CREATE TABLE telco_churn (
  customer_id           VARCHAR(20) PRIMARY KEY,
  gender                VARCHAR(10),
  senior_citizen        INT,
  partner               VARCHAR(50),
  dependents            VARCHAR(50),
  tenure                INT,
  phone_service         VARCHAR(50),
  multiple_lines        VARCHAR(20),
  internet_service      VARCHAR(20),
  online_security       VARCHAR(50),
  online_backup         VARCHAR(50),
  device_protection     VARCHAR(50),
  tech_support          VARCHAR(50),
  streaming_tv          VARCHAR(50),
  streaming_movies      VARCHAR(50),
  contract              VARCHAR(20),
  paperless_billing     VARCHAR(50),
  payment_method        VARCHAR(30),
  monthly_charges       DECIMAL(10,2),
  total_charges         DECIMAL(10,2),
  churn                 VARCHAR(5),
  churn_flag            INT,
  tenure_band           VARCHAR(20),
  monthly_charge_band   VARCHAR(20),
  lifetime_value        DECIMAL(10,2)
);

-- Check if the data is all imported

select count(*) from telco_churn;

-- All the data is perfect and now we can move on to the analysis part

select count(*) as total_customers, sum(churn_flag) as total_churned,
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges,
round(avg(tenure),1) as avg_tenure_months from telco_churn;

-- We can see that out of the 7043 customers, a total of 1869 customers have left
-- The churn rate being 26.54% with and avg monthly charge of $64.76 and avg monthly tenure of 32.4 months
-- Now, we will check the churn by contract type 

select contract, count(*) as customers, sum(churn_flag) as total_churn,
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges 
from telco_churn
group by contract order by churn_rate desc;

-- Month-to-Month has the highest churn rate of 42.71%, a huge gap from the one year contract with 11.27%
-- The two year contrct type have a very less 2.83% churn rate
-- Now the churn rate by type of internet service

select internet_service, count(*) as customers, sum(churn_flag) as total_churn,
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges 
from telco_churn
group by internet_service order by churn_rate desc;

-- The Fiber Optic has a 41.89% churn rate followed by DSL with 18.96%, the avg charge of high amt. $91.50 may be the
-- reason for the fiber optic churn rate
-- The people with no internet service have a 7.41% churn rate
-- Now with people with phone_service

select phone_service, count(*) as customers, sum(churn_flag) as total_churn,
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges 
from telco_churn
group by phone_service order by churn_rate desc;

-- There is not much difference between the people having and not having phone service
-- Yes -> 26.71% , No -> 24.93%
-- Now we can look into the payment methods and the type of billing

select payment_method, count(*)as customers, sum(churn_flag) as total_churn, 
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges
from telco_churn
group by payment_method order by churn_rate desc;

-- Electronic check has the highest churn rate with 45.29% followed by Mailed check with 19.11%
-- The third and fourth being bank transfer and credit card with 16.71% and 15.24% respectively
-- Electronic check customers pay an avg of $76.26/month — the highest among all payment 
-- methods. Despite mailed check having the lowest avg charge ($43.92), it still has a 
-- 19.11% churn rate, suggesting price alone is not the primary churn driver.

select internet_service, count(*) as customers, sum(churn_flag) as total_churn,
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges 
from telco_churn where payment_method = 'Electronic Check'
group by  internet_service  order by churn_rate desc;

-- We can clearly see that fiber optic has the highest number of customers and churn rate with 53.23%
-- This is followed by DSL and no internet service 31.94% and 12.30% respectively
-- We should check the same for mailed check as it has the lowest charges yet has a high churn rate

select internet_service, count(*) as customers, sum(churn_flag) as total_churn,
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges 
from telco_churn where payment_method = 'Mailed Check'
group by internet_service  order by churn_rate desc;

-- Here we can see that here a similar story is happening, Fiber optic having the highest churn rate with 42.64%
-- This is followed by DSL and no internet service with 20.72% and 9.58% respectively
-- Now we go on to check the tenure band

select tenure_band, count(*)as customers, sum(churn_flag) as total_churn, 
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges
from telco_churn
group by tenure_band order by churn_rate desc;

-- 1. 0–12 Months → 2186 customers, 1037 churned, 47.44% churn rate, avg monthly charges 56.10
-- 2. 13–24 Months → 1024 customers, 294 churned, 28.71% churn rate, avg monthly charges 61.36
-- 3. 25–48 Months → 1594 customers, 325 churned, 20.39% churn rate, avg monthly charges 65.93
-- 4. 49+ Months → 2239 customers, 213 churned, 9.51% churn rate, avg monthly charges 73.95

select internet_service, count(*) as customers, sum(churn_flag) as total_churn,
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges 
from telco_churn where tenure_band = '0-12 Months'
group by internet_service  order by churn_rate desc;

-- We can see the same result being fiber optic having the highest churn rate in this category too, along with
-- people unsubscribing within a year, which gives us an insight that the services provided by us is not that
-- good, so people might be switching up

select monthly_charge_band, count(*)as customers, sum(churn_flag) as total_churn, 
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(tenure),1) as avg_tenure
from telco_churn
group by monthly_charge_band order by churn_rate desc;

-- 1. High ($60–$90) → 2392 customers, 807 churned, 33.74% churn rate, avg tenure 29.9 months
-- 2. Very High (>$90) → 1744 customers, 573 churned, 32.86% churn rate, avg tenure 44.8 months
-- 3. Medium ($30–$60) → 1254 customers, 327 churned, 26.08% churn rate, avg tenure 24.3 months
-- 4. Low (<$30) → 1653 customers, 162 churned, 9.80% churn rate, avg tenure 29.0 months

select internet_service, count(*) as customers, sum(churn_flag) as total_churn,
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges 
from telco_churn where monthly_charge_band = 'High ($60-$90)'
group by internet_service  order by churn_rate desc;

-- In this, the fiber optic service churn rate is 51.52%
-- The frquency of fiber optic service has come up goes on to show that we need to improve the 
-- service quality of it

select contract, internet_service, count(*) as customers, sum(churn_flag) as total_churn,
round(sum(churn_flag)*100/count(*),2) as churn_rate, round(avg(monthly_charges),2) as avg_monthly_charges
from telco_churn group by contract, internet_service order by churn_rate desc;

-- The highest is month-to-month with fiber optic at 54.61% churn rate, which was means that the recent services
-- along with the fiber optic needs to be improved
-- The lowest being two year without any internet service with 0.78%
-- Now after these findings we will see the rankings exactly over the contract types

select customer_id, contract, tenure, monthly_charges, lifetime_value, 
rank() over(partition by contract order by lifetime_value desc) as value_rank_in_contract
from telco_churn where churn_flag= 1
order by contract, value_rank_in_contract;

-- This shows us that which customers were with us until they left the using the services
-- It shows the tenure ranging from 71 months to even 1 month, with payment for that period being
-- $7462.10 to $618.75, this information can help us for win-back campaigns
-- and also some surveys to understand what we did wrong and how we can improve our services

with churn_profile as (
  select contract, internet_service, tenure_band, count(*) as customers,
round(sum(churn_flag) * 100.0 / count(*), 2) as churn_rate, round(avg(monthly_charges), 2) as avg_monthly_charges
from telco_churn group by contract, internet_service, tenure_band having count(*) >= 10
), risk_labelled as (
select *,
case
when churn_rate >= 50 then 'Critical'
when churn_rate >= 35 then 'High' when churn_rate >= 20 then 'Medium' else 'Low' end as risk_tier
from churn_profile) select *
from risk_labelled
order by churn_rate desc
limit 10;

-- The top 10 most dangerous profiles are therefore:
-- 1. Month-to-month + Fiber optic + 0–12 Months → 916 customers, 70.20% churn rate, avg monthly charges 82.08, Risk Tier: Critical
-- 2. Month-to-month + Fiber optic + 13–24 Months → 425 customers, 50.59% churn rate, avg monthly charges 87.54, Risk Tier: Critical
-- 3. Month-to-month + Fiber optic + 25–48 Months → 521 customers, 43.38% churn rate, avg monthly charges 91.24, Risk Tier: High
-- 4. Month-to-month + DSL + 0–12 Months → 690 customers, 42.46% churn rate, avg monthly charges 47.88, Risk Tier: High
-- 5. Month-to-month + Fiber optic + 49+ Months → 266 customers, 29.32% churn rate, avg monthly charges 94.95, Risk Tier: Medium
-- 6. Month-to-month + DSL + 13–24 Months → 232 customers, 23.71% churn rate, avg monthly charges 52.68, Risk Tier: Medium
-- 7. Month-to-month + No Internet Service + 0–12 Months → 388 customers, 22.68% churn rate, avg monthly charges 20.27, Risk Tier: Medium
-- 8. One year + Fiber optic + 25–48 Months → 154 customers, 20.13% churn rate, avg monthly charges 96.04, Risk Tier: Medium
-- 9. One year + Fiber optic + 49+ Months → 355 customers, 18.87% churn rate, avg monthly charges 100.49, Risk Tier: Low
-- 10. One year + Fiber optic + 13–24 Months → 23 customers, 17.39% churn rate, avg monthly charges 91.85, Risk Tier: Low

-- OVERALL CONCLUSION:
-- Three factors compound churn risk: Month-to-Month contract + Fiber Optic internet + 
-- Early tenure (0-12 months). When all three combine, churn hits 70.20% — Critical tier.
-- Key recommendations:
-- 1. Incentivize Month-to-Month customers to upgrade to 1-year contracts within first 3 months
-- 2. Investigate Fiber Optic service quality — it drives high churn across ALL contract types
-- 3. Launch win-back campaigns targeting high lifetime value churned customers identified 
--    in the window function ranking
-- 4. Electronic check users churn at 45.29% — targeted payment method switch incentives 
--    (auto-pay discounts) could reduce churn significantly