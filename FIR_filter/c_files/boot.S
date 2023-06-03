	.section .text
	.global boot
	.global _start

boot:
	# /* print "START\n" */
	# lui a0,0x10000000>>12
	# addi a1,zero,'B'
	# addi a2,zero,'O'
	# addi a3,zero,'O'
	# addi a4,zero,'T'
	# addi a5,zero,'\n'
	# sw a1,0(a0)
	# sw a2,0(a0)
	# sw a3,0(a0)
	# sw a4,0(a0)
	# sw a5,0(a0)

	/* set stack pointer */
	lui sp,(64*1024)>>12

	/* jump to application */
	jal ra,_start
