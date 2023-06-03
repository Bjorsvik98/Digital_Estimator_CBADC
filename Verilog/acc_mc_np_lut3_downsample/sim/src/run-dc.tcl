set script_path [pwd]
set script_dir [file dirname $script_path]
set vcd_name [string map {"/home/anbjors/pro/" "" "/sim" ""} $script_dir]
puts "vcd_name: $vcd_name"

# database -open -shm -into ncsim.shm acc_mc_np_lut3_downsample -default
# probe -create -shm resetn chip.accelerator.clk -waveform
# probe -create -shm chip.accelerator.start -waveform
# probe -create -shm chip.accelerator.S_matrix -waveform
# probe -create -shm chip.accelerator.H_matrix_000 -waveform
# probe -create -shm chip.accelerator.H_matrix_1111 -waveform
# probe -create -shm chip.accelerator.adder.single_as_result -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.adder_input_stage_1 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.final_adder_input -waveform
# probe -create -shm chip.accelerator.adder.genblk1[5].mca_single_as.H_matrix_000 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[5].mca_single_as.S_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.H_matrix_01 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[3].mca_single_as.H_matrix_10 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[3].mca_single_as.H_matrix_11 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.stage_1_generate[10].mca_adder_stage_1.S_values -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.stage_1_generate[10].mca_adder_stage_1.operands_00 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.genblk2.stage_1_generate[0].mca_adder_stage_1.S_val_packed -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.genblk2.stage_1_generate[0].mca_adder_stage_1.operands_01 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.genblk2.stage_1_generate[0].mca_adder_stage_1.operands_10 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.genblk2.stage_1_generate[0].mca_adder_stage_1.operands_11 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.genblk2.stage_1_generate[0].mca_adder_stage_1.imm_res_reg -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.genblk2.stage_1_generate[0].mca_adder_stage_1.res_reg -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.genblk2.stage_1_generate[0].mca_adder_stage_1.counter -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.genblk2.stage_1_generate[0].mca_adder_stage_1.counter_double -waveform

run
database -open coreTest_vcd -vcd -timescale ps -into /sim/anbjors/accelerator/${vcd_name}.vcd
probe -create -database coreTest_vcd [scope -tops] -packed 200000 -depth all -all
# dumpsaif -scope tb_picorv32 -internal -overwrite -output /sim/anbjors/accelerator/${vcd_name}.saif
run

puts "Finished simulation successfully."
exit 
 
 
 