#' Createing table of simulation results
#' 
#' @param bias_estimates 
#' `data.frame` of bias estiamtes accross different scenarios as created by
#' `compute_bias()`.
#'  
#' @param table_path
#' File name/path of the new table
#'  
#' @return
#'  None.
#' 
#' @export

create_sim_table <- function(bias_estimates,
                             by_vars,
                             table_path,
                             highlight = TRUE,
                             measures = c("bias", "rel_bias", "coverage"),
                             labels   = c("Bias", "Rel. Bias", "Coverage")) {
  
  box::use(kx = kableExtra,
           dt = data.table,
           stringr,
           stats)
 
  bias_estimates[,bias_lcb     := bias     - 1.96 * bias_se]
  bias_estimates[,bias_ucb     := bias     + 1.96 * bias_se]
  bias_estimates[,rel_bias_lcb := rel_bias - 1.96 * rel_bias_se]
  bias_estimates[,rel_bias_ucb := rel_bias + 1.96 * rel_bias_se]
  bias_estimates[,cov_lcb      := coverage - 1.96 * coverage_se]
  bias_estimates[,cov_ucb      := coverage + 1.96 * coverage_se]
  
  bias_estimates[, bias_sig     := bias_lcb > 0    | bias_ucb < 0]
  bias_estimates[, rel_bias_sig := rel_bias_lcb > 0| rel_bias_ucb < 0]
  bias_estimates[, cov_sig      := cov_lcb  > 0.95 | cov_ucb  < 0.95]
  
  # 3. Export table to Latex ---------------------------------------------------
  
  #   3.1 Improve printing of numbers and percentages ==========================
  table_out <- dt$copy(bias_estimates)
  table_out[, bias := as.character(format(round(bias, 3), 
                                          digits = 3,
                                          nsmall = 3))]
  table_out[, rel_bias := paste0(format(round(rel_bias * 100, 3), 
                                        digits = 3,
                                        nsmall = 3), "\\%")]
  table_out[, coverage := paste0(format(round(coverage * 100, 1), 
                                        nsmall = 1), "\\%")]
  
  #   3.2 Highlight significant bias and low coverage with bold ================
  if(highlight){
    
    table_out[bias_sig == TRUE, 
              bias := kx$cell_spec(.SD$bias,
                                   format = "latex",
                                   bold = TRUE)]
    
    table_out[rel_bias_sig == TRUE, 
              rel_bias := kx$cell_spec(.SD$rel_bias,
                                       format = "latex",
                                       bold = TRUE)]
    
    table_out[cov_sig  == TRUE, 
              coverage := kx$cell_spec(.SD$coverage,
                                       format = "latex",
                                       bold = TRUE)]
    
  }
  
  #   3.3 Prepare column order =================================================
  table_out <- dt$dcast(table_out,
                        stats$as.formula(paste(paste(by_vars, collapse = "+"), 
                                               "~ stop")),
                        value.var = measures)
  
  new_col_orde <-  c(
    seq_along(by_vars), 
    order(
      as.numeric(
        sub(".*_", "", colnames(table_out)[-seq_along(by_vars)])
        )
      ) + length(by_vars)
  )
  
  dt$setcolorder(table_out, new_col_orde)
  
  #   3.4 Convert table to Latex ===============================================
  
  kx$kbl(table_out, 
         col.names = c(stringr$str_to_sentence(by_vars), 
                       rep(labels, 3)),
         booktabs = TRUE,
         linesep = c(rep("", (3 * length(by_vars)) - 1), "\\rule{0pt}{4ex}"),
         caption = paste("Estimates of bias, relative bias, and coverage", 
                         "at 2.5, 5, and 10",
                         "years of $\\mu(t)$"),
         align = c("c", "c", rep("r", ncol(table_out) - length(by_vars))),
         format = "latex",
         escape = FALSE) |> 
    kx$column_spec(1, bold = TRUE) |>
    kx$add_header_above(c(" " = length(by_vars), 
                          "At 2.5 Years" = length(labels), 
                          "At 5 Years"   = length(labels), 
                          "At 10 Years"  = length(labels))) |> 
    kx$collapse_rows(column = 1,
                     latex_hline = "none",
                     valign = "top",
                     row_group_label_position = c("identity"),
                     row_group_label_fonts = list(list(escape = FALSE))) |> 
    kx$kable_styling()|>
    kx$save_kable(table_path)
  
}

