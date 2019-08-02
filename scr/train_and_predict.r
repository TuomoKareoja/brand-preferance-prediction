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
predictors <- names(data)[!names(data) %in% target]

fit_rf_egb <- caretList(
    data[, predictors],
    data[, target],
    trControl = fitControl,
    preProc = pre_proc,
    methodList = c('xgbTree', 'ranger'),
    metric = 'ROC'
)

fit_c5_egb <- caretList(
    data[, predictors],
    data[, target],
    trControl = fitControl,
    preProc = pre_proc,
    methodList = c('C5.0', 'ranger'),
    metric = 'ROC'
)

cv_results <-
    resamples(list(
        RF_EGB = fit_rf_egb,
        C5.0_EGB = fit_c5_egb
    )
)

stack_rf_egb <-
    caretStack(fit_rf_egb,
               method = 'glm',
               metric = 'ROC',
               trControl = fitControl)
stack_c5_egb <-
    caretStack(fit_c5_egb,
               method = 'glm',
               metric = 'ROC',
               trControl = fitControl)
 
best_predictions <-
    predict(stack_c5_egb, newdata = data_pred)

data_clean_missing$brand = best_predictions 
data_fixed <- bind_rows(data_clean_missing, data_clean_nomissing) 
write.csv(data_fixed, file='./data/fixed/data_nomissing.csv', row.names = FALSE)
