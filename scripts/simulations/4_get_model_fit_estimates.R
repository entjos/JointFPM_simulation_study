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
  
  benchmark <- rbind(benchmark_x0[c(which.min(abs(benchmark_x0$time - 2.5)),
                                    which.min(abs(benchmark_x0$time - 5.0)),
                                    which.min(abs(benchmark_x0$time - 10)))],
                     benchmark_x1[c(which.min(abs(benchmark_x1$time - 2.5)),
                                    which.min(abs(benchmark_x1$time - 5.0)),
                                    which.min(abs(benchmark_x1$time - 10)))])
  
  benchmark[, t := round(time, 1)]
  
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
bias_estimates <- lapply(1:10, compute_bias) |> 
  dt$rbindlist()

# 2. Add significances ---------------------------------------------------------

bias_estimates[,bias_lcb := bias - 1.96 * bias_se]
bias_estimates[,bias_ucb := bias + 1.96 * bias_se]
bias_estimates[,cov_lcb  := coverage - 1.96 * coverage_se]
bias_estimates[,cov_ucb  := coverage + 1.96 * coverage_se]

bias_estimates[, bias_sig := bias_lcb > 0    | bias_ucb < 0]
bias_estimates[, cov_sig  := cov_lcb  > 0.95 | cov_ucb  < 0.95]

# 3. Export table to Latex -----------------------------------------------------

#   3.1 Improve printing of numbers and percentages ============================
table_out <- dt$copy(bias_estimates)
table_out[, bias := as.character(round(bias, 3))]
table_out[, rel_bias := paste0(format(round(rel_bias * 100, 3), 
                                      nsmall = 1), "\\%")]
table_out[, coverage := paste0(format(round(coverage * 100, 1), 
                                      nsmall = 1), "\\%")]

#   3.2 Highlight significant bias and low coverage with bold ==================
table_out$bias[table_out$bias_sig] <- 
  kx$cell_spec(table_out$bias[table_out$bias_sig],
               format = "latex",
               bold = TRUE)

table_out$coverage[table_out$cov_sig] <- 
  kx$cell_spec(table_out$coverage[table_out$cov_sig],
               format = "latex",
               bold = TRUE)

#   3.3 Prepare column order ===================================================
table_out <- dt$dcast(table_out,
                      scenario + x ~ stop,
                      value.var = c("bias", "rel_bias", "coverage"))

new_col_orde <-  c(1, 2, 
                   order(sub(".*_", "", colnames(table_out[, -(1:2)]))) + 2)

dt$setcolorder(table_out, new_col_orde)

#   3.4 Convert table to Latex =================================================

kx$kbl(table_out, 
       col.names = c("Scenario", "x", rep(c("Bias", "Rel. Bias", 
                                            "Coverage"), 3)),
       booktabs = TRUE,
       linesep = c(rep("", 5), "\\rule{0pt}{4ex}"),
       caption = paste("Estimates of bias, relative bias, and coverage", 
                       "at 2.5, 5, and 10",
                       "years of $\\mu(t)$"),
       align = c("c", "c", rep("r", ncol(table_out) - 2)),
       format = "latex",
       escape = FALSE) |> 
  kx$column_spec(1, bold = TRUE) |>
  kx$add_header_above(c(" " = 2, 
                        "At 2.5 Years" = 3, 
                        "At 5 Years"   = 3, 
                        "At 10 Years"  = 3)) |> 
  kx$collapse_rows(column = 1,
                   latex_hline = "none",
                   valign = "top",
                   row_group_label_position = c("identity"),
                   row_group_label_fonts = list(list(escape = FALSE))) |> 
  kx$kable_styling()|>
  kx$save_kable("./tables/simulation_restuls.tex")

# 4. Save bias estimates -------------------------------------------------------

save(bias_estimates,
     file = "./data/sim_bias_estimates/bias_estimates.RData")

#///////////////////////////////////////////////////////////////////////////////
# END OF R-FILE