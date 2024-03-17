.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:

    # Prologue
    ble a2, x0, exit_75 # if arr len <= 0 then exception
    ble a3, x0, exit_76 # if stride1 <= 0 then exception
    ble a4, x0, exit_76 # if stride2 <= 0 then exception

    li t0, 0        # int i = 0
    li t1, 0        # int dot = 0

    slli a3, a3, 2  # offset in bytes with stride1
    slli a4, a4, 2  # offset in bytes with stride2

loop_start:
    beq t0, a2, loop_end    # end loop if i==n

    lw t2, 0(a0)    # arr1[i]
    lw t3, 0(a1)    # arr2[i]

    mul t2, t2, t3  # arr1[i] *= arr2[i]

    add t1, t1, t2  # dot += arr1[i]

    addi t0, t0, 1  # i++

    add a0, a0, a3  # move pointer to arr1[i]
    add a1, a1, a4  # move pointer to arr2[i]

    j loop_start

loop_end:
    mv  a0, t1 # return dot through a0
    ret

exit_75:
    li a1, 75
    j exit2

exit_76:
    li a1, 76
    j exit2
