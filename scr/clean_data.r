library(dplyr)
library(readr)
library(tidyr)

# reading in the data
data_train <- read.csv('./data/raw/CompleteResponses.csv')
data_predict <- read.csv('./data/raw/SurveyIncomplete.csv')

  # values set as zero although these should be null
plot(data_predict$brand)
data_predict$brand <- NA
data_predict$brand <- as.numeric(data_predict$brand)

# creating a column to mark datasets
data_train$predict <- 0
data_predict$predict <- 1
data <- union(data_train, data_predict)

# Coding categorical variables as factors with right levels values
data$brand <- factor(data$brand, levels=c(0,1), labels=c('Acer', 'Sony'))
data$elevel <- factor(data$elevel, levels=c(0,1,2,3,4), labels = c(
    "Less than High Scool Degree",
    "High School Degree",
    "Some College",
    "4-Year College Degree",
    "Master's, Doctoral or Professional Degree"
    )
)
data$car <- factor(data$car, levels=seq(1,20), labels=c(
    "BMW",
    "Buick",
    "Cadillac",
    "Chevrolet",
    "Chrysler",
    "Dodge",
    "Ford",
    "Honda",
    "Hyundai",
    "Jeep",
    "Kia",
    "Lincoln",
    "Mazda",
    "Mercedes Benz",
    "Mitsubishi",
    "Nissan",
    "Ram",
    "Subaru",
    "Toyota",
    "None of the above"
    )
)
data$zipcode <- factor(data$zipcode, levels=seq(0,8), labels=c(
    "New England",
    "Mid-Atlantic",
    "East North Central",
    "West North Central",
    "South Atlantic",
    "East South Central",
    "West South Central",
    "Mountain",
    "Pacific"
)) 

write.csv(data, file='./data/clean/clean_train_predict.csv', row.names = FALSE)
