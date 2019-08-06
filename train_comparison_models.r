
# Trains all models to used in comparisons and saves them

# Normal models
source("./scr/optimize_c5.r")
source("./scr/optimize_rf.r")
source("./scr/optimize_egb.r")
source("./scr/optimize_glmnet.r")

# Ensemble model
source("./scr/optimize_c5_egb_rf.r")
