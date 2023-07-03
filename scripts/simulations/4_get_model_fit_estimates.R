################################################################################
# Project: Parametic Estimation of The Mean Number of Events
# 
# Title: Calculating bias and coverage
# 
# Author: Joshua Entrop
# 
################################################################################

# Prefix -----------------------------------------------------------------------

# clear memory
rm(list = ls())

# Load packages
box::use(dt = data.table,
         kx = kableExtra)

# 1. Define function for calculating bias and coverage -------------------------

compute_bias <- function(sim_no){
  
  sim_results <- lapply(dir(paste0("./data/sim_iterations/sim", sim_no), 
                            full.names = TRUE,
                            pattern = ".csv$"), 
                        dt$fread) |> 
    dt$rbindlist()
  
  n_sim <- length(unique(sim_results$iteration))
  
  benchmark <- dt$fread(paste0("./data/sim_benchmark/sim", sim_no, ".csv"))
  
  benchmark_x0 <- subset(benchmark, x == 0)
  benchmark_x1 <- subset(benchmark, x == 1)
  
  
  benchmark <- rbind(benchmark_x0[c(which.min(abs(benchmark_x0$t - 2.5)),
                                    which.min(abs(benchmark_x0$t - 5.0)),
                                    which.min(abs(benchmark_x0$t - 7.5)))],
                     benchmark_x1[c(which.min(abs(benchmark_x1$t - 2.5)),
                                    which.min(abs(benchmark_x1$t - 5.0)),
                                    which.min(abs(benchmark_x1$t - 7.5)))])
  
  benchmark[, t := round(t, 1)]
  
  comb <- merge(sim_results,
                benchmark,
                by.x = c("stop", "x"),
                by.y = c("t", "x"))
  
  comb <- comb[, .(bias     = mean(expn - fit),
                   rel_bias = mean((expn - fit) / expn),
                   bias_se  = sqrt((1/(n_sim * (n_sim - 1))) * sum((expn - fit)^2)),
                   coverage = sum(expn >= lci & expn <= uci, na.rm = TRUE) / 
                     sum(!is.na(lci))),
               by = c("x", "stop")]
  
  comb[, coverage_se := sqrt((coverage * (1 - coverage)) / n_sim)]
  comb[, scenario    := sim_no]
  
  return(comb)
}

# Apply function
bias_estimates <- lapply(1:9, compute_bias) |> 
  dt$rbindlist()

# 2. Export table to Latex -----------------------------------------------------

table_out <- bias_estimates[, .(scenario, x, stop, 
                                bias     = round(bias, 3),
                                rel_bias = paste0(format(round(rel_bias * 100, 3), 
                                                         nsmall = 1), 
                                                  "%"),
                            coverage = paste0(format(round(coverage * 100, 1), 
                                                     nsmall = 1), 
                                              "%"))] |> 
  dt$dcast(scenario + x ~ stop,
           value.var = c("bias", "rel_bias", "coverage"))

new_col_orde <-  c(1, 2, 
                   order(sub(".*_", "", colnames(table_out[, -(1:2)]))) + 2)

dt$setcolorder(table_out, new_col_orde)

kx$kbl(table_out, 
       col.names = c("Scenario", "x", rep(c("Bias", "Rel. Bias", 
                                            "Coverage"), 3)),
       booktabs = TRUE,
       linesep = c(rep("", 5), "\\rule{0pt}{4ex}"),
       caption = paste("Estimates of bias, relative bias, and coverage", 
                       "at 2.5, 5, and 7.5",
                       "years of $\\mu(t)$"),
       align = c("c", "c", rep("r", ncol(table_out) - 2)),
       format = "latex") |> 
  kx$column_spec(1, bold = TRUE) |>
  kx$add_header_above(c(" " = 2, 
                        "At 2.5 Years" = 3, 
                        "At 5 Years"   = 3, 
                        "At 7.5 Years" = 3)) |> 
  kx$collapse_rows(column = 1,
                   latex_hline = "none",
                   valign = "top",
                   row_group_label_position = c("identity")) |> 
  kx$kable_styling()|>
  kx$save_kable("./tables/simulation_restuls.tex")

# 3. Save bias estimates -------------------------------------------------------

save(bias_estimates,
     file = "./data/sim_bias_estimates/bias_estimates.RData")

#///////////////////////////////////////////////////////////////////////////////
# END OF R-FILE