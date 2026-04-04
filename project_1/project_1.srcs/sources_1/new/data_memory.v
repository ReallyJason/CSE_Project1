`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2026 11:52:25 AM
// Design Name: 
// Module Name: data_memory
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


module data_memory(
    input clk,
    input [15:0] address,
    input [15:0] write_data,
    input mem_write,
    input mem_read,
    output reg [15:0] read_data
    );


// Memory array: 256 locations (minimum 64 required)
    // Each location is 8 bits (byte-addressable)
    reg [7:0] mem [0:255];
    
    // Initialize memory with some test values
    integer i;
    initial begin
      
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 8'h00;
        end
        
        // Initialize some test data
        mem[0] = 8'h12;
        mem[1] = 8'h34;
        mem[2] = 8'hAB;
        mem[3] = 8'hCD;
        
        $display("Data Memory Initialized");
    end
    
    // Write operation (synchronous - on clock edge)
    always @(posedge clk) begin
        if (mem_write) begin
            // Big-endian: MSB at lower address
            // Store 16-bit data as 2 bytes
            mem[address]     <= write_data[15:8];  // Store upper byte
            mem[address + 1] <= write_data[7:0];   // Store lower byte
            
            $display("Time=%0t: Data Memory Write - Address=0x%h, Data=0x%h", 
                     $time, address, write_data);
        end
    end
    
    // Read operation (combinational)
    always @(*) begin
        if (mem_read) begin
            // Big-endian: MSB at lower address
            // Read 16-bit data from 2 bytes
            read_data = {mem[address], mem[address + 1]};
        end else begin
            read_data = 16'h0000;
        end
    end
 
endmodule