`timescale 1ns / 1ps

module adder_16bit(
    input [15:0] A,
    input [15:0] B,
    output [15:0] SUM
    );
    
    assign SUM = A + B;
    
endmodule
