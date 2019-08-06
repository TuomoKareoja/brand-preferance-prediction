library(dplyr)
library(readr)
library(tidyr)
library(caret)
library(caTools)
library(caretEnsemble)

data_train <- read.csv('./data/processed/processed_train.csv')
data_test <- read.csv('./data/processed/processed_test.csv')
data_pred <- read.csv('./data/processed/processed_pred.csv')
data_clean <- read.csv('./data/clean/clean_train_predict.csv')

# combining the train data
data <- bind_rows(data_train, data_test)

# splitting the cleaned data
data_clean_missing <- filter(data_clean, predict == 1)
data_clean_nomissing <- filter(data_clean, predict == 0)

# Create custom indices
my_folds <- createMultiFolds(y = data$brand, k = 10, times = 3)

# Create reusable trainControl object: myControl
fitControl <- trainControl(
    summaryFunction = twoClassSummary,
    classProbs = TRUE,
    verboseIter = TRUE,
    savePredictions = 'final',
    index = my_folds
)

target <- 'brand'
predictors <- names(data)[!names(data) %in% target]

fit_c5 <- train(
    data[, predictors],
    data[, target],
    trControl = fitControl,
    method = 'C5.0',
    metric = 'ROC'
) 

saveRDS(fit_c5_rf, './models/C5.0_full.rds')
