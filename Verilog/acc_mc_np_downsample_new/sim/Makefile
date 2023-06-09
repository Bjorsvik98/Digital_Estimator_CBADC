
ifeq ($(GUI),1)
GUI_FLAG=-gui
endif

VOLTAGE ?= 1.10
TEMP ?= 25C
CORNER ?= tt
THRESHOLD ?= LR
TRACE_HEIGHT ?= 12
TYPE_SHORT ?= SC


VERSION = $(shell basename $(shell dirname $(shell pwd)))
VCD_FILE_PATH = /sim/anbjors/accelerator/$(VERSION).vcd

VARIABLE_FILE ?= variables.txt

ifeq ($(wildcard $(VARIABLE_FILE)),)
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
	CLK_PERIOD_HALF = 0.5

	N_MAX = 8
	K_MAX = 512
else
	K = $(shell sed -n '1p' $(VARIABLE_FILE))
	N = $(shell sed -n '2p' $(VARIABLE_FILE))
	LUT_SIZE = $(shell sed -n '3p' $(VARIABLE_FILE))
	WIDTH_COEFFICIENT = $(shell sed -n '4p' $(VARIABLE_FILE))
	NUM_ADD_CLK = $(shell sed -n '5p' $(VARIABLE_FILE))
	NUM_ADDER_STAGES = $(shell sed -n '6p' $(VARIABLE_FILE))

	NUM_INPUTS_S3 = $(shell sed -n '7p' $(VARIABLE_FILE))
	NUM_INPUTS_S2 = $(shell sed -n '8p' $(VARIABLE_FILE))
	NUM_INPUTS_S1 = $(shell sed -n '9p' $(VARIABLE_FILE))

	NUM_S3_ADDERS = $(shell sed -n '10p' $(VARIABLE_FILE))
	NUM_S2_ADDERS = $(shell sed -n '11p' $(VARIABLE_FILE))
	NUM_S1_ADDERS = $(shell sed -n '12p' $(VARIABLE_FILE))

	CLK_PERIOD = $(shell sed -n '13p' $(VARIABLE_FILE))
	CLK_PERIOD_HALF = $(shell sed -n '14p' $(VARIABLE_FILE)) 

	N_MAX = $(shell sed -n '15p' $(VARIABLE_FILE))
	K_MAX = $(shell sed -n '16p' $(VARIABLE_FILE))

endif

ifeq ($(VERSION),acc_mcKvar)
	SOURCE_FILE_NAME = filesXcelium_N${N}_K_MAX${K_MAX}.txt
else ifeq ($(VERSION),acc_mcNvar)
	SOURCE_FILE_NAME = filesXcelium_N_MAX${N_MAX}_K${K}.txt
else ifeq ($(VERSION),acc_mc_paramKN_downsample)
	SOURCE_FILE_NAME = filesXcelium_N_MAX${N_MAX}_K_MAX${K_MAX}.txt
else ifeq ($(VERSION),acc_mc_paramKN_downsample_new)
	SOURCE_FILE_NAME = filesXcelium_N_MAX${N_MAX}_K_MAX${K_MAX}.txt
else
	SOURCE_FILE_NAME = filesXcelium_N${N}_K${K}.txt
endif

test:
	@echo "N = $(N)"
	@echo "K = $(K)"
	@echo "N_MAX = $(N_MAX)"


.PHONY : run_sim check_exit gate_sim_xcelium clean copy_tb sim


run_sim :
	cd results && \
	xrun \
		-define CLOCK_PERIOD_HALF=$(CLK_PERIOD_HALF) \
		+define+N=$(N) \
		+define+K=$(K) \
		+define+LUT_SIZE=$(LUT_SIZE) \
		+define+WIDTH_COEFFICIENT=$(WIDTH_COEFFICIENT) \
		+define+NUM_ADD_CLK=$(NUM_ADD_CLK) \
		+define+NUM_ADDER_STAGES=$(NUM_ADDER_STAGES) \
		+define+NUM_INPUTS_S3=$(NUM_INPUTS_S3) \
		+define+NUM_INPUTS_S2=$(NUM_INPUTS_S2) \
		+define+NUM_INPUTS_S1=$(NUM_INPUTS_S1) \
		+define+NUM_S3_ADDERS=$(NUM_S3_ADDERS) \
		+define+NUM_S2_ADDERS=$(NUM_S2_ADDERS) \
		+define+NUM_S1_ADDERS=$(NUM_S1_ADDERS) \
		+define+N_MAX=$(N_MAX) \
		+define+K_MAX=$(K_MAX) \
		-f ../src/files.txt -access +r -top tb_picorv32 $(GUI_FLAG) -mess -input ../src/run-dc.tcl | tee deleteme.tmp
	
	
check_exit:
	@if tail -n 10 results/deleteme.tmp | grep -q "Finished simulation successfully."; then \
		echo ""; \
		echo "****** Info: Simulation on Leda finished ******"; \
	else \
		echo "ERROR: Simulation failed on Leda"; \
		exit 1; \
	fi

sim: run_sim check_exit
gate_sim: check_version copy_tb gate_sim_xcelium check_exit

gate_sim_fast: 
	$(MAKE) copy_tb FAST_MODE=fast 
	$(MAKE) gate_sim_xcelium check_exit



gate_sim_xcelium : 
	rm -rf results
	mkdir -p results
	@echo "Running gate level simulation on Xcelium with $(SOURCE_FILE_NAME)"
	cd results && xrun -v $(libfile1).v \
					$(libfile2).v \
					$(libfile3).v \
		-define CLOCK_PERIOD_HALF=$(CLK_PERIOD_HALF) \
		+define+N=$(N) \
		+define+K=$(K) \
		+define+LUT_SIZE=$(LUT_SIZE) \
		+define+WIDTH_COEFFICIENT=$(WIDTH_COEFFICIENT) \
		+define+NUM_ADD_CLK=$(NUM_ADD_CLK) \
		+define+NUM_ADDER_STAGES=$(NUM_ADDER_STAGES) \
		+define+NUM_INPUTS_S3=$(NUM_INPUTS_S3) \
		+define+NUM_INPUTS_S2=$(NUM_INPUTS_S2) \
		+define+NUM_INPUTS_S1=$(NUM_INPUTS_S1) \
		+define+NUM_S3_ADDERS=$(NUM_S3_ADDERS) \
		+define+NUM_S2_ADDERS=$(NUM_S2_ADDERS) \
		+define+NUM_S1_ADDERS=$(NUM_S1_ADDERS) \
		+define+N_MAX=$(N_MAX) \
		+define+K_MAX=$(K_MAX) \
		-f ../../syn/DC/$(SOURCE_FILE_NAME) -access +r -top tb_picorv32 -mess -input ../src/run-dc.tcl $(GUI_FLAG) \
		-timescale 1ns/1ps | tee deleteme.tmp
	@echo "Done"


FAST_MODE = 0
copy_tb:
ifeq ($(VERSION),acc_mcKvar)
	python copy_tb.py src/tb_picorv32.v src/tb_picorv32_gls.v ../syn/DC/results_N${N}_K_MAX${K_MAX}/picorv32_top.mapped.SAIF.namemap $(VCD_FILE_PATH) $(FAST_MODE)
else ifeq ($(VERSION),acc_mcNvar)
	python copy_tb.py src/tb_picorv32.v src/tb_picorv32_gls.v ../syn/DC/results_N_MAX${N_MAX}_K${K}/picorv32_top.mapped.SAIF.namemap $(VCD_FILE_PATH) $(FAST_MODE)
else ifeq ($(VERSION),acc_mc_paramKN_downsample)
	python copy_tb.py src/tb_picorv32.v src/tb_picorv32_gls.v ../syn/DC/results_N_MAX${N_MAX}_K_MAX${K_MAX}/picorv32_top.mapped.SAIF.namemap $(VCD_FILE_PATH) $(FAST_MODE)
else ifeq ($(VERSION),acc_mc_paramKN_downsample_new)
	python copy_tb.py src/tb_picorv32.v src/tb_picorv32_gls.v ../syn/DC/results_N_MAX${N_MAX}_K_MAX${K_MAX}/picorv32_top.mapped.SAIF.namemap $(VCD_FILE_PATH) $(FAST_MODE)
else
	python copy_tb.py src/tb_picorv32.v src/tb_picorv32_gls.v ../syn/DC/results_N${N}_K${K}/picorv32_top.mapped.SAIF.namemap $(VCD_FILE_PATH) $(FAST_MODE)
endif

clean :
	rm -rf xcelium.d

check_version:
	@echo "VERSION = $(VERSION)"
ifeq ($(VERSION),acc_mcKvar)
	@echo "No check if version exists"
	@echo "Starting gate_sim on the version with N=${N} and K=${K}"
else ifeq ($(VERSION),acc_mcNvar)
	@echo "No check if version exists"
	@echo "Starting gate_sim on the version with N=${N} and K=${K}"
else ifeq ($(VERSION),acc_mc_paramKN_downsample)
	@echo "No check if version exists"
	@echo "Starting gate_sim on the version with N=${N} and K=${K}"
else ifeq ($(VERSION),acc_mc_paramKN_downsample_new)
	@echo "No check if version exists"
	@echo "Starting gate_sim on the version with N=${N} and K=${K}"
else
	@if [ -z "$(wildcard ../syn/DC/results_N${N}_K${K}/picorv32_top.mapped.v)" ]; then \
        echo "Error: There is no version with N=${N} and K=${K} synthesised yet"; \
        exit 1; \
    fi
		@echo "Starting gate_sim on the version with N=${N} and K=${K}"
endif

# gen_file:
# ifeq ($(VERSION), acc_mcKvar)
# ifeq ($(N), 3)
# 	for k in 256 320 384 448 512; do \
# 		# if [ $$k -ne $(K) ]; then \
# 			echo ../../syn/DC/results_N${N}_K256/picorv32_top.mapped.v > ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 			echo ../../sim/src/tb_picorv32_gls.v >> ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 		# fi \
# 	done
# else ifeq ($(N), 4)
# 	for k in 256 320 384 448 512; do \
# 		if [ $$k -ne $(K) ]; then \
# 			echo ../../syn/DC/results_N${N}_K320/picorv32_top.mapped.v > ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 			echo ../../sim/src/tb_picorv32_gls.v >> ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 		fi \
# 	done
# else ifeq ($(N), 5)
# 	for k in 256 320 384 448 512; do \
# 		if [ $$k -ne $(K) ]; then \
# 			echo ../../syn/DC/results_N${N}_K320/picorv32_top.mapped.v > ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 			echo ../../sim/src/tb_picorv32_gls.v >> ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 		fi \
# 	done
# else ifeq ($(N), 6)
# 	for k in 256 320 384 448 512; do \
# 		if [ $$k -ne $(K) ]; then \
# 			echo ../../syn/DC/results_N${N}_K448/picorv32_top.mapped.v > ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 			echo ../../sim/src/tb_picorv32_gls.v >> ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 		fi \
# 	done
# else ifeq ($(N), 7)
# 	for k in 256 320 384 448 512; do \
# 		if [ $$k -ne $(K) ]; then \
# 			echo ../../syn/DC/results_N${N}_K448/picorv32_top.mapped.v > ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 			echo ../../sim/src/tb_picorv32_gls.v >> ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 		fi \
# 	done
# else ifeq ($(N), 8)
# 	for k in 256 320 384 448 512; do \
# 		if [ $$k -ne $(K) ]; then \
# 			echo ../../syn/DC/results_N${N}_K512/picorv32_top.mapped.v > ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 			echo ../../sim/src/tb_picorv32_gls.v >> ../syn/DC/filesXcelium_N${N}_K$$k.txt; \
# 		fi \
# 	done
# endif
# endif