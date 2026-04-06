`timescale 1ns / 1ps

module alu(
    input [15:0] a,
    input [15:0] b,
    input [2:0] alu_control,
    output reg [15:0] result,
    output zero
    );


    // ALU Control codes
    parameter ADD = 3'b000;   // Addition
    parameter SUB = 3'b001;   // Subtraction
    parameter AND = 3'b010;   // Bitwise AND
    parameter SLL = 3'b011;   // Shift left logical
    parameter OR  = 3'b100;   // Bitwise OR (optional)
    parameter XOR = 3'b101;   // Bitwise XOR (optional)
    parameter SLT = 3'b110;   // Set less than (optional)
    
    // Perform operation based on control signal
    always @(*) begin
        case (alu_control)
            ADD: result = a + b;                    // Addition
            SUB: result = a - b;                    // Subtraction
            AND: result = a & b;                    // Bitwise AND
            SLL: result = a << b[3:0];              // Shift left (use lower 4 bits of b)
            OR:  result = a | b;                    // Bitwise OR
            XOR: result = a ^ b;                    // Bitwise XOR
            SLT: result = ($signed(a) < $signed(b)) ? 16'd1 : 16'd0; // Set less than
            default: result = 16'h0000;             // Default to 0
        endcase
    end
    
    // Zero flag: 1 if result is zero (used for beq/bne)
    assign zero = (result == 16'h0000);
 
endmodule