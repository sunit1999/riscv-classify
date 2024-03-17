.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    ble a1, x0, exit_72     # invalid rows of m0
    ble a2, x0, exit_72     # invalid rows of m0

    ble a4, x0, exit_73     # invalid rows of m1
    ble a5, x0, exit_73     # invalid cols of m1

    bne a2, a4, exit_74     # cols of m0 != rows of m1, D[a1][a5]

    li t0, 0       # int i = 0

    # Prologue
    addi sp, sp, -60
    sw ra, 0(sp)


outer_loop_start:

    beq t0, a1, outer_loop_end      # if i == rows of m0

    li t1, 0       # int j = 0
    mv t2, a3      # store a3 in temp

    j inner_loop_start

inner_loop_start:
    beq t1, a5, inner_loop_end      # if j == cols of m1

    # Save registers

    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)
    sw a4, 20(sp)
    sw a5, 24(sp)

    sw t0, 28(sp)
    sw t1, 32(sp)
    sw t2, 36(sp)
    sw t3, 40(sp)
    sw t4, 44(sp)
    sw t5, 48(sp)
    sw t6, 52(sp)
    sw a6, 56(sp)    


    mv a0, a0           # pointer to start of ith row of m0
    mv a1, t2           # pointer to start of jth col of m1
    mv a2, a2           # size of vectors = cols of m0 == rows of m1
    li a3, 1            # stride of v0 = unit
    mv a4, a5           # stride of v1 = cols of m1

    jal dot             # D[i][j] = dot(m0[i][:], m1[:][j])

    lw a6, 56(sp)
    sw, a0, 0(a6)       # store D[i][j]

    # Restore registers

    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    lw a3, 16(sp)
    lw a4, 20(sp)
    lw a5, 24(sp)
    
    lw t0, 28(sp)
    lw t1, 32(sp)
    lw t2, 36(sp)
    lw t3, 40(sp)
    lw t4, 44(sp)
    lw t5, 48(sp)
    lw t6, 52(sp)


    addi t1, t1, 1      # j++
    addi a6, a6, 4      # pos of new D[i][j]

    slli t2, t1, 2      # t2 = offset in a3
    add t2, a3, t2

    j inner_loop_start

inner_loop_end:
    addi t0, t0, 1      # i++

    slli t5, a2, 2      # t5 = cols of m0 * 4
    add a0, a0, t5      # a0 = pointer to next row of m0

    j outer_loop_start


outer_loop_end:
    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 60
    
    ret


exit_72:
    li a1, 72
    j exit2

exit_73:
    li a1, 73
    j exit2

exit_74:
    li a1, 74
    j exit2
