`timescale 1ns / 1ps

module SignExtension(
    input [3:0] immediate_in,
    output [15:0] immediate_out
    );
    
    assign immediate_out[0] = immediate_in[0];
    assign immediate_out[1] = immediate_in[1];
    assign immediate_out[2] = immediate_in[2];
    assign immediate_out[3] = immediate_in[3];
    assign immediate_out[4] = immediate_in[3];
    assign immediate_out[5] = immediate_in[3];
    assign immediate_out[6] = immediate_in[3];
    assign immediate_out[7] = immediate_in[3];
    assign immediate_out[8] = immediate_in[3];
    assign immediate_out[9] = immediate_in[3];
    assign immediate_out[10] = immediate_in[3];
    assign immediate_out[11] = immediate_in[3];
    assign immediate_out[12] = immediate_in[3];
    assign immediate_out[13] = immediate_in[3];
    assign immediate_out[14] = immediate_in[3];
    assign immediate_out[15] = immediate_in[3];
    
endmodule


