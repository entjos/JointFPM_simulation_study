#' Testing Fit of Cock and Lawless Estimate in Multiple Bootstrapp Iterations
#' 
#' @param data
#'  A `data.frame` with a dataset in stacked fromat, e.g.
#'  preprocessed with `stack_simreccomp()`.
#'  
#' @param path_sim_iterations
#'  A `character` vector specifying the path to the file in which the
#'  predicted values of E[N(t)] are to be stored.
#'  
#' @param n_cluster
#'  The number of clusters used for paralleling the bootstrapping and model
#'  estimation.
#'  
#' @param size_bootstrapp
#'  The number of observations sampled from the whole dataset for each
#'  bootstrapp.
#'  
#' @return
#'  None. `ghosh_lin_test` stores the estimates for each iteration in 
#'  `path_sim_iterations/iteration<n>.csv`.
#' 
#' @export

ghosh_lin_test <- function(data,
                           path_sim_iterations,
                           n_cluster,
                           n_bootstrapps,
                           size_bootstrapp){
  
  # Load packages
  box::use(par = parallel)
  
  # Obtain list of unique observations
  unique_ids <- unique(data[["id"]])
  
  # Set up clusters
  
  cl <- par$makeCluster(n_cluster, type = "SOCK")
  
  par$clusterExport(cl, c("data", "unique_ids", "path_sim_iterations",
                          "size_bootstrapp"),
                    envir = environment())
  
  par$clusterApply(cl, 1:n_bootstrapps, function(i){
    
    # Change seed for each iteration
    set.seed(i * 2)
    
    # Load packages
    box::use(data.table[...],
             mets[...],
             stats[...],
             survival[...])
    
    tmp_data <- data[id %in% sample(unique_ids, 
                                    size_bootstrapp, 
                                    replace = FALSE),]
    
    # Convert data to format requiered by recurrentMargnal()
    tmp_data <- merge(tmp_data[re == 1],
                      tmp_data[ce == 1, .(id, 
                                          ce_time = stop, 
                                          status_ce = status)],
                      by = "id")
    
    tmp_data[ce_time != stop, status_ce := 0]
    
    # Estimates E[N(t)] using Ghosh and Lin CIs
    out <- lapply(0:1, \(i){
      
      fit <- recurrentMarginal(phreg(Surv(start, stop, status) ~ cluster(id),
                                     data = tmp_data[x == i]), 
                               phreg(Surv(start, stop, status_ce) ~ cluster(id),
                                     data = tmp_data[x == i])) |> 
        summary() |> 
        as.data.table()
      
      fit[, x := i]
      
      return(fit)
      
    }) |> rbindlist()
    
    # Find the estimates for 2.5, 5, and 10 years
    out[, lead_times := shift(times, type = "lead"), by = x]
    
    out <- out[, .SD[c(match(TRUE, lead_times > 2.5),
                       match(TRUE, lead_times > 5),
                       which.max(times))],
               by = x]
    
    
    # Prepare output data
    out <- out[, .(stop = c(2.5, 5, 10),
                   fit  = mean,
                   lci  = `CI-2.5%`,
                   uci  = `CI-97.5%`,
                   x,
                   iteration = i)]
    
    fwrite(out, paste0(path_sim_iterations, "iteration", i, ".csv"))
  
    })
}