################################################################################
# Project: Parametric Estimation of The Mean Number of Events
# 
# Title: Estimate E[N(t)] in scenario 11, with continuous C
# 
# Author: Joshua Entrop
#
# Creates: ./data/sim_iterations/mean_no/sim11/iteration<n>.csv
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# Load packages
box::use(usr = scripts/user_functions,
         dt  = data.table)

# 1. Run Simulations -----------------------------------------------------------

# Define preditions calls
newdata <- expand.grid(x.V1 = 0:1,
                       x.V2 = 0:3)

predict_calls <- lapply(seq_len(nrow(newdata)), 
                        function(i){
                          list(type    = "mean_no",
                               newdata = newdata[i, ],
                               t       = c(2.5, 5, 10),
                               ci_fit  = TRUE)
                        })

# Load data
sim_data <- dt$fread(paste0("./data/sim_data/sim11.csv"))

# Obtain benchmark estimates
usr$model_test(sim_data,
               type = "mean_no",
               path_sim_iterations = paste0("./data/sim_iterations",
                                            "/mean_no/sim11/"),
               arg_JointFPM = list(surv = Surv(start, stop, 
                                               status, type = 'counting') ~ 1,
                                   re_model = ~ x.V1 + x.V2,
                                   ce_model = ~ x.V1 + x.V2,
                                   re_indicator = "re",
                                   ce_indicator = "ce",
                                   dfs_ce = 1:3,
                                   dfs_re = 1:3,
                                   tvc_re_terms = list(x.V1 = 1, x.V2 = 1),
                                   tvc_ce_terms = list(x.V1 = 1, x.V2 = 1),
                                   cluster = "id"),
               predict_calls = predict_calls,
               # These parameters are defined in the .Rprofile file
               n_cluster       = getOption("n_cluster"),
               n_bootstrapps   = getOption("n_bootstraps"),
               size_bootstrapp = getOption("size_bootstrap"))

################################################################################
# END OF R-FILE