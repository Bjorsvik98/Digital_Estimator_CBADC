


puts "RM-Info: Running script [info script]\n"



set DESIGN_LABEL                 "picorv32_top"  ;#  The name of the top-level design

set DESIGN_REF_DATA_PATH          "${DESIGN_LABEL}"  ;#  Absolute path prefix variable for library/design data.
                                       #  Use this variable to prefix the common absolute path  
                                       #  to the common variables defined below.
                                       #  Absolute paths are mandatory for hierarchical 
                                       #  reference methodology flow.


set file_handle [open "../../sim/variables.txt" r]

# Read the values from the file and assign them to variables
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


# Close the file
close $file_handle

set PARAM_LIST "WIDTH_COEFFICIENT=${WIDTH_COEFFICIENT}, K=${K}, N=${N}, LUT_SIZE=${LUT_SIZE}, NUM_ADD_CLK=${NUM_ADD_CLK}, NUM_ADDER_STAGES=${NUM_ADDER_STAGES}, "
append PARAM_LIST "NUM_INPUTS_S3=${NUM_INPUTS_S3}, NUM_INPUTS_S2=${NUM_INPUTS_S2}, NUM_INPUTS_S1=${NUM_INPUTS_S1}, "
append PARAM_LIST "NUM_S3_ADDERS=${NUM_S3_ADDERS}, NUM_S2_ADDERS=${NUM_S2_ADDERS}, NUM_S1_ADDERS=${NUM_S1_ADDERS}, "
append PARAM_LIST "N_MAX=${N_MAX}, K_MAX=${K_MAX}"





##########################################################################################
# Library Setup Variables
##########################################################################################

# For the following variables, use a blank space to separate multiple entries.
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"

set ADDITIONAL_SEARCH_PATH        [glob "libs"]  ;#  Additional search path to be added to the default search path (used by all tools)

set TARGET_LIBRARY_FILES          ".db"  ;#  Target technology logical libraries (used by DC, DCCNT)
set TARGET_LIBRARY_FILES_LIB      ".lib"  ;#  Target technology logical libraries (used by DC, DCCNT)
set ADDITIONAL_LINK_LIB_FILES     ".db" ;#  Extra link logical libraries not included in TARGET_LIBRARY_FILES (used by DC, DCNXT)


set MIN_LIBRARY_FILES             ""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

set MIN_ROUTING_LAYER            ""   ;# Min routing layer
set MAX_ROUTING_LAYER            ""   ;# Max routing layer

set LIBRARY_DONT_USE_FILE        ""   ;# Tcl file with library modifications for dont_use





set VERSION 1
if { [info exists ::env(VERSION)] } {
  set VERSION $::env(VERSION)
}
puts "RTL VERSION: ${DESIGN_LABEL}"

set source_file [open  "../../src/sources.txt" r]
set file_content [read $source_file]
close $source_file
set RTL_SOURCE_FILES [split $file_content "\n"]

# The following variables are used by scripts in the rm_dc_scripts folder to direct 
# the location of the output files.
set REPORTS_DIR "reports"

if {$VERSION eq "acc_mcKvar"} {
  set RESULTS_DIR "results_N${N}_K_MAX${K_MAX}"
} elseif {$VERSION eq "acc_mcNvar"} {
  set RESULTS_DIR "results_N_MAX${N_MAX}_K${K}"
} elseif {$VERSION eq "acc_mc_paramKN_downsample"} {
  set RESULTS_DIR "results_N_MAX${N_MAX}_K_MAX${K_MAX}"
} elseif {$VERSION eq "acc_mc_paramKN_downsample_new"} {
  set RESULTS_DIR "results_N_MAX${N_MAX}_K_MAX${K_MAX}"
} else {
  set RESULTS_DIR "results_N${N}_K${K}"
}


file mkdir ${REPORTS_DIR}
file mkdir ${RESULTS_DIR}
puts "Results directory: ${RESULTS_DIR}"


puts "RM-Info: Completed script [info script]\n"

