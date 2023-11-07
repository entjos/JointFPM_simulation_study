################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Obtaining Benchmark Estimates for Scenario 1
# 
# Author: Joshua Entrop
#
# Model specification:
#   - l_a = 3
#   - l_b = 3
#   - l_x_re = 2
#   - l_x_ce = 2
#
# Creates: ./data/sim_iterations/sim<1-10>/iteration<n>.csv
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# Load packages
box::use(usr = scripts/user_functions,
         dt  = data.table)

# 1. Run Simulations -----------------------------------------------------------
lapply(1:10, function(i) {
  
  # Load data
  sim_data <- dt$fread(paste0("./data/sim_data/sim", i, ".csv"))
  
  # Obtain benchmark estimates
  usr$model_test(sim_data,
                 path_sim_iterations = paste0("./data/sim_iterations/sim", i, 
                                              "/"),
                 arg_JointFPM = list(surv = Surv(start, stop, 
                                                 status, type = 'counting') ~ 1,
                                     re_model = ~ x,
                                     ce_model = ~ x,
                                     re_indicator = "re",
                                     ce_indicator = "ce",
                                     dfs_ce = 1:3,
                                     dfs_re = 1:3,
                                     tvc_re_terms = list(x = 1),
                                     tvc_ce_terms = list(x = 1),
                                     cluster = "id"),
                 times = c(2.5, 5.0, 10),
                 n_cluster = 10,
                 n_bootstrapps = 1900,
                 size_bootstrapp = 1000,
                 ci_fit = TRUE)
  
  # Success
  return(1)
  
})

################################################################################
# END OF R-FILE