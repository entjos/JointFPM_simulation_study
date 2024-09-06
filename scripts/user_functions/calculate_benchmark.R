calculate_benchmark <- function(i, newdata){
  scenarios <- readRDS("./data/sim_data/scenarios.RData")
  
  lambda0_rec  <- scenarios$scale_rec[[i]]
  lambda0_comp <- scenarios$scale_comp[[i]]
  
  shape_rec  <- scenarios$shape_rec[[i]]
  shape_comp <- scenarios$shape_comp[[i]]
  
  beta_rec  <- scenarios$beta.xr[[i]]
  beta_comp <- scenarios$beta.xc[[i]]
  
  # define intensity function
  lambda_rec <- \(x){
    lambda0_rec * exp(x %*% beta_rec)
  }
  
  lambda_comp <- \(x){
    lambda0_comp * exp(x %*% beta_comp)
  }
  
  haz    <- \(t, x) {
    shape_rec * lambda_rec(x) * t ^ (shape_rec -1)
  }
  
  surv <- \(t, x){
    exp(-lambda_comp(x) * t ^ shape_comp)
  }
  
  int <- \(t, x) rmutil::int(\(t) {surv(t, x) * haz(t, x)}, 0, t)
  Haz <- \(t, x) -log(surv(t, x))
  
  newdata$target <-  mapply(int, newdata$stop, newdata$x)
  
  return(newdata)
  
}