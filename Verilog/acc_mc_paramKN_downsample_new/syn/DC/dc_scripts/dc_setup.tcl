
source -echo -verbose ./dc_scripts/common_setup.tcl

puts "RM-Info: Running script [info script]\n"


###############
# Input Files #
###############

set DCRM_SDC_INPUT_FILE                                 ${DESIGN_NAME}.sdc
set DCRM_CONSTRAINTS_INPUT_FILE                         ${DESIGN_NAME}.constraints.tcl

###########
# Reports #
###########

set DCRM_CHECK_LIBRARY_REPORT                           ${DESIGN_NAME}.check_library.rpt

set DCRM_CONSISTENCY_CHECK_ENV_FILE                     ${DESIGN_NAME}.compile_ultra.env
set DCRM_CHECK_DESIGN_REPORT                            ${DESIGN_NAME}.check_design.rpt
set DCRM_ANALYZE_DATAPATH_EXTRACTION_REPORT             ${DESIGN_NAME}.analyze_datapath_extraction.rpt

set DCRM_FINAL_QOR_REPORT                               ${DESIGN_NAME}.mapped.qor.rpt
set DCRM_FINAL_TIMING_REPORT                            ${DESIGN_NAME}.mapped.timing.rpt
set DCRM_FINAL_AREA_REPORT                              ${DESIGN_NAME}.mapped.area.rpt
set DCRM_FINAL_POWER_REPORT                             ${DESIGN_NAME}.mapped.power.rpt
set DCRM_FINAL_CLOCK_GATING_REPORT                      ${DESIGN_NAME}.mapped.clock_gating.rpt
set DCRM_FINAL_SELF_GATING_REPORT                       ${DESIGN_NAME}.mapped.self_gating.rpt
set DCRM_THRESHOLD_VOLTAGE_GROUP_REPORT                 ${DESIGN_NAME}.mapped.threshold.voltage.group.rpt
set DCRM_INSTANTIATE_CLOCK_GATES_REPORT                 ${DESIGN_NAME}.instantiate_clock_gates.rpt
set DCRM_FINAL_DESIGNWARE_AREA_REPORT                   ${DESIGN_NAME}.mapped.designware_area.rpt
set DCRM_FINAL_RESOURCES_REPORT                         ${DESIGN_NAME}.mapped.final_resources.rpt


################
# Output Files #
################

set DCRM_AUTOREAD_RTL_SCRIPT                            ${DESIGN_NAME}.autoread_rtl.tcl
set DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE              ${DESIGN_NAME}.elab.ddc
set DCRM_COMPILE_ULTRA_DDC_OUTPUT_FILE                  ${DESIGN_NAME}.compile_ultra.ddc
set DCRM_FINAL_DDC_OUTPUT_FILE                          ${DESIGN_NAME}.mapped.ddc
set DCRM_FINAL_PG_VERILOG_OUTPUT_FILE                   ${DESIGN_NAME}.mapped.pg.v
set DCRM_FINAL_VERILOG_OUTPUT_FILE                      ${DESIGN_NAME}.mapped.v
set DCRM_FINAL_SDC_OUTPUT_FILE                          ${DESIGN_NAME}.mapped.sdc
set DCRM_FINAL_DESIGN_ICC2                              ICC2_files


####################
# DCT Output Files #
####################

set DCRM_DCT_FLOORPLAN_OUTPUT_FILE                      ${DESIGN_NAME}.initial.fp

set DCRM_DCT_FINAL_FLOORPLAN_OUTPUT_FILE                ${DESIGN_NAME}.mapped.fp
set DCRM_DCT_FINAL_SPEF_OUTPUT_FILE                     ${DESIGN_NAME}.mapped.spef
set DCRM_DCT_FINAL_SDF_OUTPUT_FILE                      ${DESIGN_NAME}.mapped.sdf


set_app_var search_path ". $ADDITIONAL_SEARCH_PATH $search_path"


if {$synopsys_program_name == "dc_shell"}  {
    set_app_var target_library ${TARGET_LIBRARY_FILES}
    set_app_var link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES"
}


puts "RM-Info: Completed script [info script]\n"

