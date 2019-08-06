library(dplyr)
library(readr)
library(tidyr)
library(caret)
library(caTools)
library(ROCit)
library(caretEnsemble)
source('./scr/draw_confusion_plot.r')

data_test <- read.csv('./data/processed/processed_test.csv')
data_train <- read.csv('./data/processed/processed_train.csv')

# Loading models
model_c5 <- readRDS('./models/C5.0.rds')
model_egb <- readRDS('./models/EGB.rds')
model_rf <- readRDS('./models/RF.rds')
model_c5_full <- readRDS('./models/C5.0_full.rds')

# Comparing models

# TODO how to incorporate ensemble models?
cv_results <-
    resamples(list(
        C5 = model_c5,
        EGB = model_egb,
        RF = model_rf
    ))

# Random Forest and Extreme Gradient boosting are clearly the best models
summary(cv_results)
png(filename='./figures/dotplot_comparison.png')
dotplot(cv_results)
dev.off()

# Model correlations are low so combining models makes sense
modelCor(cv_results)
png(filename='./figures/model_prediction_correlations.png')
splom(cv_results)
dev.off()

predictions_c5 <-
    predict(model_c5, newdata = data_test, type = 'prob')
predictions_egb <-
    predict(model_egb, newdata = data_test, type = 'prob')
predictions_rf <-
    predict(model_rf, newdata = data_test, type = 'prob')
# In the ensemble model the predictions are for the wrong category
predictions_c5_rf <-
    1 - predict(model_c5_rf, newdata = data_test, type = 'prob')
png(filename='./figures/AUC_comparison.png')
rf_rocit <- rocit(predictions_rf$Sony, data_test$brand)
c5_rocit <- rocit(predictions_c5$Sony, data_test$brand)
egb_rocit <- rocit(predictions_egb$Sony, data_test$brand)
plot(rf_rocit, col=1, YIndex = FALSE, legend = FALSE)
lines(c5_rocit$TPR ~ c5_rocit$FPR, col=2, lwd=2)
lines(egb_rocit$TPR ~ egb_rocit$FPR, col=4, lwd=2)
legend('bottomright', col = c(1,2,4), c('RF', 'C5.0', 'EGB'), lwd=2)
dev.off()

# plotting confusion matrices
predictions_c5_classes <-
    predict(model_c5, newdata = data_test)
predictions_egb_classes <-
    predict(model_egb, newdata = data_test)
predictions_rf_classes <-
    predict(model_rf, newdata = data_test)

predictions_c5_classes_train <-
    predict(model_c5, newdata = data_train)
predictions_egb_classes_train <-
    predict(model_egb, newdata = data_train)
predictions_rf_classes_train <-
    predict(model_rf, newdata = data_train)

cm_c5 <- confusionMatrix(predictions_c5_classes, data_test$brand)
cm_egb <- confusionMatrix(predictions_egb_classes, data_test$brand)
cm_rf <- confusionMatrix(predictions_rf_classes, data_test$brand)

cm_c5_train <- confusionMatrix(predictions_c5_classes_train, data_train$brand)
cm_egb_train <- confusionMatrix(predictions_egb_classes_train, data_train$brand)
cm_rf_train <- confusionMatrix(predictions_rf_classes_train, data_train$brand)

png(filename='./figures/cm_c5.png')
cm_c5_plot <- draw_confusion_plot(cm_c5, title='C5.0 Confusion Matrix: Test')
dev.off()
png(filename='./figures/cm_egb.png')
cm_egb_plot <- draw_confusion_plot(cm_egb, title='EGB Confusion Matrix: Test')
dev.off()
png(filename='./figures/cm_rf.png')
cm_rf_plot <- draw_confusion_plot(cm_rf, title='RF Confusion Matrix: Test')
dev.off()
png(filename='./figures/cm_c5_train.png')
cm_c5_train_plot <- draw_confusion_plot(cm_c5_train, title='C5.0 Confusion Matrix: Train')
dev.off()
png(filename='./figures/cm_egb_train.png')
cm_egb_train_plot <- draw_confusion_plot(cm_egb_train, title='EGB Confusion Matrix: Train')
dev.off()
png(filename='./figures/cm_rf_train.png')
cm_rf_train_plot <- draw_confusion_plot(cm_rf_train, title='RF Confusion Matrix: Train')
dev.off()

# Model correlations are low there ensembling is a good idea
modelCor(cv_results)
png(filename='./figures/model_prediction_correlations.png')
splom(cv_results)
dev.off()

# Model variable importance
png(filename='./figures/c5_feature_importance.png')
plot(varImp(model_c5, useModel = FALSE), top = 15)
dev.off()
png(filename='./figures/egb_feature_importance.png')
plot(varImp(model_egb, useModel = FALSE), top = 15)
dev.off()
png(filename='./figures/rf_feature_importance.png')
plot(varImp(model_rf, useModel = FALSE), top = 15)
dev.off()
png(filename='./figures/c5_full_feature_importance.png')
plot(varImp(model_c5_full, useModel = FALSE), top = 15)
dev.off()

# Salary is in all models the most important predictor
# Lets draw the distribution of wage and brand preference with the full data
data_full <- bind_rows(data_train, data_test)
png(filename='./figures/brand_salary_distribution.png')
ggplot(data_full, aes(x=salary, color=brand, group=brand)) +
    geom_freqpoly(data=subset(data_full, brand=='Sony'), bins=60, aes(y=(..count..)/sum(..count..))) +
    geom_freqpoly(data=subset(data_full, brand=='Acer'), bins=60, aes(y=(..count..)/sum(..count..))) +
    xlab('Salary') +
    ylab('%') +
    scale_y_continuous(labels=scales::percent)
dev.off()
 