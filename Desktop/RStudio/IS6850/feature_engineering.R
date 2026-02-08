
# =============================================================================
# HOME CREDIT DEFAULT RISK - FEATURE ENGINEERING PIPELINE
# =============================================================================
# Description: Comprehensive feature engineering for Home Credit data
# Author: Data Science Team  
# Date: 2026-02-08
# Version: 1.0
# =============================================================================

library(data.table)
library(dplyr)

# =============================================================================
# PART 1: APPLICATION DATA FEATURE ENGINEERING
# =============================================================================

clean_and_engineer_features <- function(df, is_train = TRUE, train_stats = NULL) {
  cat("=== STARTING FEATURE ENGINEERING ===\n")
  
  # 1. FIX DAYS_EMPLOYED ANOMALY
  cat("1. Fixing DAYS_EMPLOYED anomaly...\n")
  df[, DAYS_EMPLOYED_ANOM := as.integer(DAYS_EMPLOYED == 365243)]
  df[DAYS_EMPLOYED == 365243, DAYS_EMPLOYED := NA]
  
  # 2. DEMOGRAPHIC FEATURES
  cat("2. Creating demographic features...\n")
  df[, AGE_YEARS := abs(DAYS_BIRTH) / 365]
  df[, EMPLOYED_YEARS := abs(DAYS_EMPLOYED) / 365]
  df[, REGISTRATION_YEARS := abs(DAYS_REGISTRATION) / 365]
  df[, ID_PUBLISH_YEARS := abs(DAYS_ID_PUBLISH) / 365]
  
  # 3. FINANCIAL RATIOS
  cat("3. Engineering financial ratios...\n")
  df[, CREDIT_INCOME_RATIO := AMT_CREDIT / AMT_INCOME_TOTAL]
  df[, ANNUITY_CREDIT_RATIO := AMT_ANNUITY / AMT_CREDIT]
  df[, INCOME_ANNUITY_RATIO := AMT_INCOME_TOTAL / AMT_ANNUITY]
  df[, CREDIT_GOODS_RATIO := AMT_CREDIT / AMT_GOODS_PRICE]
  df[, DOWN_PAYMENT_RATIO := (AMT_GOODS_PRICE - AMT_CREDIT) / AMT_GOODS_PRICE]
  df[, PAYMENT_BURDEN := AMT_ANNUITY / AMT_INCOME_TOTAL]
  df[, INCOME_PER_PERSON := AMT_INCOME_TOTAL / CNT_FAM_MEMBERS]
  df[, CREDIT_PER_CHILD := ifelse(CNT_CHILDREN > 0, AMT_CREDIT / CNT_CHILDREN, 0)]
  df[, EMPLOYMENT_RATIO := EMPLOYED_YEARS / AGE_YEARS]
  df[, CREDIT_TERM_YEARS := AMT_CREDIT / (AMT_ANNUITY * 12)]
  
  cat(sprintf("   Created %d financial ratios\n", 10))
  return(df)
}

add_advanced_features <- function(df) {
  cat("=== ADDING ADVANCED FEATURES ===\n")
  
  # 4. MISSING INDICATORS
  cat("4. Creating missing indicators...\n")
  missing_cols <- c("EXT_SOURCE_1", "EXT_SOURCE_2", "EXT_SOURCE_3",
                    "OWN_CAR_AGE", "AMT_GOODS_PRICE", "AMT_ANNUITY",
                    "CNT_FAM_MEMBERS", "DAYS_LAST_PHONE_CHANGE")
  
  for(col in missing_cols) {
    if(col %in% names(df)) {
      new_col <- paste0(col, "_MISSING")
      df[, (new_col) := as.integer(is.na(get(col)))]
    }
  }
  
  # 5. INTERACTIONS
  cat("5. Creating interactions...\n")
  df[, AGE_INCOME_INTERACTION := AGE_YEARS * AMT_INCOME_TOTAL]
  df[, EXT_SOURCE_MEAN := rowMeans(cbind(EXT_SOURCE_1, EXT_SOURCE_2, EXT_SOURCE_3), na.rm = TRUE)]
  df[, EXT_SOURCE_12_INTERACTION := EXT_SOURCE_1 * EXT_SOURCE_2]
  df[, EXT_SOURCE_23_INTERACTION := EXT_SOURCE_2 * EXT_SOURCE_3]
  df[, EDUCATION_INCOME_INTERACTION := as.numeric(as.factor(NAME_EDUCATION_TYPE)) * AMT_INCOME_TOTAL]
  df[, OCCUPATION_INCOME_INTERACTION := as.numeric(as.factor(OCCUPATION_TYPE)) * AMT_INCOME_TOTAL]
  
  # 6. BINNED VARIABLES
  cat("6. Creating binned features...\n")
  df[, AGE_GROUP := cut(AGE_YEARS, breaks = c(0, 25, 35, 45, 55, 65, 100),
                        labels = c("18-25", "26-35", "36-45", "46-55", "56-65", "65+"))]
  df[, INCOME_BIN := cut(AMT_INCOME_TOTAL, breaks = c(0, 100000, 150000, 200000, 300000, Inf),
                         labels = c("Low", "Medium-Low", "Medium", "Medium-High", "High"))]
  df[, CREDIT_BIN := cut(AMT_CREDIT, breaks = c(0, 300000, 600000, 900000, 1200000, Inf),
                         labels = c("Small", "Medium", "Large", "Very Large", "Huge"))]
  
  # 7. DOCUMENT AGGREGATES
  cat("7. Creating document aggregates...\n")
  doc_cols <- grep("^FLAG_DOCUMENT_", names(df), value = TRUE)
  df[, TOTAL_DOCUMENTS := rowSums(.SD), .SDcols = doc_cols]
  
  return(df)
}

# =============================================================================
# PART 2: SUPPLEMENTARY DATA AGGREGATION
# =============================================================================

aggregate_bureau_features <- function(bureau) {
  cat("=== AGGREGATING BUREAU DATA ===\n")
  
  bureau_agg <- bureau[, .(
    BUREAU_COUNT = .N,
    BUREAU_ACTIVE_COUNT = sum(CREDIT_ACTIVE == "Active", na.rm = TRUE),
    BUREAU_CLOSED_COUNT = sum(CREDIT_ACTIVE == "Closed", na.rm = TRUE),
    BUREAU_SOLD_COUNT = sum(CREDIT_ACTIVE == "Sold", na.rm = TRUE),
    BUREAU_CREDIT_TYPES = uniqueN(CREDIT_TYPE),
    BUREAU_OVERDUE_MEAN = mean(AMT_CREDIT_SUM_OVERDUE, na.rm = TRUE),
    BUREAU_OVERDUE_MAX = max(AMT_CREDIT_SUM_OVERDUE, na.rm = TRUE),
    BUREAU_OVERDUE_SUM = sum(AMT_CREDIT_SUM_OVERDUE, na.rm = TRUE),
    BUREAU_DEBT_MEAN = mean(AMT_CREDIT_SUM_DEBT, na.rm = TRUE),
    BUREAU_DEBT_MAX = max(AMT_CREDIT_SUM_DEBT, na.rm = TRUE),
    BUREAU_DEBT_SUM = sum(AMT_CREDIT_SUM_DEBT, na.rm = TRUE),
    BUREAU_CREDIT_MEAN = mean(AMT_CREDIT_SUM, na.rm = TRUE),
    BUREAU_CREDIT_MAX = max(AMT_CREDIT_SUM, na.rm = TRUE),
    BUREAU_CREDIT_SUM = sum(AMT_CREDIT_SUM, na.rm = TRUE),
    BUREAU_DAYS_CREDIT_MIN = min(DAYS_CREDIT, na.rm = TRUE),
    BUREAU_DAYS_CREDIT_MAX = max(DAYS_CREDIT, na.rm = TRUE),
    BUREAU_DAYS_CREDIT_MEAN = mean(DAYS_CREDIT, na.rm = TRUE),
    BUREAU_PROLONGED_COUNT = sum(CNT_CREDIT_PROLONG > 0, na.rm = TRUE),
    BUREAU_DAYS_UPDATE_MEAN = mean(DAYS_CREDIT_UPDATE, na.rm = TRUE),
    BUREAU_DAYS_ENDDATE_MEAN = mean(DAYS_ENDDATE_FACT, na.rm = TRUE)
  ), by = SK_ID_CURR]
  
  bureau_agg[, BUREAU_ACTIVE_RATIO := BUREAU_ACTIVE_COUNT / BUREAU_COUNT]
  bureau_agg[, BUREAU_DEBT_CREDIT_RATIO := BUREAU_DEBT_SUM / BUREAU_CREDIT_SUM]
  bureau_agg[, BUREAU_OVERDUE_DEBT_RATIO := BUREAU_OVERDUE_SUM / BUREAU_DEBT_SUM]
  
  cat(sprintf("Bureau: %d applicants, %d features\n", nrow(bureau_agg), ncol(bureau_agg) - 1))
  return(bureau_agg)
}

aggregate_previous_applications <- function(prev_app) {
  cat("=== AGGREGATING PREVIOUS APPLICATIONS ===\n")
  
  prev_agg <- prev_app[, .(
    PREV_APP_COUNT = .N,
    PREV_APP_APPROVED = sum(NAME_CONTRACT_STATUS == "Approved", na.rm = TRUE),
    PREV_APP_REFUSED = sum(NAME_CONTRACT_STATUS == "Refused", na.rm = TRUE),
    PREV_APP_CANCELED = sum(NAME_CONTRACT_STATUS == "Canceled", na.rm = TRUE),
    PREV_APP_UNUSED = sum(NAME_CONTRACT_STATUS == "Unused offer", na.rm = TRUE),
    PREV_AMT_CREDIT_MEAN = mean(AMT_CREDIT, na.rm = TRUE),
    PREV_AMT_CREDIT_MAX = max(AMT_CREDIT, na.rm = TRUE),
    PREV_AMT_CREDIT_SUM = sum(AMT_CREDIT, na.rm = TRUE),
    PREV_AMT_APPLICATION_MEAN = mean(AMT_APPLICATION, na.rm = TRUE),
    PREV_AMT_APPLICATION_MAX = max(AMT_APPLICATION, na.rm = TRUE),
    PREV_AMT_DOWN_PAYMENT_MEAN = mean(AMT_DOWN_PAYMENT, na.rm = TRUE),
    PREV_AMT_DOWN_PAYMENT_MAX = max(AMT_DOWN_PAYMENT, na.rm = TRUE),
    PREV_AMT_GOODS_PRICE_MEAN = mean(AMT_GOODS_PRICE, na.rm = TRUE),
    PREV_AMT_GOODS_PRICE_MAX = max(AMT_GOODS_PRICE, na.rm = TRUE),
    PREV_DAYS_DECISION_MIN = min(DAYS_DECISION, na.rm = TRUE),
    PREV_DAYS_DECISION_MAX = max(DAYS_DECISION, na.rm = TRUE),
    PREV_DAYS_DECISION_MEAN = mean(DAYS_DECISION, na.rm = TRUE),
    PREV_PRODUCT_TYPES = uniqueN(NAME_PRODUCT_TYPE),
    PREV_CASH_LOANS = sum(NAME_CONTRACT_TYPE == "Cash loans", na.rm = TRUE),
    PREV_CONSUMER_LOANS = sum(NAME_CONTRACT_TYPE == "Consumer loans", na.rm = TRUE),
    PREV_REVOLVING_LOANS = sum(NAME_CONTRACT_TYPE == "Revolving loans", na.rm = TRUE)
  ), by = SK_ID_CURR]
  
  prev_agg[, PREV_APPROVAL_RATE := PREV_APP_APPROVED / PREV_APP_COUNT]
  prev_agg[, PREV_REFUSAL_RATE := PREV_APP_REFUSED / PREV_APP_COUNT]
  prev_agg[, PREV_CREDIT_APP_RATIO := PREV_AMT_CREDIT_MEAN / PREV_AMT_APPLICATION_MEAN]
  
  cat(sprintf("Previous apps: %d applicants, %d features\n", nrow(prev_agg), ncol(prev_agg) - 1))
  return(prev_agg)
}

aggregate_installments <- function(installments) {
  cat("=== AGGREGATING INSTALLMENTS ===\n")
  
  installments[, PAYMENT_DIFF := AMT_PAYMENT - AMT_INSTALMENT]
  installments[, DAYS_LATE := pmax(0, DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT)]
  installments[, IS_LATE := as.integer(DAYS_LATE > 0)]
  
  install_agg <- installments[, .(
    INSTALL_COUNT = .N,
    INSTALL_LATE_COUNT = sum(IS_LATE, na.rm = TRUE),
    INSTALL_PAYMENT_DIFF_MEAN = mean(PAYMENT_DIFF, na.rm = TRUE),
    INSTALL_PAYMENT_DIFF_MAX = max(PAYMENT_DIFF, na.rm = TRUE),
    INSTALL_PAYMENT_DIFF_MIN = min(PAYMENT_DIFF, na.rm = TRUE),
    INSTALL_PAYMENT_DIFF_SUM = sum(PAYMENT_DIFF, na.rm = TRUE),
    INSTALL_DAYS_LATE_MEAN = mean(DAYS_LATE[DAYS_LATE > 0], na.rm = TRUE),
    INSTALL_DAYS_LATE_MAX = max(DAYS_LATE, na.rm = TRUE),
    INSTALL_DAYS_LATE_SUM = sum(DAYS_LATE, na.rm = TRUE),
    INSTALL_AMT_PAYMENT_MEAN = mean(AMT_PAYMENT, na.rm = TRUE),
    INSTALL_AMT_PAYMENT_MAX = max(AMT_PAYMENT, na.rm = TRUE),
    INSTALL_AMT_PAYMENT_SUM = sum(AMT_PAYMENT, na.rm = TRUE),
    INSTALL_AMT_INSTALMENT_MEAN = mean(AMT_INSTALMENT, na.rm = TRUE),
    INSTALL_AMT_INSTALMENT_MAX = max(AMT_INSTALMENT, na.rm = TRUE),
    INSTALL_AMT_INSTALMENT_SUM = sum(AMT_INSTALMENT, na.rm = TRUE)
  ), by = SK_ID_CURR]
  
  install_agg[, INSTALL_LATE_RATE := INSTALL_LATE_COUNT / INSTALL_COUNT]
  install_agg[, INSTALL_PAYMENT_RATIO := INSTALL_AMT_PAYMENT_SUM / INSTALL_AMT_INSTALMENT_SUM]
  install_agg[is.infinite(INSTALL_DAYS_LATE_MEAN), INSTALL_DAYS_LATE_MEAN := NA]
  
  cat(sprintf("Installments: %d applicants, %d features\n", nrow(install_agg), ncol(install_agg) - 1))
  return(install_agg)
}

# =============================================================================
# PART 3: MASTER PIPELINE
# =============================================================================

run_feature_engineering_pipeline <- function(data_dir, save_output = TRUE) {
  cat("=================================================================\n")
  cat("       HOME CREDIT FEATURE ENGINEERING PIPELINE\n")
  cat("=================================================================\n\n")
  
  # Load data
  cat("Step 1: Loading data...\n")
  app_train <- fread(file.path(data_dir, "application_train.csv"))
  app_test <- fread(file.path(data_dir, "application_test.csv"))
  
  # Engineer application features
  cat("\nStep 2: Engineering application features...\n")
  train_processed <- clean_and_engineer_features(app_train, is_train = TRUE)
  train_processed <- add_advanced_features(train_processed)
  test_processed <- clean_and_engineer_features(app_test, is_train = FALSE)
  test_processed <- add_advanced_features(test_processed)
  
  # Aggregate supplementary data
  cat("\nStep 3: Aggregating supplementary data...\n")
  bureau <- fread(file.path(data_dir, "bureau.csv"))
  bureau_agg <- aggregate_bureau_features(bureau)
  
  prev_app <- fread(file.path(data_dir, "previous_application.csv"))
  prev_agg <- aggregate_previous_applications(prev_app)
  
  installments <- fread(file.path(data_dir, "installments_payments.csv"))
  install_agg <- aggregate_installments(installments)
  
  # Join all features
  cat("\nStep 4: Joining features...\n")
  train_final <- merge(train_processed, bureau_agg, by = "SK_ID_CURR", all.x = TRUE)
  train_final <- merge(train_final, prev_agg, by = "SK_ID_CURR", all.x = TRUE)
  train_final <- merge(train_final, install_agg, by = "SK_ID_CURR", all.x = TRUE)
  
  test_final <- merge(test_processed, bureau_agg, by = "SK_ID_CURR", all.x = TRUE)
  test_final <- merge(test_final, prev_agg, by = "SK_ID_CURR", all.x = TRUE)
  test_final <- merge(test_final, install_agg, by = "SK_ID_CURR", all.x = TRUE)
  
  # Save
  if(save_output) {
    cat("\nStep 5: Saving files...\n")
    fwrite(train_final, file.path(data_dir, "application_train_processed.csv"))
    fwrite(test_final, file.path(data_dir, "application_test_processed.csv"))
    cat("✓ Saved successfully\n")
  }
  
  cat("\n=================================================================\n")
  cat("COMPLETE! Training: %d x %d | Test: %d x %d\n", 
      nrow(train_final), ncol(train_final), nrow(test_final), ncol(test_final))
  cat("=================================================================\n")
  
  return(list(train = train_final, test = test_final,
              bureau_agg = bureau_agg, prev_agg = prev_agg, install_agg = install_agg))
}

# =============================================================================
# USAGE:
# source("feature_engineering.R")
# data_dir <- "C:/Users/msdor/Desktop/RStudio/IS6850"
# results <- run_feature_engineering_pipeline(data_dir)
# =============================================================================

