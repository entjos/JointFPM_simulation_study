################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Example analysis of the readmission dataset
# 
# Author: Joshua Entrop
# 
################################################################################

# Load packages
library(dplyr)
library(ggplot2)
library(patchwork)

# Load estimates of E[N(t)] into memory
load("./data/example/expn_estimates.RData")

# 1. Improve labeling for plotting ---------------------------------------------
expn <- expn |> 
  mutate(sex   = ifelse(female == 1, "(A) Females", "(B) Males"),
         chemo = if_else(chemo == 1, "Yes", "No"),
         type  = "Conditional")

expn_marg <- expn_marg |> 
  mutate(sex = ifelse(female == 1, "(A) Females", "(B) Males"),
         chemo = if_else(chemo == 1, "Yes", "No"),
         type  = "Standardised")

expn <- bind_rows(expn, expn_marg)

np_expn <- np_expn |> 
  mutate(sex   = ifelse(female == 1, "(A) Females", "(B) Males"),
         chemo = if_else(chemo == 1, "Yes", "No"))

diff_expn <- diff_expn |> 
  mutate(sex = ifelse(female == 1, "(C) Females", "(D) Males"))

# 2. Create plot of E[N(t)] across time ----------------------------------------
gg_mean_no <- ggplot(expn,
                     aes(x = t.stop,
                         y = fit,
                         linetype = type,
                         colour = chemo)) +
  geom_line() +
  geom_step(aes(x = time,
                y = expn,
                colour = chemo,
                linetype = "Conditional"),
            data = np_expn) +
  scale_colour_brewer(palette = "Set1") +
  facet_wrap(~ sex) +
  labs(x = "",
       y = "Mean number\nof hospitalisations",
       colour = "Received chemo\nafter surgery",
       linetype = "Estimate") +
  theme_bw() +
  theme(plot.margin = unit(c(0, 0, 2, 0), "mm"))

# 2. Create plot of difference E[N(t)] across time -----------------------------
gg_diff <- ggplot(diff_expn,
                  aes(x = t.stop,
                      y = fit)) +
  geom_line() +
  geom_ribbon(aes(ymin = lci,
                  ymax = uci),
              alpha = 0.1,
              colour = NA) +
  geom_hline(yintercept = 0,
             lty = "dashed") +
  scale_colour_brewer(palette = "Set1") +
  facet_wrap(~ sex) +
  labs(x = "Time since surgery (days)",
       y = "Difference in mean number\nof hospitalisations") +
  theme_bw() +
  theme(plot.margin = unit(c(0, 0, 0, 0), "mm"))

# 3. Combine plots into one plot -----------------------------------------------
gg_comb <- wrap_plots(gg_mean_no,
                      gg_diff,
                      ncol = 1, 
                      nrow = 2,
                      guides = "collect") & 
  theme(legend.position      = "right",
        legend.box           = "vertical")

# 4. Export graph as pdf -------------------------------------------------------
ggsave("./plots/figure4.pdf",
       gg_comb,
       device = "pdf",
       height = 14,
       width = 18,
       units = "cm")

# //////////////////////////////////////////////////////////////////////////////
# END OF R-SCRIPT