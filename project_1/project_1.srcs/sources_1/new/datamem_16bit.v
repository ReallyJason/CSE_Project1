`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2026 06:12:23 PM
// Design Name: 
// Module Name: datamem_16bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module datamem_16bit(
    input clk,
    input MemWrite,
    input MemRead,
    input [15:0] Address,
    input [15:0] WriteData,
    output [15:0] ReadData
    );
endmodule
