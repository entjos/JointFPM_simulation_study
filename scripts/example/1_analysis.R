################################################################################
# Project: Parametric Estimation of The Mean Number of Events
# 
# Title: Example analysis of the readmission dataset
# 
# Author: Joshua Entrop
# 
################################################################################

# Load packages
library(JointFPM)
library(dplyr)
library(tidyr)
library(survival)
library(fastDummies)

# Load readmission data included in {frailtypack}
load("./data/example/readmission.rda")

# 1. Prepare data for analysis -------------------------------------------------

# limit to 1500 days of follow-up
readmission <- readmission |> 
  filter(t.start < 1500)   |> 
  mutate(death  = if_else(t.stop >= 1500, 0     , death),
         event  = if_else(t.stop >= 1500, 0     , event),
         t.stop = if_else(t.stop < 1500 , t.stop, 1500))

# Create one dataset for competing event times
ce_data <- readmission |> 
  group_by(id)         |>  
  slice_max(n = 1,
            order_by = t.stop) |>  
  mutate(status   = death,
         ce       = 1,
         re       = 0,
         t.start  = 0)

# Create one dataset for recurrent event times
re_data <- readmission |>  
  mutate(status = event,
         ce     = 0,
         re     = 1)

# Stack the datasets for recurrent and competing event times
comb_data <- bind_rows(ce_data, re_data) |> 
  mutate(female       = if_else(sex   == "Female",  1, 0),
         chemo        = if_else(chemo == "Treated", 1, 0),
         female_chemo = female * chemo)

# Create varialbe charlston at diagnosis
comb_data <- comb_data |> 
  group_by(id)         |> 
  mutate(cci_dx = first(charlson, order_by = enum))

# Save prepared dataset
write.csv(comb_data, "./data/example/readmission_stacked.csv")

# 2. Calculate non-parametric estimator of E[N(t)] -----------------------------

# Calculate E[N(t)] for males
np_expn <- mean_no(Surv(t.start, t.stop, status, type = 'counting') ~ 
                     chemo + female,
                   re_indicator = "re",
                   ce_indicator = "ce",
                   comb_data)

# Stack numbers for males and females
np_expn <- np_expn %>% 
  separate_wider_delim(strata, delim = ", ", names = c("chemo", "female")) |>  
  mutate(chemo  = as.numeric(gsub("(.*)(\\d)", "\\2", chemo)),
         female = as.numeric(gsub("(.*)(\\d)", "\\2", female)))

# 3. Estimate parametric estimator of E[N(t)] ----------------------------------

#   3.1 Test model for different dfs ===========================================

model_fits <- test_dfs_JointFPM(surv = Surv(t.start, t.stop, status, 
                                        type = 'counting') ~ 1,
                                re_model = ~ female * chemo,
                                ce_model = ~ female * chemo,
                                re_indicator = "re",
                                ce_indicator = "ce",
                                dfs_ce = 1:5,
                                dfs_re = 1:5,
                                tvc_re_terms = list(female = 1:2,
                                                    chemo  = 1:2),
                                tvc_ce_terms = list(female = 1:2,
                                                    chemo  = 1:2),
                                cluster = "id",
                                data = comb_data)

# Get the dfs for the best model fit
model_fits[which.min(model_fits$AIC), ]

#   3.2 Fit model for E[N(t)] ==================================================

# Fit model with best model fit
fit <- JointFPM(surv = Surv(t.start, t.stop, status, type = 'counting') ~ 1,
                re_model =  ~ female * chemo,
                ce_model =  ~ female * chemo,
                re_indicator = "re",
                ce_indicator = "ce",
                df_ce = 3,
                df_re = 3,
                tvc_re_terms = list(female = 1,
                                    chemo  = 1),
                tvc_ce_terms = list(female = 2,
                                    chemo  = 2),
                cluster = "id",
                data = comb_data) 

#   3.3 Estimate E[N(t)] =======================================================

# Create a dataset including the prediction points of interest
prediction_dataset <- expand.grid(female = 0:1,
                                  chemo  = 0:1) |>  
  arrange(female)

# Predict the mean number of events
expn <- lapply(seq_len(nrow(prediction_dataset)), function(i){
  
  fit <- predict(fit,
                 type = "mean_no",
                 newdata = prediction_dataset[i, ],
                 t =  seq(0, 1500, length.out = 100),
                 ci_fit = TRUE)
  
  data.frame(prediction_dataset[i, ], fit)
  
})

# Combine results stored in a list into one data.frame
expn <- do.call(rbind, expn)

#   3.4 Estimate differences in E[N(t)] ========================================

# Prepare an empty list for storing the estimates
diff_expn <- list()

# Predict the difference in E[N(t)] among females
diff_expn[[1]] <- predict(fit,
                          type = "diff",
                          newdata = data.frame(female       = 1,
                                               chemo        = 0),
                          t = seq(0, 1500, length.out = 100),
                          exposed = function(x) transform(x, chemo = 1),
                          ci_fit = TRUE)

diff_expn[[1]]$female <- 1 

# Predict the difference in E[N(t)] among males
diff_expn[[2]] <- predict(fit,
                          type = "diff",
                          newdata = data.frame(female       = 0,
                                               chemo        = 0),
                          t = seq(0, 1500, length.out = 100),
                          exposed = function(x) transform(x, chemo = 1),
                          ci_fit = TRUE)

diff_expn[[2]]$female <- 0

# Combine results stored in a list into one data.frame
diff_expn <- do.call(rbind, diff_expn)

# 5. Get marginalised estimates ------------------------------------------------

comb_data <- dummy_cols(comb_data, c("cci_dx", "dukes")) |> 
  rename_with(~ gsub("-", "_", .x))

fit_fully_adjusted <- JointFPM(
  surv = Surv(t.start, t.stop, status, type = 'counting') ~ 1,
  re_model = ~ female * chemo + cci_dx_1_2 + cci_dx_3 + dukes_C + dukes_D,
  ce_model = ~ female * chemo + cci_dx_1_2 + cci_dx_3 + dukes_C + dukes_D,
  re_indicator = "re",
  ce_indicator = "ce",
  df_ce = 3,
  df_re = 3,
  tvc_re_terms = list(female = 1,
                      chemo  = 1),
  tvc_ce_terms = list(female = 2,
                      chemo  = 2),
  cluster = "id",
  data = comb_data
) 

# Predict the mean number of events
expn_marg <- lapply(seq_len(nrow(prediction_dataset)), function(i){
  
  fit <- predict(fit_fully_adjusted,
                 type = "marg_mean_no",
                 newdata = prediction_dataset[i, ],
                 t =  seq(0, 1500, length.out = 100),
                 ci_fit = FALSE)
  
  data.frame(prediction_dataset[i, ], fit)
  
})

# Combine results stored in a list into one data.frame
expn_marg <- do.call(rbind, expn_marg)

# Estimate CIs for marginal difference at 1500 days
sink("./tables/marg_diff.txt")
cat("Estimated marginal difference in the mean number of rehospitalisations\n")
cat("after colon cancer surgery comparing patients treated with and without\n")
cat("chemo.\n")

cat("\nEstimates for males\n")
predict(fit_fully_adjusted,
        type = "marg_diff",
        newdata = data.frame(female       = 0,
                             chemo        = 0),
        t = 1500,
        exposed = function(x) transform(x, chemo = 1),
        ci_fit = TRUE)

cat("\nEstimates for females\n")
predict(fit_fully_adjusted,
        type = "marg_diff",
        newdata = data.frame(female       = 1,
                             chemo        = 0),
        t = 1500,
        exposed = function(x) transform(x, chemo = 1),
        ci_fit = TRUE)
sink()

# 6. Export estimates ----------------------------------------------------------

save(np_expn, expn, diff_expn, expn_marg,
     file = "./data/example/expn_estimates.RData")

# //////////////////////////////////////////////////////////////////////////////
# END OF R-SCRIPT