################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Estimate Lambda(t) in all scenarios
# 
# Author: Joshua Entrop
#
# Creates: ./data/sim_iterations/cum_haz/sim<1-10>/iteration<n>.csv
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# 1. Run Simulations -----------------------------------------------------------
lapply(1:10, function(i) {
  
  box::use(usr = scripts/user_functions,
           surv = survival[Surv, frailty],
           rstpm2[...],
           dt  = data.table)
  
  # Load data (drop death times)
  sim_data <- dt$fread(paste0("./data/sim_data/sim", i, ".csv"))[re == 1]
  
  # Obtain benchmark estimates
  usr$test_cum_haz_model(sim_data,
                         path_sim_iterations = paste0("./data/sim_iterations",
                                                      "/cum_haz/sim", i, "/"),
                         arg_stpm2 = list(
                           formula = Surv(start, stop, 
                                          status, type = 'counting') ~ x,
                           dfs_bh = 1:3
                         ),
                         cluster_var = "id",
                         times = c(2.5, 5.0, 10),
                         ci_fit = TRUE,
                         # These parameters are defined in the .Rprofile file
                         n_cluster       = getOption("n_cluster"),
                         n_bootstrapps   = getOption("n_bootstraps"),
                         size_bootstrapp = getOption("size_bootstrap"))
  
  # Success
  return(1)
  
})

################################################################################
# END OF R-FILE