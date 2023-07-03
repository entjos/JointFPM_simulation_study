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
         scales,
         ggtext[element_markdown],
         dt = data.table)

# load benchmark estimates
estimates <- lapply(dir("./data/sim_benchmark", full.names = TRUE), 
                    dt$fread)

# 1. Preapre data for plotting -------------------------------------------------

# Get parameters for scenarios
scenarios <- expand.grid(scale_rec   = c(0.1, 0.3, 0.5),
                         shape_rec   = c(1.40),
                         scale_comp  = c(0.02, 0.20, 0.60),
                         shape_comp  = c(0.50))

# Improve labeling of facets
test <- lapply(1:9, function(i){
  
  dta <- dt$copy(estimates)
  
  dta[[i]][, scenario := paste0("Scenario~", i, "~iota~`=`~",
                               scenarios$scale_comp[[i]],
                               "~rho~`=`~",
                               scenarios$scale_rec[[i]])]
  dta[[i]][, x := factor(x)]
  dta[[i]][sample(.N, 10000)] # Take sampel of 10000 time points
  
})

test <- dt$rbindlist(test)

# 2. Create plot ---------------------------------------------------------------
my_labeller <- as_labeller(c(`1` = '"rho"',
                             `2` = '"rho"',
                             `3` = '"rho"',
                             `4` = '"rho"',
                             `5` = '"rho"',
                             `6` = '"rho"',
                             `7` = '"rho"',
                             `8` = '"rho"',
                             `9` = '"rho"'),
                           default = label_parsed)

benchmark_plot <- ggplot(test,
                         aes(x = t,
                             y = expn,
                             colour = x,
                             group  = x)) +
  geom_line()           +
  scale_colour_brewer(palette = "Set1") +
  labs(x = "Time",
       y = "Mean number of events")     +
  theme(strip.text = element_markdown()) +
  facet_wrap(~ scenario,
             scales = "free_y",
             labeller = label_parsed) +
  theme_bw()

# 3. Export plot ---------------------------------------------------------------
ggsave("./plots/benchmark_plot.pdf",
       benchmark_plot,
       device = cairo_pdf,
       height = 14,
       width = 17,
       units = "cm")

#///////////////////////////////////////////////////////////////////////////////
# END OF R-FILE