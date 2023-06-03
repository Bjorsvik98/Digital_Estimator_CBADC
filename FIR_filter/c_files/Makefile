USE_MYSTDLIB = 1
IBEX_OFF = 1

CC = riscv32-unknown-elf-gcc
# TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-
TOOLCHAIN_PREFIX = /opt/riscv32-custom-new/bin/riscv32-unknown-elf-# with added custom instructions to work with accelerator
CFLAGS = -O3 -mabi=ilp32e -march=rv32e -DTIME -DRISCV -DIBEX_OFF -ffreestanding #-lgcc #-MD 

OBJS = stdlib.o #boot.o #filter.o fillData.o 
LDLIBS = -lstdc++

ifeq ($(USE_MYSTDLIB),1)
CFLAGS += -DUSE_MYSTDLIB -ffreestanding -nostdlib -g
OBJS += start.o
else

endif

.PHONY: test
test: run_local

.PHONY: compile_local
compile_local: #fir.o
	gcc fir.c -g -DIBEX_OFF -fstack-protector -fsanitize=address -o out 
	


.PHONY: compile_local_accellerated
compile_local_accellerated: 
	gcc fir_accelerated.c -DIBEX_OFF -o out 

.PHONY: run_local
run_local: clean compile_local 
	./out

.PHONY: run_acc
run_acc: clean compile_local 
	./out

%.hex: %.elf assembly_% #Path kan være feil her
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $< $@
	python3 ../hex_files/hex8tohex32.py $@ > ../hex_files/$*32.hex
	@echo "     hex file created"

%.elf: $(OBJS) %.o sections.lds
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -Wl,-Bstatic,-T,sections.lds,-Map,fir.map,--strip-debug -o $@ $(OBJS) $*.o
	chmod -x $@
	@echo "     elf file created"

%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) $<

%.o: %.S
	$(TOOLCHAIN_PREFIX)gcc -c $(CFLAGS) $<

assembly_%: 
	$(TOOLCHAIN_PREFIX)objdump -d $*.elf > ../hex_files/$@.txt	
	$(TOOLCHAIN_PREFIX)objdump -d $*.elf > $@.txt	
	@echo "     assembly file created"
	
.PHONY: clean
clean:
	rm -f *.o out *.d *.elf *.bin *.map


