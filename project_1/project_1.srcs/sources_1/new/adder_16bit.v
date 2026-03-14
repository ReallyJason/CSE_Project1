`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 02:07:20 AM
// Design Name: 
// Module Name: adder_16bit
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


module adder_16bit(
    input [15:0] A,
    input [15:0] B,
    output [15:0] SUM
    );
    
    assign SUM = A + B;
    
endmodule
