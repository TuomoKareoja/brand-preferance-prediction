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

fit_egb_normalized <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        preProc = pre_proc,
        method = 'xgbTree',
        metric = 'ROC'
    )
saveRDS(fit_egb_normalized, './models/EGB_normalized.rds')

# Trying the same model but this time without centering and scaling

fit_egb <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        method = 'xgbTree',
        metric = 'ROC'
    )

saveRDS(fit_egb, './models/EGB.rds')
