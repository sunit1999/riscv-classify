.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    li t0, 5
    bne a0, t0, exit_89     # incorrect # of args

    # PROLOGUE
    addi sp, sp, -44
    sw   s0, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    sw   s6, 20(sp)
    sw   s8, 24(sp)
    sw  s10, 28(sp)
    sw  s11, 32(sp)
    sw   ra, 36(sp)
    sw   s5, 40(sp)

    # initializations
    lw s0, 4(a1)            # pointer to m0_path
    lw s1, 8(a1)            # pointer to m1_path
    lw s2, 12(a1)           # pointer to input_path
    lw s3, 16(a1)           # pointer to output_path
    mv s5, a2

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0

    # malloc rows and cols variables
    li a0, 8                # 8 bytes
    jal malloc
    beq a0, x0, exit_88     # malloc error
    mv s4, a0               # pointer to m0's [rows, cols] variable

    mv a0, s0               # m0 path
    mv a1, s4               # m0 rows
    addi a2, s4, 4          # m0 cols
    jal read_matrix

    mv s0, a0               # save pointer to m0

    # Load pretrained m1

    # malloc rows and cols variables
    li a0, 8                # 8 bytes
    jal malloc
    beq a0, x0, exit_88     # malloc error
    mv s6, a0               # pointer to m1's [rows, cols] variable

    mv a0, s1               # m1 path
    mv a1, s6               # m1 rows
    addi a2, s6, 4          # m1 cols
    jal read_matrix

    mv s1, a0               # save pointer to m1

    # Load input matrix

    # malloc rows and cols variables
    li a0, 8                # 8 bytes
    jal malloc
    beq a0, x0, exit_88     # malloc error
    mv s8, a0               # pointer to input's [rows, cols] variable

    mv a0, s2               # input path
    mv a1, s8               # input rows
    addi a2, s8, 4          # input cols
    jal read_matrix

    mv s2, a0               # save pointer to input matrix

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # Layer 1: Sets D = matmul(m0, input)
    # allocate space for D = m0_rows * input_cols * 4 bytes
    lw t0, 0(s4)
    lw t1, 4(s8)
    mul a0, t0, t1          # m0_rows * input_cols
    slli a0, a0, 2
    jal malloc
    beq a0, x0, exit_88     # malloc error
    mv s10, a0              # save pointer to D

    mv a0, s0
    lw a1, 0(s4)
    lw a2, 4(s4)
    mv a3, s2
    lw a4, 0(s8)
    lw a5, 4(s8)
    mv a6, s10
    jal matmul

    # Layer 2: ReLU(D). D->D'
    lw t0, 0(s4)
    lw t1, 4(s8)
    mv a0, s10              # pointer to D
    mul a1, t0, t1          # D_rows*D_cols
    jal relu


    # Layer 3: Sets O = matmul(m1, D')
    # allocate space for O = m1_rows * D'_cols(==input_cols) * 4 bytes
    lw t0, 0(s6)
    lw t1, 4(s8)
    mul a0, t0, t1
    slli a0, a0, 2
    jal malloc
    beq a0, x0, exit_88     # malloc error
    mv s0, a0               # save pointer to O


    mv a0, s1
    lw a1, 0(s6)
    lw a2, 4(s6)
    mv a3, s10
    lw a4, 0(s4)
    lw a5, 4(s8)
    mv a6, s0
    jal matmul


    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

    mv a0, s3
    mv a1, s0
    lw a2, 0(s6)
    lw a3, 4(s8)
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

    lw t0, 0(s6)        # O_rows
    lw t1, 4(s8)        # O_cols
    
    mv a0, s0
    mul a1, t0, t1      # O_rows*O_cols
    jal argmax
    mv s11, a0           # save classification from argmax

    bne s5, x0, no_prints

    # Print classification
    mv a1, s11
    jal print_int

    # Print newline afterwards for clarity
    li a1, '\n'
    jal print_char

no_prints:
    # Prepare return value
    mv a0, s11

    # Free memory
    mv   a0, s0
    jal  free
    
    mv   a0, s4
    jal  free
    
    mv   a0, s6
    jal  free
    
    mv   a0, s8
    jal  free
    
    mv   a0, s10
    jal  free

    # EPILOGUE
    lw   s5, 40(sp)
    lw   ra, 36(sp)
    lw  s11, 32(sp)
    lw  s10, 28(sp)
    lw   s8, 24(sp)
    lw   s6, 20(sp)
    lw   s4, 16(sp)
    lw   s3, 12(sp)
    lw   s2, 8(sp)
    lw   s1, 4(sp)
    lw   s0, 0(sp)
    addi sp, sp, 44


    ret

exit_88:
    li a1, 88
    j exit2

exit_89:
    li a1, 89
    j exit2