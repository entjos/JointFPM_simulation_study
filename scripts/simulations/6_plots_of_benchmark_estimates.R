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
estimates <- lapply(1:10, function(x) {
  dt$fread(paste0("./data/sim_benchmark/sim", x, ".csv"))
})

# 1. Prepare data for plotting -------------------------------------------------

# Get parameters for scenarios
scenarios <- readRDS("./data/sim_data/scenarios.RData")

# Improve labeling of facets
estimates <- lapply(1:10, function(i){
  
  estimates[[i]][, scenario := paste0("Scenario~", sprintf("%02d", i),
                                "~rho~`=`~",
                                scenarios$scale_rec[[i]],
                                if(i == 10) "%up%",
                                "~iota~`=`~",
                                scenarios$scale_comp[[i]]),]
  estimates[[i]][, x := factor(x)]
  
}) |> dt$rbindlist()

# 2. Create plot ---------------------------------------------------------------
benchmark_plot <- ggplot(estimates,
                         aes(x = stop,
                             y = target,
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
             labeller = label_parsed,
             ncol = 3) +
  theme_bw()

# 3. Export plot ---------------------------------------------------------------
ggsave("./plots/figure2.pdf",
       benchmark_plot,
       device = cairo_pdf,
       height = 18.6,
       width = 17,
       units = "cm")

#///////////////////////////////////////////////////////////////////////////////
# END OF R-FILE