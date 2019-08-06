library(dplyr)
library(readr)
library(tidyr)
library(caret)

data_train <- read.csv('./data/processed/processed_train.csv')

# use the right folding pattern
source("./scr/my_folds.r")

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


fit_egb <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        method = 'xgbTree',
        metric = 'ROC'
    )

saveRDS(fit_egb, './models/EGB.rds')
