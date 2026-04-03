
`timescale 1ns / 1ps
module mux_alu_src (
    input  [15:0] reg_data,
    input  [15:0] imm_ext,
    input         sel,
    output [15:0] alu_input_b
);
    assign alu_input_b = (sel == 1'b0) ? reg_data : imm_ext;
endmodule


module mux_wb (
    input  [15:0] alu_result,
    input  [15:0] mem_data,
    input         sel,
    output [15:0] write_data
);
    assign write_data = (sel == 1'b0) ? alu_result : mem_data;
endmodule


module mux_pc (
    input  [15:0] pc_plus2,
    input  [15:0] branch_addr,
    input         sel,
    output [15:0] next_pc
);
    assign next_pc = (sel == 1'b0) ? pc_plus2 : branch_addr;
endmodule
