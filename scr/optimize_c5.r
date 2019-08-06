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
