`timescale 1ns / 1ps
module branch_jump (
    input  [15:0] read_data1,
    input  [15:0] read_data2,
    input  [15:0] pc_plus2,
    input  [15:0] branch_offset,
    input  [15:0] jump_offset,
    input         branch_eq,
    input         branch_ne,
    input         jump,
    output [15:0] branch_target,
    output [15:0] jump_target,
    output        pc_src
);
    assign branch_target = pc_plus2 + branch_offset;
    assign jump_target   = pc_plus2 + jump_offset;

    wire alu_zero;
    assign alu_zero = (read_data1 == read_data2) ? 1'b1 : 1'b0;

    assign pc_src = (branch_eq & alu_zero)
                  | (branch_ne & ~alu_zero)
                  | jump;

endmodule