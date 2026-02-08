# Home Credit Feature Engineering Pipeline

## Overview
This R script provides a comprehensive feature engineering pipeline for the Home Credit Default Risk competition. It processes raw application data and supplementary files to create 97+ engineered features for credit default prediction.

## Features Created

### 1. Demographic Features (4)
- AGE_YEARS: Age in years (converted from DAYS_BIRTH)
- EMPLOYED_YEARS: Employment duration in years
- REGISTRATION_YEARS: Registration age in years  
- ID_PUBLISH_YEARS: ID publication age in years

### 2. Financial Ratios (10)
- CREDIT_INCOME_RATIO: Total credit / Income (debt burden)
- PAYMENT_BURDEN: Annuity / Income (affordability)
- INCOME_ANNUITY_RATIO: Income / Annuity payment
- CREDIT_GOODS_RATIO: Credit / Goods price
- DOWN_PAYMENT_RATIO: Down payment percentage
- INCOME_PER_PERSON: Income per family member
- CREDIT_PER_CHILD: Credit amount per child
- EMPLOYMENT_RATIO: Employment stability metric
- CREDIT_TERM_YEARS: Loan duration in years
- ANNUITY_CREDIT_RATIO: Annuity as % of credit

### 3. Missing Value Indicators (8)
Flags for missing values in:
- EXT_SOURCE_1, EXT_SOURCE_2, EXT_SOURCE_3
- OWN_CAR_AGE, AMT_GOODS_PRICE, AMT_ANNUITY
- CNT_FAM_MEMBERS, DAYS_LAST_PHONE_CHANGE

### 4. Interaction Features (6)
- AGE_INCOME_INTERACTION: Life-stage income
- EXT_SOURCE_MEAN: Average external score
- EXT_SOURCE_12_INTERACTION, EXT_SOURCE_23_INTERACTION
- EDUCATION_INCOME_INTERACTION
- OCCUPATION_INCOME_INTERACTION

### 5. Binned Variables (3)
- AGE_GROUP: 6 age brackets
- INCOME_BIN: 5 income levels
- CREDIT_BIN: 5 credit amount levels

### 6. Bureau Features (23)
Aggregated credit history:
- Active/closed/sold credit counts
- Overdue amounts (mean, max, sum)
- Debt amounts and ratios
- Credit history statistics

### 7. Previous Application Features (24)
Historical application data:
- Application counts by status
- Credit and application amounts
- Approval/refusal rates
- Days to decision statistics

### 8. Installments Features (17)
Payment behavior:
- Late payment counts and rates
- Payment differences
- Days late statistics
- Payment ratios

## Quick Start

```r
# 1. Load the pipeline
source("feature_engineering.R")

# 2. Set your data directory
data_dir <- "C:/Users/msdor/Desktop/RStudio/IS6850"

# 3. Run the complete pipeline
results <- run_feature_engineering_pipeline(data_dir, save_output = TRUE)

# 4. Access processed data
train_data <- results$train
test_data <- results$test
```

## Using Individual Functions

```r
# Load only application data
app_train <- fread("application_train.csv")

# Apply application-level features
train_processed <- clean_and_engineer_features(app_train)
train_processed <- add_advanced_features(train_processed)

# Aggregate bureau data separately
bureau <- fread("bureau.csv")
bureau_agg <- aggregate_bureau_features(bureau)

# Join to main data
train_final <- merge(train_processed, bureau_agg, by = "SK_ID_CURR", all.x = TRUE)
```

## Data Quality Fixes

### 1. DAYS_EMPLOYED Anomaly
- Problem: 18% of rows have placeholder value 365243
- Solution: Convert to NA and create indicator flag DAYS_EMPLOYED_ANOM

### 2. Demographic Features
- Problem: Negative values in days (e.g., DAYS_BIRTH = -9461)
- Solution: Convert to positive years (AGE_YEARS = 25.9)

### 3. Missing Values
- Problem: High missing rates in EXT_SOURCE variables
- Solution: Create missing indicators + composite scores

## Output

### Training Data
- Rows: 307,511
- Original columns: 122
- Final columns: 219
- New features: 97

### Test Data  
- Rows: 48,744
- Original columns: 121
- Final columns: 218 (same as train minus TARGET)

### Saved Files
- application_train_processed.csv (337 MB)
- application_test_processed.csv (55 MB)

## Requirements

```r
library(data.table)
library(dplyr)
```

## Next Steps

After feature engineering:
1. Handle remaining missing values (imputation)
2. Encode categorical variables
3. Scale/normalize numeric features
4. Feature selection
5. Model training (XGBoost, LightGBM, etc.)

## Notes

- All transformations maintain train/test consistency
- No data leakage between train and test
- Aggregations computed on supplementary files
- File processing time: ~2-3 minutes on standard hardware

## Author
Data Science Team - Home Credit Default Risk Project
Version 1.0 - February 2026

