################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Estimate E[N(t|x=0)] - E[N(t|x=1)] in all scenarios
# 
# Author: Joshua Entrop
#
# Creates: ./data/sim_iterations/diff/sim<1-10>/iteration<n>.csv
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
                 type = "diff",
                 path_sim_iterations = paste0("./data/sim_iterations",
                                              "/diff/sim", i, "/"),
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
                 predict_calls = list(list(type    = "diff",
                                           newdata = data.frame(x = 0),
                                           exposed = \(x) transform(x, x = 1),
                                           t       = c(2.5, 5, 10),
                                           ci_fit  = TRUE)),
                 n_cluster = 10,
                 n_bootstrapps = 1900,
                 size_bootstrapp = 1000)
  
  # Success
  return(1)
  
})

################################################################################
# END OF R-FILE