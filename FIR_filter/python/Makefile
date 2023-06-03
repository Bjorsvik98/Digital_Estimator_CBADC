### Variables ###
N = 4
sizeBits = 11
K1 = 256
FPB = 22 # FixedPointBits
o = 2
LUT_size = 1
NUM_ADD_CLK = 4
MCA_NUM_ADDITIONS = 16
CLK_PERIOD = 1
DSR = 1

OSR = 16
ENOB = 12
BW = 20000000

K_MAX = 0
N_MAX = 0


#Ibex, Pico or Pico_accelerated
CORE_NAME=Pico_accelerated
#Vcs, Verilator or Xrun, Xrun_gate
SIMULATOR=Xrun
#DC, genus
SYNTHESIS=DC
#picorv_single_core, acc_single_cycle, acc_single_cycle_config, acc_multi_cycle, acc_multi_cycle_ds, acc_mcds_param
# VERSION=acc_mc_np
VERSION=acc_mc_np


SINGLE_H_VERSIONS = acc_single_cycle acc_single_cycle_config picorv_single_core acc_mcds_param_sm acc_mc_np acc_mcKvar acc_mcNvar acc_mcds_sm acc_mc_np_rcwKN acc_mc_np_downsample 
SINGLE_H_VERSIONS += acc_mc_np_rcw_downsample acc_mc_np_rcwKN_downsample acc_mc_np_lut acc_mc_np_lut4_downsample acc_mc_paramKN_downsample acc_mc_paramKN_downsample_new acc_mc_np_downsample_new acc_mc_np_lut6_downsample
# make gate_sim VERSION=acc_mc_np_rcw FPB=20 N=4 K1=128 DSR=1 > log.log && \
# make pwr VERSION=acc_mc_np_rcw FPB=20 N=4 K1=128 DSR=1 >> log.log



# make syn VERSION=acc_mc_np_rcwKN N=7 K1=224 DSR=1 OSR=8 FPB=21 > log.log && \
# make gate_sim VERSION=acc_mc_np_rcwKN N=7 K1=224 DSR=1 OSR=8 FPB=21 >> log.log && \
# make pwr VERSION=acc_mc_np_rcwKN N=7 K1=224 DSR=1 OSR=8 FPB=21 >> log.log && \
# make sim VERSION=acc_multi_cycle >> log.log && \
# make sim VERSION=acc_mc_sm >> log.log && \
# make sim VERSION=acc_mc_np >> log.log

# make syn gate_sim pwr VERSION=acc_mc_np_downsample N=7 K1=224 OSR=8 DSR=8 FPB=23 sizeBits=11 \
# make syn gate_sim pwr VERSION=acc_mc_np_rcw_downsample N=7 K1=224 OSR=8 DSR=8 FPB=23 sizeBits=11 \
# make syn gate_sim pwr VERSION=acc_mc_np_rcwKN_downsample N=7 K1=224 OSR=8 DSR=8 FPB=23 sizeBits=11

### DO NOT EDIT BELOW THIS LINE ###

DOUBLE_H = 1
ifeq ($(filter $(VERSION), $(SINGLE_H_VERSIONS)), $(VERSION))
    DOUBLE_H = 0
endif


CLK_PERIOD_HALF = $(shell printf "%f" $$(echo "$(CLK_PERIOD)/2" | bc -l))
K2 = $(K1)
K = $(shell echo $$(( $(K1) + $(K2) )))
fractionBits = $(shell echo $$(( $(FPB) - 0 )))
SIM_CMD = sim

ADD_DEFINE_FILE = "../c_files/include/add_to_define.txt"
ADD_DEFINE_FILE_NEW = "accelerator_versions/$(VERSION)/c_files/include/add_to_define.txt"


# Set the number of adder stages
define check_i
	ifeq ($(shell echo $(shell echo $(K) \* $(N) | bc) \> $(shell echo "scale=0; $(NUM_ADD_CLK)^$(1)" | bc) | bc),1)
		NUM_ADDER_STAGES = $(shell echo $$(( $(1) + 1 )))
	endif
endef
I_VALUES := 1 2 3 4 5 6
$(foreach i,$(I_VALUES),$(eval $(call check_i,$(i))))
PIPELINE_DELAY = $(shell echo $$(( $(NUM_ADDER_STAGES) - 2 )))

FILTER_INFO = "The filter parameters is: N = $(N), K1 = K2 = $(K1), K = $(K) LUT_size = $(LUT_size), and number of samples calculated is 2^$(sizeBits)"

# LUT_STATE = 0
# DSR_OLD = $(shell printf "%.0f" $(shell echo "$(LUT_size)/$(N)" | bc -l))
# ifeq ($(DSR_OLD), 0)
# 	LUT_STATE = 0
# endif

eta2 = 0


IBEX_STATE=0
ifeq ($(CORE_NAME), Ibex)
	IBEX_STATE=1
endif


OUTPUT_HEX_FILE = ../hex_files/resultHex$(CORE_NAME)$(SIMULATOR).txt
OUTPUT_HEX_FILE_NEW = accelerator_versions/$(VERSION)/hex_files/resultHex$(CORE_NAME)$(SIMULATOR).txt

FLAGS = -s $(sizeBits) -K1 $(K1) -K2 $(K2) -N $(N) --DSR $(DSR) --bits $(FPB) --fraction $(fractionBits) -o $(o) --LUT $(LUT_size) --coreName $(CORE_NAME) --ibex_state $(IBEX_STATE) --pipeline_delay $(PIPELINE_DELAY) --OSR $(OSR) --ENOB $(ENOB) --BW $(BW) --N_MAX $(N_MAX) --K_MAX $(K_MAX) --eta2 $(eta2)

DATE_TIME = $(shell date +"%Y-%m-%d_%H-%M-%S")

LOG_FILE_NAME = _N_$(N)_K_$(K)
LOG_FILE_K1_NAME = _N$(N)_K1_$(K1)

ifeq ($(VERSION),acc_mcKvar)
	LOG_FILE_NAME = _K_MAX$(K_MAX)_N_$(N)_K_$(K)
	LOG_FILE_K1_NAME = _K_MAX$(K_MAX)_N$(N)_K1_$(K1)
else ifeq ($(VERSION),acc_mcNvar)
	LOG_FILE_NAME = _N_MAX$(N_MAX)_N_$(N)_K_$(K)
	LOG_FILE_K1_NAME = _N_MAX$(N_MAX)_N$(N)_K1_$(K1)
else ifeq ($(VERSION),acc_mcKvar_downsample)
	LOG_FILE_NAME = _K_MAX$(K_MAX)_N_MAX$(N_MAX)_N_$(N)_K_$(K)
	LOG_FILE_K1_NAME = _K_MAX$(K_MAX)_N_MAX$(N_MAX)_N$(N)_K1_$(K1)
else ifeq ($(VERSION),acc_mc_paramKN_downsample)
	LOG_FILE_NAME = _K_MAX$(K_MAX)_N_MAX$(N_MAX)_N_$(N)_K_$(K)
	LOG_FILE_K1_NAME = _K_MAX$(K_MAX)_N_MAX$(N_MAX)_N$(N)_K1_$(K1)
else ifeq ($(VERSION),acc_mc_paramKN_downsample_new)
	LOG_FILE_NAME = _K_MAX$(K_MAX)_N_MAX$(N_MAX)_N_$(N)_K_$(K)
	LOG_FILE_K1_NAME = _K_MAX$(K_MAX)_N_MAX$(N_MAX)_N$(N)_K1_$(K1)
else ifeq ($(VERSION),acc_mc_paramKN)
	LOG_FILE_NAME = _K_MAX$(K_MAX)_N_MAX$(N_MAX)_N_$(N)_K_$(K)
	LOG_FILE_K1_NAME = _K_MAX$(K_MAX)_N_MAX$(N_MAX)_N$(N)_K1_$(K1)
endif


minTest:
	@echo "LOG_FILE_NAME: $(LOG_FILE_NAME)"

### COMMANDS TO USE ###
.PHONY: all
all: variable run_local plot 

.PHONY: verify
verify: convertHex plot 

.PHONY: sim
sim: print
ifeq ($(VERSION), picorv_single_core)
	@echo "Info: Starting simulation of $(VERSION)"
	# $(MAKE) variable $(CORE_NAME)_$(SIMULATOR) convertHex plot 

	$(MAKE) variable c_hex save_variables
	scp ../hex_files/fir32.hex anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/src/memimage.hex
ifeq ($(SIM_CMD), sim)
	scp varibles.txt anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/variables.txt
endif

	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/Master/ && make $(SIM_CMD) VERSION=$(VERSION)"
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/out.hex $(OUTPUT_HEX_FILE)
	mkdir -p ../simulationResults/$(CORE_NAME)/old_runs/

	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/old_runs/$(SIMULATOR)_$(DATE_TIME)$(LOG_FILE_NAME).log
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/$(VERSION)$(LOG_FILE_NAME).log
	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/old_runs/$(SIMULATOR)_$(DATE_TIME)$(LOG_FILE_NAME).log
	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/$(VERSION)$(LOG_FILE_NAME).log
	$(MAKE) verify


else

ifeq ($(DOUBLE_H), 1)
	@echo "DOUBLEH 1" > $(ADD_DEFINE_FILE)
endif
	$(MAKE) variable 
	@echo "DOUBLEH 0" > $(ADD_DEFINE_FILE)
	$(MAKE) c_hex_accelerated save_variables
	@echo "Info: Starting simulation of $(VERSION)"
	scp ../hex_files/fir_accelerated32.hex anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/src/memimage.hex
# ifeq ($(SIM_CMD), sim)
	scp varibles.txt anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/variables.txt
# endif
	# ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/$(VERSION)/sim/ && make $(SIM_CMD)"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/Master/ && make $(SIM_CMD) VERSION=$(VERSION)"
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/out.hex $(OUTPUT_HEX_FILE)
	mkdir -p ../simulationResults/$(CORE_NAME)/old_runs
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/$(VERSION)$(LOG_FILE_NAME).log
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/old_runs/$(SIMULATOR)_$(DATE_TIME)$(LOG_FILE_NAME).log
	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/$(VERSION)$(LOG_FILE_NAME).log
	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/old_runs/$(SIMULATOR)_$(DATE_TIME)$(LOG_FILE_NAME).log
	$(MAKE) verify
endif


.PHONY: sim_new
sim_new: 
	mkdir -p accelerator_versions/$(VERSION)/python
	cp Makefile accelerator_versions/$(VERSION)/python/Makefile
	cp make_variables.py accelerator_versions/$(VERSION)/python/
	cp convertHex.py accelerator_versions/$(VERSION)/python/
	cp makePlot.py accelerator_versions/$(VERSION)/python/

	cp -r functions accelerator_versions/$(VERSION)/python/
	cp -r ../c_files accelerator_versions/$(VERSION)/
	mkdir -p accelerator_versions/$(VERSION)/hex_files
	cp ../hex_files/hex8tohex32.py accelerator_versions/$(VERSION)/hex_files/hex8tohex32.py
	cp gen_param.py accelerator_versions/$(VERSION)/python/gen_param.py

ifeq ($(DOUBLE_H), 1)
	@echo "DOUBLEH 1" > $(ADD_DEFINE_FILE_NEW)
endif
	make -C accelerator_versions/$(VERSION)/python variable
	@echo "DOUBLEH 0" > $(ADD_DEFINE_FILE_NEW)
	make -C accelerator_versions/$(VERSION)/python c_hex_accelerated save_variables
	@echo "Info: Starting simulation of $(VERSION)"
	scp accelerator_versions/$(VERSION)/hex_files/fir_accelerated32.hex anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/src/memimage.hex
	scp accelerator_versions/$(VERSION)/python/varibles.txt anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/variables.txt
	
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/Master/ && make $(SIM_CMD) VERSION=$(VERSION)"
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/out.hex $(OUTPUT_HEX_FILE_NEW)
	mkdir -p accelerator_versions/$(VERSION)/simulationResults/$(CORE_NAME)/old_runs
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/xrun.log accelerator_versions/$(VERSION)/simulationResults/$(CORE_NAME)/old_runs/$(SIMULATOR)_$(DATE_TIME)$(LOG_FILE_NAME).log
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/xrun.log accelerator_versions/$(VERSION)/simulationResults/$(CORE_NAME)/$(VERSION)$(LOG_FILE_NAME).log
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/$(VERSION)$(LOG_FILE_NAME).log
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/old_runs/$(SIMULATOR)_$(DATE_TIME)$(LOG_FILE_NAME).log
	echo $(FILTER_INFO) >> accelerator_versions/$(VERSION)/simulationResults/$(CORE_NAME)/old_runs/$(SIMULATOR)_$(DATE_TIME)$(LOG_FILE_NAME).log
	echo $(FILTER_INFO) >> accelerator_versions/$(VERSION)/simulationResults/$(CORE_NAME)/$(VERSION)$(LOG_FILE_NAME).log
	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/$(VERSION)$(LOG_FILE_NAME).log
	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/old_runs/$(SIMULATOR)_$(DATE_TIME)$(LOG_FILE_NAME).log
	make -C accelerator_versions/$(VERSION)/python verify
	mkdir -p ../SNR_Result/old_runs
	cp accelerator_versions/$(VERSION)/SNR_Result/$(VERSION)$(LOG_FILE_K1_NAME).log ../SNR_Result/$(VERSION)$(LOG_FILE_K1_NAME).log
	cp accelerator_versions/$(VERSION)/SNR_Result/$(VERSION)$(LOG_FILE_K1_NAME).log ../SNR_Result/old_runs/$(DATE_TIME)$(LOG_FILE_K1_NAME)_$(VERSION).log


plot_new:
	make -C accelerator_versions/$(VERSION)/python verify

.PHONY: gate_sim
gate_sim: print
	$(MAKE) sim SIM_CMD=gate_sim

.PHONY: gate_sim_new
gate_sim_new: print
	$(MAKE) sim_new SIM_CMD=gate_sim

.PHONY: gate_sim_fast
gate_sim_fast: print
	$(MAKE) sim SIM_CMD=gate_sim_fast

.PHONY: syn
syn: save_variables
ifeq ($(VERSION), picorv_single_core)
	# $(MAKE) copy_hex_file 
	$(MAKE) syn_$(CORE_NAME)_$(SYNTHESIS)
else
	@echo "Info: running synthesis of pico"
	scp varibles.txt anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/sim/variables.txt
	# ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/$(VERSION) && make syn"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/Master && make syn VERSION=$(VERSION)"
	mkdir -p ../synthesisResults/pico/old_runs/$(DATE_TIME)_$(VERSION)$(LOG_FILE_NAME)
	mkdir -p ../synthesisResults/pico/$(VERSION)$(LOG_FILE_NAME)
	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/syn/DC/reports/*  ../synthesisResults/pico/old_runs/$(DATE_TIME)_$(VERSION)$(LOG_FILE_NAME)
	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/syn/DC/reports/*  ../synthesisResults/pico/$(VERSION)$(LOG_FILE_NAME)
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/syn/DC/syn.log  ../synthesisResults/pico/old_runs/$(DATE_TIME)_$(VERSION)$(LOG_FILE_NAME)/
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/syn/DC/syn.log  ../synthesisResults/pico/$(VERSION)$(LOG_FILE_NAME)/
# ifeq ($(VERSION), acc_mcKvar)
# 	for k in 256 320 384 448 512; do \
# 		if [ $$k -ne $(K) ]; then \
# 			ssh anbjors@leda.tele.ntnu.no "cp -R /home/anbjors/pro/$(VERSION)/syn/DC/results_N$(N)_K$(K)/. /home/anbjors/pro/$(VERSION)/syn/DC/results_N$(N)_K$$k"; \
# 			ssh anbjors@leda.tele.ntnu.no "cp -R /home/anbjors/pro/$(VERSION)/syn/DC/filesXcelium_N${N}_K${K}.txt /home/anbjors/pro/$(VERSION)/syn/DC/filesXcelium_N${N}_K$$k.txt"; \
# 		fi \
# 	done
# endif
# ifeq ($(VERSION), acc_mcNvar)
# 	for n in 3 4 5 6 7 8; do \
# 		if [ $$n -ne $(N) ]; then \
# 			ssh anbjors@leda.tele.ntnu.no "cp -R /home/anbjors/pro/$(VERSION)/syn/DC/results_N$(N)_K$(K)/. /home/anbjors/pro/$(VERSION)/syn/DC/results_N$$n_K$(K)"; \
# 			ssh anbjors@leda.tele.ntnu.no "cp -R /home/anbjors/pro/$(VERSION)/syn/DC/filesXcelium_N${N}_K${K}.txt /home/anbjors/pro/$(VERSION)/syn/DC/filesXcelium_N$$n_K$(K).txt"; \
# 		fi \
# 	done
# endif

endif



.PHONY: pwr
pwr: 
ifeq ($(VERSION), picorv_single_core)
	$(MAKE) pwr_$(CORE_NAME)
else
	@echo "Info: running power analysis of pico"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/Master && make pwr VERSION=$(VERSION)"
	mkdir -p ../powerResults/pico/$(VERSION)$(LOG_FILE_NAME)
	mkdir -p ../powerResults/pico/old_runs/$(DATE_TIME)_$(VERSION)$(LOG_FILE_NAME)
	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/pwr/results/*.log ../powerResults/pico/$(VERSION)$(LOG_FILE_NAME)
	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/pwr/results/*.log ../powerResults/pico/old_runs/$(DATE_TIME)_$(VERSION)$(LOG_FILE_NAME)
endif

.PHONY: pwr_acc
pwr_acc:
ifeq ($(VERSION), picorv_single_core)
	$(MAKE) pwr_$(CORE_NAME)
else
	@echo "Info: running power analysis of pico"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/Master && make pwr_acc VERSION=$(VERSION)"
# mkdir -p ../powerResults/pico/$(VERSION)$(LOG_FILE_NAME)
# mkdir -p ../powerResults/pico/old_runs/$(DATE_TIME)_$(VERSION)$(LOG_FILE_NAME)
# scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/pwr/results/*.log ../powerResults/pico/$(VERSION)$(LOG_FILE_NAME)
# scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/$(VERSION)/pwr/results/*.log ../powerResults/pico/old_runs/$(DATE_TIME)_$(VERSION)$(LOG_FILE_NAME)
endif

print: 
	@echo "running simulation of $(CORE_NAME) using $(SIMULATOR) and core version = $(VERSION)"
	@echo "NUM_ADDER_STAGES = $(NUM_ADDER_STAGES)"


### HOW TO RUN THE SIMULATIONS ###

.PHONY: dat
dat:
	python3 makeDat.py $(FLAGS)

.PHONY: variable
variable: #dat
	@echo "Info: making variables"
	python3 make_variables.py $(FLAGS)

.PHONY: run_local
run_local:
	make -C ../c_files run_local USE_MYSTDLIB=0 -B

.PHONY: c_hex
c_hex:
	# make -C ../c_files clean
	make -C ../c_files fir.hex -B

.PHONY: c_hex_accelerated
c_hex_accelerated:
	# make -C ../c_files clean
	make -C ../c_files fir_accelerated.hex -B


.PHONY: plot
plot: run_local
	mkdir -p ../SNR_Result/old_runs
	python3 makePlot.py $(FLAGS) | tee ../SNR_Result/old_runs/$(DATE_TIME)$(LOG_FILE_K1_NAME)_$(VERSION).log
	cp ../SNR_Result/old_runs/$(DATE_TIME)$(LOG_FILE_K1_NAME)_$(VERSION).log ../SNR_Result/$(VERSION)$(LOG_FILE_K1_NAME).log

.PHONY: plot2
plot2: 
	python3 makePlot2.py $(FLAGS)  

.PHONY: check
check:
	@echo "Error: This option is removed, the functionality is moved to plot"
	# python3 checkIfEqual.py $(FLAGS)

.PHONY: convertHex
convertHex: 
	python3 convertHex.py $(CORE_NAME) $(SIMULATOR) $(sizeBits) $(OUTPUT_HEX_FILE) $(PIPELINE_DELAY)

.PHONY: copy_c_file
copy_c_file:
	cp ../c_files/fir.c /home/sp22/ibex/examples/sw/simple_system/hello_test/hello_test.c
	scp ../c_files/fir.c anbjors@leda.tele.ntnu.no:/home/anbjors/pro/ibex/examples/sw/simple_system/FIR/FIR.c

.PHONY: copy_hex_file
copy_hex_file: variable c_hex_accelerated save_variables
	scp ../hex_files/fir_accelerated32.hex anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_picorv_single_core/sim/src/memimage.hex
	scp varibles.txt anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_picorv_single_core/sim/variables.txt



### DIFFERENT SIMULATION OPTIONS ###

.PHONY: Pico_Xrun
Pico_Xrun: c_hex save_variables
	@echo "Info: copying hex file to pico"
	scp ../hex_files/fir32.hex anbjors@leda.tele.ntnu.no:/home/anbjors/pro/picorv_single_core/sim/src/memimage.hex
	@echo "Info: running simulation of pico"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/picorv_single_core/sim/ && make sim"
	@echo "Info: copying result to local folder"
	@echo "Info: The output from the simulation is in the file: $(OUTPUT_HEX_FILE)"
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/picorv_single_core/sim/results/out.hex $(OUTPUT_HEX_FILE)
	mkdir -p ../simulationResults/$(CORE_NAME)
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/picorv_single_core/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log
	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log

# .PHONY: Pico_accelerated_Xrun
# Pico_accelerated_Xrun: c_hex_accelerated save_variables
# 	@echo "Info: copying hex file to pico"
# 	scp ../hex_files/fir_accelerated32.hex anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_single_cycle/sim/src/memimage.hex
# 	@echo "Info: running simulation of pico"
# 	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/acc_single_cycle/sim/ && make sim N=$(N) K=$(K) LUT_SIZE=$(LUT_size) WIDTH_COEFFICIENTS=$(FPB) NUM_ADD_CLK=$(NUM_ADD_CLK) NUM_ADDER_STAGES=$(NUM_ADDER_STAGES)"
# 	@echo "\nInfo: Copying result to local folder"
# 	@echo "Info: The output from the simulation is in the file: $(OUTPUT_HEX_FILE)"
# 	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_single_cycle/sim/results/out.hex $(OUTPUT_HEX_FILE)
# 	python3 ../hex_files/removeZeros.py 101 150 $(OUTPUT_HEX_FILE) ##### Remove the lines containing zeros from 101 to 150 #####

# 	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_single_cycle/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log
# 	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log

# .PHONY: Pico_accelerated_Xrun_gate
# Pico_accelerated_Xrun_gate: c_hex_accelerated save_variables
# 	@echo "Info: copying hex file to pico"
# 	scp ../hex_files/fir_accelerated32.hex anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_single_cycle/sim/src/memimage.hex
# 	@echo "Info: running simulation of pico"
# 	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/acc_single_cycle/sim/ && make gate_sim_xcelium"
# 	@echo "\nInfo: Copying result to local folder"
# 	@echo "Info: The output from the simulation is in the file: $(OUTPUT_HEX_FILE)"
# 	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_single_cycle/sim/results/out.hex $(OUTPUT_HEX_FILE)
# 	python3 ../hex_files/removeZeros.py 101 150 $(OUTPUT_HEX_FILE) ##### Remove the lines containing zeros from 101 to 150 #####

# 	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_single_cycle/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log
# 	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log

.PHONY: Pico_Xrun_gate
Pico_Xrun_gate: c_hex
	@echo "Info: copying hex file to pico"
	scp ../hex_files/fir32.hex anbjors@leda.tele.ntnu.no:/home/anbjors/pro/picorv_single_core/sim/src/memimage.hex
	@echo "Info: running gate level simulation of pico"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/picorv_single_core/sim/ && make gate_sim_xcelium"
	@echo "Info: copying result to local folder"
	@echo "Info: The output from the simulation is in the file: $(OUTPUT_HEX_FILE)"
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/picorv_single_core/sim/results/out.hex $(OUTPUT_HEX_FILE)
	mkdir -p ../simulationResults/$(CORE_NAME)
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/picorv_single_core/sim/results/xrun.log ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log
	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log

.PHONY: Ibex_Verilator
Ibex_Verilator: #simulation on ibex
	@echo "Info: copying hex file to ibex"
	cp ../c_files/include/coefficients.h /home/sp22/ibex/examples/sw/simple_system/hello_test/include/
	@echo "Info: Making ibex executable"
	cd /home/sp22/ibex/examples/sw/simple_system/hello_test && make clean && make 
	@echo "Info: running simulation of ibex"
	cd ../../../ibex && ./build/lowrisc_ibex_ibex_simple_system_0/sim-verilator/Vibex_simple_system [-t] --meminit=ram,/home/sp22/ibex/examples/sw/simple_system/hello_test/hello_test.elf
	@echo "Info: copying result to local folder"
	cp /home/sp22/ibex/ibex_simple_system.log $(OUTPUT_HEX_FILE)


.PHONY: Ibex_Vcs
Ibex_Vcs: #simulation of ibex using vcs on Leda
	@echo "Info: copying hex file to ibex"
	scp ../c_files/include/coefficients.h anbjors@leda.tele.ntnu.no:/home/anbjors/pro/ibex/examples/sw/simple_system/FIR/include
	@echo "Info: Making ibex executable and running simulation of ibex"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/ibex/ && make clean && make sim-VCS"
	@echo "Info: copying result to local folder"
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/ibex/ibex_simple_system.log $(OUTPUT_HEX_FILE)
	mkdir -p ../simulationResults/$(CORE_NAME)
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/ibex/Ibex_VCS.log ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log
	echo $(FILTER_INFO) >> ../simulationResults/$(CORE_NAME)/$(SIMULATOR)_$(DATE_TIME).log


### SYNTHESIS OPTIONS ###
.PHONY: syn_Ibex_DC
syn_Ibex_DC:
	@echo "Info: running synthesis of ibex"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/ibex && make syn-DC"
	mkdir -p ../synthesisResults/ibex
	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/ibex/syn/out/latest/reports  ../synthesisResults/ibex/
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/ibex/syn/out/logs/log_latest.log  ../synthesisResults/ibex/reports
	cp -r ../synthesisResults/ibex/reports ../synthesisResults/ibex/$(DATE_TIME)
	
.PHONY: syn_Pico_DC
syn_Pico_DC:
	@echo "Info: running synthesis of pico"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/picorv_single_core && make syn-dc"
	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/picorv_single_core/syn/DC/reports  ../synthesisResults/pico/
	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/picorv_single_core/syn/DC/syn.log  ../synthesisResults/pico/
	cp -r ../synthesisResults/pico/reports ../synthesisResults/pico/$(DATE_TIME)

# .PHONY: syn_Pico_accelerated_DC
# syn_Pico_accelerated_DC:
# 	@echo "Info: running synthesis of pico"
# 	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/acc_single_cycle && make syn-dc"
# 	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_single_cycle/syn/DC/reports  ../synthesisResults/pico/
# 	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_single_cycle/syn/DC/syn.log  ../synthesisResults/pico/
# 	cp -r ../synthesisResults/pico/reports ../synthesisResults/pico/$(DATE_TIME)

# .PHONY: syn_doubleH_DC
# syn_doubleH_DC:
# 	@echo "Info: running synthesis of pico"
# 	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/acc_multi_cycle && make syn-dc"
# 	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_multi_cycle/syn/DC/reports  ../synthesisResults/pico/acc_multi_cycle
# 	scp anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_multi_cycle/syn/DC/syn.log  ../synthesisResults/pico/acc_multi_cycle
# 	cp -r ../synthesisResults/pico/reports ../synthesisResults/pico/$(DATE_TIME)





### POWER ANALYSIS OPTIONS ###

.PHONY: pwr_Pico
pwr_Pico:
	@echo "Info: running power analysis of pico"
	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/picorv_single_core && make pwr-dc"
	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/picorv_single_core/pwr/results/*.log ../powerResults/pico/
	mkdir -p ../powerResults/pico/$(DATE_TIME)
	cp -r ../powerResults/pico/*.log ../powerResults/pico/$(DATE_TIME)

# .PHONY: pwr_Pico_accelerated
# pwr_Pico_accelerated:
# 	@echo "Info: running power analysis of pico"
# 	ssh anbjors@leda.tele.ntnu.no "cd /home/anbjors/pro/acc_single_cycle && make pwr-dc"
# 	scp -r anbjors@leda.tele.ntnu.no:/home/anbjors/pro/acc_single_cycle/pwr/results/*.log ../powerResults/pico/
# 	# mkdir -p ../powerResults/pico/$(DATE_TIME)
# 	cp -r ../powerResults/pico/*.log ../powerResults/pico/$(DATE_TIME)



SNR:
	python3 findSNR.py $(FLAGS)


.PHONY: save_variables
save_variables:
	@echo "$(K)" > varibles.txt
	@echo "$(N)" >> varibles.txt
	@echo "$(LUT_size)" >> varibles.txt
	@echo "$(FPB)" >> varibles.txt
	@echo "$(NUM_ADD_CLK)" >> varibles.txt
	@echo "$(NUM_ADDER_STAGES)" >> varibles.txt
	$(MAKE) python_gen_param
	@echo "$(CLK_PERIOD)" >> varibles.txt
	@echo "$(CLK_PERIOD_HALF)" >> varibles.txt
	@echo "$(N_MAX)" >> varibles.txt
	@echo "$(K_MAX)" >> varibles.txt

.PHONY: python_gen_param
python_gen_param:
	python3 gen_param.py $(K) $(N) $(MCA_NUM_ADDITIONS)
