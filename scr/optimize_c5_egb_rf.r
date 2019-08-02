library(dplyr)
library(readr)
library(tidyr)
library(caret)

data_train <- read.csv('./data/processed/processed_train.csv')

# Create custom indices
my_folds <- createMultiFolds(y = data_train$brand, k = 3, times = 1)

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

fit_c5_rf_egb <- caretList(
    data_train[, predictors],
    data_train[, target],
    trControl = fitControl,
    methodList = c('xgbTree', 'C5.0', 'ranger'),
    metric = 'ROC'
)

stack_c5_rf_egb <-
    caretStack(
        fit_rf_egb_normalized,
        method = 'glm',
        metric = 'ROC',
        trControl = fitControl
    )

saveRDS(stack_rf_egb, './models/C5.0_EGB_RF.rds')
