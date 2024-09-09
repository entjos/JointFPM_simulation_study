################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Plotting estimates of bias and coverage
# 
# Author: Joshua Entrop
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# clear memory
rm(list = ls())

# Load packages
box::use(ggplot2[...],
         ptw = patchwork,
         scales,
         dplyr[...])

# Set colour scale
options(ggplot2.discrete.colour = scales$brewer_pal(type = "seq", 
                                                    palette = "Set1")(3))

# Load data
load("./data/sim_bias_estimates/bias_estimates_mean_no.RData")

# 1. User functions for plotting -----------------------------------------------
remove_x <- theme(axis.title.y  = element_blank(),
                  axis.text.y   = element_blank(),
                  axis.ticks.y  = element_blank())

# 2. Create labels for plotting ------------------------------------------------
bias_estimates <- bias_estimates_mean_no |> 
  mutate(label = paste0("Scenario ", sprintf("%02d", scenario),
                        "; x = ", x),
         stop = factor(stop))

# 3. Create plots --------------------------------------------------------------

#   3.1 Plot of absolute biases ================================================
res_plot1 <- ggplot(bias_estimates,
                    aes(x = bias,
                        y = label,
                        colour = stop,
                        group  = stop))       +
  geom_point()                                +
  scale_x_continuous(limits = c(-0.10, 0.20)) +
  scale_y_discrete(limits = rev)              +
  geom_vline(xintercept = 0,
             lty = "dashed")                  +
  labs(title  = "(A)",
       x      = "Absolute bias",
       colour = "Time since surgery (years)") +
  theme_bw()                                  +
  theme(axis.text.x = element_text(angle = 45, 
                                   hjust = 1),
        axis.title.y = element_blank())

#   3.2 Plot of relative biases ================================================
res_plot2 <- ggplot(bias_estimates,
                    aes(x = rel_bias,
                        y = label,
                        colour = stop,
                        group  = stop))        +
  geom_point()                                 +
  scale_x_continuous(limits = c(-0.1, 0.1),
                     labels = scales$percent)  +
  scale_y_discrete(limits = rev)               +
  geom_vline(xintercept = 0,
             lty = "dashed")                   +
  labs(title  = "(B)",
       x      = "Relative bias (%)",
       colour = "Time since surgery (years)")  +
  theme_bw()                     + 
  theme(axis.text.x = element_text(angle = 45, 
                                   hjust = 1)) +
  remove_x

#   3.3 Plot of coverage =======================================================
res_plot3 <- ggplot(bias_estimates,
                    aes(x = coverage,
                        y = label,
                        colour = stop,
                        group  = stop)) +
  geom_point() +
  scale_x_continuous(limits = c(0.8, 1),
                     labels = scales$percent) +
  scale_y_discrete(limits = rev)              +
  geom_vline(xintercept = 0.95,
             lty = "dashed") +
  labs(title  = "(C)",
       x      = "Coverage (%)",
       colour = "Time since surgery (years)")   +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust=1)) +
  remove_x

# 4. Combine plots -------------------------------------------------------------
gg_comb <- ptw$wrap_plots(res_plot1, res_plot2, res_plot3,
                          ncol = 3, 
                          nrow = 1,
                          guides = "collect") & 
  theme(legend.position = "bottom")

# 5. Export plot ---------------------------------------------------------------

ggsave("./plots/figure3.pdf",
       gg_comb,
       device = "pdf",
       height = 14,
       width = 14,
       units = "cm")

#///////////////////////////////////////////////////////////////////////////////
# END OF R-FILE