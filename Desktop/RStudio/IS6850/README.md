# Home Credit Default Risk - Data Preparation Pipeline

A comprehensive R-based data preparation and feature engineering pipeline for credit default risk prediction, including exploratory data analysis.

## 📊 Project Overview

This repository contains a production-ready data preparation script that transforms raw Home Credit application data into ML-ready features. The pipeline processes multiple data sources and creates 97 engineered features designed to improve credit default prediction models.

## 📁 Repository Contents

```
├── README.md                          # This file
├── EDA_homecredit_short.qmd          # Exploratory Data Analysis (Quarto)
├── feature_engineering.R              # Main data preparation script
├── README_feature_engineering.md      # Detailed feature documentation
├── QUICK_REFERENCE.md                # Quick start guide
└── .gitignore                        # Git ignore rules
```

## 🔍 Exploratory Data Analysis

**File:** `EDA_homecredit_short.qmd`

The EDA document provides:
- **Data Quality Assessment**: Missing values, anomalies, outliers
- **Distribution Analysis**: Univariate and bivariate distributions
- **Key Findings**:
  - DAYS_EMPLOYED anomaly (365243 in 18% of records)
  - High missing rates in EXT_SOURCE_1 (56.4%)
  - Target imbalance (8% default rate)
  - Income and credit amount distributions
- **Visualizations**: Histograms, box plots, correlation matrices
- **Recommendations**: Guides feature engineering decisions

To render the EDA:
```r
library(quarto)
quarto_render("EDA_homecredit_short.qmd")
```

## 🎯 Key Features

- **Automated Pipeline**: Single function call processes all data sources
- **97 Engineered Features**: Financial ratios, interactions, aggregations, and indicators
- **Data Quality Fixes**: Handles anomalies, missing values, and data type issues
- **Train/Test Consistency**: Ensures identical transformations for both datasets
- **Modular Design**: 6 reusable functions for flexible workflows
- **Well Documented**: Complete documentation and quick reference guides

## 🚀 Quick Start

### Prerequisites
```r
install.packages(c("data.table", "dplyr"))
```

### Basic Usage
```r
# Load the pipeline
source("feature_engineering.R")

# Set data directory
data_dir <- "path/to/your/data"

# Run complete pipeline
results <- run_feature_engineering_pipeline(data_dir)

# Access processed data
train <- results$train  # 307,511 × 219
test <- results$test    # 48,744 × 218
```

## 📈 Data Transformation

| Dataset  | Original | Final | Features Added |
|----------|----------|-------|----------------|
| Training | 122 cols | 219 cols | +97 (+80%) |
| Test     | 121 cols | 218 cols | +97 (+80%) |

## 🔧 Engineered Features

### Financial Health Indicators (10)
- Credit-to-Income Ratio (debt burden)
- Payment Burden (monthly affordability)
- Income per Person (family adequacy)
- Credit Term, Down Payment Ratio, etc.

### Credit History (23 from Bureau data)
- Active/Closed credit counts
- Overdue amounts and debt ratios
- Credit history statistics
- Prolongation patterns

### Application History (24)
- Approval/Refusal rates
- Previous credit amounts
- Days to decision statistics
- Application patterns

### Payment Behavior (17 from Installments)
- Late payment rates
- Payment differences
- Days late statistics
- Payment compliance ratios

### Additional Features (23)
- Demographic features (age, employment)
- Missing value indicators
- Interaction terms
- Binned variables

## 🛠️ Data Quality Improvements

| Issue | Solution |
|-------|----------|
| DAYS_EMPLOYED anomaly (365243) | Convert to NA + indicator flag |
| Negative day values | Convert to positive years |
| Missing EXT_SOURCE (56.4%) | Missing indicators + composite score |
| Supplementary data (millions of rows) | Aggregate to applicant level |

## 📚 Documentation

- **[EDA_homecredit_short.qmd](EDA_homecredit_short.qmd)**: Exploratory data analysis with visualizations
- **[README_feature_engineering.md](README_feature_engineering.md)**: Complete feature documentation
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)**: Quick start commands and common tasks

## 💡 Complete Workflow

```r
# 1. Explore the data (optional)
# Open and render EDA_homecredit_short.qmd in RStudio

# 2. Load and process data
source("feature_engineering.R")
results <- run_feature_engineering_pipeline("./data")

# 3. Check output
dim(results$train)  # 307511 × 219
sum(is.na(results$train$TARGET))  # 0

# 4. View key features
names(results$train) %>% grep("RATIO", ., value = TRUE)

# 5. Save for modeling
fwrite(results$train, "train_processed.csv")
```

## 🔄 Pipeline Functions

1. `clean_and_engineer_features()` - Application data processing
2. `add_advanced_features()` - Interactions and indicators
3. `aggregate_bureau_features()` - Credit history aggregation
4. `aggregate_previous_applications()` - Application history
5. `aggregate_installments()` - Payment behavior
6. `run_feature_engineering_pipeline()` - Master function

## 📊 Performance

- **Processing Time**: ~2-3 minutes on standard hardware
- **Memory Usage**: ~4-6 GB RAM recommended
- **Output Size**: 337 MB (train) + 55 MB (test)

## 🎓 Use Cases

- Credit default risk prediction
- Loan approval modeling
- Customer segmentation
- Risk scoring systems
- Feature engineering education

## 🤝 Contributing

This is a class project for IS6850. Feel free to:
- Report issues or bugs
- Suggest additional features
- Share improvements
- Use for educational purposes

## 📝 License

Educational use only - IS6850 Class Project

## 👤 Author

IS6850 Student - University of Arizona
Spring 2026

## 🙏 Acknowledgments

- Home Credit Default Risk Kaggle Competition
- IS6850 Data Science Course
- R data.table and dplyr communities
- Quarto for reproducible analysis

---

**Note**: Large CSV files are excluded from repository (see .gitignore). Download raw data from [Kaggle](https://www.kaggle.com/c/home-credit-default-risk/data).

