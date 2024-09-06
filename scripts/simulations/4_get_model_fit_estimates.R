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
         ft = future,
         future.apply[future_lapply],
         kx = kableExtra,
         usr = scripts/user_functions)

# 1. Set Up Parallelisation ----------------------------------------------------

ft$plan(strategy = "multisession",
        workers  = 10)

# 2. Define function for calculating bias and coverage -------------------------

# Apply function
bias_estimates_mean_no <- future_lapply(1:10, \(i) {
  box::use(usr = scripts/user_functions)
  usr$compute_bias(i, 
                   estimate = "mean_no",
                   target   = "mean_no",
                   by_vars  = c("stop", "x"))
}) |> 
  dt$rbindlist()

bias_estimates_diff <- future_lapply(1:10, \(i) {
  box::use(usr = scripts/user_functions)
  usr$compute_bias(i, 
                   estimate = "diff",
                   target   = "diff", 
                   by_vars  = c("stop"))
}) |> 
  dt$rbindlist()

bias_estimates_cum_haz <- future_lapply(1:10, \(i) {
  box::use(usr = scripts/user_functions)
  usr$compute_bias(i, 
                   estimate = "cum_haz",
                   target   = "mean_no",
                   by_vars  = c("stop", "x"))
}) |> 
  dt$rbindlist()

bias_estimates_ghosh_lin <- future_lapply(1:10, \(i) {
  box::use(usr = scripts/user_functions)
  usr$compute_bias(i, 
                   estimate = "ghosh_lin",
                   target   = "mean_no",
                   by_vars  = c("stop", "x"))
}) |> 
  dt$rbindlist()

bias_estimates_cont_x <- usr$compute_bias(11, 
                                          estimate = "mean_no",
                                          target   = "mean_no", 
                                          by_vars  = c("stop", "x.V1", "x.V2"))

# Close clusters
par$stopCluster(cl)

# 3. Export table to Latex -----------------------------------------------------

usr$create_sim_table(bias_estimates_mean_no,
                     by_vars = c("scenario", "x"),
                     table_path = "./tables/table3.tex")

usr$create_sim_table(bias_estimates_cont_x,
                     by_vars = c("x.V2", "x.V1"),
                     table_path = "./tables/tableS1.tex")

usr$create_sim_table(bias_estimates_diff,
                     by_vars = "scenario",
                     table_path = "./tables/tableS2.tex")

usr$create_sim_table(bias_estimates_ghosh_lin,
                     by_vars = c("scenario", "x"),
                     table_path = "./tables/tableS3.tex")

usr$create_sim_table(bias_estimates_cum_haz,
                     by_vars = c("scenario", "x"),
                     table_path = "./tables/tableS4.tex",
                     highlight = FALSE,
                     measures = c("bias", "rel_bias"),
                     labels   = c("Bias", "Rel. Bias"))

# 4. Create table of MC error limits -------------------------------------------

temp_var_selection <- c("limit_bias", "limit_rel_bias", "limit_coverage")

bias_estimates_mean_no[, limit_bias     := 1.96 * bias_se]
bias_estimates_mean_no[, limit_rel_bias := 1.96 * rel_bias_se]
bias_estimates_mean_no[, limit_coverage := 1.96 * coverage_se]

bias_estimates_mean_no[, (temp_var_selection) := lapply(.SD, function(x) round(x, 4)),
               .SDcols = temp_var_selection]

tab_error_range <- dt$dcast(bias_estimates_mean_no,
                            scenario + x ~ stop,
                            value.var = temp_var_selection)

new_col_orde <-  c(
  1, 2, order(as.numeric(sub(".*_", "", colnames(tab_error_range[, -(1:2)])))) + 2)

dt$setcolorder(tab_error_range, new_col_orde)

kx$kbl(tab_error_range, 
       col.names = c("Scenario", "x", rep(c("Bias", "Rel. Bias", 
                                            "Coverage"), 3)),
       booktabs = TRUE,
       linesep = c(rep("", 5), "\\rule{0pt}{4ex}"),
       caption = paste("Estimates of bias, relative bias, and coverage", 
                       "at 2.5, 5, and 10",
                       "years of $\\mu(t)$"),
       align = c("c", "c", rep("r", ncol(tab_error_range) - 2)),
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
  kx$save_kable("./tables/MC_error_limits.tex")

# 4. Save bias estimates -------------------------------------------------------

save(bias_estimates_mean_no,
     file = "./data/sim_bias_estimates/bias_estimates.RData")

#///////////////////////////////////////////////////////////////////////////////
# END OF R-FILE