# QUICK REFERENCE - Feature Engineering Pipeline

## One-Line Execution
```r
source("feature_engineering.R"); results <- run_feature_engineering_pipeline("C:/Users/msdor/Desktop/RStudio/IS6850")
```

## Step-by-Step Execution

### 1. Load Functions
```r
source("feature_engineering.R")
data_dir <- "C:/Users/msdor/Desktop/RStudio/IS6850"
```

### 2. Full Pipeline (All Features)
```r
results <- run_feature_engineering_pipeline(data_dir, save_output = TRUE)
train <- results$train
test <- results$test
```

### 3. Application Features Only
```r
app_train <- fread(file.path(data_dir, "application_train.csv"))
train <- clean_and_engineer_features(app_train)
train <- add_advanced_features(train)
```

### 4. Add Bureau Features
```r
bureau <- fread(file.path(data_dir, "bureau.csv"))
bureau_agg <- aggregate_bureau_features(bureau)
train <- merge(train, bureau_agg, by = "SK_ID_CURR", all.x = TRUE)
```

### 5. Add Previous Applications
```r
prev_app <- fread(file.path(data_dir, "previous_application.csv"))
prev_agg <- aggregate_previous_applications(prev_app)
train <- merge(train, prev_agg, by = "SK_ID_CURR", all.x = TRUE)
```

### 6. Add Installments
```r
installments <- fread(file.path(data_dir, "installments_payments.csv"))
install_agg <- aggregate_installments(installments)
train <- merge(train, install_agg, by = "SK_ID_CURR", all.x = TRUE)
```

## Key Features by Category

### Financial Health Indicators
- CREDIT_INCOME_RATIO: Debt burden
- PAYMENT_BURDEN: Monthly payment affordability
- INCOME_PER_PERSON: Family income adequacy

### Credit History
- BUREAU_ACTIVE_RATIO: % of active credits
- BUREAU_DEBT_CREDIT_RATIO: Current debt load
- BUREAU_OVERDUE_SUM: Total overdue amounts

### Application History
- PREV_APPROVAL_RATE: Historical approval success
- PREV_REFUSAL_RATE: Historical rejection rate
- PREV_APP_COUNT: Total applications made

### Payment Behavior
- INSTALL_LATE_RATE: % of late payments
- INSTALL_PAYMENT_RATIO: Payment compliance
- INSTALL_DAYS_LATE_MAX: Worst late payment

### Risk Signals
- DAYS_EMPLOYED_ANOM: Employment data missing flag
- EXT_SOURCE_*_MISSING: External score availability
- TOTAL_DOCUMENTS: Documentation completeness

## Common Tasks

### Load Processed Data
```r
train <- fread("application_train_processed.csv")
test <- fread("application_test_processed.csv")
```

### Check Feature Count
```r
ncol(train)  # Should be 219
ncol(test)   # Should be 218 (no TARGET)
```

### Inspect New Features
```r
# Financial ratios
names(train)[grep("RATIO", names(train))]

# Bureau features
names(train)[grep("BUREAU", names(train))]

# Missing indicators
names(train)[grep("MISSING", names(train))]
```

### Check for Missing Values
```r
missing_pct <- colMeans(is.na(train)) * 100
sort(missing_pct[missing_pct > 0], decreasing = TRUE)
```

## Troubleshooting

### Error: File not found
```r
# Check data directory
list.files(data_dir, pattern = "\\.csv$")
```

### Error: Out of memory
```r
# Process files individually and clear memory
gc()  # Garbage collection
rm(list = setdiff(ls(), c("train", "test")))
```

### Warning: Many NaN/Inf values
```r
# Replace Inf with NA
train <- train %>% mutate(across(where(is.numeric), ~na_if(., Inf)))
train <- train %>% mutate(across(where(is.numeric), ~na_if(., -Inf)))
```

## Performance Tips

1. **Use data.table** for faster processing (already implemented)
2. **Process supplementary files once**, save aggregations
3. **Clear memory** after each aggregation step
4. **Use fread/fwrite** instead of read.csv/write.csv
5. **Set threads** for data.table: `setDTthreads(4)`

## Next Steps After Feature Engineering

1. **Exploratory Data Analysis**
   ```r
   summary(train)
   cor(train[, sapply(train, is.numeric)], use = "complete.obs")
   ```

2. **Handle Missing Values**
   ```r
   library(mice)
   train_imputed <- mice(train, method = "rf")
   ```

3. **Feature Selection**
   ```r
   library(Boruta)
   boruta_output <- Boruta(TARGET ~ ., data = train)
   ```

4. **Model Training**
   ```r
   library(xgboost)
   # Prepare data and train model
   ```

