#' Testing effect of ignoring the competing event in Multiple 
#' Bootstrapp Iterations
#' 
#' `test_cum_haz_model` estimates the cumulativ hazard using a flexible
#' parametric model in samples of the simulated datasets.
#' 
#' @param data
#'  A `data.frame` with a dataset in stacked fromat, e.g.
#'  preprocessed with `stack_simreccomp()`.
#'  
#' @param path_sim_iterations
#'  A `character` vector specifying the path to the file in which the
#'  predicted values of E[N(t)] are to be stored.
#'  
#' @param arg_stpm2
#'  A `list` of argument passed to the `rstpm2::stpm2()` call.
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
#'  None. `test_cum_haz_model` stores the estimates for each iteration in 
#'  `path_sim_iterations/iteration<n>.csv`.
#' 
#' @export

test_cum_haz_model <- function(data,
                               path_sim_iterations,
                               arg_stpm2,
                               cluster_var,
                               n_cluster,
                               n_bootstrapps,
                               size_bootstrapp,
                               times,
                               ci_fit){
  
  # Load packages
  box::use(ft = future,
           future.apply[future_lapply])
  
  # Obtain list of unique observations
  unique_ids <- unique(data[[cluster_var]])
  
  # Set up clusters
  ft$plan(strategy = "multisession",
          workers  = 10)
  
  # Run model tests on cluster
  
  future_lapply(1:n_bootstrapps, 
                future.seed = 97235,
                FUN = function(i){
    
    # Load packages
    box::use(rstpm2[...],
             survival[...],
             data.table[...],
             purrr[safely, quietly],
             entjosR[...])
    
    # Sample from whole dataset
    tmp_data <- data[data[[cluster_var]] %in% sample(unique_ids, 
                                                 size_bootstrapp, 
                                                 replace = FALSE),]
    
    # Test dfs for best model fit
    arg_stpm2$data <- tmp_data
    
    test_dfs_call <- safely(function() do.call(fpm_test_dfs, arg_stpm2))
    test_dfs      <- test_dfs_call()
    
    # Return with message on error
    if(!is.null(test_dfs$error)){
      
      # Save error message
      sink(paste0(path_sim_iterations, "error_iteration", i, ".txt"))
      
      cat("Error in fpm_test_dfs() fit:\n")
      print(test_dfs$error)
      
      sink()
      
      return(NULL)
      
    } else {
      
      dfs_test_results <- test_dfs$result
      
    }
    
    # Save best no dfs for best model fit
    best_fit <- dfs_test_results[which.min(dfs_test_results$aic), ]
    
    # Update model call based on best dfs fit
    best_fit_specification <- list(formula =  arg_stpm2$formula, 
                                   data    = tmp_data, 
                                   df      = best_fit$df_bh)
    
    # Fit model with best fitting dfs
    model_call <- safely(function() do.call(stpm2, best_fit_specification))
    model_test <- model_call()
    
    # Return with message on error
    if(!is.null(model_test$error)){
      
      # Save error message
      sink(paste0(path_sim_iterations, "error_iteration", i, ".txt"))
      
      cat("Error in stpm2() fit:\n")
      print(model_test$error)
      
      sink()
      
      return(NULL)
      
    } else {
      
      model <- model_test$result
      
    }
    
    # Predict mean no. for treated and untreated
    fit <- lapply(0:1, function(j){
      
      predict_call <- quietly(
        function(){
          
          est <- predict(model,
                         type        = "cumhaz",
                         newdata     = data.frame(x = j, stop = times),
                         se.fit      = ci_fit)
          
        })
      
      predict_test <- predict_call()
      
      # Return with message on error
      if(!identical(predict_test$warnings, character(0))){
        
        # Save error message
        sink(paste0(path_sim_iterations, "error_iteration", i, ".txt"),
             append = TRUE)
        
        cat("Warning in predict.stpm2() in subet x = ", j, ":\n")
        print(predict_test$warnings)
        
        sink()
        
        return(NULL)
        
      } else if(ci_fit){
        
        tmp <- data.frame(stop = times,
                          fit  = predict_test$result$Estimate,
                          lci  = predict_test$result$lower,
                          uci  = predict_test$result$upper)
        
      } else {
        
        tmp <- data.frame(stop = times,
                          fit  = predict_test$result$Estimate)
        
      }
      
      tmp$x <- j
      
      return(tmp)
      
    }) |> rbindlist()
    
    if(nrow(fit) == 6){
      # Save data as .csv file only if no warning was issued by predict.stpm2()
      
      fit$iteration <- i
      fit$df        <- best_fit$df_bh
      
      fwrite(fit,
             paste0(path_sim_iterations, "iteration", i, ".csv"))
      
      cat("saved iteration", i)
    }
    
  })
  
}
