.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    # Prologue
    ble a1, x0, exception   # size <= 0, then terminate

    li t0, 0        # iterator

    # use first index as starting result
    li t1, 0        # result index
    lw t2, 0(a0)    # running_max

    j loop_continue

loop_start:
    beq t0, a1, loop_end

    lw t3, 0(a0)        # t3 = curr number

    ble t3, t2, loop_continue # if curr <= running_max, then continue
    
    mv  t1, t0      # else, found new max index
    mv  t2, t3

loop_continue:
    addi t0, t0, 1  # t0++
    addi a0, a0, 4
    j loop_start

loop_end:
    # Epilogue
    mv  a0, t1
    ret

exception:
    li a1, 77
    j exit2