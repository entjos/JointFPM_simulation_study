#//////////////////////////////////////////////////////////////////////////////
# Project: Fertility in BEACOPP trt. HL survivros
# File: Make file
#
# Author: Joshua Entrop
#         Department of Medicine, Solna | Karolinska Institutet
#         171 77 Stockholm | Maria Aspmans gata 30A
#         +46 76 255 20 58 |
#         joshua.entrop@ki.se | ki.se
#
# Date last updated: 2021-01-18 (JE)
#
#//////////////////////////////////////////////////////////////////////////////

# 1. Prefix -------------------------------------------------------------------

# Define R call
# SHELL = <PATH TO SEHLL> This only needs to be specified in case you are on 
# system where you don't automatically have acess to the shell
REXE  = R.exe # Please replace R.exe with the full path to your R installation
              # if you don't have R on your system path


RCALL = $(REXE) --no-save CMD BATCH
# Define user functions directory
USER_FUNCTIONS  = ./scripts/user_functions

# Define all call
all: sim example

# 2. Simulatations ------------------------------------------------------------

# Define repositories
SIMULATIONS_DIR = ./scripts/simulations
SIMULATIONS_OBJ = ./scripts/simulations/log
 
sim: $(SIMULATIONS_OBJ)/1_simulate_data.out \
	 $(SIMULATIONS_OBJ)/2_get_benchmark.out \
	 $(SIMULATIONS_OBJ)/3_test_fpm_model_fit.out \
         $(SIMULATIONS_OBJ)/4_get_model_fit_estimates.out \
	 $(SIMULATIONS_OBJ)/5_bias_plot.out \
         $(SIMULATIONS_OBJ)/6_plots_of_benchmark_estimates.out

$(SIMULATIONS_OBJ)/1_simulate_data.out: $(SIMULATIONS_DIR)/1_simulate_data.R \
                                        $(USER_FUNCTIONS)/sim.R
	$(RCALL) $< $@

$(SIMULATIONS_OBJ)/2_get_benchmark.out: $(SIMULATIONS_DIR)/2_get_benchmark.R \
                                        $(SIMULATIONS_OBJ)/1_simulate_data.out \
                                        $(USER_FUNCTIONS)/benchmarking.R
	$(RCALL) $< $@

$(SIMULATIONS_OBJ)/3_test_fpm_model_fit.out: $(SIMULATIONS_DIR)/3_test_fpm_model_fit.R \
                                             $(SIMULATIONS_OBJ)/1_simulate_data.out \
                                             $(SIMULATIONS_OBJ)/2_get_benchmark.out \
                                             $(USER_FUNCTIONS)/model_test.R
	$(RCALL) $< $@

$(SIMULATIONS_OBJ)/4_get_model_fit_estimates.out: $(SIMULATIONS_DIR)/4_get_model_fit_estimates.R \
                                                  $(SIMULATIONS_OBJ)/3_test_fpm_model_fit.out
	$(RCALL) $< $@

$(SIMULATIONS_OBJ)/5_bias_plot.out: $(SIMULATIONS_DIR)/5_bias_plot.R \
			            $(SIMULATIONS_OBJ)/4_get_model_fit_estimates.out
	$(RCALL) $< $@

$(SIMULATIONS_OBJ)/6_plots_of_benchmark_estimates.out: $(SIMULATIONS_DIR)/6_plots_of_benchmark_estimates.R \
			                               $(SIMULATIONS_OBJ)/4_get_model_fit_estimates.out
	$(RCALL) $< $@

# 3. Example ------------------------------------------------------------------

# Define repositories
EXAMPLE_DIR = ./scripts/example
EXAMPLE_OBJ = ./scripts/example/log

example: $(EXAMPLE_OBJ)/1_analysis.out \
         $(EXAMPLE_OBJ)/2_graphs.out \
         $(EXAMPLE_OBJ)/3_appendix_graphs.out \

$(EXAMPLE_OBJ)/1_analysis.out: $(EXAMPLE_DIR)/1_analysis.R 
	$(RCALL) $< $@

$(EXAMPLE_OBJ)/2_graphs.out: $(EXAMPLE_DIR)/2_graphs.R \
	$(EXAMPLE_OBJ)/1_analysis.out 
	$(RCALL) $< $@

$(EXAMPLE_OBJ)/3_appendix_graphs.out: $(EXAMPLE_DIR)/3_appendix_graphs.R \
	$(EXAMPLE_OBJ)/1_analysis.out 
	$(RCALL) $< $@

#//////////////////////////////////////////////////////////////////////////////
# END OF MAKE-FILE