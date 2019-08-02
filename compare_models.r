library(dplyr)
library(readr)
library(tidyr)
library(caret)
library(caTools)
library(ROCit)
library(caretEnsemble)

data_test <- read.csv('./data/processed/processed_test.csv')

# Loading models
model_c5 <- readRDS('./models/C5.0.rds')
model_egb <- readRDS('./models/EGB.rds')
model_rf <- readRDS('./models/RF.rds')
model_c5_egb_rf <- readRDS('./models/C5.0_EGB_RF.rds')

# Save model output
sink("./figures/C5.0_output.txt")
model_c5
sink()
sink("./figures/EGB_output.txt")
model_egb
sink()
sink("./figures/RF_output.txt")
model_rf
sink()
sink("./figures/C5.0_EGB_RF_output.txt")
model_c5_egb_rf
sink()

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

# Model correlations are in some cases low so
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
predictions_c5_egb_rf <-
    predict(model_c5_egb, newdata = data_test, type = 'prob')

png(filename='./figures/AUC_comparison.png')
colAUC(
    data.frame(
        'RF' = predictions_rf$Acer,
        'C5.0' = predictions_c5$Acer,
        'EGB' = predictions_egb$Acer,
        'C5.0_EGB_RF' = predictions_c5_egb_rf
    ),
    data_test$brand,
    plotROC = TRUE
)
dev.off()

# Model correlations are low there ensembling is a good idea
modelCor(cv_results)
splom(cv_results)
ggsave('./figures/model_prediction_correlations.png')
