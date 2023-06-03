set power_enable_analysis TRUE

if {$power_enable_timing_analysis == false} {set_app_var power_enable_timing_analysis true} 

# set power_analysis_mode averaged
set power_analysis_mode time_based


set file_handle [open "../../sim/variables.txt" r]
set K [gets $file_handle]
set N [gets $file_handle]
set LUT_SIZE [gets $file_handle]
set WIDTH_COEFFICIENT [gets $file_handle]
set NUM_ADD_CLK [gets $file_handle]
set NUM_ADDER_STAGES [gets $file_handle]

set NUM_INPUTS_S3 [gets $file_handle]
set NUM_INPUTS_S2 [gets $file_handle]
set NUM_INPUTS_S1 [gets $file_handle]
set NUM_S3_ADDERS [gets $file_handle]
set NUM_S2_ADDERS [gets $file_handle]
set NUM_S1_ADDERS [gets $file_handle]

set CLK_PERIOD [gets $file_handle]
set CLK_PERIOD_HALF [gets $file_handle]

set N_MAX [gets $file_handle]
set K_MAX [gets $file_handle]

close $file_handle



set LIBRARY_SEARCH_PATH "libs/" 
set LIBRARY_SEARCH_PATH_CLK "libs/" 
set LIBRARY_SEARCH_PATH_PR "libs/" 



#####################################################################
#       link design
#####################################################################

set search_path "../syn/DC/ \
  ${LIBRARY_SEARCH_PATH} \
  ${LIBRARY_SEARCH_PATH_CLK} \
  ${LIBRARY_SEARCH_PATH_PR} ."

set link_library " * ${TARGET_LIB}.db \
* ${TARGET_LIB_CLK}.db \
* ${TARGET_LIB_PR}.db"

#####################################################################
#       load design name from namemap file
#####################################################################
set VERSION 1
if { [info exists ::env(VERSION)] } {
  set VERSION $::env(VERSION)
}


if {$VERSION eq "acc_mcKvar"} {
  set result_dir_name "results_N${N}_K_MAX${K_MAX}"
} elseif {$VERSION eq "acc_mcNvar"} {
  set result_dir_name "results_N_MAX${N_MAX}_K${K}"
} elseif {$VERSION eq "acc_mc_paramKN_downsample"} {
  set result_dir_name "results_N_MAX${N_MAX}_K_MAX${K_MAX}"
} elseif {$VERSION eq "acc_mc_paramKN_downsample_new"} {
  set result_dir_name "results_N_MAX${N_MAX}_K_MAX${K_MAX}"
} else {
  set result_dir_name "results_N${N}_K${K}"
}
puts "result_dir_name = $result_dir_name"
set f [open "../../syn/DC/${result_dir_name}/picorv32_top.mapped.SAIF.namemap" r]
set content [read $f]
close $f
if {[regexp {# design (\S+)} $content match design_name]} {
    puts "Design: $design_name"
} else {
    puts "Design not found."
}

read_verilog ../../syn/DC/${result_dir_name}/picorv32_top.mapped.v
current_design $design_name
link


#####################################################################
#       set transition time / annotate parasitics
#####################################################################

read_sdc ../../syn/DC/${result_dir_name}/picorv32_top.mapped.sdc -version "2.1" -echo
read_parasitics ../../syn/DC/${result_dir_name}/picorv32_top.mapped.spef


report_annotated_parasitics > annotated_parasitics.log


#####################################################################
#       check/update/report timing 
#####################################################################
check_timing
update_timing
report_timing > timing_report.log

#####################################################################
#       read switching activity file
#####################################################################

set script_path [file normalize [info script]]
set script_dir [file dirname $script_path]
set design_name_path [string map {"/home/anbjors/pro/" "" "/pwr" ""} $script_dir]
puts "vcd file name = $design_name_path.vcd"


read_vcd /sim/anbjors/accelerator/${design_name_path}.vcd -strip_path "tb_picorv32/chip" -format systemverilog



report_switching_activity > switching_activity.log


#####################################################################
#       check/update/report power 
#####################################################################
check_power
# set_power_analysis_options -waveform_format fsdb -waveform_output /sim/anbjors/power_time_based
update_power
report_power > power_report.log

quit
