################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Estimate E[N(t)] in all scenarios
# 
# Author: Joshua Entrop
#
# Creates: ./data/sim_iterations/mean_no/sim<1-10>/iteration<n>.csv
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
  usr$ghosh_lin_test(sim_data,
                 path_sim_iterations = paste0("./data/sim_iterations",
                                              "/ghosh_lin/sim", i, "/"),
                 n_cluster = 10,
                 n_bootstrapps = 1900,
                 size_bootstrapp = 1000)
  
  # Success
  return(1)
  
})

################################################################################
# END OF R-FILE