`timescale 1ns / 1ps

module ALU_16bit(
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [2:0] ALUcontrol,
    output reg [15:0] R,
    output zero
    );
    
    always @(*) begin
        if (ALUcontrol == 3'b000)begin
            R = A + B;
        end
        else if (ALUcontrol == 3'b001)begin
            R = A - B;
        end
        else if (ALUcontrol == 3'b010)begin
            R = A << B;
        end
        else if (ALUcontrol == 3'b000)begin    
            R = A & B;
        end
        else begin
            R = 16'b0;
        end
    end
    
    assign Zero = (R == 16'b0);
    
endmodule
