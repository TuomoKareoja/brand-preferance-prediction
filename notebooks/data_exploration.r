library(dplyr)
library(readr)
library(ggplot2)
library(GGally)
library(tidyr)
library(purrr)

# reading in the data
data_train <- read.csv('./data/raw/CompleteResponses.csv')
data_predict <- read.csv('./data/raw/SurveyIncomplete.csv')

# datatypes and columns names match so we can just combine the two datasets
str(data_train)
str(data_predict)

# no weird discrepancies in distributions based on key values
summary(data_train)
summary(data_predict)

# we can see that all the predict data has all brand
# values set as zero although these should be null
plot(data_predict$brand)
data_predict$brand <- NA
data_predict$brand <- as.numeric(data_predict$brand)

# creating a column to mark which dataset is in question and combining
data_train$train <- TRUE
data_predict$train <- FALSE
data <- union(data_train, data_predict)

# Coding categorical variables as factors with right levels values
data$brand <- factor(data$brand, levels=c(0,1), labels = c("Acer", "Sony"))
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
))
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

# checking out general patterns
str(data)
summary(data)

# Big pair plot
ggally_mysmooth <- function(data, mapping, ...){
    ggplot(data = data, mapping=mapping) +
        geom_density(mapping = aes_string(color='brand'), fill=NA)
}

ggpairs(
    # sample to make manageable, car and zipcode have too many values to plot
    subset(data[sample(nrow(data), size=1000),], select=-c(car, zipcode)),
    mapping = ggplot2::aes(color = brand),
    lower = list(
        continuous = wrap("points", alpha = 0.2, size=0.3),
        combo = wrap("dot", alpha = 0.2, size=0.3)
    ),
    diag = list(continuous = ggally_mysmooth),
    title = "Brand",
) 

ggsave("./figures/pairs_plot.png", dpi=600, limitsize = FALSE)


# OBSERVATIONS
# the relationship between numberical factors is essentially random
# There is a clear non-linear relationship between brand preferance and salary
# Less clear relationships also with age and credit

# Plotting all variables independently
qplot(data$salary)
qplot(data$age)
qplot(data$elevel)
qplot(data$car)
qplot(data$zipcode)
qplot(data$credit)
qplot(data$brand)

# OBSERVATIONS
# Have to be carefull with the predictions as the brands are not represented equally, 
# so simple accuracy metrics in model optimization and comparison won't work

# Checking for missing
sapply(data, function(x) sum(is.na(x)))

# checking for correlations --> miniscule
cor(data[ , map_lgl(data, is.numeric)])
