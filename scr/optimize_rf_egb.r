library(dplyr)
library(readr)
library(tidyr)
library(caret)

data_train <- read.csv('./data/processed/processed_train.csv')

# Create custom indices
my_folds <- createMultiFolds(y = data_train$brand, k = 6, times = 2)

# Preprocessing steps
pre_proc <- c('center', 'scale')

# Create reusable trainControl object: myControl
fitControl <- trainControl(
    summaryFunction = twoClassSummary,
    classProbs = TRUE,
    verboseIter = TRUE,
    savePredictions = 'final',
    index = my_folds
)

target <- 'brand'
predictors <- names(data_train)[!names(data_train) %in% target]

fit_rf_egb_normalized <- caretList(
    data_train[, predictors],
    data_train[, target],
    trControl = fitControl,
    preProc = pre_proc,
    methodList = c('xgbTree', 'ranger'),
    metric = 'ROC'
)

stack_rf_egb_normalized <-
    caretStack(fit_rf_egb_normalized,
               method = 'glm',
               metric = 'ROC',
               trControl = fitControl)

saveRDS(stack_rf_egb_normalized, './models/RF_EGB_normalized.rds')

# Trying the same model but this time without centering and scaling

fit_rf_egb <- caretList(
    data_train[, predictors],
    data_train[, target],
    trControl = fitControl,
    methodList = c('xgbTree', 'ranger'),
    metric = 'ROC'
)

stack_rf_egb <-
    caretStack(fit_rf_egb,
               method = 'glm',
               metric = 'ROC',
               trControl = fitControl)

saveRDS(stack_rf_egb, './models/RF_EGB.rds')
