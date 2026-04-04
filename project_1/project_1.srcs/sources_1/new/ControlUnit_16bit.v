`timescale 1ns / 1ps

module ControlUnit_16bit(
    input wire opcode,
  
    output reg RegDst, //check if  stores in rd(add)(1) or rt(addi)(0)
    output reg Branch,
    output reg BNE, 
    output reg Jump,
    output reg MemRead, 
    output reg MemtoReg,
    output reg [1:0] ALUOp, //00=ADD (sw and lw) 01=SUB and 10=look at func
    output reg MemWrite,
    output reg ALUSrc, //0=read from regi 1=read sign extension
    output reg RegWrite
    );
    
    always @(*) begin
        case (opcode)
            4'b0000: begin //r-type
                RegDst = 1'b1;   
                ALUSrc = 1'b0;   
                MemtoReg = 1'b0;   
                RegWrite = 1'b1;   
                ALUOp = 2'b10;  
            end
            
            4'b0001: begin //lw
                RegDst = 1'b0;   
                ALUSrc = 1'b1;   
                MemtoReg = 1'b1;   
                RegWrite = 1'b1;   
                MemRead = 1'b1;   
                ALUOp = 2'b00;  
            end
            
            4'b0010: begin //sw
                ALUSrc = 1'b1;   
                MemWrite = 1'b1;   
                ALUOp = 2'b00;  
            end
            4'b0011: begin //addi
                RegDst = 1'b0;   
                ALUSrc = 1'b1;   
                MemtoReg = 1'b0;   
                RegWrite = 1'b1;   
                ALUOp = 2'b00;  
            end
            4'b0100: begin //beq
                ALUSrc = 1'b0;   
                Branch = 1'b1;   
                ALUOp = 2'b01;  
            end
            4'b0101: begin //bne
                ALUSrc = 1'b0;   
                BNE = 1'b1;   
                ALUOp = 2'b01;  
            end
            4'b0110: begin //bmp
                Jump = 1'b1;
            end
        endcase
    end
endmodule