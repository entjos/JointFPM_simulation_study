#' Estimating Benchmark Estimates for the Mean Number of Events
#' 
#' `benchmarking` estimates the mean number of events using the non-parametric
#' estimate of E[N(t)] suggested by Cook and Lawless implemented in 
#' `JointFPM::mean_no()`. This estimate is approximating the true value in
#' large samples.
#' 
#' @param data 
#'  A `data.frame` with a dataset in stacked fromat, e.g.
#'  preprocessed with `stack_simreccomp()`.
#' 
#' @param by_var
#'  A `chacater` vector of a varaible used for identifying different stratas in
#'  the dataset.
#'  
#' @param arg_mean_no
#'  A `list` of argument passed to the `JointFPM::mean_no()` call.
#'  
#' @return 
#'  Returns a `data.table` with the following variables:
#'  \item{`t`}{Event times}
#'  \item{`expn`}{Estimated mean number of events at time `t`}
#'  \item{`x`}{Value of strata variable `x`}
#' 
#' @export

benchmarking <- function(data,
                         by_var,
                         arg_mean_no){
  
  # Load functions
  box::use(JointFPM[mean_no])
  
  # Estimate benchmarks as non-parametric E[N(t)]
  benchmark <- by(data,
                  data[[by_var]],
                  function(x){
                    
                    arg_mean_no$data    <- x
                    
                    do.call(mean_no,
                            arg_mean_no)
                    
                  })
  
  # Export benchmark
  benchmark[[1]]$x <- 0
  benchmark[[2]]$x <- 1
  
  # Combine lists into one dataframe
  benchmark <- rbind(benchmark[[1]], benchmark[[2]])
  
  return(benchmark)
  
}
