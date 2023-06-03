
VERSION=acc_multi_cycle

SRC_FILES = picorv32.v 
SIM_FILES = Makefile copy_tb.py
SIM_SRC_FILES = tb_picorv32.v # run-dc.tcl #memimage.hex
SYN_FILES = filesXcelium.txt
SYN_DC_FILES = common_setup.tcl dc_setup.tcl dc.tcl
PWR_FILES = pwr.tcl pwr_acc.tcl
HEAD_FILES = libSetup

test: check_files
	$(MAKE) -s -C ../$(VERSION)/sim/ test

.PHONY: sim
sim: check_files
	$(MAKE) -C ../$(VERSION)/sim/ sim

.PHONY: gate_sim
gate_sim: check_files
	$(MAKE) -s -C ../$(VERSION)/sim/ gate_sim

.PHONY: gate_sim_fast
gate_sim_fast: check_files
	$(MAKE) -s -C ../$(VERSION)/sim/ gate_sim_fast

.PHONY: syn
syn: check_files
	$(MAKE) -s -C ../$(VERSION)/ syn-dc

.PHONY: pwr
pwr: check_files
	$(MAKE) -s -C ../$(VERSION)/ pwr-dc

.PHONY: pwr_acc
pwr_acc: check_files
	$(MAKE) -s -C ../$(VERSION)/ pwr_acc-dc

.PHONY: cp
cp: 
	cp -r ../$(VERSION)/$(FILE) $(FILE)

copy_path_%:
	@if [ -f $(FILE_PATH)$* ] && [ -f ../$(VERSION)/$(FILE_PATH)$* ]; then \
		if diff $(FILE_PATH)$* ../$(VERSION)/$(FILE_PATH)$* > /dev/null; then \
			# echo "The files $(FILE_PATH)$* and ../$(VERSION)/$(FILE_PATH)$* are the same"; \
			echo " " > dummy; rm dummy; \
		else \
			echo "Warning: The ../$(VERSION)/$(FILE_PATH)$* is replaced, the old one can be found in the folder old_files, it is replaced by $(FILE_PATH)$*"; \
			mkdir -p old_files/$(VERSION); \
			cp ../$(VERSION)/$(FILE_PATH)$* old_files/$(VERSION)/$*_$(shell date +%Y-%m-%d_%H-%M-%S); \
			cp $(FILE_PATH)$* ../$(VERSION)/$(FILE_PATH)$*; \
			# $(ERROR) "The $(FILE_PATH)$* is replaced, the old one can be found in the folder old_files"; \
		fi; \
	else \
		if [ ! -f $(FILE_PATH)$* ]; then \
			echo "Warning: The file $(FILE_PATH)$* does not exist in $(FILE_PATH)"; \
		fi; \
		if [ ! -f ../$(VERSION)/$(FILE_PATH)$* ]; then \
			echo "Warning: The file $* does not exist in ../$(VERSION)/$(FILE_PATH)"; \
		fi; \
	fi

.PHONY: copy_Makefile
copy_Makefile:
	@if [ -f Makefile_main ] && [ -f ../$(VERSION)/Makefile ]; then \
		if diff Makefile_main ../$(VERSION)/Makefile > /dev/null; then \
			echo " " > dummy; rm dummy; \
		else \
			echo "Warning: The ../$(VERSION)/Makefile is replaced, the old one can be found in the folder old_files, check Makefile_main"; \
			mkdir -p old_files/$(VERSION); \
			cp ../$(VERSION)/Makefile old_files/$(VERSION)/$*_$(shell date +%Y-%m-%d_%H-%M-%S); \
			cp Makefile_main ../$(VERSION)/Makefile; \
		fi; \
	else \
		if [ ! -f Makefile_main ]; then echo "Error: The file Makefile_main does not exist in $(FILE_PATH)"; fi; \
		if [ ! -f ../$(VERSION)/Makefile ]; then echo "Error: The file $* does not exist in ../$(VERSION)/$(FILE_PATH)"; fi; \
	fi



.PHONY: copy_files
copy_files: $(addprefix test_, $(FILE_TO_CHECK))

$(addprefix test_, $(FILE_TO_CHECK)):
	$(MAKE) -s copy_path_$(subst test_,,$@) 

.PHONY: check_files
check_files:
	$(MAKE) -s copy_Makefile FILE_PATH=Makefile
	$(MAKE) -s copy_files FILE_TO_CHECK="$(SRC_FILES)" FILE_PATH=src/
	$(MAKE) -s copy_files FILE_TO_CHECK="$(SIM_FILES)" FILE_PATH=sim/
	$(MAKE) -s copy_files FILE_TO_CHECK="$(SIM_SRC_FILES)" FILE_PATH=sim/src/
	$(MAKE) -s copy_files FILE_TO_CHECK="$(HEAD_FILES)" FILE_PATH=
	$(MAKE) -s copy_files FILE_TO_CHECK="$(SYN_FILES)" FILE_PATH=syn/DC/
	$(MAKE) -s copy_files FILE_TO_CHECK="$(SYN_DC_FILES)" FILE_PATH=syn/DC/dc_scripts/
	$(MAKE) -s copy_files FILE_TO_CHECK="$(PWR_FILES)" FILE_PATH=pwr/






