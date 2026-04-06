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
    
    // Perform operation based on control signal
    always @(*) begin
        case (alu_control)
            ADD: result = a + b;                    // Addition
            SUB: result = a - b;                    // Subtraction
            AND: result = a & b;                    // Bitwise AND
            SLL: result = a << b[3:0];              // Shift left (use lower 4 bits of b)
            default: result = 16'h0000;             // Default to 0
        endcase
    end
    
    // Zero flag: 1 if result is zero (used for beq/bne)
    assign zero = (result == 16'h0000);

endmodule