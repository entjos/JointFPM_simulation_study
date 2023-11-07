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
estimates <- lapply(1:9, function(x) {
  dt$fread(paste0("./data/sim_benchmark/sim", x, ".csv"))
})

# 1. Preapre data for plotting -------------------------------------------------

# Get parameters for scenarios
scenarios <- readRDS("./data/sim_data/scenarios.RData")

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

test <- test |> dt$rbindlist()

# 2. Create plot ---------------------------------------------------------------
benchmark_plot <- ggplot(test,
                         aes(x = time,
                             y = expn,
                             colour = x,
                             lty    = x,
                             group  = x)) +
  geom_line()           +
  scale_colour_brewer(palette = "Set1") +
  labs(x = "Time (Years since randomisation)",
       y = "Mean number of events")     +
  theme(strip.text = element_markdown()) +
  facet_wrap(~ scenario,
             scales = "fixed",
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