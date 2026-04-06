`timescale 1ns / 1ps

module data_memory(
    input clk,
    input [15:0] address,
    input [15:0] write_data,
    input mem_write,
    input mem_read,
    output reg [15:0] read_data
    );


    reg [7:0] mem [0:255]; //256 location address -> 8 bits at each address
    
    // Initialize memory with some test values
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 8'h00;
        end
        
        //random tests
        mem[0] = 8'h12;
        mem[1] = 8'h34;
        mem[2] = 8'hAB;
        mem[3] = 8'hCD;        
    end
    
    always @(posedge clk) begin
        if (mem_write) begin
            // Big-endian
            mem[address] <= write_data[15:8];  // Store upper byte
            mem[address + 1] <= write_data[7:0];   // Store lower byte
        end
    end
    
    always @(*) begin
        if (mem_read) begin
            // Read 16-bit data from 2 bytes
            read_data = {mem[address], mem[address + 1]};
        end else begin
            read_data = 16'h0000;
        end
    end

endmodule