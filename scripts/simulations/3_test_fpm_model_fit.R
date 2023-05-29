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
# Creates: ./data/sim_iterations/sim<1-9>/iteration<n>.csv
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# Load packages
box::use(usr = scripts/user_functions,
         dt  = data.table)

# 1. Run Simulations -----------------------------------------------------------
lapply(seq_along(dir("./data/sim_data")), function(i) {
  
  # Load data
  sim_data <- dt$fread(paste0("./data/sim_data/sim", i, ".csv"))
  
  # Obtain benchmark estimates
  usr$model_test(sim_data,
                 path_sim_iterations = paste0("./data/sim_iterations/sim", i, 
                                              "/"),
                 arg_JointFPM = list(surv = "Surv(start, stop, 
                                                  status, type = 'counting')",
                                     re_terms = "x",
                                     ce_terms = "x",
                                     re_indicator = "re",
                                     ce_indicator = "ce",
                                     df_ce  = 2,
                                     tvc_re = 2,
                                     tvc_re_terms = list(x = 2),
                                     tvc_ce_terms = list(x = 2),
                                     cluster = "id"),
                 times = c(2.5, 5.0, 7.5),
                 n_cluster = 10,
                 n_bootstrapps = 200,
                 size_bootstrapp = 500,
                 ci_fit = TRUE)
  
  # Success
  return(1)
  
})

################################################################################
# END OF R-FILE