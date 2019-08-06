library(dplyr)
library(readr)
library(tidyr)
library(caret)

data_train <- read.csv('./data/processed/processed_train.csv')

# use the right folding pattern
source("./scr/my_folds.r")

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

fit_glmnet_normalized <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        preProc = pre_proc,
        method = 'glmnet',
        metric = 'ROC'
    )
saveRDS(fit_glmnet_normalized, './models/GLMNET_normalized.rds')

# Trying the same model but this time without centering and scaling

fit_glmnet <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        method = 'glmnet',
        metric = 'ROC'
    )

saveRDS(fit_glmnet, './models/GLMNET.rds')
