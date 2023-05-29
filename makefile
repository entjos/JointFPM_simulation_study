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
SHELL = ./rtools40/usr/bin/sh.exe # Shell call when running on the server
RCALL = "C:/PROGRA~1/R/R-41~1.2/bin/R.exe" --no-save CMD BATCH # R call if R is on the local path

# Define all call
all: sim

# Define repositories

SIMULATIONS_DIR = ./scripts/simulations
SIMULATIONS_OBJ = ./scripts/simulations/log
USER_FUNCTIONS  = ./scripts/user_functions

# 2. Simulatations ------------------------------------------------------------
 
sim: $(SIMULATIONS_OBJ)/1_simulate_data.out \
	 $(SIMULATIONS_OBJ)/2_get_benchmark.out \
	 $(SIMULATIONS_OBJ)/3_test_fpm_model_fit.out

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

#//////////////////////////////////////////////////////////////////////////////
# END OF MAKE-FILE