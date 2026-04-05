`timescale 1ns / 1ps

module ProgramCounter_16bit(
    input wire clk,
    input wire [15:0] next,
    output reg [15:0] current
    );
    
    always @(posedge clk)begin
        current <= next;
    end
    
endmodule
