
set DESIGN_NAME "picorv32_top"

source -echo -verbose ./dc_scripts/dc_setup.tcl

set_host_options -max_cores 8

#################################################################################
# Design Compiler Reference Methodology Script for Top-Down Flow
# Script: dc.tcl
# Version: S-2021.06  
# Copyright (C) 2007-2021 Synopsys, Inc. All rights reserved.
#################################################################################

saif_map -start

#################################################################################
# Read in the RTL Design
#
# Read in the RTL source files or read in the elaborated design (.ddc).
#################################################################################

define_design_lib WORK -path ./WORK


analyze -format sverilog ${RTL_SOURCE_FILES}
elaborate ${DESIGN_NAME} -parameters ${PARAM_LIST}

#################################################################################
# Create Clock
# set ck_period [expr (1*10**9) / (1600*10**6)]
#################################################################################

set ck_pin clk_n
set ck_period ${CLK_PERIOD}
puts "Creating clock ${ck_pin} with period ${ck_period} ns"
create_clock -name ck -period ${ck_period} ${ck_pin}

#################################################################################
# Check for Design Problems 
#################################################################################

# Check the current design for consistency
check_design -summary
check_design > ${REPORTS_DIR}/${DCRM_CHECK_DESIGN_REPORT}

list_libs > ${REPORTS_DIR}/list_libs.log

#################################################################################
# Compile the Design
#################################################################################

# Use -gate_clock to insert clock-gating logic during optimization.  This
# is now the recommended methodology for clock gating.


compile_ultra -gate_clock

optimize_netlist -area

#################################################################################
# Write Out Final Design and Reports
#
#        .ddc:   Recommended binary format used for subsequent Design Compiler sessions
#    Milkyway:   Recommended binary format for IC Compiler
#        .v  :   Verilog netlist for ASCII flow (Formality, PrimeTime, VCS)
#       .spef:   Topographical mode parasitics for PrimeTime
#        .sdf:   SDF backannotated topographical mode timing for PrimeTime
#        .sdc:   SDC constraints for ASCII flow
#
#################################################################################

change_names -rules verilog -hierarchy

write_icc2_files -force  -output ${RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}


#################################################################################
# Write out Design
#################################################################################

write -format verilog -hierarchy -output ${RESULTS_DIR}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}

write -format ddc     -hierarchy -output ${RESULTS_DIR}/${DCRM_FINAL_DDC_OUTPUT_FILE}

write_parasitics -o ${RESULTS_DIR}/${DCRM_DCT_FINAL_SPEF_OUTPUT_FILE}






write_sdc -nosplit ${RESULTS_DIR}/${DCRM_FINAL_SDC_OUTPUT_FILE}

# If SAIF is used, write out SAIF name mapping file for PrimeTime-PX
saif_map -type ptpx -write_map ${RESULTS_DIR}/${DESIGN_NAME}.mapped.SAIF.namemap

#################################################################################
# Generate Final Reports
#################################################################################


report_qor > ${REPORTS_DIR}/${DCRM_FINAL_QOR_REPORT}
report_timing -transition_time -nets -attributes -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_TIMING_REPORT}
report_area -nosplit -hierarchy > ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
# puts "${CLK_PERIOD}" >> ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
report_area -designware  > ${REPORTS_DIR}/${DCRM_FINAL_DESIGNWARE_AREA_REPORT}
report_resources -hierarchy > ${REPORTS_DIR}/${DCRM_FINAL_RESOURCES_REPORT}
report_clock_gating -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}


# Use SAIF file for power analysis
# read_saif -auto_map_names -input ${DESIGN_NAME}.saif -instance < DESIGN_INSTANCE > -verbose


report_power -nosplit -analysis_effort high -hierarchy > ${REPORTS_DIR}/${DCRM_FINAL_POWER_REPORT}
report_clock_gating -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}

# report_net > ${REPORTS_DIR}/report_net.log


exit
