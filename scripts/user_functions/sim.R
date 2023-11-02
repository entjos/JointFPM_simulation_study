#' Wrapper for `simrec::simreccomp()` for improving readability of the
#' simulation code.
#' 
#' `sim` calls `simrec::simreccomp()` with fixt parameters for the frailty 
#' terms and effects of X on the competing and recurrent event process.
#' 
#' @param n
#'  Number of observations to be simulated.
#'  
#' @param par_rec
#'  A `list` with the shape and scale parameter of the Weibull distribution for
#'  the recurrent event process. The argument requires a names list with the
#'  two elements shape and scale.
#'  
#' @param par_rec
#'  A `list` with the shape and scale parameter of the Weibull distribution for
#'  the competing event process. The argument requires a names list with the
#'  two elements shape and scale.
#' 
#' @export

sim <- function(n, par_rec, par_comp) {
  
  # Load modules
  box::use(usr = scripts/user_functions)
  
  # Run simulation
  temp <- usr$simreccomp_adapted(n,
                                 fu.min = 0,
                                 fu.max = 10,
                                 cens.prob = 0,
                                 dist.x = "binomial",
                                 par.x = 0.5,
                                 beta.xr = 1.2,
                                 beta.xc = 0.4,
                                 dist.zr = "gamma",
                                 par.zr = 1,
                                 dist.zc = "gamma",
                                 par.zc = 0,
                                 dist.rec = "weibull",
                                 par.rec = c(par_rec$scale, 
                                             par_rec$shape, 
                                             par_rec$scale_inc),
                                 dist.comp = "weibull",
                                 par.comp = c(par_comp$scale, 
                                              par_comp$shape),
                                 pfree = 1,
                                 dfree = 0.001)
  
  # Transform simulated dataset into stacked format
  out <- usr$stack_simreccomp(temp)
  
  return(out)
  
}