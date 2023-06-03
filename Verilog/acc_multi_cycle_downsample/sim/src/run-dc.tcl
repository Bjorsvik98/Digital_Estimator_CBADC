set script_path [pwd]
set script_dir [file dirname $script_path]
set vcd_name [string map {"/home/anbjors/pro/" "" "/sim" ""} $script_dir]
puts "vcd_name: $vcd_name"


# database -open -shm -into ncsim.shm acc_multi_cycle_downsample -default
# probe -create -shm clk_n reset adr dat sel we cyc rdt cyclecounter ack_n pcpi_insn pcpi_valid pcpi_rs1 pcpi_rs2 pcpi_insn_decoded -waveform
# probe -create -shm chip.accelerator.sample_out chip.accelerator.pcpi_rd -waveform
# probe -create -shm chip.accelerator.clk  -waveform
# probe -create -shm chip.accelerator.start  -waveform
# probe -create -shm chip.accelerator.H_matrix chip.accelerator.H_matrix_n chip.accelerator.S_matrix chip.accelerator.sample_out -waveform

# probe -create -shm chip.accelerator.H_matrix -waveform
# probe -create -shm chip.accelerator.H_matrix_n -waveform
# probe -create -shm chip.accelerator.start chip.accelerator.sample_out -waveform
# probe -create chip.accelerator.adder.stage_3_generate[0].mca_adder_stage_3.imm_res_reg chip.accelerator.adder.stage_3_generate[0].mca_adder_stage_3.operands chip.accelerator.adder.stage_3_generate[0].mca_adder_stage_3.counter -shm -waveform
# probe -create chip.accelerator.adder.adder_input_stage_3 chip.accelerator.adder.adder_input_stage_2 chip.accelerator.adder.adder_input_stage_1 chip.accelerator.adder.final_adder_input -shm -waveform



run


database -open coreTest_vcd -vcd -timescale ps -into /sim/anbjors/accelerator/${vcd_name}.vcd
probe -create -database coreTest_vcd [scope -tops] -packed 200000 -depth all -all
# # dumpsaif -scope tb_picorv32 -internal -overwrite -output /sim/anbjors/accelerator/${vcd_name}.saif

run
puts "Finished simulation successfully."
exit 
 
 
 