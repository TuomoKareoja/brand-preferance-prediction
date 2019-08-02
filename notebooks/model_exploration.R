library(dplyr)
library(readr)
library(tidyr)
library(caret)
library(caTools)
library(caretEnsemble)

data_train <- read.csv('./data/processed/processed_train.csv')
data_test <- read.csv('./data/processed/processed_test.csv')

# Create custom indices
my_folds <- createMultiFolds(y = data_train$brand, k = 6, times = 2)

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
predictors <- names(data_train)[!names(data_train) %in% target]

# C5.0 (method = 'C5.0')
# For classification using packages C50 and plyr with tuning parameters:
#     Number of Boosting Iterations (trials, numeric)
#     Model Type (model, character)
#     Winnow (winnow, logical)
fit_c5 <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        preProc = pre_proc,
        method = 'C5.0',
        metric = 'ROC'
    )
summary(fit_c5)
ggplot(fit_c5)

# eXtreme Gradient Boosting (method = 'xgbTree')
# For classification and regression using packages xgboost and plyr with tuning parameters:
#     Number of Boosting Iterations (nrounds, numeric)
#     Max Tree Depth (max_depth, numeric)
#     Shrinkage (eta, numeric)
#     Minimum Loss Reduction (gamma, numeric)
#     Subsample Ratio of Columns (colsample_bytree, numeric)
#     Minimum Sum of Instance Weight (min_child_weight, numeric)
#     Subsample Percentage (subsample, numeric)
fit_egb <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        preProc = pre_proc,
        method = 'xgbTree',
        metric = 'ROC'
    )
fit_egb
ggplot(fit_egb)

# glmnet (method = 'glmnet')
# For classification and regression using packages glmnet and Matrix with tuning parameters:
#     Mixing Percentage (alpha, numeric)
#     Regularization Parameter (lambda, numeric)
fit_glmnet <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        preProc = pre_proc,
        method = 'glmnet',
        metric = 'ROC'
    )
fit_glmnet
ggplot(fit_glmnet)

# Random Forest (method = 'rf')
# For classification and regression using package randomForest with tuning parameters:
#     Number of Randomly Selected Predictors (mtry, numeric)
fit_rf <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        preProc = pre_proc,
        method = 'ranger',
        metric = 'ROC'
    )
fit_rf
ggplot(fit_rf)

# Trying the same models but this time without centering and scaling

fit_c5_nopre <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        method = 'C5.0',
        metric = 'ROC'
    )
summary(fit_c5_nopre)
ggplot(fit_c5_nopre)

fit_egb_nopre <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        method = 'xgbTree',
        metric = 'ROC'
    )
fit_egb_nopre
ggplot(fit_egb_nopre)

fit_glmnet_nopre <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        method = 'glmnet',
        metric = 'ROC'
    )
fit_glmnet_nopre
ggplot(fit_glmnet_nopre)

fit_rf_nopre <-
    train(
        data_train[, predictors],
        data_train[, target],
        trControl = fitControl,
        method = 'ranger',
        metric = 'ROC'
    )
fit_rf_nopre
ggplot(fit_rf_nopre)


# Compare models graphically
cv_results <-
    resamples(list(
        C5 = fit_c5,
        EGB = fit_egb,
        GLMNET = fit_glmnet,
        RF = fit_rf,
        C5_nopre = fit_c5_nopre,
        EGB_nopre = fit_egb_nopre,
        GLMNET_nopre = fit_glmnet_nopre,
        RF_nopre = fit_rf_nopre
    ))

# Random Forest and Extreme Gradient boosting are clearly the best models
summary(cv_results)
ggplot(cv_results)
dotplot(cv_results)

predictions_c5 <-
    predict(fit_c5, newdata = data_test, type = 'prob')
predictions_egb <-
    predict(fit_egb, newdata = data_test, type = 'prob')
predictions_glmnet <-
    predict(fit_glmnet, newdata = data_test, type = 'prob')
predictions_rf <-
    predict(fit_rf, newdata = data_test, type = 'prob')

colAUC(
    data.frame(
        'RF' = predictions_rf$Acer,
        'C5.0' = predictions_c5$Acer,
        'GLMNET' = predictions_glmnet$Acer,
        'EGB' = predictions_egb$Acer
    ),
    data_test$brand,
    plotROC = TRUE
)

postResample()

# Interestingly the model correlation between RF and EGB is very low - Maybe the models could be ensembled?
# also C5 and EGB could be good candite for ensembling
modelCor(cv_results)
splom(cv_results)

fit_rf_egb <- caretList(
    data_train[, predictors],
    data_train[, target],
    trControl = fitControl,
    preProc = pre_proc,
    methodList = c('xgbTree', 'ranger'),
    metric = 'ROC'
)

fit_c5_egb <- caretList(
    data_train[, predictors],
    data_train[, target],
    trControl = fitControl,
    preProc = pre_proc,
    methodList = c('C5.0', 'ranger'),
    # metric = 'ROC'
)

plot(caretEnsemble(fit_rf_egb))
plot(caretEnsemble(fit_glmnet_egb))

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

plot(caretEnsemble(fit_c5_egb))
# TODO check how the stacks perform in CV
stack_cv_results <-
    resamples(list(
        RF_EGB = stack_rf_egb,
        C5.0_EGB = stack_c5_egb
    )
)

"plot"(stack_rf_egb)

predictions_stack_rf_egb <-
    predict(stack_rf_egb, newdata = data_test, type = 'prob')
predictions_stack_c5_egb <-
    predict(stack_c5_egb, newdata = data_test, type = 'prob')

colAUC(
    data.frame(
        'RF' = predictions_rf$Acer,
        'C5.0' = predictions_c5$Acer,
        'GLMNET' = predictions_glmnet$Acer,
        'EGB' = predictions_egb$Acer,
        'RF_EGB' = predictions_stack_rf_egb,
        'C5.0_EGB' = predictions_stack_c5_egb
    ),
    data_test$brand,
    plotROC = FALSE
)

models <- caretList(iris[1:50,1:2], iris[1:50,3], methodList=c("glm", "rpart"))
ens <- caretEnsemble(models)
plot(ens)
