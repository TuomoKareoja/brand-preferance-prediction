library(dplyr)
library(readr)
library(tidyr)
library(caret)
library(caretEnsemble)

best_model_path <- './models/C5.0_full.rds'

data_pred <- read.csv('./data/processed/processed_pred.csv')
data_clean <- read.csv('./data/clean/clean_train_predict.csv')

# combining the train data
data <- bind_rows(data_train, data_test)

# splitting the cleaned data
data_clean_missing <- filter(data_clean, predict == 1)
data_clean_nomissing <- filter(data_clean, predict == 0)

# Loading the model
best_model <- readRDS(best_model_path)

best_predictions <-
    predict(best_model, newdata = data_pred)

data_clean_missing$brand = best_predictions
data_fixed <- bind_rows(data_clean_missing, data_clean_nomissing)
write.csv(data_fixed, file='./data/fixed/data_nomissing.csv', row.names = FALSE)
