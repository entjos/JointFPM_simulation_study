################################################################################
# Project: Parametric Estimation of The Mean Number of Events
# 
# Title: Obtaining Benchmark Estimates for Scenarios 1-10
# 
# Author: Joshua Entrop
#
# Creates: ./data/sim_benchmark/sim<1-10>.csv
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# Load package
box::use(par = parallel)

# 2. Set Up Parallelisation ----------------------------------------------------

cl <- par$makeCluster(10, type = "SOCK")

# 3. Run Simulations -----------------------------------------------------------
par$clusterApply(cl, 1:10, function(i) {
  
  # Load packages
  box::use(dt  = data.table,
           survival[Surv],
           JointFPM[mean_no])
  
  # Load data
  sim_data <- dt$fread(paste0("./data/sim_data/sim", i, ".csv"))
  
  # Obtain benchmark estimates
  temp <- mean_no(formula      = Surv(start, stop, status) ~ x,
                  re_indicator = "re",
                  ce_indicator = "ce",
                  data         = sim_data,
                  re_control   = list(timefix = FALSE))
  
  temp[, x := gsub("x=", "", strata)]
  temp[, strata := NULL]
  
  # Export dataset
  dt$fwrite(temp, paste0("./data/sim_benchmark/sim", i, ".csv"))
  
  # Success
  return(1)
  
})

# 4. Clean up ------------------------------------------------------------------

par$stopCluster(cl)

################################################################################
# END OF R-FILE