.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
	addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    # initilizers
    mv s1, a1   
    mv s2, a2

    # open file
    mv a1, a0
    li a2, 0
    jal fopen

    li t0, -1
    beq a0, t0, exit_90     # error in fopen, FD == -1
    mv s0, a0               # save FD

    # read # rows
    mv a1, s0
    mv a2, s1
    li a3, 4
    jal fread

    li t0, 4
    bne a0, t0, exit_91     # fread error

    # read # cols
    mv a1, s0
    mv a2, s2
    li a3, 4
    jal fread

    li t0, 4
    bne a0, t0, exit_91     # fread error



    # allocate rows*cols memory
    lw s1, 0(s1)    # get #rows
    lw s2, 0(s2)    # get #cols
    mul s1, s1, s2  # rows *= cols
    slli s1, s1, 2  # s1 = 4*rows*cols bytes

    mv a0, s1
    jal malloc

    beq a0, x0, exit_88     # malloc error
    mv s3, a0               # save pointer to matrix

    # read rows*cols
    mv a1, s0       # s0 = FD
    mv a2, s3       # s3 = pointer to matrix
    mv a3, s1       # s1 = 4*rows*cols bytes
    jal fread

    bne a0, s1, exit_91     # fread error

    # close file
    mv a1, s0
    jal fclose

    li t0, -1
    beq a0, t0, exit_92     # fclose error, if a0 = -1 


    # prepare return values
    mv a0, s3

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
	addi sp, sp, 20

    ret


exit_88:
    li a1, 88
    j exit2

exit_90:
    li a1, 90
    j exit2

exit_91:
    li a1, 91
    j exit2

exit_92:
    li a1, 92
    j exit2