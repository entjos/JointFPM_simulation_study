#' #############################################################################
#' THIS IS A CHANGED VERSION OF THE FOLLOWING FILE
#' SOURCE: https://github.com/federicomarini/simrec
#' SOURCE AUTHOR: FREDERICO MARINI
#' SOURCE LICENSE: GPL>=2
#' 
#' CHANGED BY: JOSHUA PHILIPP ENTROP (JOSHUA.ENTROP@KI.SE)
#' CHANGED LAST: 2023/11/02
#' LICENSE OF ADAPTED FFUNCTION GPL>=2
#' CHANGES MADE TO THE ORIGINAL SCRIPT:
#'
#' The original version of the `simreccomp` function included in the `simrec`
#' packages allows to simulate recurrent event data from pre-defined
#' intensity functions for a competing and recurrent event. In the original 
#' version of the function, the intensity function of the recurrent event is 
#' assumed to be constant with regards to the number of previous events. 
#' This adapted verion of the `simrec` function allows to define the intensity 
#' function of the recurrent event process as a function of the number of 
#' previous events.
#' 
#' This function has been specifically adopted for this projects and is
#' not intended to be used outside this project.
#'
#' Changes made in this function affect the simulation of recurrent event times
#' from a Weibull distribution. The `par.rec` argument has been changed and
#' takes now a vector of 3 elements as input:
#'    - 1. element: Scale parameter of the requested Weibull distribution,
#'    - 2. element: Shape parameter of the requested Weibull distribution,
#'    - 3. element: A function of the number of previous events (`x`) defining
#'                  how the shape parameter changes based on the number of
#'                  previous events. NA if the shape parameter is constant
#'                  across all event occurences.
#'
#' All code blocks that have been changed in the adapted version have been
#' hilighted with the following statement:
#' 
#' # BEGIN OF CHANGES ----------------------------------------------------------
#'  <CHANGED CODE>
#' # END OF CHANGES ------------------------------------------------------------
#'
#' #############################################################################
#'
#' simreccomp
#'
#' This function allows simulation of time-to-event-data that follow a multistate-model
#' with recurrent events of one type and a competing event. The baseline hazard for the
#' cause-specific hazards are here functions of the total/calendar time.
#' To induce between-subject-heterogeneity a random
#' effect covariate (frailty term) can be incorporated for the recurrent and the competing event.
#' Data for the recurrent events of the individual \eqn{i} are generated
#' according to the cause-specific hazards \deqn{\lambda_{0r}(t)* Z_{ri} *exp(\beta_r^t X_i),}
#' where \eqn{X_i} defines the covariate vector and \eqn{\beta_r} the regression coefficient vector.
#' \eqn{\lambda_{0r}(t)} denotes the baseline hazard, being a function of the total/calendar
#' time \eqn{t} and
#' \eqn{Z_{ri}} denotes the frailty variables with \eqn{(Z_{ri})_i} iid with \eqn{E(Z_{ri})=1} and
#' \eqn{Var(Z_{ri})=\theta_r}. The parameter \eqn{\theta_r} describes the degree of
#' between-subject-heterogeneity for the recurrent event.
#' Analougously the competing event is generated according to the cause-specific hazard conditionally
#' on the frailty variable and covariates: \deqn{\lambda_{0c}(t)* Z_{ci} *exp(\beta_c^t X_i)}
#' Data output is in the counting process format.
#'
#' @param N          Number of individuals
#' @param fu.min     Minimum length of follow-up.
#' @param fu.max     Maximum length of follow-up. Individuals length of follow-up is
#' generated from a uniform distribution on
#' \code{[fu.min, fu.max]}. If \code{fu.min=fu.max}, then all individuals have a common
#' follow-up.
#' @param cens.prob  Gives the probability of being censored due to loss to follow-up before
#' \code{fu.max}. For a random set of individuals defined by a B(N,\code{cens.prob})-distribution,
#' the time to censoring is generated from a uniform
#' distribution on \code{[0, fu.max]}. Default is \code{cens.prob=0}, i.e. no censoring
#' due to loss to follow-up.
#' @param dist.x     Distribution of the covariate(s) \eqn{X}. If there is more than one covariate,
#' \code{dist.x} must be a vector of distributions with one entry for each covariate. Possible
#' values are \code{"binomial"} and \code{"normal"}, default is \code{dist.x="binomial"}.
#' @param par.x      Parameters of the covariate distribution(s). For \code{"binomial", par.x} is
#' the probability for \eqn{x=1}. For \code{"normal"}, \code{par.x=c(}\eqn{\mu, \sigma}\code{)}
#' where \eqn{\mu} is the mean and \eqn{\sigma} is the standard deviation of a normal distribution.
#' If one of the covariates is defined to be normally distributed, \code{par.x} must be a list,
#' e.g. \code{ dist.x <- c("binomial", "normal")} and \code{par.x  <- list(0.5, c(1,2))}.
#' Default is \code{par.x=0}, i.e. \eqn{x=0} for all individuals.
#' @param beta.xr  Regression coefficient(s) for the covariate(s) \eqn{x} corresponding to the
#' recurrent events. If there is more than one covariate,
#' \code{beta.xr} must be a vector of coefficients with one entry for each covariate.
#' \code{simreccomp} generates as many covariates as there are entries in \code{beta.xr}. Default is
#' \code{beta.xr=0}, corresponding to no effect of the covariate \eqn{x} on the recurrent events.
#' @param beta.xc Regression coefficient(s) for the covariate(s) \eqn{x} corresponding to the
#' competing event. If there is more than one covariate, \code{beta.xc}
#' must be a vector of coefficients with one entry for each covariate. Default is
#' \code{beta.xc=0}, corresponding to no effect of the covariate \eqn{x} on the competing event.
#' @param dist.zr     Distribution of the frailty variable \eqn{Z_r} for the recurent events with \eqn{E(Z_r)=1} and
#' \eqn{Var(Z_r)=\theta_r}. Possible values are \code{"gamma"} for a Gamma distributed frailty
#' and \code{"lognormal"} for a lognormal distributed frailty.
#' Default is \code{dist.zr="gamma"}.
#' @param par.zr Parameter \eqn{\theta_r} for the frailty distribution: this parameter gives
#' the variance of the frailty variable \eqn{Z_r}.
#' Default is \code{par.zr=0}, which causes \eqn{Z_r=1}, i.e. no frailty effect for the recurrent events.
#' @param dist.zc Distribution of the frailty variable \eqn{Z_c} for the competing event with \eqn{E(Z_c)=1} and
#' \eqn{Var(Z_c)=\theta_c}. Possible values are \code{"gamma"} for a Gamma distributed frailty
#' and \code{"lognormal"} for a lognormal distributed frailty.
#' Default is \code{dist.zc=NULL}.
#' @param par.zc Parameter \eqn{\theta_c} for the frailty distribution: this parameter gives
#' the variance of the frailty variable \eqn{Z_c}.
#' Default is \code{par.zc=NULL}.
#' @param a Alternatively, the frailty distribution for the competing event can be computed through the distribution
#' of the frailty variable \eqn{Z_r} by \eqn{Z_c=Z_r**a}.
#' Default is \code{a=NULL}.
#' @param dist.rec   Form of the baseline hazard function for the recurrent events.
#' Possible values are \code{"weibull"} or
#' \code{"gompertz"} or \code{"lognormal"} or \code{"step"}.
#' @param par.rec  Parameters for the distribution of the recurrent event data.
#' If \code{dist.rec="weibull"} the  hazard function is \deqn{\lambda_0(t)=\lambda*\nu* t^{\nu - 1},}
#' where \eqn{\lambda>0} is the scale and \eqn{\nu>0} is the shape parameter. Then
#' \code{par.rec=c(}\eqn{\lambda, \nu}\code{)}. A special case
#' of this is the exponential distribution for \eqn{\nu=1}.
#' If \code{dist.rec="gompertz"}, the hazard function is \deqn{\lambda_0(t)=\lambda*exp(\alpha t),}
#' where \eqn{\lambda>0} is the scale and \eqn{\alpha\in(-\infty,+\infty)} is the shape parameter.
#' Then \code{par.rec=c(}\eqn{\lambda, \alpha}\code{)}.
#' If \code{dist.rec="lognormal"}, the hazard function is
#' \deqn{\lambda_0(t)=[(1/(\sigma t))*\phi((ln(t)-\mu)/\sigma)]/[\Phi((-ln(t)-\mu)/\sigma)],}
#' where \eqn{\phi} is the probability density function and \eqn{\Phi} is the cumulative
#' distribution function of the standard normal distribution, \eqn{\mu\in(-\infty,+\infty)} is a
#' location parameter and \eqn{\sigma>0} is a shape parameter. Then \code{par.rec=c(}\eqn{\mu,\sigma}\code{)}.
#' Please note, that specifying \code{dist.rec="lognormal"} together with some covariates does not
#' specify the usual lognormal model (with covariates specified as effects on the parameters of the
#' lognormal distribution resulting in non-proportional hazards), but only defines the baseline
#' hazard and incorporates covariate effects using the proportional hazard assumption.
#' If \code{dist.rec="step"} the hazard function is \deqn{\lambda_0(t)=a, t<=t_1, and \lambda_0(t)=b, t>t_1}.
#' Then \code{par.rec=c(}\eqn{a,b,t_1}\code{)}.
#' @param dist.comp Form of the baseline hazard function for the competing event.
#' Possible values are \code{"weibull"} or
#' \code{"gompertz"} or \code{"lognormal"} or \code{"step"}       .
#' @param par.comp  Parameters for the distribution of the competing event data.
#' For more details see \code{par.rec}.
#' @param pfree Probability that after experiencing an event the individual is not at risk
#' for experiencing further events for a length of \code{dfree} time units.
#' Default is \code{pfree=0}.
#' @param dfree Length of the risk-free interval. Must be in the same time unit as \code{fu.max}.
#' Default is \code{dfree=0}, i.e. the individual is continously at risk for experiencing
#' events until end of follow-up.
#' @return The output is a data.frame consisting of the columns:
#' \item{id}{An integer number for identification of each individual}
#' \item{x}{or \code{x.V1, x.V2, ...} - depending on the covariate matrix. Contains the
#' randomly generated value of the covariate(s) \eqn{X} for each individual.}
#' \item{zr}{Contains the randomly generated value of the frailty variable \eqn{Z_r} for each individual.}
#' \item{zc}{Contains the randomly generated value of the frailty variable \eqn{Z_c} for each individual.}
#' \item{start}{The start of interval \code{[start, stop]}, when the individual
#' starts to be at risk for a next event.}
#' \item{stop}{The time of an event or censoring, i.e. the end of interval \code{[start, stop]}.}
#' \item{status}{An indicator of whether an event occured at time \code{stop} (\code{status=1}),
#' the individual is censored at time \code{stop} (\code{status=0}) or the competing event occured at time
#' \code{stop} (\code{status=2}).}
#' \item{fu}{Length of follow-up period \code{[0,fu]} for each individual.}
#' For each individual there are as many lines as it experiences events,
#' plus one line if being censored.
#' The data format corresponds to the counting process format.
#' @author Katharina Ingel, Stella Preussler, Antje Jahn-Eimermacher.
#' Institute of Medical Biostatistics, Epidemiology and Informatics (IMBEI),
#' University Medical Center of the Johannes Gutenberg-University Mainz, Germany
#' @seealso simrec
#' @export
#' @examples
#' ### Example:
#' ### A sample of 10 individuals
#'
#' N <- 10
#'
#' ### with a binomially distributed covariate and a standard normally distributed covariate
#' ### with regression coefficients of beta.xr=0.3 and beta.xr=0.2, respectively,
#' ### for the recurrent events,
#' ### as well as regression coefficients of beta.xc=0.5 and beta.xc=0.25, respectively,
#' ### for the competing event.
#'
#' dist.x <- c("binomial", "normal")
#' par.x <- list(0.5, c(0, 1))
#' beta.xr <- c(0.3, 0.2)
#' beta.xc <- c(0.5, 0.25)
#'
#' ### a gamma distributed frailty variable for the recurrent event with variance 0.25
#' ### and for the competing event with variance 0.3,
#'
#' dist.zr <- "gamma"
#' par.zr <- 0.25
#'
#' dist.zc <- "gamma"
#' par.zc <- 0.3
#'
#' ### alternatively the frailty variable for the competing event can be computed via a:
#' a <- 0.5
#'
#' ### Furthermore a Weibull-shaped baseline hazard for the recurrent event with shape parameter
#' ### lambda=1 and scale parameter nu=2,
#'
#' dist.rec <- "weibull"
#' par.rec <- c(1, 2)
#'
#' ### and a Weibull-shaped baseline hazard for the competing event with shape parameter lambda=1
#' ### and scale parameter nu=2
#'
#' dist.comp <- "weibull"
#' par.comp <- c(1, 2)
#'
#' ### Subjects are to be followed for two years with 20% of the subjects
#' ### being censored according to a uniformly distributed censoring time
#' ### within [0,2] (in years).
#'
#' fu.min <- 2
#' fu.max <- 2
#' cens.prob <- 0.2
#'
#' ### After each event a subject is not at risk for experiencing further events
#' ### for a period of 30 days with a probability of 50%.
#'
#' dfree <- 30 / 365
#' pfree <- 0.5
#'
#' simdata1 <- simreccomp(
#'   N = N, fu.min = fu.min, fu.max = fu.max, cens.prob = cens.prob,
#'   dist.x = dist.x, par.x = par.x, beta.xr = beta.xr, beta.xc = beta.xc,
#'   dist.zr = dist.zr, par.zr = par.zr, a = a,
#'   dist.rec = dist.rec, par.rec = par.rec, dist.comp = dist.comp, par.comp = par.comp,
#'   pfree = pfree, dfree = dfree
#' )
#'
#' simdata2 <- simreccomp(
#'   N = N, fu.min = fu.min, fu.max = fu.max, cens.prob = cens.prob,
#'   dist.x = dist.x, par.x = par.x, beta.xr = beta.xr, beta.xc = beta.xc,
#'   dist.zr = dist.zr, par.zr = par.zr, dist.zc = dist.zc, par.zc = par.zc,
#'   dist.rec = dist.rec, par.rec = par.rec, dist.comp = dist.comp, par.comp = par.comp,
#'   pfree = pfree, dfree = dfree
#' )
#'
#' simdata1
#' simdata2

simreccomp_adapted <- function(N,
                               fu.min,
                               fu.max,
                               cens.prob = 0,
                               dist.x = "binomial",
                               par.x = 0,
                               beta.xr = 0,
                               beta.xc = 0,
                               dist.zr = "gamma",
                               par.zr = 0,
                               a = NULL,
                               dist.zc = NULL,
                               par.zc = NULL,
                               dist.rec,
                               par.rec,
                               dist.comp,
                               par.comp,
                               pfree = 0,
                               dfree = 0) {
  
  # Load stats functions
  box::use(stats[...])
  
  if ((cens.prob > 0) & (fu.min != fu.max)) {
    warning(
      paste0(
        "The censoring scheme for parameters cens.prob greater than 0 and fu.min != fu.max is undefined. \n",
        "The package properly implements two censoring schemes depending on parameters cens.prob, fu.min, and fu.max: \n",
        "a) cens.prob>0 and fu.min=fu.max: follow-up ends at time fu.max with a probability of 1-cens.prob and follow-up ends uniformly distributed in [0, fu.max] with a probability of cens.prob. \n",
        "b) cens.prob=0 and fu.min<fu.max: follow-up ends uniformly distributed in [0,fu.max] for each subject."
      )
    )
  }
  
  ID <- c(1:N)
  # generating the follow-up  *****************************************************************
  # follow-up uniformly distributed in [fu.min, fu.max] if not censored
  # or uniformly distributed in [0, fu.max] if censored
  if (cens.prob < 0 || cens.prob > 1) {
    stop("cens.prob must be a probability between 0 and 1")
  }
  if (fu.min > fu.max || fu.min < 0) {
    stop("fu.min must be a non-negative value smaller or equal fu.max")
  }
  
  fu <- rbinom(N, 1, cens.prob) # 1 = censored
  nr.cens <- sum(fu)
  
  if (nr.cens == 0) { # nobody censored
    fu <- runif(N, min = fu.min, max = fu.max)
  } else {
    index.cens <- which(fu == 1)
    fu[-index.cens] <- runif((N - nr.cens), min = fu.min, max = fu.max)
    fu[index.cens] <- runif(nr.cens, min = 0, max = fu.max)
  }
  if (length(beta.xr) != length(dist.x)) {
    stop("dimensions of beta.xr and dist.x differ")
  }
  if (length(beta.xr) != length(par.x)) {
    stop("dimensions of beta.xr and par.x differ")
  }
  if (length(beta.xr) != length(beta.xc)) {
    stop("dimensions of beta.xr and beta.xc differ")
  }
  
  # generating the covariate-matrix x   *****************************************************
  nr.cov <- length(beta.xr) # number of covariates
  x <- matrix(0, N, nr.cov) # matrix with N lines and one column for each covariate
  
  for (i in 1:nr.cov) {
    dist.x[i] <- match.arg(dist.x[i], choices = c("binomial", "normal"))
    if (dist.x[i] == "binomial") {
      if (length(par.x[[i]]) != 1) {
        stop("par.x has wrong dimension")
      }
      if (par.x[[i]] < 0 || par.x[[i]] > 1) {
        stop("par.x must be a probability between 0 and 1 for the binomially distributed covariate")
      }
      x[, i] <- c(rbinom(N, 1, par.x[[i]]))
    } else { # normally distributed covariate
      if (length(par.x[[i]]) != 2) {
        stop("par.x has wrong dimension")
      }
      mu.x <- par.x[[i]][1]
      sigma.x <- par.x[[i]][2]
      x[, i] <- c(rnorm(N, mean = mu.x, sd = sigma.x))
    }
  }
  
  # generating the frailty variables zr and zc  ************************************************************
  if (length(a) != 0 & (length(dist.zc) != 0 | length(par.zc) != 0)) {
    stop("enter either a or dist.zc and par.zc")
  }
  zr <- rep(1, N)
  dist.zr <- match.arg(dist.zr, choices = c("gamma", "lognormal"))
  if (length(par.zr) != 1) {
    stop("par.zr has wrong dimension")
  }
  if (par.zr < 0) {
    stop("par.zr must be non-negative")
  }
  if (par.zr != 0) { # if par.zr=0 then frailty=1 for all
    if (dist.zr == "gamma") { # gamma-frailty
      aGamma.r <- 1 / par.zr
      zr <- rgamma(N, shape = aGamma.r, scale = 1 / aGamma.r)
    } else { # lognormal frailty
      mu.zr <- log(1 / sqrt(par.zr + 1))
      sigma.zr <- sqrt(log(par.zr + 1))
      zr <- exp(rnorm(N, mean = mu.zr, sd = sigma.zr))
    }
  }
  
  if (length(a) == 0) {
    if (length(dist.zc) == 0 | length(par.zc) == 0) {
      stop("enter either a or dist.zc and par.zc")
    }
    zc <- rep(1, N)
    dist.zc <- match.arg(dist.zc, choices = c("gamma", "lognormal"))
    if (length(par.zc) != 1) {
      stop("par.zc has wrong dimension")
    }
    if (par.zc < 0) {
      stop("par.zc must be non-negative")
    }
    if (par.zc != 0) { # if par.zc=0 then frailty=1 for all
      if (dist.zc == "gamma") { # gamma-frailty
        aGamma.c <- 1 / par.zc
        zc <- rgamma(N, shape = aGamma.c, scale = 1 / aGamma.c)
      } else { # lognormal frailty
        mu.zc <- log(1 / sqrt(par.zc + 1))
        sigma.zc <- sqrt(log(par.zc + 1))
        zc <- exp(rnorm(N, mean = mu.zc, sd = sigma.zc))
      }
    }
  } else {
    zc <- zr**a
  }
  # generating the recurrent event times *************************************************************
  # derivation of the distributional parameters for the recurrent event data
  dist.rec <- match.arg(dist.rec, choices = c("weibull", "lognormal", "gompertz", "step"))
  if (dist.rec == "lognormal") { # lognormal
    if (length(par.rec) != 2) {
      stop("par.rec has wrong dimension")
    }
    mu <- par.rec[1]
    sigma <- par.rec[2]
    if (any(beta.xr != 0)) {
      warning("lognormal together with covariates specified: this does not define the usual lognormal model! see help for details")
    }
  } else if (dist.rec == "weibull") { # weibull
    if (length(par.rec) != 3) {
      stop("par.rec has wrong dimension")
    }
    lambda <- par.rec[[1]]
    nu <- par.rec[[2]]
    f_lambda_inc <- par.rec[[3]]
  } else if (dist.rec == "gompertz") { # gompertz
    if (length(par.rec) != 2) {
      stop("par.rec has wrong dimension")
    }
    lambdag <- par.rec[1]
    alpha <- par.rec[2]
  } else if (dist.rec == "step") { # step
    if (length(par.rec) != 3) {
      stop("par.rec has wrong dimensions")
    }
    fc <- par.rec[1]
    sc <- par.rec[2]
    jump <- par.rec[3]
    jumpinv <- jump * fc
  }
  
  if (length(pfree) != 1) {
    stop("pfree has wrong dimension")
  }
  if (length(dfree) != 1) {
    stop("dfree has wrong dimension")
  }
  if (pfree < 0 || pfree > 1) {
    stop("pfree must be a probability between 0 and 1")
  }
  
  # initial step: simulation of N first event times
  # BEGIN OF CHANGES -----------------------------------------------------------  
  k <- 0 # initiate counter of occurrences
  # END OF CHANGES -------------------------------------------------------------
  U <- runif(N)
  Y <- (-1) * log(U) * exp((-1) * x %*% beta.xr) * 1 / zr
  if (dist.rec == "lognormal") { # lognormal
    t <- exp(qnorm(1 - exp((-1) * Y)) * sigma + mu)
  } else if (dist.rec == "weibull") { # weibull
    t <- ((lambda)^(-1) * Y)^(1 / nu)
  } else if (dist.rec == "gompertz") { # gompertz
    t <- (1 / alpha) * log((alpha / lambdag) * Y + 1)
  } else if (dist.rec == "step") { # step
    t <- rep(NA, N)
    indexTr1 <- which(Y <= jumpinv)
    if (length(indexTr1 > 0)) {
      t[indexTr1] <- Y[indexTr1] / fc
    }
    indexTr2 <- which(Y > jumpinv)
    if (length(indexTr2 > 0)) {
      t[indexTr2] <- (Y[indexTr2] - (fc - sc) * jump) / sc
    }
  }
  
  Tmat <- matrix(t, N, 1)
  dirty <- rep(TRUE, N)
  T1 <- NULL
  
  # recursive step: simulation of N subsequent event times
  while (any(dirty)) {
    # BEGIN OF CHANGES ---------------------------------------------------------
    k <- k + 1
    # END OF CHANGES -----------------------------------------------------------
    pd <- rbinom(N, 1, pfree)
    U <- runif(N)
    Y <- (-1) * log(U) * exp((-1) * x %*% beta.xr) * 1 / zr
    t1 <- t + pd * dfree
    if (dist.rec == "lognormal") { # lognormal
      t <- (t1 + exp(qnorm(1 - exp(log(1 - pnorm((log(t1) - mu) / sigma)) - Y)) * sigma + mu) - (t1))
    } else if (dist.rec == "weibull") { # weibull
      # BEGIN OF CHANGES -------------------------------------------------------
      if(is.function(f_lambda_inc)){
        lambda_inc <- do.call(f_lambda_inc, list("x" = k))
      } else {
        lambda_inc <- 1
      }
      t <- (t1 + ((Y + (lambda * lambda_inc) * (t1)^(nu)) / (lambda * lambda_inc))^(1 / nu) - (t1))
      # END OF CHANGES ---------------------------------------------------------
    } else if (dist.rec == "gompertz") { # gompertz
      t <- (t1 + ((1 / alpha) * log((alpha / lambdag) * Y + exp(alpha * t1))) - (t1))
    } else if (dist.rec == "step") { # step
      indexTr3 <- which((t1 <= jump) & (Y <= (jump - t1) * fc))
      if (length(indexTr3 > 0)) {
        t[indexTr3] <- t1[indexTr3] + Y[indexTr3] / fc
      }
      indexTr4 <- which((t1 <= jump) & (Y > (jump - t1) * fc))
      if (length(indexTr4 > 0)) {
        t[indexTr4] <- t1[indexTr4] + (Y[indexTr4] + (fc - sc) * (t1[indexTr4] - jump)) / sc
      }
      indexTr5 <- which(t1 > jump)
      if (length(indexTr5 > 0)) {
        t[indexTr5] <- t1[indexTr5] + Y[indexTr5] / sc
      }
    }
    T1 <- cbind(T1, ifelse(dirty, t1, NA))
    dirty <- ifelse(dirty, (t(t) < fu) & (t(t1) < fu), dirty)
    if(any(is.na(dirty))) browser()
    if (!any(dirty)) break
    Tmat <- cbind(Tmat, ifelse(dirty, t, NA))
  }
  
  # comp. events simulation ***********************************************************
  # derivation of the distributional parameters for the comp. events
  dist.comp <- match.arg(dist.comp, choices = c("weibull", "lognormal", "gompertz", "step"))
  
  if (dist.comp == "lognormal") { # lognormal
    if (length(par.comp) != 2) {
      stop("par.comp has wrong dimension")
    }
    mu2 <- par.comp[1]
    sigma2 <- par.comp[2]
  } else if (dist.comp == "weibull") { # weibull
    if (length(par.comp) != 2) {
      stop("par.comp has wrong dimension")
    }
    lambda2 <- par.comp[1]
    nu2 <- par.comp[2]
  } else if (dist.comp == "gompertz") { # gompertz
    if (length(par.comp) != 2) {
      stop("par.comp has wrong dimension")
    }
    lambdag2 <- par.comp[1]
    alpha2 <- par.comp[2]
  } else if (dist.comp == "step") { # step
    if (length(par.comp) != 3) {
      stop("par.comp has wrong dimensions")
    }
    fc2 <- par.comp[1]
    sc2 <- par.comp[2]
    jump2 <- par.comp[3]
    jumpinv2 <- jump2 * fc2
  }
  
  # simulation of N comp. events
  U2 <- runif(N)
  Y2 <- (-1) * log(U2) * exp((-1) * x %*% beta.xc) * 1 / zc
  if (dist.comp == "lognormal") { # lognormal
    t2 <- exp(qnorm(1 - exp((-1) * Y2)) * sigma2 + mu2)
  } else if (dist.comp == "weibull") { # weibull
    t2 <- ((lambda2)^(-1) * Y2)^(1 / nu2)
  } else if (dist.comp == "gompertz") { # gompertz
    t2 <- (1 / alpha2) * log((alpha2 / lambdag2) * Y2 + 1)
  } else if (dist.comp == "step") { # step
    t2 <- rep(NA, N)
    indexTr12 <- which(Y2 <= jumpinv2)
    if (length(indexTr12 > 0)) {
      t2[indexTr12] <- Y2[indexTr12] / fc2
    }
    indexTr22 <- which(Y2 > jumpinv2)
    if (length(indexTr22 > 0)) {
      t2[indexTr22] <- (Y2[indexTr22] - (fc2 - sc2) * jump2) / sc2
    }
  }
  T2 <- matrix(t2, N, 1)
  comp.event <- as.vector(t(T2))
  comp.event <- comp.event[!is.na(comp.event)]
  
  # **************************************************************************************
  
  # start times
  start.t <- cbind(0, T1)
  start.t <- as.vector(t(start.t))
  tab.start.t <- start.t[!is.na(start.t)]
  
  # stop times
  stop.t <- cbind(Tmat, NA)
  d <- apply(!is.na(Tmat), 1, sum) # number of events per individual
  f <- d + 1
  for (i in 1:N) {
    stop.t[i, f[i]] <- fu[i]
  }
  stop.t <- as.vector(t(stop.t))
  tab.stop.t <- stop.t[!is.na(stop.t)]
  
  # deriving the censoring indicator variable and truncating stop times that are larger than FU
  e <- NULL
  for (i in 1:N) {
    e <- cbind(e, t(rep(1, d[i])), 0)
  }
  
  tab.ID <- rep(ID, f)
  tab.X <- x[rep(1:nrow(x), f), ]
  tab.zr <- rep(zr, f)
  tab.zc <- rep(zc, f)
  tab.Fu <- rep(fu, f)
  tab.comp.event <- rep(comp.event, f)
  
  w <- tab.start.t > tab.stop.t
  # v <- rep(0,length(w))
  # for (i in 1:length(w)){
  #  if (w[i]) {v[i-1] <- 1}
  # }
  
  l <- tab.stop.t > tab.Fu
  for (i in 1:length(l)) {
    if (l[i]) {
      tab.stop.t[i] <- tab.Fu[i]
      e[i] <- 0
    }
  }
  
  s <- tab.start.t > tab.comp.event # create vector which remembers the times which are after the comp.event and therefore do not exist.
  # r<-rep(0,length(s))
  # for (i in 1:length(s)){
  #  if (s[i]) {r[i-1]<-1}
  # }
  
  m <- tab.stop.t > tab.comp.event # modify status vector, whenever the stop.time is greater than the comp. event it leads to status 2
  for (i in 1:length(m)) {
    if (m[i]) {
      tab.stop.t[i] <- tab.comp.event[i]
      e[i] <- 2
    }
  }
  
  tab <- cbind(
    tab.ID, tab.X, tab.zr, tab.zc, tab.start.t, tab.stop.t,
    t(e),
    pmin(tab.Fu, tab.comp.event),
    tab.comp.event
  )
  
  for (i in 1:length(w)) {
    if (w[i]) {
      tab[i, ] <- rep(NA, nr.cov + 8)
    } # delete times, which are after the FU and therefore don't exist
  }
  for (i in 1:length(w)) {
    if (s[i]) {
      tab[i, ] <- rep(NA, nr.cov + 8)
    } # delete times, which are after the comp. event and therefore don't exist
  }
  
  tab <- data.frame(id = tab[, 1], x = tab[, 2:(nr.cov + 1)], zr = tab[, (nr.cov + 2)], zc = tab[, (nr.cov + 3)], start = tab[, (nr.cov + 4)], stop = tab[, (nr.cov + 5)], status = tab[, (nr.cov + 6)], fu = tab[, (nr.cov + 7)])
  tab <- na.omit(tab)
  
  return(tab)
}

# Unit tests
if (is.null(box::name())) {
  box::use(./`__tests__`)
}