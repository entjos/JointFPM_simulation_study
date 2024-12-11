# PARAMETRIC ESTIMATION OF THE MEAN NUMBER OF EVENTS IN THE PRESENCE OF COMPETING RISKS

- Author: Joshua Entrop
- Email: joshua.entrop@ki.se

## Reproducing the analysis

System requirements:

- R version 4.3.3
- GNU make (optional)

This project includes a `makefile` and a `master.R` file, which both can be used to re-run the whole simulation study as well as the example analysis. The simulation is parallelised and will run on 10 cores once started, if not otherwise defined in the `.Rprofile` file. On my machine the whole program took around 5 days to finish. All datasets created in the simulation study are available as a `.zip` folder at [OSF](https://osf.io/k24gc).

The `makefile` and the `master.R` will re-create all tables and figures included in the manuscript. Running the make file requires you to install `GNU make` on your computer, if you haven't done so before. A Windows installation of `GNU make` can be found [here](https://gnuwin32.sourceforge.net/packages/make.htm) or as part of `Rtools`. All packages and package versions required for the analysis are defined in the `renv.lock` file. A list of the packages and their versions is also included at the end of the `README` file. In order to reproduce the analysis please follow the steps listed below.

   1. Open the `mean_no_events.Rproj` file. This will open a new RStudio session on your computer.
   2. Make sure that you are running R version 4.3.3
   3. If necessary install the package `{renv}`.
   4. Run the following command in your R console `renv::init()`and chose the following option in the prompt: "1: Restore the project from the lockfile."
   5. Reproduce the analysis. There are two options:
      1. The `GNU make` option: Open your shell or console in the project folder and run the following command `make all`. This will prompt make to re-run the whole analysis. Please be aware that re-running the whole simulation study might take several days. Running the makefile requires you to have R available on your system path. Otherwise, you can open the makefile using your favorite text editor and replace `R.exe` with the whole path to your `R.exe` file in the row starting with `REXE`, e.g. `RCALL = "C:/programmes/R/R-4.3.3/bin/R.exe"`.
      2. The `master.R` option: Open the `mean_no_events.Rproj` file. This will open a RStudio session. Within this session run the `master.R` file.

Don't hesitate to write me an email if you should have troubles re-running the analysis for this project.

## Reducing computation time

The computation time for the analysis can be reduced by changing the simulation parameters in the `.Rprofile` file. The file includes the following options:

```
options(n_cluster      = 11)    # Number of computational clusters
options(n_bootstraps   = 1900)  # Number of bootstraps per simulation iterations
options(size_bootstrap = 1000)  # Size of each bootstrap
options(n_obs_sim_data = 1e+06) # No. of observations included in the simulated datasets,
                                # which are used for the bootstrapping.
```
I once tried the following configuration, which substantially reduced the computation time. Please make sure to re-initiate your R session, once you made changes to the `.Rprofile` file.

```
options(n_cluster      = 11)    # Number of computational clusters
options(n_bootstraps   = 10)    # Number of bootstraps per simulation iterations
options(size_bootstrap = 1000)  # Size of each bootstrap
options(n_obs_sim_data = 1e+04) # No. of observations included in the simulated datasets,
                                # which are used for the bootstrapping.
```

## Data provenance

The example dataset `data/example/readmission.rds` used in the illustrative example was first published in the [`frailtypack`](https://cran.r-project.org/package=frailtypack) package for R under a GPL-2 license.

## Folder structure

```

(PROJECT ROOT)
+--- data/                                       This folder is available at https://osf.io/wt4m3
|    +--- example                                Includes datasets created by the example scripts
|    +--- sim_benchmark                          Includes datasets with benchmark estimates for each scenario
|    |                                           Obtained by running 
|    |                                              ./scripts/simulations/2_get_benchmarks
|    +--- sim_bias_estimates                     Includes the bias for each scenario
|    |                                           Obtained by running 
|    |                                              ./scripts/simulations/4_get_model_fit_estimates
|    +--- sim_data                               Includes simulated datasets for each scenario
|    |                                           Obtained by running 
|    |                                              ./scripts/simulations/1_simulate_data
|    +--- sim_iterations                         Includes datasets including the predicted estimate of interest 
|    |    |                                      each simulation iteration (1 to 1900)
|    |    +--- cum_haz                           Including prediction of the cumulative intensity function
|    |    +--- diff                              Including prediction of the difference in E[N(t)]
|    |    +--- ghosh_lin                         Including estimate of E[N(t)] using Ghosh and Lin's estimate
|    |    +--- mean_no                           Including estimate of E[N(t)] using the proposed parametric modelA                                                
+--- plots/                                      Includes plots used in the manuscript 
+--- scripts/
|    +--- example/
|    |    +--- log/                              Log flies for the last run of each script included in the folder
|    |    +--- 1_analysis.R                      Script for reproducing the analysis in the illustrative example
|    |    +--- 2_main_figures.R                  Script for creating the graphs in the illustrative example
|    |    +--- 3_1_appendix_figures_S1_S2.R      Script for creating graphs of the survival and intensity functions
|    |    +--- 3_2_appendix_figures_S3.R         Script for creating graphs ignoring the competing event
|    +--- simulations/
|    |    +---  log/                             Log flies for the last run of each script included in the folder
|    |    +--- 1_simulate_data.R                 Script for creating simulated datasets for each scenario
|    |    +--- 2_get_benchmark.R                 Script for getting benchmark estimates of the mean number 
|    |    |                                      of events for each scenario
|    |    +--- 3_1_test_fpm_model_fit_mean_no.R	 Script for iteratively predicting E[N(t)] (n=1900) from the parametric model
|    |    |                                      across the different scenarios (n=10)
|    |    +--- 3_3_test_fpm_model_fit_diff.R	    Script for iteratively predicting E[N(t|x=0)] - E[N(t|x=1)] (n=1900) 
|    |    |                                      from the parametric model across the different scenarios (n=10)
|    |    +--- 3_3_test_fpm_model_fit_cumhaz.R	 Script for iteratively predicting Lambda(t) (n=1900) 
|    |    |                                      from the parametric model across the different scenarios (n=10)
|    |    +--- 3_4_test_fpm_model_fit_cont_x.R	 Script for iteratively predicting E[N(t)] (n=1900) 
|    |    |                                      from the parametric model for a scenario including a continuous x
|    |    +--- 3_5_test_ghosh_lin.R              Script for iteratively predicting E[N(t)] (n=1900) from the non-parametric model
|    |    |                                      across the different scenarios (n=10)
|    |    +--- 4_get_model_fit_estimates.R       Script for calculate the bias and coverage for each scenario
|    |    +--- 5_bias_plot.R                     Script for create a plot of bias and coverage estimates 
|    |    |                                      across scenarios
|    |    +--- 6_plots_of_benchmark_estimates.R  Script for creating a plot of benchmark estimates 
|    |                                           across scenarios
|    +--- user_functions/
|    |    +--- __tests__/                        Folder including unit tests for user functions
|    |    +--- __init__.R                        Internal script for using the box package in R
|    |    +--- benchmarking.R                    See files for function descriptions of the user functions 
|    |    |                                      used in this project
|    |    +--- calculate_benchmark.R
|    |    +--- compute_bias.R
|    |    +--- create_sim_table.R
|    |    +--- ghosh_lin_test.R
|    |    +--- model_test.R                      
|    |    +--- plot_model_test.R
|    |    +--- sim.R
|    |    +--- simreccomp_adapted.R
|    |    +--- stack_simreccomp.R
|    |    +--- test_cum_haz_model.R
+--- tables/                                     LaTeX table of simulation results. These table need
|                                                some additional formating to be used in the final LaTeX document
+--- .gitignore                                  Gitignore file
+--- makefile                                    Makefile, that can be used to reproduce the simulation 
|                                                and example analysis
+--- mean_no_events.Rproj                        R-project file
+--- README.txt                                  Readme file
+--- renv.lock                                   Renv lock file specifying the packages and package version 
|                                                used in this project
+--- .Rprofile                                   Configuration file, that can be used to change the
|                                                simulation parameters
+--- deps.R                                      List of additional packages not recognised by renv
```                                                 

## Session Info

```
R version 4.3.3 (2024-02-29 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19045)

Matrix products: default


locale:
[1] LC_COLLATE=English_United Kingdom.utf8 
[2] LC_CTYPE=English_United Kingdom.utf8   
[3] LC_MONETARY=English_United Kingdom.utf8
[4] LC_NUMERIC=C                           
[5] LC_TIME=English_United Kingdom.utf8    

time zone: Europe/Stockholm
tzcode source: internal

attached base packages:
[1] splines   stats     graphics  grDevices datasets  utils    
[7] methods   base     

other attached packages:
 [1] purrr_1.0.2       magrittr_2.0.3    rlang_1.1.1      
 [4] rstpm2_1.6.2      patchwork_1.1.3   ggplot2_3.4.4    
 [7] fastDummies_1.7.3 survival_3.5-5    tidyr_1.3.0      
[10] dplyr_1.1.3       JointFPM_1.2.0   

loaded via a namespace (and not attached):
 [1] gtable_0.3.4        xfun_0.40           box_1.1.3          
 [4] lattice_0.21-8      numDeriv_2016.8-1.1 vctrs_0.6.3        
 [7] tools_4.3.3         generics_0.1.3      stats4_4.3.3       
[10] parallel_4.3.3      tibble_3.2.1        fansi_1.0.5        
[13] pkgconfig_2.0.3     Matrix_1.5-4.1      data.table_1.14.8  
[16] RColorBrewer_1.1-3  webshot_0.5.5       lifecycle_1.0.4    
[19] farver_2.1.1        compiler_4.3.3      stringr_1.5.1      
[22] textshaping_0.3.7   munsell_0.5.0       codetools_0.2-19   
[25] htmltools_0.5.6.1   rmutil_1.1.10       pillar_1.9.0       
[28] MASS_7.3-60.0.1     nlme_3.1-162        parallelly_1.36.0  
[31] tidyselect_1.2.0    bdsmatrix_1.3-6     rvest_1.0.3        
[34] digest_0.6.33       mvtnorm_1.2-3       stringi_1.7.12     
[37] future_1.33.0       listenv_0.9.0       labeling_0.4.3     
[40] fastmap_1.1.1       grid_4.3.3          colorspace_2.1-0   
[43] cli_3.6.1           utf8_1.2.3          future.apply_1.11.0
[46] withr_2.5.2         scales_1.2.1        rmarkdown_2.25     
[49] httr_1.4.7          globals_0.16.2      ggtext_0.1.2       
[52] deSolve_1.38        ragg_1.2.7          kableExtra_1.3.4   
[55] evaluate_0.23       knitr_1.44          bbmle_1.0.25       
[58] viridisLite_0.4.2   mgcv_1.8-42         gridtext_0.1.5     
[61] Rcpp_1.0.11         glue_1.6.2          xml2_1.3.5         
[64] renv_1.0.7          svglite_2.1.1       rstudioapi_0.15.0  
[67] R6_2.5.1            systemfonts_1.0.5 
```