box::use(../simreccomp_adapted)

impl = attr(simreccomp_adapted, 'namespace')

test_that("Adapted simreccomp function works similar to old version",{
  expect_true({
    
    box::use(simrec)
    
    set.seed(12987)
    new <- simreccomp_adapted(10,
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
                              par.rec = c(0.1, 
                                          1.4, 
                                          NA),
                              dist.comp = "weibull",
                              par.comp = c(0.02, 
                                           0.05),
                              pfree = 1,
                              dfree = 0.001)
    
    set.seed(12987)
    old <- simrec$simreccomp(10,
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
                             par.rec = c(0.1, 
                                         1.4),
                             dist.comp = "weibull",
                             par.comp = c(0.02, 
                                          0.05),
                             pfree = 1,
                             dfree = 0.001)
    
    all.equal(new, old)
  })
})

