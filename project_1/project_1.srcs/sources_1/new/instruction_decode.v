`timescale 1ns / 1ps

module instruction_decode (
    input  [15:0] instruction,
    output [3:0]  opcode,
    output [3:0]  rt_rd,
    output [3:0]  rs,
    output [3:0]  funct,
    output [3:0]  immediate,
    output [11:0] jump_addr,
    output [15:0] imm_sign_ext,
    output [15:0] branch_offset,
    output [15:0] jump_offset
);
    assign opcode    = instruction[15:12];
    assign rt_rd     = instruction[11:8];
    assign rs        = instruction[7:4];
    assign funct     = instruction[3:0];
    assign immediate = instruction[3:0];
    assign jump_addr = instruction[11:0];

    assign imm_sign_ext  = {{12{immediate[3]}}, immediate};
    assign branch_offset = {{12{immediate[3]}}, immediate} << 1;
    assign jump_offset   = {{4{jump_addr[11]}}, jump_addr} << 1;

endmodule