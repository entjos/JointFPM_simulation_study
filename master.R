################################################################################
# Project: Parametric Estimation of The Mean Number of Events
# 
# Title: Master script
# 
# Author: Joshua Entrop
#
# Notes: This master script can be used in case one cannot use the MAKE file.
#        Note that the MAKE file is the recommended way of reproducing the
#        analysis.
#
#        The simulation parameters can be changed in the options included in the
#        .Rprofile file. The options that can be changed include:
#           - the number of Monte Carlo iterations
#           - the size of each random draw,
#           - the size of the simulated datasets, and 
#           - the number of computational cluster used.
# 
################################################################################


# PART 1 SIMULATION STUDY ------------------------------------------------------

#   1.1 Create Simulation Data ================================================= 
source("scripts/simulations/1_simulate_data.R")

#   1.2 Get Benchmark Estimates ================================================
source("scripts/simulations/2_get_benchmark.R")

#   1.3 Main Analysis ==========================================================
source("scripts/simulations/3_1_test_fpm_model_fit_mean_no.R")
source("scripts/simulations/3_2_test_fpm_model_fit_diff.R")

#   1.4 Supplementary Analyses =================================================
source("scripts/simulations/3_3_test_fpm_model_fit_cumhaz.R")
source("scripts/simulations/3_4_test_fpm_model_fit_cont_x.R")
source("scripts/simulations/3_5_test_ghosh_lin.R")

#   1.5 Report Model Performance Measures ======================================
source("scripts/simulations/4_create_tables.R")         # Tables 3, S1-S4
source("scripts/simulations/5_create_bias_plot.R")      # Figure 3
source("scripts/simulations/6_create_benchmark_plot.R") # Figure 2

# PART 2 EXAMPLE ---------------------------------------------------------------

source("scripts/example/1_analysis.R")
source("scripts/example/2_main_figures.R")              # Figure 4
source("scripts/example/3_1_appendix_figures_S1_S2.R")  # Figures S1, S2
source("scripts/example/3_2_appendix_figure_S3.R")      # Figure S3

# //////////////////////////////////////////////////////////////////////////////
# END OF R-SCRIPT