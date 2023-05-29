################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Calculating bias and coverage
# 
# Author: Joshua Entrop
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# Load packages
box::use(dt  = data.table)

compute_bias <- function(sim_no){
  
  sim_results <- lapply(dir(paste0("./data/sim_iterations/sim", sim_no), 
                            full.names = TRUE,
                            pattern = ".csv$"), 
                        dt$fread) |> 
    dt$rbindlist()
  
  benchmark <- dt$fread(paste0("./data/sim_benchmark/sim", sim_no, ".csv"))
  
  benchmark_x0 <- subset(benchmark, x == 0)
  benchmark_x1 <- subset(benchmark, x == 1)
  
  
  benchmark <- rbind(benchmark_x0[c(which.min(abs(benchmark_x0$t - 2.5)),
                                    which.min(abs(benchmark_x0$t - 5.0)),
                                    which.min(abs(benchmark_x0$t - 7.5)))],
                     benchmark_x1[c(which.min(abs(benchmark_x1$t - 2.5)),
                                    which.min(abs(benchmark_x1$t - 5.0)),
                                    which.Smin(abs(benchmark_x1$t - 7.5)))])
  
  benchmark[, t := round(t, 1)]
  
  comb <- merge(sim_results,
                benchmark,
                by.x = c("stop", "x"),
                by.y = c("t", "x"))
  
  comb[, .(bias     = mean(expn - fit),
           coverage = sum(expn >= lci & expn <= uci) / .N),
       by = c("x", "stop")]
  
}

bias_estimates <- lapply(1:9, compute_bias)
