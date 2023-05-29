################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Simulate Data for Scenario 1
# 
# Author: Joshua Entrop
#
# Creates: ./data/sim_data/sim<1-9>.csv
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# Load package
box::use(par = parallel)

# 1. Define Scenarios ----------------------------------------------------------

scenarios <- expand.grid(scale_rec   = c(0.1, 0.3, 0.5),
                         shape_rec   = c(1.40),
                         scale_comp  = c(0.02, 0.20, 0.60),
                         shape_comp  = c(0.50))

# 2. Set Up Parallelisation ----------------------------------------------------

cl <- par$makeCluster(9, type = "SOCK")

par$clusterExport(cl, c("scenarios"))

# 3. Run Simulations -----------------------------------------------------------
par$clusterApply(cl, seq_len(nrow(scenarios)), function(i) {

  # Load packages
  box::use(usr = scripts/user_functions,
           dt  = data.table)

  # Run Simulation (see function documentation for fixed parameters)
  temp <- usr$sim(1000000,
                  par_rec  = list(scale = scenarios$scale_rec[[i]], 
                                  shape = scenarios$shape_rec[[i]]),
                  par_comp = list(scale = scenarios$scale_comp[[i]], 
                                  shape = scenarios$shape_comp[[i]]))

  # Add indicator for scenario number
  temp$scenario <- i
  
  # Export dataset
  dt$fwrite(temp, paste0("./data/sim_data/sim", i, ".csv"))

  # Success
  return(1)

})

# 4. Clean up ------------------------------------------------------------------

par$stopCluster(cl)

################################################################################
# END OF R-FILE