library(dplyr)
library(readr)
library(tidyr)
library(caret)

set.seed(123)

# reading in clean data
data <- read.csv('./data/clean/clean_train_predict.csv')
  
# one hot encoding
dmy <- dummyVars(" ~ elevel + car + zipcode", data = data)
encoded_columns <- data.frame(predict(dmy, newdata=data))
data_encoded <- bind_cols(encoded_columns, data[c('salary', 'age', 'credit', 'brand', 'predict')]) 

# # Scaling everything using values from both train and predict datasets 
# scaler <- preProcess(select(data_encoded, select=-c('sony', 'predict')), method=c('center', 'scale'))
# data_encoded_scaled <- predict(scaler, data_encoded)

# Creating separate datasets for training, testing and predicting
pred <- data_encoded[data_encoded$predict == 1, !names(data_encoded) %in% c('predict')]
non_pred <- data_encoded[!data_encoded$predict == 1, !names(data_encoded) %in% c('predict')]

inTrain <- createDataPartition(non_pred$brand, p=.7, list=FALSE)
train <- non_pred[inTrain, ]
test <- non_pred[-inTrain, ]

write.csv(pred, file='./data/processed/processed_pred.csv', row.names = FALSE)
write.csv(train, file='./data/processed/processed_train.csv', row.names = FALSE)
write.csv(test, file='./data/processed/processed_test.csv', row.names = FALSE)
