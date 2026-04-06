`timescale 1ns / 1ps

module instruction_memory(
    input [15:0] address,
    output reg [15:0] instruction
    );

    reg [15:0] mem [0:255]; //256 location address -> 8 bits at each address
    integer i;
    
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 16'h0000; //all mem stores 0
        end
        
        // Sample test program demonstrating sw, lw, addi
        // Address 0x00: addi $s1, $s0, 5     -> $s1 = 0 + 5 = 5
        mem[0] = 16'h3105;  // 0011 0001 0000 0101
        
        // Address 0x02: addi $s2, $s0, 3     -> $s2 = 0 + 3 = 3
        mem[1] = 16'h3203;  // 0011 0010 0000 0011
        
        // Address 0x04: add $s3, $s1, $s2    -> $s3 = $s1 + $s2 = 8
        mem[2] = 16'h0312;  // 0000 0011 0001 0010 (Function 0000 needs to be added)
        // Corrected: 0000 0011 0001 0000
        mem[2] = 16'h0310;
        
        // Address 0x06: sw $s3, 4($s0)       -> Store $s3 at mem[4]
        mem[3] = 16'h2304;  // 0010 0011 0000 0100
        
        // Address 0x08: lw $s4, 4($s0)       -> Load mem[4] into $s4
        mem[4] = 16'h1404;  // 0001 0100 0000 0100
        
        // Address 0x0A: addi $s5, $s4, -1    -> $s5 = $s4 - 1 = 7
        mem[5] = 16'h354F;  // 0011 0101 0100 1111
        
        // Address 0x0C: beq $s1, $s1, 2      -> Branch taken (always equal to itself)
        mem[6] = 16'h4112;  // 0100 0001 0001 0010
        
        // Address 0x0E: addi $s6, $s0, 99    -> Should be skipped
        mem[7] = 16'h3603;  // This will be skipped due to branch
        
        // Address 0x10: (branch target) sub $s7, $s3, $s2  -> $s7 = 8 - 3 = 5
        mem[8] = 16'h0731;  // 0000 0111 0011 0001
        
        // Address 0x12: jmp 4                -> Jump forward
        mem[9] = 16'h6004;  // 0110 0000 0000 0100
        
        // More test cases can be added here
        
        $display("Instruction Memory Initialized");
        $display("Memory[0] = 0x%h (addi $s1, $s0, 5)", mem[0]);
        $display("Memory[1] = 0x%h (addi $s2, $s0, 3)", mem[1]);
        $display("Memory[2] = 0x%h (add $s3, $s1, $s2)", mem[2]);
        $display("Memory[3] = 0x%h (sw $s3, 4($s0))", mem[3]);
        $display("Memory[4] = 0x%h (lw $s4, 4($s0))", mem[4]);
    end
    
    // Combinational read
    // Address is byte-addressable, but instructions are 2 bytes
    // So we divide by 2 (right shift by 1)
    always @(*) begin
        instruction = mem[address[15:1]];  // Divide address by 2
    end

endmodule