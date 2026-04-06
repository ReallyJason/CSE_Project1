`timescale 1ns / 1ps

module datamem_16bit(
    input clk,
    input MemWrite,
    input MemRead,
    input [15:0] Address,
    input [15:0] WriteData,
    output [15:0] ReadData
    );
endmodule
