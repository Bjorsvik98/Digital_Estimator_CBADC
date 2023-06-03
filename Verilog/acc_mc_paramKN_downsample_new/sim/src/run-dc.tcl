set script_path [pwd]
set script_dir [file dirname $script_path]
set vcd_name [string map {"/home/anbjors/pro/" "" "/sim" ""} $script_dir]
puts "vcd_name: $vcd_name"

# probe -create -shm  -depth all -all -waveform

# database -open -shm -into ncsim.shm paramKN -default
probe -create -shm resetn chip.accelerator.clk -waveform
probe -create -shm chip.accelerator.sample_out chip.accelerator.start -waveform
# probe -create -shm chip.accelerator.H_matrix chip.accelerator.S_matrix -waveform
probe -create -shm chip.accelerator.K chip.accelerator.N -waveform
probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.adder_input_stage_1 -waveform
probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.enable_adder -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.S_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[1].mca_single_as.S_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[2].mca_single_as.S_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[3].mca_single_as.S_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[4].mca_single_as.S_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[5].mca_single_as.S_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[6].mca_single_as.S_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[7].mca_single_as.S_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.H_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[3].mca_single_as.H_matrix -waveform
# probe -create -shm chip.accelerator.adder.genblk1[4].mca_single_as.H_matrix -waveform

# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.stage_2_generate[0].mca_adder_stage_2.operands -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.stage_2_generate[0].mca_adder_stage_2.S_values -waveform
probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.final_adder_input -waveform



# probe -create -shm chip.accelerator.adder.mca_adder_final.imm_res_reg chip.accelerator.adder.mca_adder_final.res_reg -waveform




run
database -open coreTest_vcd -vcd -timescale ps -into /sim/anbjors/accelerator/${vcd_name}.vcd
# database -open coreTest_vcd -vcd -timescale ps -into /home/anbjors/pro/acc_mc_paramKN_downsample_new/sim/results/${vcd_name}.vcd
probe -create -database coreTest_vcd [scope -tops] -packed 200000 -depth all -all
# # dumpsaif -scope tb_picorv32 -internal -overwrite -output /sim/anbjors/accelerator/${vcd_name}.saif
run

puts "Finished simulation successfully."
exit 
 
 
 