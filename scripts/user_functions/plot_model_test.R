#' Plotting Comparisons of The Predicted E[N(t)] Against The Benchmark
#' 
#' `plot_model_test` creates a plot of the benchmark of E[N(t)] and the
#' predicted E[N(t)] in different simulation iterations.
#' 
#' @param path_benchmark
#'  A `character` vector specifying the path to the file in which the
#'  benchmark estimates are stored.
#'  
#' @param path_model_test
#'  A `character` vector specifying the path to the file in which the
#'  predicted values of E[N(t)] are stored.
#'  
#' @return 
#'  A new graph of the benchmark estimate and the predicted estimates.
#'  
#' @export

plot_model_test <- function(path_benchmark,
                            path_model_test){
  
  # Read benchmark estimates
  benchmark <- data.table::fread(path_benchmark)
  
  # Open new graphic device
  graphics::plot.new()
  graphics::plot.window(xlim = c(min(benchmark$t), 
                                 max(benchmark$t)),
                        ylim = c(min(benchmark$expn) - min(benchmark$expn) * 0.3,
                                 max(benchmark$expn) + max(benchmark$expn) * 0.3))
  
  # Add axes
  graphics::axis(1)
  graphics::axis(2)
  
  # Print all predicted estimates of E[N(t)] in different iterations
  lapply(dir(path_model_test,
             full.names = TRUE), function(x){
               
               data <- data.table::fread(x)
               
               graphics::lines(data$stop[data$x == 0],
                               data$fit [data$x == 0],
                               col = scales::alpha("gray", 0.8))
               
               graphics::lines(data$stop[data$x == 1],
                               data$fit [data$x == 1],
                               col = scales::alpha("gray", 0.8))
               
             })
  
  # Add benchmark estimates to the plot
  graphics::lines(benchmark$t   [benchmark$x == 0],
                  benchmark$expn[benchmark$x == 0],
                  type = "s",
                  lwd  = 2)
  
  graphics::lines(benchmark$t   [benchmark$x == 1],
                  benchmark$expn[benchmark$x == 1],
                  type = "s",
                  lwd  = 2)
}
