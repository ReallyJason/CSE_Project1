`timescale 1ns / 1ps

module control_unit(
    input [3:0] opcode,

    output reg reg_write,
    output reg mem_to_reg,
    output reg mem_write,
    output reg mem_read,
    output reg alu_src,
    output reg branch,
    output reg branch_ne,
    output reg jump,
    output reg [1:0] alu_op
    );

    parameter OP_RTYPE = 4'b0000;  // R-type (add, sub, sll, and)
    parameter OP_LW    = 4'b0001;  // Load word
    parameter OP_SW    = 4'b0010;  // Store word
    parameter OP_ADDI  = 4'b0011;  // Add immediate
    parameter OP_BEQ   = 4'b0100;  // Branch if equal
    parameter OP_BNE   = 4'b0101;  // Branch if not equal
    parameter OP_JMP   = 4'b0110;  // Jump
    parameter OP_ADDIF = 4'b0111;  // Add immediate if
    
    parameter ALU_ADD_OP  = 2'b00;  // Add (for lw, sw, addi)
    parameter ALU_SUB_OP  = 2'b01;  // Subtract (for beq, bne)
    parameter ALU_RTYPE_OP = 2'b10; // R-type (function code)
    
    always @(*) begin
        // Default values (all signals off)
        reg_write = 0;
        mem_to_reg = 0;
        mem_write = 0;
        mem_read = 0;
        alu_src = 0;
        branch = 0;
        branch_ne = 0;
        jump = 0;
        alu_op = 2'b00;
        
        case (opcode)
            //==================================================
            // R-TYPE INSTRUCTIONS (add, sub, sll, and)
            //==================================================
            OP_RTYPE: begin
                reg_write = 1;      // Write result to register
                mem_to_reg = 0;     // Result comes from ALU
                mem_write = 0;      // No memory write
                mem_read = 0;       // No memory read
                alu_src = 0;        // ALU source B is Read Data 2
                branch = 0;         // Not a branch
                branch_ne = 0;
                jump = 0;           // Not a jump
                alu_op = ALU_RTYPE_OP; // Use function code
            end
            
            //==================================================
            // LW (LOAD WORD)
            //==================================================
            OP_LW: begin
                reg_write = 1;      // Write loaded data to register
                mem_to_reg = 1;     // Data comes from memory
                mem_write = 0;      // No memory write
                mem_read = 1;       // Enable memory read
                alu_src = 1;        // ALU source B is sign-extended immediate
                branch = 0;
                branch_ne = 0;
                jump = 0;
                alu_op = ALU_ADD_OP; // ALU adds base + offset
            end
            
            //==================================================
            // SW (STORE WORD)
            //==================================================
            OP_SW: begin
                reg_write = 0;      // No register write
                mem_to_reg = 0;     // Don't care (not writing to reg)
                mem_write = 1;      // Enable memory write
                mem_read = 0;       // No memory read
                alu_src = 1;        // ALU source B is sign-extended immediate
                branch = 0;
                branch_ne = 0;
                jump = 0;
                alu_op = ALU_ADD_OP; // ALU adds base + offset
            end
            
            //==================================================
            // ADDI (ADD IMMEDIATE)
            //==================================================
            OP_ADDI: begin
                reg_write = 1;      // Write result to register
                mem_to_reg = 0;     // Result comes from ALU
                mem_write = 0;      // No memory write
                mem_read = 0;       // No memory read
                alu_src = 1;        // ALU source B is sign-extended immediate
                branch = 0;
                branch_ne = 0;
                jump = 0;
                alu_op = ALU_ADD_OP; // ALU performs addition
            end
            
            //==================================================
            // BEQ (BRANCH IF EQUAL)
            //==================================================
            OP_BEQ: begin
                reg_write = 0;      // No register write
                mem_to_reg = 0;     // Don't care
                mem_write = 0;      // No memory write
                mem_read = 0;       // No memory read
                alu_src = 0;        // ALU source B is Read Data 2
                branch = 1;         // This is a branch instruction
                branch_ne = 0;      // Branch on equal (not not-equal)
                jump = 0;
                alu_op = ALU_SUB_OP; // ALU subtracts for comparison
            end
            
            //==================================================
            // BNE (BRANCH IF NOT EQUAL)
            //==================================================
            OP_BNE: begin
                reg_write = 0;
                mem_to_reg = 0;
                mem_write = 0;
                mem_read = 0;
                alu_src = 0;
                branch = 1;
                branch_ne = 1;      // Branch on not equal
                jump = 0;
                alu_op = ALU_SUB_OP;
            end
            
            //==================================================
            // JMP (JUMP)
            //==================================================
            OP_JMP: begin
                reg_write = 0;
                mem_to_reg = 0;
                mem_write = 0;
                mem_read = 0;
                alu_src = 0;        // Don't care
                branch = 0;
                branch_ne = 0;
                jump = 1;           // Unconditional jump
                alu_op = 2'b00;     // Don't care
            end
            
            //==================================================
            // ADDIF (ADD IMMEDIATE IF)
            //==================================================
            OP_ADDIF: begin
                reg_write = 1;      // Conditionally write (handled by condition logic)
                mem_to_reg = 0;
                mem_write = 0;
                mem_read = 0;
                alu_src = 1;        // Use immediate
                branch = 0;
                branch_ne = 0;
                jump = 0;
                alu_op = ALU_ADD_OP;
            end
            
            //==================================================
            // DEFAULT (treat as NOP or R-type)
            //==================================================
            default: begin
                reg_write = 0;
                mem_to_reg = 0;
                mem_write = 0;
                mem_read = 0;
                alu_src = 0;
                branch = 0;
                branch_ne = 0;
                jump = 0;
                alu_op = 2'b00;
            end
        endcase
    end

endmodule