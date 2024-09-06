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
#' @param dist.x
#'  A list of distribution for Xses
#'  
#' @param par.x
#'  A list of distribution parameters for Xses
#' 
#' @param beta.xr
#'  A vector with the effects of X on the recurrent event process
#' @param beta.xr
#'  A vector with the effects of X on the competing event process
#' 
#' @export

sim <- function(n, par_rec, 
                par_comp, 
                dist.x,
                par.x ,
                beta.xr,
                beta.xc) {
  
  # Load modules
  box::use(usr = scripts/user_functions)
  
  # Run simulation
  temp <- usr$simreccomp_adapted(n,
                                 fu.min = 0,
                                 fu.max = 10,
                                 cens.prob = 0,
                                 dist.x = dist.x,
                                 par.x = par.x,
                                 beta.xr = beta.xr,
                                 beta.xc = beta.xc,
                                 dist.zr = "gamma",
                                 par.zr = 0,
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