`timescale 1ns / 1ps

module datapath(
    input clk,
    input reset,
    output [15:0] led  // Added to prevent Vivado "empty design" error
);

    //=========================================================
    // 1. WIRES (The physical connections between modules)
    //=========================================================
    
    // Program Counter Wires
    wire [15:0] pc_current, pc_next, pc_plus2, pc_branch_target, pc_after_branch;
    
    // Output assignment for synthesis
    assign led = pc_current; 

    // Instruction Wires
    wire [15:0] instruction;
    wire [3:0] opcode, rt_rd, rs, funct, immediate;
    wire [11:0] jump_addr;
    wire [15:0] imm_sign_ext, branch_offset, jump_offset;
    
    // Control Wires
    wire reg_write, mem_to_reg, mem_write, mem_read;
    wire alu_src, branch, branch_ne, jump;
    wire [1:0] alu_op;
    
    // Register & ALU Wires
    wire [15:0] write_data, read_data1, read_data2;
    wire [15:0] alu_input_b, alu_result;
    wire zero;
    reg  [2:0] alu_control;
    
    // Data Memory Wires
    wire [15:0] mem_read_data;

    //=========================================================
    // 2. INSTRUCTION FETCH STAGE
    //=========================================================
    
    ProgramCounter_16bit pc_reg(
        .clk(clk),
        .next(reset ? 16'd0 : pc_next), 
        .current(pc_current)
    );

    adder_16bit pc_add2(
        .A(pc_current),
        .B(16'd2),           
        .SUM(pc_plus2)
    );

    instruction_memory imem(
        .address(pc_current),
        .instruction(instruction)
    );

    //=========================================================
    // 3. INSTRUCTION DECODE & CONTROL STAGE
    //=========================================================
    
    instruction_decode decode(
        .instruction(instruction),
        .opcode(opcode),
        .rt_rd(rt_rd),
        .rs(rs),
        .funct(funct),
        .immediate(immediate),
        .jump_addr(jump_addr),
        .imm_sign_ext(imm_sign_ext),
        .branch_offset(branch_offset),
        .jump_offset(jump_offset)
    );

    control_unit ctrl(
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .alu_src(alu_src),
        .branch(branch),
        .branch_ne(branch_ne),
        .jump(jump),
        .alu_op(alu_op)
    );

    register_file registers(
        .clk(clk),
        .reg_write(reg_write),
        .read_reg1(rs),
        .read_reg2(rt_rd),
        .write_reg(rt_rd),       
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    wire [15:0] explicit_sign_ext;
    SignExtension sign_ext(
        .immediate_in(immediate),
        .immediate_out(explicit_sign_ext)
    );

    //=========================================================
    // 4. EXECUTION (ALU) STAGE
    //=========================================================
    
    mux_alu_src alu_mux(
        .reg_data(read_data2),
        .imm_ext(imm_sign_ext),
        .sel(alu_src),
        .alu_input_b(alu_input_b)
    );

    always @(*) begin
        case (alu_op)
            2'b00: alu_control = 3'b000; // ADD (lw, sw, addi)
            2'b01: alu_control = 3'b001; // SUB (beq, bne)
            2'b10: begin                 // R-Type 
                case (funct)
                    4'b0000: alu_control = 3'b000; // ADD
                    4'b0001: alu_control = 3'b001; // SUB
                    4'b0010: alu_control = 3'b011; // SLL
                    4'b0011: alu_control = 3'b010; // AND
                    default: alu_control = 3'b000;
                endcase
            end
            default: alu_control = 3'b000;
        endcase
    end

    alu execution_unit(
        .a(read_data1),
        .b(alu_input_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    //=========================================================
    // 5. MEMORY & WRITEBACK STAGE
    //=========================================================
    
    data_memory dmem(
        .clk(clk),
        .address(alu_result),
        .write_data(read_data2),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_read_data)
    );

    mux_wb writeback_mux(
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .sel(mem_to_reg),
        .write_data(write_data)
    );

    //=========================================================
    // 6. BRANCH & JUMP LOGIC
    //=========================================================
    
    wire branch_taken;
    assign branch_taken = (branch & zero) | (branch_ne & ~zero);

    adder_16bit branch_adder(
        .A(pc_plus2),
        .B(branch_offset),
        .SUM(pc_branch_target)
    );

    mux_pc branch_mux(
        .pc_plus2(pc_plus2),
        .branch_addr(pc_branch_target),
        .sel(branch_taken),
        .next_pc(pc_after_branch)
    );

    wire [15:0] pc_jump_target;
    adder_16bit jump_adder(
        .A(pc_plus2),
        .B(jump_offset),
        .SUM(pc_jump_target)
    );

    assign pc_next = jump ? pc_jump_target : pc_after_branch;

endmodule