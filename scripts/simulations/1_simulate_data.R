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
box::use(dt  = data.table,
         ft  = future,
         future.apply[future_lapply])

# 1. Define Scenarios ----------------------------------------------------------

scenarios <- expand.grid(scale_rec     = list(0.1, 0.3, 0.5),
                         shape_rec     = list(1.40),
                         scale_rec_inc = list(NA),
                         scale_comp  = list(0.02, 0.20, 0.60),
                         shape_comp  = list(0.50)) |> 
  as.list()

# Add one scenario with a lambda being a function of previous occurences
scenarios$scale_rec[[10]] <- 0.1
scenarios$shape_rec[[10]] <- 1.4
scenarios$scale_rec_inc[[10]] <- function(x){1 + (x/(x + 1))}
scenarios$scale_comp[[10]] <- 0.2
scenarios$shape_comp[[10]] <- 0.5

# Save scenarios
saveRDS(scenarios, file = "./data/sim_data/scenarios.RData")

# 2. Set Up Parallelisation ----------------------------------------------------

ft$plan(strategy = "multisession",
        workers  = 10)

# 3. Run Simulations -----------------------------------------------------------
future_lapply(1:10, 
              future.seed = 22345,
              function(i) {

  # Load packages
  box::use(usr = scripts/user_functions,
           dt  = data.table)

  # Run Simulation (see function documentation for fixed parameters)
  temp <- usr$sim(1000000,
                  par_rec  = list(scale     = scenarios$scale_rec[[i]], 
                                  shape     = scenarios$shape_rec[[i]],
                                  scale_inc = scenarios$scale_rec_inc[[i]]),
                  par_comp = list(scale     = scenarios$scale_comp[[i]], 
                                  shape     = scenarios$shape_comp[[i]]))

  # Add indicator for scenario number
  temp$scenario <- i
  
  # Export dataset
  dt$fwrite(temp, paste0("./data/sim_data/sim", i, ".csv"))

  # Success
  return(1)

})

################################################################################
# END OF R-FILE