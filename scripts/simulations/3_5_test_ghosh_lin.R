################################################################################
# Project: Parametric Estimation of The Mean Number of Events
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
                     # These parameters are defined in the .Rprofile file
                     n_cluster       = getOption("n_cluster"),
                     n_bootstrapps   = getOption("n_bootstraps"),
                     size_bootstrapp = getOption("size_bootstrap"))
  
  # Success
  return(1)
  
})

################################################################################
# END OF R-FILE