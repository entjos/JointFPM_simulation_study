# PARAMETRIC ESTIMATION OF THE MEAN NUMBER OF EVENTS IN THE PRESENCE OF COMPETING RISKS

- Author: Joshua Entrop
- Email: joshua.entrop@ki.se

## Reproducing the analysis

System requirements:

- R version 4.3.1
- GNU make
- Microsoft Windows 10 

This project includes a `makefile` which can be used to re-run the whole simulation study as well as the example analysis. The simulation is parallelised and will run on 10 cores once started. On my machine the whole program took around 3 days to finish.

The `makefile` will re-create all tables and figures included in the manuscript. Running the make file requires you to install `GNU make` on your computer, if you haven't done so before. A Windows installation of `GNU make` can be found  [here](https://gnuwin32.sourceforge.net/packages/make.htm) or as part of `Rtools`. All packages and package versions required for the analysis are defined in the `renv.lock` file. In order to reproduce the analysis please follow the steps listed below.

   1. Open the `mean_no_events.Rproj` file. This will open a new RStudio session on your computer.
   2. Make sure that you are running R version 4.3.1
   3. If necessary install the package `{renv}`.
   4. Run the following command in your R console `renv::init()`and chose the following option in the prompt: "1: Restore the project from the lockfile."
   5. Open your shell or console in the project folder and run the following command `make all`. This will prompt make to re-run the whole analysis. Please be aware that re-running the whole simulation study might take several days. Running the makefile requires you to have R available on your system path. Otherwise you can open the makefile using your favorite text editor and replace `R.exe` with the whole path to your `R.exe` file in the row starting with `REXE`, e.g. `RCALL = "C:/programmes/R/R-4.3.1/bin/R.exe"`.

Don't hesitate to write me an email if you should have troubles re-running the analysis for this project.

## Folder structure

```

(PROJECT ROOT)
+--- data/
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
|    +--- sim_iterations                         Includes datasets including the predicted mean number of 
|                                                events from each simulation iteration (1 to 1900)
+--- plots/                                      Includes plots used in the manuscript 
+--- scripts/
|    +--- example/
|    |    +--- log/                              Log flies for the last run of each script included in the folder
|    |    +--- analysis.R                        Script for reproducing the analysis in the illustrative example
|    |    +--- graphs.R                          Script for creating the graphs in the illustrative example
|    +--- simulations/
|    |    +---  log/                             Log flies for the last run of each script included in the folder
|    |    +--- 1_simulate_data.R                 Script for creating simulated datasets for each scenario
|    |    +--- 2_get_benchmark.R                 Script for getting benchmark estimates of the mean number 
|    |    |                                      of events for each scenario
|    |    +--- 3_test_fpm_model_fit.R	         Script for iteratively fitting the parametric model of 
|    |    |                                      E[N(t)] to each simulated dataset
|    |    +--- 4_get_model_fit_estimates.R       Script for calculate the bias and coverage for each scenario
|    |    +--- 5_bias_plot.R                     Script for create a plot of bias and coverage estimates 
|    |    |                                      across scenarios
|    |    +--- 6_plots_of_benchmark_estimates.R  Script for creating a plot of benchmakr estimates 
|    |                                           across scenarios
|    +--- user_functions/
|    |    +--- __tests__/                        Folder including unit tests for user functions
|    |    +--- __init__.R                        Internal script for using the box package in R
|    |    +--- benchmarking.R                    See files for function descriptions of the user functions 
|    |    |                                      used in this project
|    |    +--- model_test.R                      
|    |    +--- plot_model_test.R
|    |    +--- sim.R
|    |    +--- simreccomp_adapted.R
|    |    +--- stack_simreccomp.R
+--- tables/
|    +--- simulations_results.tex                LaTeX table of simulation results. This table might need 
|                                                some additional formating to be used in the final LaTeX document
+--- .gitignore                                  Gitignore file
+--- makefile                                    Makefile, that can be used to reproduce the simulation 
|                                                and example analysis
+--- mean_no_events.Rproj                        R-project file
+--- README.txt                                  Readme file
+--- renv.lock                                   Renv lock file specifying the packages and package version 
                                                 used in this project
```                                                 
