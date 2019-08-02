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

fit_c5_normalized <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        preProc = pre_proc,
        method = 'C5.0',
        metric = 'ROC'
    )

saveRDS(fit_c5_normalized, './models/C5.0_normalized.rds')

# Trying the same model but this time without centering and scaling
fit_c5 <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        method = 'C5.0',
        metric = 'ROC'
    )

saveRDS(fit_c5, './models/C5.0.rds')
