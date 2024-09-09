################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Example analysis of the readmission dataset
# 
# Author: Joshua Entrop
# 
################################################################################

# Load packages
library(rstpm2)
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)

# Load readmission data included in {frailtypack}
load("./data/example/readmission.rda")

# Load estimates of E[N(t)] into memory
load("./data/example/expn_estimates.RData")

# 1. Prepare data for analysis -------------------------------------------------

# limit to 1500 days of follow-up
readmission <- readmission |> 
  filter(t.start < 1500)   |> 
  mutate(death  = if_else(t.stop >= 1500, 0     , death),
         event  = if_else(t.stop >= 1500, 0     , event),
         t.stop = if_else(t.stop < 1500 , t.stop, 1500))

# 2. Fit model -----------------------------------------------------------------

# Create one dataset for recurrent event times
re_data <- readmission |>  
  mutate(status = event,
         ce     = 0,
         re     = 1,
         female = if_else(sex   == "Female",  1, 0),
         chemo  = if_else(chemo == "Treated", 1, 0),)

fit <- stpm2(Surv(t.start, t.stop, status, 
                  type = 'counting') ~ female * chemo,
             df = 3,
             tvc = list(female = 1,
                        chemo  = 1),
             data = re_data)

# 3. Estimate H(t) -------------------------------------------------------------

# Predict H(t)
cumhaz <- predict(fit,
                  type = "cumhaz",
                  newdata = expand.grid(female = 0:1,
                                        chemo  = 0:1,
                                        t.stop = seq(1, 1500, 
                                                     length.out = 100)),
                  se.fit = TRUE,
                  full = TRUE)

# Predict H(t|x = 0) - H(t|x = 1)
cumhaz_x0 <- predict(fit,
                     type = "cumhaz",
                     newdata = expand.grid(female = 0:1,
                                           chemo  = 0,
                                           t.stop = seq(1, 1500, 
                                                        length.out = 100)),
                     se.fit = FALSE,
                     full = FALSE)

cumhaz_x1 <- predict(fit,
                     type = "cumhaz",
                     newdata = expand.grid(female = 0:1,
                                           chemo  = 1,
                                           t.stop = seq(1, 1500, 
                                                        length.out = 100)),
                     se.fit = FALSE,
                     full = FALSE)

diff_cumhaz <- cbind(expand.grid(female = 0:1,
                                 t.stop = seq(1, 1500, 
                                              length.out = 100)),
                     cumhaz_x0, cumhaz_x1)

diff_cumhaz$fit <- diff_cumhaz$cumhaz_x0 - diff_cumhaz$cumhaz_x1

# 4. PLot H(t) and E[N(t)] -----------------------------------------------------

#   4.1 Prepare data for plotting ==============================================

# Add typpe variable
cumhaz$type <- "cumhaz"
expn$type    <- "mean_no"
diff_cumhaz$type <- "cumhaz"
diff_expn$type    <- "mean_no"

# Combine H(t) and E[N(t)] datasets
comb <- rbind(cumhaz, setNames(expn, names(cumhaz)))

diff_comb <- rbind(diff_cumhaz[, c("female", "t.stop", "fit", "type")],
                   diff_expn[, c("female", "t.stop", "fit", "type")])

# Improve labels
comb <- comb |> 
  mutate(sex   = ifelse(female == 1, "(A) Females", "(B) Males"),
         chemo = if_else(chemo == 1, "Yes", "No"))

diff_comb <- diff_comb |> 
  mutate(sex   = ifelse(female == 1, "(C) Females", "(D) Males"))

#   4.2 Create plot of H(t) across time ========================================
gg_ht <- ggplot(comb,
                aes(x = t.stop,
                    y = Estimate,
                    linetype = type,
                    colour = chemo)) +
  geom_line() +
  scale_colour_brewer(palette = "Set1") +
  scale_y_continuous(limits = c(0, 2.5)) +
  scale_linetype_manual(values = c(1, 2),
                        labels = c("E[N(t)]", bquote(Lambda(t)))) +
  facet_wrap(~ sex) +
  labs(x = "",
       y = "Mean number\nof hospitalisations",
       colour = "Received chemo\nafter surgery",
       linetype = "Estimate") +
  theme_bw() +
  theme(plot.margin = unit(c(0, 0, 2, 0), "mm"))

#   4.3 Create plot of difference E[N(t)] across time ==========================
gg_diff <- ggplot(diff_comb,
                  aes(x = t.stop,
                      y = fit,
                      linetype = type)) +
  geom_line() +
  geom_hline(yintercept = 0,
             lty = "dashed") +
  scale_colour_brewer(palette = "Set1") +
  scale_y_continuous(limits = c(-0.2, 1.6)) +
  scale_linetype_manual(values = c(1, 2),
                        labels = c("E[N(t)]", bquote(Lambda(t)))) +
  facet_wrap(~ sex) +
  labs(x = "Time since surgery (days)",
       y = "Difference in mean number\nof hospitalisations",
       linetype = "Estimate") +
  theme_bw() +
  theme(plot.margin = unit(c(0, 0, 0, 0), "mm"))

#   4.4 Combine plots into one plot ============================================
gg_comb <- wrap_plots(gg_ht,
                      gg_diff,
                      ncol = 1, 
                      nrow = 2,
                      guides = "collect") & 
  theme(legend.position      = "right",
        legend.box           = "vertical")

#   4.5 Export graph as pdf ====================================================
ggsave("./plots/figureS3.pdf",
       gg_comb,
       device = "pdf",
       height = 14,
       width = 18,
       units = "cm")

# //////////////////////////////////////////////////////////////////////////////
# END OF R-SCRIPT