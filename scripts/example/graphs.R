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
         chemo = if_else(chemo == 1, "Yes", "No"))

np_expn <- np_expn |> 
  mutate(sex   = ifelse(female == 1, "(A) Females", "(B) Males"),
         chemo = if_else(chemo == 1, "Yes", "No"))

diff_expn <- diff_expn |> 
  mutate(sex = ifelse(female == 1, "(C) Females", "(D) Males"))

# 2. Create plot of E[N(t)] across time ----------------------------------------
gg_mean_no <- ggplot(expn,
                     aes(x = t.stop,
                         y = fit,
                         colour = chemo,
                         group  = chemo)) +
  geom_line() +
  geom_step(aes(x = time,
                y = expn,
                colour = chemo,
                group  = chemo),
            data = np_expn) +
  geom_ribbon(aes(ymin = lci,
                  ymax = uci),
              data  = subset(expn, chemo == 1),
              alpha = 0.1,
              colour = NA) +
  scale_colour_brewer(palette = "Set1") +
  facet_wrap(~ sex) +
  labs(x = "",
       y = "Mean number\nof hospitalisations",
       colour = "Received chemotherapy after surgery") +
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
  theme(legend.position      = "bottom")

# 4. Export graph as pdf -------------------------------------------------------
ggsave("./plots/example_plot_1.pdf",
       gg_comb,
       device = "pdf",
       height = 14,
       width = 14,
       units = "cm")

# //////////////////////////////////////////////////////////////////////////////
# END OF R-SCRIPT