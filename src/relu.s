.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Prologue    
    ble a1, x0, exception # if size <= 0, then exception

    li t0, 0    # t0 = iteration count    

loop_start:
    beq t0, a1, loop_end

    lw t1, 0(a0)    # t1 = arr[i]

    bge t1, x0, loop_continue   # if (arr[i] >= 0) continue;

    sw  x0, 0(a0)    # store 0 in arr[i]

loop_continue:
    addi t0, t0, 1  # t0++
    addi a0, a0, 4  # move pointer to next element
    j loop_start

loop_end:
	ret

exception:
    li a1, 78
    j exit2
