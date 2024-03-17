.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)

    # initializers
    mv s1, a1
    mv s2, a2
    mv s3, a3


    # open file
    mv a1, a0       # Pointer to file name
    li a2, 1        # write permission
    jal fopen

    li t0, -1
    beq a0, t0, exit_93     # fopen error
    mv s0, a0               # save FD


    # malloc rows and cols variables
    li a0, 8        # 8 bytes
    jal malloc

    beq a0, x0, exit_88     # malloc error

    sw s2, 0(a0)    # store rows
    sw s3, 4(a0)    # store cols

    # write #rows and #cols
    mv a1, s0       # file FD
    mv a2, a0       # pointer to rows, cols stored consecutively
    li a3, 2        # tow ints to read from pointer
    li a4, 4        # of 4 byte each
    jal fwrite

    li t0, 2
    bne a0, t0, exit_94     # fwrite error




    mul s2, s2, s3          # s2 = rows*cols

    # write matrix of size rows*cols
    mv a1, s0       # file FD
    mv a2, s1       # pointer to matrix
    mv a3, s2       # rows*cols to write
    li a4, 4        # of 4 byte each
    jal fwrite
    
    bne a0, s2, exit_94     # fwrite error

    # close file
    mv a1, s0
    jal fclose

    li t0, -1
    beq a0, t0, exit_95     # fclose error

    # Epilogue

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20

    ret


exit_88:
    li a1, 88
    j exit2

exit_93:
    li a1, 93
    j exit2

exit_94:
    li a1, 94
    j exit2

exit_95:
    li a1, 95
    j exit2