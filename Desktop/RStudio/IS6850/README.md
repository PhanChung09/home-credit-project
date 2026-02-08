# Home Credit Default Risk - Data Preparation & Feature Engineering

[![R](https://img.shields.io/badge/R-4.5.1-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-Educational-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-success.svg)](https://github.com)

A comprehensive, production-ready data preparation and feature engineering pipeline for credit default risk prediction. This project includes exploratory data analysis, automated feature engineering, and complete documentation.

## 📊 Project Overview

This repository implements a complete data science workflow for the Home Credit Default Risk competition. Starting with raw application data and supplementary files, the pipeline performs thorough EDA and creates 97 engineered features optimized for machine learning models.

### Key Achievements
- 🔍 **Comprehensive EDA**: 1,003 lines of exploratory analysis with visualizations
- 🔧 **Feature Engineering**: 97 new features from 5 data sources
- 📈 **80% Feature Increase**: From 122 to 219 features
- ✅ **Data Quality**: Fixed anomalies, handled missing values
- 🎯 **Production Ready**: Modular, documented, tested code

---

## 🔧 Data Preparation Script

### What It Does

**`feature_engineering.R`** is the main data preparation script that automates the entire feature engineering pipeline. It transforms raw Home Credit data into ML-ready features through a series of carefully designed transformations.

**Core Functionality:**
1. **Cleans Data**: Fixes DAYS_EMPLOYED anomaly, handles missing values, converts negative days to years
2. **Engineers Features**: Creates 97 new features including financial ratios, interactions, and aggregations
3. **Aggregates Data**: Combines 5 data sources (application, bureau, previous apps, installments) at applicant level
4. **Ensures Consistency**: Applies identical transformations to train and test data (no data leakage)
5. **Outputs Clean Data**: Saves processed CSV files ready for modeling

### How It Is Used

**Basic Usage (One Function Call):**
```r
# Load the script
source("feature_engineering.R")

# Run the complete pipeline
results <- run_feature_engineering_pipeline(
  data_dir = "path/to/home-credit-data",
  save_output = TRUE
)

# Access processed data
train <- results$train
test <- results$test
```

**Step-by-Step Usage (Modular):**
```r
# 1. Load application data
app_train <- fread("application_train.csv")
app_test <- fread("application_test.csv")

# 2. Apply feature engineering
train <- clean_and_engineer_features(app_train)
train <- add_advanced_features(train)

# 3. Aggregate supplementary data
bureau <- fread("bureau.csv")
bureau_agg <- aggregate_bureau_features(bureau)

# 4. Join features
train <- merge(train, bureau_agg, by = "SK_ID_CURR", all.x = TRUE)
```

### Input Requirements

**Required Data Files:**
```
data_directory/
├── application_train.csv          # Main training data (307,511 rows)
├── application_test.csv           # Main test data (48,744 rows)
├── bureau.csv                     # Credit bureau data (1.7M rows)
├── previous_application.csv       # Previous applications (1.7M rows)
└── installments_payments.csv      # Payment history (13.6M rows)
```

**File Specifications:**
- **application_train.csv**: 307,511 applicants × 122 features + TARGET variable
- **application_test.csv**: 48,744 applicants × 121 features (no TARGET)
- **bureau.csv**: Credit history records from other financial institutions
- **previous_application.csv**: Previous Home Credit applications
- **installments_payments.csv**: Repayment history for previous credits

**Download Data:**
```r
# Download from Kaggle:
# https://www.kaggle.com/c/home-credit-default-risk/data
```

### Output Description

**Processed Data Files:**
```
output_directory/
├── application_train_processed.csv    # 307,511 × 219 features (337 MB)
└── application_test_processed.csv     # 48,744 × 218 features (55 MB)
```

**Output Features:**
- **Original Features**: 122 (train) / 121 (test)
- **New Features**: 97 engineered features
- **Total Features**: 219 (train) / 218 (test)
- **TARGET**: Only in training data (0 = repaid, 1 = default)

**Feature Categories in Output:**
1. **Demographic** (4): AGE_YEARS, EMPLOYED_YEARS, etc.
2. **Financial Ratios** (10): CREDIT_INCOME_RATIO, PAYMENT_BURDEN, etc.
3. **Missing Indicators** (8): EXT_SOURCE_1_MISSING, etc.
4. **Interactions** (6): AGE_INCOME_INTERACTION, EXT_SOURCE_MEAN, etc.
5. **Binned Variables** (3): AGE_GROUP, INCOME_BIN, CREDIT_BIN
6. **Bureau Features** (23): BUREAU_ACTIVE_RATIO, BUREAU_DEBT_CREDIT_RATIO, etc.
7. **Previous App Features** (24): PREV_APPROVAL_RATE, PREV_REFUSAL_RATE, etc.
8. **Installment Features** (17): INSTALL_LATE_RATE, INSTALL_PAYMENT_RATIO, etc.
9. **Aggregates** (1): TOTAL_DOCUMENTS
10. **Plus all original features**

**Return Object (when save_output = FALSE):**
```r
results <- list(
  train = data.table,           # Processed training data
  test = data.table,            # Processed test data
  bureau_agg = data.table,      # Aggregated bureau features
  prev_agg = data.table,        # Aggregated previous app features
  install_agg = data.table      # Aggregated installment features
)
```

### Processing Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                  DATA PREPARATION PIPELINE                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Input: Raw CSV Files                                       │
│  ├── application_train.csv (122 features)                  │
│  ├── application_test.csv (121 features)                   │
│  ├── bureau.csv (1.7M rows)                                │
│  ├── previous_application.csv (1.7M rows)                  │
│  └── installments_payments.csv (13.6M rows)                │
│                                                             │
│  ↓                                                          │
│                                                             │
│  Step 1: Fix Data Quality Issues                           │
│  ├── DAYS_EMPLOYED anomaly → NA + indicator                │
│  ├── Convert negative days → positive years                │
│  └── Identify missing patterns                             │
│                                                             │
│  ↓                                                          │
│                                                             │
│  Step 2: Engineer Application Features                     │
│  ├── 4 demographic features                                │
│  ├── 10 financial ratios                                   │
│  ├── 8 missing indicators                                  │
│  ├── 6 interaction terms                                   │
│  ├── 3 binned variables                                    │
│  └── 1 document aggregate                                  │
│                                                             │
│  ↓                                                          │
│                                                             │
│  Step 3: Aggregate Supplementary Data                      │
│  ├── Bureau: 23 features (credit history)                  │
│  ├── Previous apps: 24 features (application patterns)     │
│  └── Installments: 17 features (payment behavior)          │
│                                                             │
│  ↓                                                          │
│                                                             │
│  Step 4: Join All Features                                 │
│  └── Merge by SK_ID_CURR (applicant ID)                    │
│                                                             │
│  ↓                                                          │
│                                                             │
│  Output: ML-Ready Data                                      │
│  ├── application_train_processed.csv (219 features)        │
│  └── application_test_processed.csv (218 features)         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Performance Metrics

| Metric | Value |
|--------|-------|
| **Processing Time** | 3-4 minutes |
| **Memory Required** | 4-6 GB RAM |
| **Input Size** | ~3.5 GB (5 CSV files) |
| **Output Size** | 392 MB (2 CSV files) |
| **Features Created** | 97 new features |
| **Data Reduction** | 89% size reduction with more features |

---

## 📁 Repository Structure

```
home-credit-feature-engineering/
│
├── 📊 EDA_homecredit_short.qmd          # Exploratory Data Analysis (38 KB)
│   ├─ Missing value analysis
│   ├─ Distribution visualizations  
│   ├─ Anomaly detection
│   └─ Feature insights
│
├── 🔧 feature_engineering.R             # Main data preparation script (12.5 KB)
│   ├─ 6 modular functions
│   ├─ 97 engineered features
│   ├─ Processes 5 data sources
│   └─ Train/test consistency
│
├── 📖 README.md                         # This file
├── 📄 README_feature_engineering.md     # Detailed feature documentation
├── 📝 QUICK_REFERENCE.md               # Quick start guide
└── ⚙️  .gitignore                       # Git configuration
```

## 🚀 Quick Start

### Prerequisites
```r
install.packages(c("data.table", "dplyr", "ggplot2", "quarto"))
```

### Complete Workflow
```r
# 1. Load the pipeline
source("feature_engineering.R")

# 2. Set your data directory
data_dir <- "path/to/your/home-credit-data"

# 3. Run complete pipeline (processes all files)
results <- run_feature_engineering_pipeline(data_dir, save_output = TRUE)

# 4. Access processed data
train <- results$train      # 307,511 × 219 features
test <- results$test        # 48,744 × 218 features

# 5. Verify output
dim(train)                  # Check dimensions
summary(train$TARGET)       # Check target distribution
names(train) %>% tail(20)   # View new features

# 6. Use for modeling
# Now ready for XGBoost, LightGBM, Random Forest, etc.
```

## 🔍 Exploratory Data Analysis

**File:** `EDA_homecredit_short.qmd` (Quarto document)

### Key Findings from EDA:
- **Target Imbalance**: 8% default rate (class imbalance issue)
- **DAYS_EMPLOYED Anomaly**: 365243 placeholder in 18% of records
- **Missing Data**: EXT_SOURCE_1 (56.4%), EXT_SOURCE_3 (19.8%)
- **Income Distribution**: Right-skewed with outliers
- **Credit Amounts**: Wide range requiring log transformation
- **Correlations**: External scores highly predictive

**To render the EDA:**
```r
library(quarto)
quarto_render("EDA_homecredit_short.qmd")
# Opens HTML report in browser
```

## 📈 Data Transformation Summary

| Dataset       | Original | Processed | Features Added | Improvement |
|---------------|----------|-----------|----------------|-------------|
| **Training**  | 122 cols | 219 cols  | +97           | +80%        |
| **Test**      | 121 cols | 218 cols  | +97           | +80%        |
| **Rows**      | 307,511  | 307,511   | No reduction  | Maintained  |

## 🔧 Engineered Features (97 Total)

### 1. Demographic Features (4)
- `AGE_YEARS`: Age in years (from DAYS_BIRTH)
- `EMPLOYED_YEARS`: Employment duration in years
- `REGISTRATION_YEARS`: Registration age
- `ID_PUBLISH_YEARS`: ID publication age

### 2. Financial Ratios (10)
- `CREDIT_INCOME_RATIO`: Debt burden indicator
- `PAYMENT_BURDEN`: Monthly payment affordability
- `INCOME_ANNUITY_RATIO`: Payment capacity
- `CREDIT_GOODS_RATIO`: Financing ratio
- `DOWN_PAYMENT_RATIO`: Down payment percentage
- `INCOME_PER_PERSON`: Family income adequacy
- `CREDIT_PER_CHILD`: Per-child credit burden
- `EMPLOYMENT_RATIO`: Employment stability
- `CREDIT_TERM_YEARS`: Loan duration
- `ANNUITY_CREDIT_RATIO`: Payment structure

### 3. Credit History - Bureau Features (23)
- Credit counts, overdue amounts, debt ratios, credit history timeline

### 4. Application History (24)
- Application counts by status, approval/refusal rates, credit amounts

### 5. Payment Behavior (17)
- Late payment rates, payment differences, payment compliance ratios

### 6. Missing Value Indicators (8)
- Flags for missing EXT_SOURCE, car age, goods price, etc.

### 7. Interaction Features (6)
- Age-income interactions, external score combinations

### 8. Binned Variables (3)
- Age groups, income bins, credit amount categories

## 🛠️ Data Quality Improvements

| Issue | Impact | Solution |
|-------|--------|----------|
| **DAYS_EMPLOYED = 365243** | 18% of records | Replace with NA + create indicator flag |
| **Negative day values** | All date columns | Convert to positive years |
| **Missing EXT_SOURCE_1** | 56.4% missing | Create missing indicators + composite score |
| **Supplementary data** | Millions of rows | Aggregate to applicant level (64 features) |

## 📚 Documentation

- **[README.md](README.md)**: Project overview and script introduction (this file)
- **[README_feature_engineering.md](README_feature_engineering.md)**: Detailed feature specifications
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)**: Quick commands and examples
- **[EDA_homecredit_short.qmd](EDA_homecredit_short.qmd)**: Complete exploratory analysis

## 🎓 Use Cases

- 📊 Credit default risk prediction
- 💰 Loan approval modeling
- 👥 Customer segmentation
- 📈 Risk scoring systems
- 🎓 Feature engineering education

## 📝 Citation

```bibtex
@misc{homecredit2026,
  title={Home Credit Default Risk - Data Preparation Pipeline},
  author={IS6850 Student},
  year={2026},
  publisher={GitHub},
  url={https://github.com/YOUR_USERNAME/home-credit-feature-engineering}
}
```

## 👤 Author

**IS6850 Student** - University of Arizona, Spring 2026

## 🙏 Acknowledgments

- Home Credit Group for the Kaggle competition dataset
- IS6850 Course Staff for guidance
- R Community for data.table, dplyr, and ggplot2

---

**⭐ Star this repository if you find it helpful!**

**📅 Last Updated**: February 8, 2026

