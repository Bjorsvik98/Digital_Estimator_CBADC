DESIGN_NAME=picorv32_top

SOURCES = $(wildcard src/*)
VERSION = $(shell basename $(shell dirname $(shell pwd)))

variableFile = sim/variables.txt
N_MAX = 8
K_MAX = 512
ifeq ($(wildcard $(variableFile)),)
	K = 256
	N = 6
	LUT_SIZE = 1
	WIDTH_COEFFICIENT = 32
	NUM_ADD_CLK = 4
	NUM_ADDER_STAGES = 6

	NUM_INPUTS_S3 = 1545
	NUM_INPUTS_S2 = 105
	NUM_INPUTS_S1 = 15

	NUM_S3_ADDERS = 103
	NUM_S2_ADDERS = 7
	NUM_S1_ADDERS = 1
	CLK_PERIOD = 1
# CLK_PERIOD_HALF = 0.5

else
	K = $(shell sed -n '1p' $(variableFile))
	N = $(shell sed -n '2p' $(variableFile))
	LUT_SIZE = $(shell sed -n '3p' $(variableFile))
	WIDTH_COEFFICIENT = $(shell sed -n '4p' $(variableFile))
	NUM_ADD_CLK = $(shell sed -n '5p' $(variableFile))
	NUM_ADDER_STAGES = $(shell sed -n '6p' $(variableFile))

	NUM_INPUTS_S3 = $(shell sed -n '7p' $(variableFile))
	NUM_INPUTS_S2 = $(shell sed -n '8p' $(variableFile))
	NUM_INPUTS_S1 = $(shell sed -n '9p' $(variableFile))

	NUM_S3_ADDERS = $(shell sed -n '10p' $(variableFile))
	NUM_S2_ADDERS = $(shell sed -n '11p' $(variableFile))
	NUM_S1_ADDERS = $(shell sed -n '12p' $(variableFile))

	CLK_PERIOD = $(shell sed -n '13p' $(VARIABLE_FILE))
	CLK_PERIOD_HALF = $(shell sed -n '14p' $(VARIABLE_FILE)) 

	N_MAX = $(shell sed -n '15p' $(VARIABLE_FILE))
	K_MAX = $(shell sed -n '16p' $(VARIABLE_FILE))
	
endif


.PHONY : clean
clean :
	rm -rf build innovus.log* innovus.cmd*

.PHONY : syn-dc
syn-dc : 
	cd syn/DC && dc_shell-xg-t -f dc_scripts/dc.tcl | tee syn.log
	@echo "VERSION = $(VERSION)"
	@echo "$(shell cat $(variableFile))"

ifeq ($(VERSION),acc_mcKvar)
	@echo "filesXcelium_N$(N)_K_MAX$(K).txt is created manualy"
else ifeq ($(VERSION),acc_mcNvar)
	@echo "filesXcelium_N_MAX$(N)_K$(K).txt is created manualy"
else ifeq ($(VERSION),acc_mc_paramKN_downsample)
	@echo "filesXcelium_N_MAX$(N)_K_MAX$(K).txt is created manualy"
else ifeq ($(VERSION),acc_mc_paramKN_downsample_new)
	@echo "filesXcelium_N_MAX$(N)_K_MAX$(K).txt is created manualy"
else
	echo ../../syn/DC/results_N$(N)_K$(K)/picorv32_top.mapped.v > syn/DC/filesXcelium_N$(N)_K$(K).txt
	echo ../../sim/src/tb_picorv32_gls.v >> syn/DC/filesXcelium_N$(N)_K$(K).txt
endif

.PHONY : pwr-dc
pwr-dc : 
ifeq ($(VERSION),acc_mcKvar)
	@echo "Starting Power estimate but with no check if version exists"
	cd pwr/results && primetime -f ../pwr.tcl | tee pwr_est-DC.log
else ifeq ($(VERSION),acc_mcNvar)
	@echo "Starting Power estimate but with no check if version exists"
	cd pwr/results && primetime -f ../pwr.tcl | tee pwr_est-DC.log
else ifeq ($(VERSION),acc_mc_paramKN_downsample)
	@echo "Starting Power estimate but with no check if version exists"
	cd pwr/results && primetime -f ../pwr.tcl | tee pwr_est-DC.log
else ifeq ($(VERSION),acc_mc_paramKN_downsample_new)
	@echo "Starting Power estimate but with no check if version exists"
	cd pwr/results && primetime -f ../pwr.tcl | tee pwr_est-DC.log
else
	@if [ -z "$(wildcard syn/DC/results_N${N}_K${K}/picorv32_top.mapped.v)" ]; then \
        echo "Error: There is no version with N=${N} and K=${K} synthesised yet"; \
        exit 1; \
    fi
		@echo "Starting power estimation on the version with N=${N} and K=${K}"
		cd pwr/results && primetime -f ../pwr.tcl | tee pwr_est-DC.log
endif
	
.PHONY : pwr_acc-dc
pwr_acc-dc : 
	@if [ -z "$(wildcard syn/DC/results_N${N}_K${K}/picorv32_top.mapped.v)" ]; then \
        echo "Error: There is no version with N=${N} and K=${K} synthesised yet"; \
        exit 1; \
    fi
		@echo "Starting power estimation on the version with N=${N} and K=${K}"
		cd pwr/results_acc && primetime -f ../pwr_acc.tcl | tee pwr_est_acc-DC.log




test:
	# @if [ -z "$(wildcard syn/DC/results_N${N}_K${K}/picorv32_top.mapped.v)" ]; then \
    #     echo "Error: There is no version with N=${N} and K=${K} synthesised yet"; \
    #     exit 1; \
    # fi
	# 	@echo "Starting power estimation on the version with N=${N} and K=${K}"
	@echo "VERSION = $(VERSION)"

