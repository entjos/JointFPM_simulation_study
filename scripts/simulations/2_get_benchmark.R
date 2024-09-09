################################################################################
# Project: Parametric Estimation of The Mean Number of Events
# 
# Title: Obtaining Benchmark Estimates for Scenarios 1-11
# 
# Author: Joshua Entrop
#
# Creates: ./data/sim_benchmark/sim<1-11>.csv
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# Load package
box::use(usr = scripts/user_functions,
         dt  = data.table,
         survival[Surv],
         JointFPM[mean_no])

# 1. Get benchmarks for scenario 1:9 -------------------------------------------

for(i in 1:9){
  
  temp <- usr$calculate_benchmark(i, 
                                  newdata = expand.grid(stop = seq(0.1, 10, 0.1),
                                                        x    = 0:1))
  
  dt$fwrite(temp, paste0("./data/sim_benchmark/sim", i, ".csv"))
  
}

# 2. Get benchmarks for scenario 10 --------------------------------------------

# Load data whole dataset
sim_data <- dt$fread(paste0("./data/sim_data/sim10.csv"))

# Obtain benchmark estimates
temp <- mean_no(formula      = Surv(start, stop, status) ~ x,
                re_indicator = "re",
                ce_indicator = "ce",
                data         = sim_data,
                re_control   = list(timefix = FALSE))

temp[, x := gsub("x=", "", strata)]
temp[, strata := NULL]

# Update column names
dt$setnames(temp, old = "expn", new = "target")
dt$setnames(temp, old = "time", new = "stop")

temp <- temp[, .(stop, x, target)]

# Export dataset
dt$fwrite(temp, paste0("./data/sim_benchmark/sim10.csv"))

# 3. Get benchmarks for scenario 11 --------------------------------------------
temp <- usr$calculate_benchmark(11, 
                                newdata = expand.grid(stop = c(2.5, 5, 10),
                                                      x    = list(c(0, 0),
                                                                  c(1, 0),
                                                                  c(0, 1),
                                                                  c(1, 1),
                                                                  c(0, 2),
                                                                  c(1, 2),
                                                                  c(0, 3),
                                                                  c(1, 3))))


temp <- cbind(expand.grid(stop = c(2.5, 5, 10),
                          x.V1   = 0:1,
                          x.V2   = 0:3),
              target = temp$target)

dt$fwrite(temp, paste0("./data/sim_benchmark/sim11.csv"))

################################################################################
# END OF R-FILE