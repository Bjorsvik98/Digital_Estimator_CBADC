	.section .text
	.global _start
	.global main

_start:
	/* set stack pointer */
	lui sp,(64*1024)>>12

	# lui a0, 0
	# lui a1, 4
	# test a1, a1, a0
	
	/* jump to main C code */
	jal ra,main
	# nop
	# nop
	# nop
	# nop
	# nop
	# nop
	# nop
	# nop
	# jal ra,main



	/* exit testbench */
	lui a0,0x10000000>>12
	addi a0, a0, 0x4
	addi a1, zero, 0xad
	sw a1, 0(a0)

	/* trap */
	ebreak
