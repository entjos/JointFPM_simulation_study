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
#' @param predict_calls
#'  A `list` of argument passed to the `JointFPM:::predict.JointFPM()` call. 
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
#'  None. `model_test` stores the estimates for each iteration in 
#'  `path_sim_iterations/iteration<n>.csv`.
#' 
#' @export

model_test <- function(data,
                       type = c("mean_no", "diff"),
                       path_sim_iterations,
                       arg_JointFPM,
                       predict_calls,
                       n_cluster,
                       n_bootstrapps,
                       size_bootstrapp){
  
  # Load packages
  box::use(ft = future,
           future.apply[future_lapply])
  
  # Obtain list of unique observations
  unique_ids <- unique(data[[arg_JointFPM$cluster]])
  
  # Set up clusters
  ft$plan(strategy = "multisession",
          workers  = 10)
  
  # Run model tests on cluster
  
  future_lapply(1:n_bootstrapps, 
                future.seed = 97235,
                FUN = function(i){
                  
    # Load packages
    box::use(JointFPM[...],
             data.table[...],
             purrr[safely],
             stats[setNames])
    
    # Sample from whole dataset
    tmp_data <- data[data[[arg_JointFPM$cluster]] %in% sample(unique_ids, 
                                                              size_bootstrapp, 
                                                              replace = FALSE),]
    
    # Test dfs for best model fit
    arg_JointFPM$data <- tmp_data
    
    test_dfs_call <- safely(function() do.call(test_dfs_JointFPM, arg_JointFPM))
    test_dfs      <- test_dfs_call()
    
    # Return with message on error
    if(!is.null(test_dfs$error)){
      
      # Save error message
      sink(paste0(path_sim_iterations, "error_iteration", i, ".txt"))
      
      cat("Error in test_dfs_JointFPM() fit:\n")
      print(test_dfs$error)
      
      sink()
      
      return(NULL)
      
    } else {
      
      dfs_test_results <- test_dfs$result
      
    }
    
    # Save best no dfs for best model fit
    best_fit <- dfs_test_results[which.min(dfs_test_results$AIC), ]
    
    # Update model call based on best dfs fit
    arg_JointFPM$df_ce <- best_fit$df_ce
    arg_JointFPM$df_re <- best_fit$df_re
    
    # Update best fitting tvc terms
    nam_tvc_ce_terms <- names(arg_JointFPM$tvc_ce_terms)
    nam_tvc_re_terms <- names(arg_JointFPM$tvc_re_terms)
    arg_JointFPM$tvc_ce_terms <- best_fit[, paste0("df_ce_", nam_tvc_ce_terms)]
    arg_JointFPM$tvc_re_terms <- best_fit[, paste0("df_re_", nam_tvc_re_terms)]
    arg_JointFPM$tvc_ce_terms <- setNames(as.list(arg_JointFPM$tvc_ce_terms),
                                          nam_tvc_ce_terms)
    arg_JointFPM$tvc_re_terms <- setNames(as.list(arg_JointFPM$tvc_re_terms),
                                          nam_tvc_re_terms)
    
    # Remove old variables
    arg_JointFPM$dfs_ce <- NULL
    arg_JointFPM$dfs_re <- NULL
    
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
    
    # Prediction call
    fit <- lapply(seq_along(predict_calls), function(j){
      
      predict_calls[[j]]$object <- model
      
      predict_call <- safely(
        function(){
          do.call(JointFPM:::predict.JointFPM, predict_calls[[j]])
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
      
      tmp <- cbind(predict_calls[[j]]$newdata, tmp)
      
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
  
}
