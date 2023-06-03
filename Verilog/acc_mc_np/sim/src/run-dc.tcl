set script_path [pwd]
set script_dir [file dirname $script_path]
set vcd_name [string map {"/home/anbjors/pro/" "" "/sim" ""} $script_dir]
puts "vcd_name: $vcd_name"

# database -open -shm -into ncsim.shm acc_mc_np -default
# probe -create -shm resetn chip.accelerator.clk -waveform

# probe -create -shm resetn chip.accelerator.clk -waveform
# probe -create -shm chip.accelerator.start -waveform

# probe -create -shm chip.accelerator.adder.single_as_result -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.adder_input_stage_1 -waveform
# probe -create -shm chip.accelerator.adder.genblk1[0].mca_single_as.final_adder_input -waveform

run
database -open coreTest_vcd -vcd -timescale ps -into /sim/anbjors/accelerator/${vcd_name}.vcd
probe -create -database coreTest_vcd -depth all chip.accelerator -packed 200000 -all
# dumpsaif -scope tb_picorv32 -internal -overwrite -output /sim/anbjors/accelerator/${vcd_name}.saif
run

puts "Finished simulation successfully."
exit 
 
 
 