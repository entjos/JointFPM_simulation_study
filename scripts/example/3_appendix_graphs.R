################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Example analysis of the readmission dataset
# 
# Author: Joshua Entrop
# 
################################################################################

# Load packages
library(JointFPM)
library(rstpm2)
library(rlang)
library(magrittr)
library(tidyr)
library(purrr)
library(ggplot2)
library(dplyr)

# Load readmission data included in {frailtypack}
load("./data/example/readmission.rda")

# 1. Load data -----------------------------------------------------------------

comb_data <- read.csv("./data/example/readmission_stacked.csv")

# 2. Fit joint model -----------------------------------------------------------

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

# 2. Post-estimations ----------------------------------------------------------

#   2.1 Predict survival =======================================================
newdata <- expand.grid(female = 0:1,
                       chemo  = 0:1,
                       ce     = 1,
                       re     = 0)

surv_fit <- predict(fit$model,
                    newdata = newdata,
                    grid = TRUE,
                    full = TRUE,
                    type = "surv") |>
  mutate(chemo  = as.character(chemo),
         female = as.character(female))

#   2.2 Predict sumulative hazard ==============================================
cumhaz_fit <- predict(fit$model,
                      newdata = mutate(newdata, re = 1, ce = 0),
                      grid = TRUE,
                      full = TRUE,
                      type = "cumhaz") |>
  mutate(chemo  = as.character(chemo),
         female = as.character(female))


# 3. Non-parametric estimation -------------------------------------------------

#   3.1 Estimate KME ===========================================================
np_surv_fit <- survfit(Surv(t.stop, status) ~ chemo + female,
                       data = subset(comb_data, ce == 1)) |>
  summary()

np_surv_fit <- lapply(c(2:4, 6, 10), function(i) np_surv_fit[i])
np_surv_fit <- do.call(data.frame, np_surv_fit)
np_surv_fit <- np_surv_fit |> 
  group_by(strata) |>
  mutate(cumhaz = cumsum(n.event / n.risk)) |>
  ungroup() |>
  separate_wider_delim(strata, delim = ", ", names = c("chemo", "female")) |>  
  mutate(chemo  = as.character(gsub("(.*)(\\d)", "\\2", chemo)),
         female = as.character(gsub("(.*)(\\d)", "\\2", female)))

#   3.2 Estimate Aalen-Johanson Estimate =======================================
np_cumhaz_fit <- survfit(Surv(t.start, t.stop, status,
                              type = "counting") ~ female + chemo,
                         data = subset(comb_data, re == 1)) |>
  summary()

np_cumhaz_fit <- lapply(c(2:4, 6, 10), function(i) np_cumhaz_fit[i])
np_cumhaz_fit <- do.call(data.frame, np_cumhaz_fit)
np_cumhaz_fit <- np_cumhaz_fit |> 
  mutate(cumhaz = cumsum(n.event / n.risk),
         .by = strata) |>
  separate_wider_delim(strata, delim = ", ", names = c("female", "chemo")) |>  
  mutate(chemo  = as.character(gsub("(.*)(\\d)", "\\2", chemo)),
         female = as.character(gsub("(.*)(\\d)", "\\2", female)))

# 4. Plot surves ---------------------------------------------------------------

list("np_surv_fit"   = np_surv_fit, 
     "surv_fit"      = surv_fit,
     "np_cumhaz_fit" = np_cumhaz_fit,
     "cumhaz_fit"    = cumhaz_fit) |>
  map(~ mutate(.x,
               female = if_else(female == 1, "Females", "Males"),
               chemo  = if_else(chemo  == 1, "Treated", "Untreated"),
               label  = paste(female, chemo))) %>% 
        env_bind(.GlobalEnv, !!!.)

#   4.1 Plot survival cures ====================================================
ggplot(surv_fit,
       aes(x = t.stop,
           y = Estimate)) +
  geom_line() +
  geom_step(aes(x = time,
                y = surv),
            data = np_surv_fit) +
  facet_wrap(vars(label)) +
  labs(x = "Time since surgery (days)",
       y = "Survival probability") +
  theme_bw()

ggsave("./plots/example_surv_kme.pdf",
       device = "pdf",
       height = 14,
       width = 14,
       units = "cm")

#   4.2 Plot cumhaz curves =====================================================
ggplot(cumhaz_fit,
       aes(x = t.stop,
           y = Estimate)) +
  geom_line() +
  geom_step(aes(x = time,
                y = cumhaz),
            data = np_cumhaz_fit) +
  facet_wrap(vars(label)) +
  labs(x = "Time since surgery (days)",
       y = "Cumulative hazard") +
  theme_bw()

ggsave("./plots/example_cumhaz_na.pdf",
       device = "pdf",
       height = 14,
       width = 14,
       units = "cm")

# //////////////////////////////////////////////////////////////////////////////
# END OF R-SCRIPT