#' Computes bias and coverage comparing `sim_benchmark` and `sim_iterations`
#' 
#' @param sim_no
#' Number of simulation scenario.
#'  
#' @param target
#' One of `mean_no` or `diff`.
#' 
#' @export

compute_bias <- function(sim_no,
                         estimate,
                         target,
                         by_vars){
  
  box::use(dt = data.table)
  
  # Load estimates
  sim_results <- lapply(dir(paste0("./data/sim_iterations/", 
                                   estimate, "/sim", sim_no), 
                            full.names = TRUE,
                            pattern = ".csv$"), 
                        \(x) {
                          dt$fread(x,
                                   colClasses = c(fit = "double",
                                                  lci = "double",
                                                  uci = "double"))
                        }) |> 
    dt$rbindlist()
  
  # Make sure that fit is numeric
  sim_results[, fit := as.numeric(fit)]
  
  # Get No. of simulations
  n_sim <- length(unique(sim_results$iteration))
  
  # Load benchmark estimates
  benchmark <- dt$fread(paste0("./data/sim_benchmark/sim", sim_no, ".csv"))
  x_vars <- colnames(benchmark)[!colnames(benchmark) %in% c("stop", "target")]
  
  # Find the estimates for 2.5, 5, and 10 years (Note 1)
  benchmark[, lead_times := dt$shift(stop, type = "lead"), 
            by = x_vars]
  
  benchmark <- benchmark[, .SD[c(match(TRUE, lead_times > 2.5),
                                 match(TRUE, lead_times > 5),
                                 which.max(stop))],
                         by = x_vars,
                         .SDcols = c("stop", "target")]
  
  # Make data align with the other benchmark dataset
  benchmark[, stop := round(stop , 1)]
  
  if(target == "diff"){
    
    benchmark <- dt$dcast(benchmark, stop ~ x, value.var = "target")
    
    benchmark[, target := `0` - `1`]
    
    comb <- merge(sim_results,
                  benchmark,
                  by = by_vars)
    
  } else if(target == "mean_no"){
    
    comb <- merge(sim_results,
                  benchmark,
                  by = by_vars)
    
  }
  
  # Calculate performance measures
  comb <- comb[, `:=`(bias     = mean(fit - target),
                      rel_bias = mean((fit - target) / target),
                      bias_se  = sqrt((1/(n_sim * (n_sim - 1))) * sum((target - fit)^2)),
                      coverage = sum(target >= lci & target <= uci, na.rm = TRUE) / 
                        sum(!is.na(lci))),
               by = by_vars]
  
  comb[, rel_bias_se := sqrt((1 / (n_sim * (n_sim - 1))) * sum((((fit - target) / target) - rel_bias) ^ 2)),
       by = by_vars]
  
  comb <- comb[, .SD[1], by = by_vars]
  
  comb[, coverage_se := sqrt((coverage * (1 - coverage)) / n_sim)]
  comb[, scenario    := sim_no]
  
  return(comb)
}

# //////////////////////////////////////////////////////////////////////////////
# NOTES:
# 
# 1) This step is for finding the E[N(t)] estimates that are closest below the
#    the times 2.5, 5, and 10. This is needed as the estimate of, e.g,
#    E[N(t = 5)] based on the Ghosh and Lin estimator is the estimate that is 
#    closes below t = 5, if no event is observed at exact t = 5, which will
#    nearly always be the case. This approach also works for the analytically
#    approach as this step selects the estimate E[N(t = 5)], if an estimate 
#    for exactly t = 5 is available.
#
# //////////////////////////////////////////////////////////////////////////////