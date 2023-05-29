#' Testing Model Fit of `JointFPM::predict()` in Multiple Bootstrapp Iterations
#' 
#' `model_test` test the fit of the mean number of events predicted with
#' `JointFPM::predict()` based on draws from a large simiulated dataset.
#' 
#' @param data
#'  A `data.frame` with a dataset in stacked fromat, e.g.
#'  preprocessed with `stack_simreccomp()`.
#'  
#' @param path_sim_iterations
#'  A `character` vector specifying the path to the file in which the
#'  predicted values of E[N(t)] are to be stored.
#'  
#' @param arg_JointFPM
#'  A `list` of argument passed to the `JointFPM::JointFPM()` call.
#'  
#' @param n_cluster
#'  The number of clusters used for paralleling the bootstrapping and model
#'  estimation.
#'  
#' @param size_bootstrapp
#'  The number of observations sampled from the whole dataset for each
#'  bootstrapp.
#'  
#' @param ci_fit
#'  Indicating if confidence intervalls should be fitted or not.
#'  
#' @return
#'  None. `model_test` stores the estimates for each iteration in 
#'  `path_sim_iterations/iteration<n>.csv`.
#' 
#' @export

model_test <- function(data,
                       path_sim_iterations,
                       arg_JointFPM,
                       n_cluster,
                       n_bootstrapps,
                       size_bootstrapp,
                       times,
                       ci_fit){
  
  # Load packages
  box::use(par = parallel)
  
  # Obtain list of unique observations
  unique_ids <- unique(data[[arg_JointFPM$cluster]])
  
  # Set up clusters
  
  cl <- par$makeCluster(n_cluster, type = "SOCK")
  
  par$clusterExport(cl, c("data", "unique_ids", "path_sim_iterations",
                          "size_bootstrapp", "arg_JointFPM", "ci_fit",
                          "times"),
                    envir = environment())
  
  # Run model tests on cluster
  
  par$clusterApply(cl, 1:n_bootstrapps, function(i){
    
    # Change seed for each iteration
    set.seed(i * 2)
    
    # Load packages
    box::use(JointFPM[...],
             data.table[...],
             purrr[safely])
    
    # Sample from whole dataset
    tmp_data <- data[data[[arg_JointFPM$cluster]] %in% sample(unique_ids, 
                                                              size_bootstrapp, 
                                                              replace = FALSE),]
    
    # Test dfs for best model fit
    arg_JointFPM$data <- tmp_data
    
    dfs_test_results <- do.call(test_dfs_JointFPM, arg_JointFPM)
    
    best_fit <- dfs_test_results[which.min(dfs_test_results$bic), ]
    
    # Update model call based on best dfs fit
    arg_JointFPM$df_ce <- best_fit$df_bh
    arg_JointFPM$tvc_re <- best_fit$df_tvc_re
    arg_JointFPM$tvc_ce_terms <- list(x = best_fit$df_tvc_x_ce)
    arg_JointFPM$tvc_re_terms <- list(x = best_fit$df_tvc_x_re)
    
    # Fit model
    model_call <- safely(function() do.call(JointFPM, arg_JointFPM))
    model_test <- model_call()
    
    # Return with message on error
    if(!is.null(model_test$error)){
      
      # Save error message
      sink(paste0(path_sim_iterations, "error_iteration", i, ".txt"))
      
      cat("Error in JointFPM() fit:\n")
      print(model_test$error)
      
      sink()
      
      return(NULL)
      
    } else {
      
      model <- model_test$result
      
    }
    
    # Predict mean no. for treated and untreated
    fit <- lapply(0:1, function(j){
      
      predict_call <- safely(
        function(){
          JointFPM:::predict.JointFPM(model,
                                      newdata  = data.frame(x = j),
                                      t        = times,
                                      gauss_max_iter   = 5,
                                      gauss_nodes      = 50,
                                      ci_fit   = ci_fit)
        })
      
      predict_test <- predict_call()
     
      # Return with message on error
      if(!is.null(predict_test$error)){
        
        # Save error message
        sink(paste0(path_sim_iterations, "error_iteration", i, ".txt"),
             append = TRUE)
        
        cat("Error in predict.JointFPM() in subet x = ", j, ":\n")
        print(predict_test$error)
        
        sink()
        
        return(NULL)
        
      } else {
        
        tmp <- predict_test$result
        
      }
      
      tmp$x <- j
      
      return(tmp)
      
    }) |> data.table::rbindlist()
    
    # Save data as .csv file
    fit$iteration <- i
    fit$df_ce <- best_fit$df_bh
    fit$df_re <- best_fit$df_tvc_re
    fit$tvc_ce_terms <- best_fit$df_tvc_x_ce
    fit$tvc_re_terms <- best_fit$df_tvc_x_re
    
    data.table::fwrite(fit,
                       paste0(path_sim_iterations, "iteration", i, ".csv"))
    
    cat("saved iteration", i)

  })
  
  # Close clusters
  par$stopCluster(cl)
  
}
