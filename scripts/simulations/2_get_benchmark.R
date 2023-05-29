################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Obtaining Benchmark Estimates for Scenario 1
# 
# Author: Joshua Entrop
#
# Creates: ./data/sim_benchmark/sim1.csv
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# Load package
box::use(par = parallel)

# 2. Set Up Parallelisation ----------------------------------------------------

cl <- par$makeCluster(4, type = "SOCK")

# 3. Run Simulations -----------------------------------------------------------
par$clusterApply(cl, seq_along(dir("./data/sim_data")), function(i) {
  
  # Load packages
  box::use(usr = scripts/user_functions,
           dt  = data.table,
           survival[Surv])
  
  # Load data
  sim_data <- dt$fread(paste0("./data/sim_data/sim", i, ".csv"))
  
  # Obtain benchmark estimates
  temp <- usr$benchmarking(sim_data,
                           by_var = "x",
                           arg_mean_no = 
                             list(formula      = Surv(start, stop, status) ~ 1,
                                  re_indicator = "re",
                                  ce_indicator = "ce",
                                  data         = sim_data,
                                  re_control   = list(timefix = FALSE)))
  
  # Export dataset
  dt$fwrite(temp, paste0("./data/sim_benchmark/sim", i, ".csv"))
  
  # Success
  return(1)

  })

# 4. Clean up ------------------------------------------------------------------

par$stopCluster(cl)

################################################################################
# END OF R-FILE