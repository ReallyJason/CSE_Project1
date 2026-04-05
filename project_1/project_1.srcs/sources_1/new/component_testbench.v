//==============================================================================
// Testbench for Individual Components
// Tests: Control Unit, ALU, Data Memory, Instruction Memory
//==============================================================================

`timescale 1ns/1ps

module component_testbench;

    // Clock
    reg clk;
    
    // Test signals
    reg [3:0] opcode;
    reg [15:0] alu_a, alu_b;
    reg [2:0] alu_control;
    reg [15:0] mem_addr, mem_write_data;
    reg mem_write, mem_read;
    
    // Outputs
    wire reg_write, mem_to_reg, mem_write_out, mem_read_out;
    wire alu_src, branch, branch_ne, jump;
    wire [1:0] alu_op;
    wire [15:0] alu_result;
    wire [15:0] mem_read_data;
    wire zero;
    
    // For register files
    reg [3:0] rs, rt, rd;
    reg [15:0] reg_write_data_in;
    wire [15:0] read_data1, read_data2;
    
    // Instantiate modules
    control_unit ctrl(
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write_out),
        .mem_read(mem_read_out),
        .alu_src(alu_src),
        .branch(branch),
        .branch_ne(branch_ne),
        .jump(jump),
        .alu_op(alu_op)
    );
    
    alu test_alu(
        .a(alu_a),
        .b(alu_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );
    
    data_memory dmem(
        .clk(clk),
        .address(mem_addr),
        .write_data(mem_write_data),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_read_data)
    );
   
    register_file reg_file(
        .clk(clk),
        .reg_write(reg_write),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(rd),
        .write_data(reg_write_data_in),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        $display("===========================================");
        $display("Component Testing Started");
        $display("===========================================\n");
        
        // Initialize
        opcode = 4'b0000;
        alu_a = 16'd0;
        alu_b = 16'd0;
        alu_control = 3'b000;
        mem_addr = 16'd0;
        mem_write_data = 16'd0;
        mem_write = 0;
        mem_read = 0;
        
        #10;
        
        //===================================
        // TEST 1: Control Unit - LW
        //===================================
        $display("TEST 1: Control Unit - LW Instruction");
        opcode = 4'b0001; // LW
        #1;
        $display("Opcode: LW (0001)");
        $display("  RegWrite=%b (expect 1)", reg_write);
        $display("  MemToReg=%b (expect 1)", mem_to_reg);
        $display("  MemRead=%b (expect 1)", mem_read_out);
        $display("  MemWrite=%b (expect 0)", mem_write_out);
        $display("  ALUSrc=%b (expect 1)", alu_src);
        $display("  ALUOp=%b (expect 00)\n", alu_op);
        
        //===================================
        // TEST 2: Control Unit - SW
        //===================================
        $display("TEST 2: Control Unit - SW Instruction");
        opcode = 4'b0010; // SW
        #1;
        $display("Opcode: SW (0010)");
        $display("  RegWrite=%b (expect 0)", reg_write);
        $display("  MemWrite=%b (expect 1)", mem_write_out);
        $display("  MemRead=%b (expect 0)", mem_read_out);
        $display("  ALUSrc=%b (expect 1)", alu_src);
        $display("  ALUOp=%b (expect 00)\n", alu_op);
        
        //===================================
        // TEST 3: Control Unit - ADDI
        //===================================
        $display("TEST 3: Control Unit - ADDI Instruction");
        opcode = 4'b0011; // ADDI
        #1;
        $display("Opcode: ADDI (0011)");
        $display("  RegWrite=%b (expect 1)", reg_write);
        $display("  MemToReg=%b (expect 0)", mem_to_reg);
        $display("  ALUSrc=%b (expect 1)", alu_src);
        $display("  ALUOp=%b (expect 00)\n", alu_op);
        
        //===================================
        // TEST 4: ALU - Addition
        //===================================
        $display("TEST 4: ALU - Addition");
        alu_a = 16'd10;
        alu_b = 16'd25;
        alu_control = 3'b000; // ADD
        #1;
        $display("  10 + 25 = %d (expect 35)", alu_result);
        $display("  Zero flag = %b (expect 0)\n", zero);
        
        //===================================
        // TEST 5: ALU - Subtraction
        //===================================
        $display("TEST 5: ALU - Subtraction");
        alu_a = 16'd50;
        alu_b = 16'd20;
        alu_control = 3'b001; // SUB
        #1;
        $display("  50 - 20 = %d (expect 30)", alu_result);
        $display("  Zero flag = %b (expect 0)\n", zero);
        
        //===================================
        // TEST 6: ALU - Zero Flag
        //===================================
        $display("TEST 6: ALU - Zero Flag (for branches)");
        alu_a = 16'd15;
        alu_b = 16'd15;
        alu_control = 3'b001; // SUB
        #1;
        $display("  15 - 15 = %d (expect 0)", alu_result);
        $display("  Zero flag = %b (expect 1)\n", zero);
        
        //===================================
        // TEST 7: ALU - AND operation
        //===================================
        $display("TEST 7: ALU - AND Operation");
        alu_a = 16'hFF00;
        alu_b = 16'h0FFF;
        alu_control = 3'b010; // AND
        #1;
        $display("  0xFF00 & 0x0FFF = 0x%h (expect 0x0F00)", alu_result);
        $display("  Zero flag = %b\n", zero);
        
        //===================================
        // TEST 8: ALU - Shift Left
        //===================================
        $display("TEST 8: ALU - Shift Left Logical");
        alu_a = 16'h0005;  // 0000 0000 0000 0101
        alu_b = 16'd2;     // Shift by 2
        alu_control = 3'b011; // SLL
        #1;
        $display("  0x0005 << 2 = 0x%h (expect 0x0014)", alu_result);
        $display("  Zero flag = %b\n", zero);
        
        //===================================
        // TEST 9: Data Memory - Write
        //===================================
        $display("TEST 9: Data Memory - Write Operation");
        @(posedge clk);
        mem_addr = 16'd10;
        mem_write_data = 16'hABCD;
        mem_write = 1;
        mem_read = 0;
        @(posedge clk);
        mem_write = 0;
        #1;
        $display("  Wrote 0xABCD to address 10\n");
        
        //===================================
        // TEST 10: Data Memory - Read
        //===================================
        $display("TEST 10: Data Memory - Read Operation");
        mem_addr = 16'd10;
        mem_write = 0;
        mem_read = 1;
        #1;
        $display("  Read from address 10: 0x%h (expect 0xABCD)\n", mem_read_data);
        
        //===================================
        // TEST 11: Store and Load Sequence
        //===================================
        $display("TEST 11: Complete SW-LW Sequence");
        
        // Store
        @(posedge clk);
        mem_addr = 16'd20;
        mem_write_data = 16'd12345;
        mem_write = 1;
        mem_read = 0;
        $display("  Storing 12345 at address 20");
        
        @(posedge clk);
        mem_write = 0;
        
        // Load
        #1;
        mem_addr = 16'd20;
        mem_read = 1;
        #1;
        $display("  Loading from address 20: %d (expect 12345)\n", mem_read_data);
        
        //===================================
        // TEST 12: Control Unit - R-Type (ADD, SUB, AND, SLL)
        //===================================
        $display("TEST 12: Control Unit - R-Type (ADD, SUB, AND, SLL)");
        opcode = 4'b0000; // OP_RTYPE
        #1;
        $display("Opcode: R-Type (0000)");
        $display("  RegWrite=%b (expect 1)", reg_write);
        $display("  MemToReg=%b (expect 0)", mem_to_reg);
        $display("  ALUSrc=%b (expect 0)", alu_src);
        $display("  ALUOp=%b (expect 10)\n", alu_op);
        
        //===================================
        // TEST 13: Register File - Write & Read Test
        //===================================
        $display("TEST 13: Register File - Write & Read (reg_write test)");
        opcode = 4'b0011; //use addi to make reg_write = 1 
        #1;
        rd = 4'd8;            // Write to $s8
        reg_write_data_in = 16'hAAAA;
        @(posedge clk);
        
        opcode = 4'b0010; // Turn off reg_write using SW
        #1;
        rs = 4'd8;            // Read from $s8
        #1;
        $display("  Wrote 0xAAAA to $s8 with Control Unit reg_write=%b", reg_write);
        $display("  Read from $s8: 0x%h (expect 0xAAAA)\n", read_data1);

        //===================================
        // TEST 14: Register File - Multi-Port Read & No-Write
        //===================================
        $display("TEST 14: Register File - Multi-Port Read & No-Write Test");
        opcode = 4'b0011; //use addi to make reg_write = 1 
        #1;
        rd = 4'd9;            // Write to $s9
        reg_write_data_in = 16'h5555;
        @(posedge clk);
        
        opcode = 4'b0010; // Turn off reg_write using SW
        #1;
        rd = 4'd10;  // Write from $s10
        reg_write_data_in = 16'hFFFF;
        @(posedge clk);
        
        // Read $s8 and $s9 simultaneously, then check $s10
        rs = 4'd8;
        rt = 4'd9;
        #1;
        $display("  Read $s8 on port 1: 0x%h (expect 0xAAAA)", read_data1);
        $display("  Read $s9 on port 2: 0x%h (expect 0x5555)", read_data2);
        
        rs = 4'd10; // Check $s10
        #1;
        $display("  Read $s10 (write attempted with reg_write=0): 0x%h (expect 0x0000)\n", read_data1);
        
        //===================================
        // Summary
        //===================================
        #20;
        $display("===========================================");
        $display("Component Testing Completed");
        $display("===========================================");
        
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("Time=%0t clk=%b", $time, clk);
    end

endmodule


//==============================================================================
// Testbench for Sign Extension
//==============================================================================

module sign_extend_tb;
    reg [3:0] imm_in;
    wire [15:0] imm_out;
    
    SignExtension se(
        .imm_in(imm_in),
        .imm_out(imm_out)
    );
    
    initial begin
        $display("\n=== Sign Extension Test ===");
        
        // Positive numbers
        imm_in = 4'b0000; #1;
        $display("0000 -> 0x%h (expect 0x0000)", imm_out);
        
        imm_in = 4'b0101; #1;
        $display("0101 -> 0x%h (expect 0x0005)", imm_out);
        
        imm_in = 4'b0111; #1;
        $display("0111 -> 0x%h (expect 0x0007)", imm_out);
        
        // Negative numbers
        imm_in = 4'b1111; #1;
        $display("1111 -> 0x%h (expect 0xFFFF = -1)", imm_out);
        
        imm_in = 4'b1000; #1;
        $display("1000 -> 0x%h (expect 0xFFF8 = -8)", imm_out);
        
        imm_in = 4'b1010; #1;
        $display("1010 -> 0x%h (expect 0xFFFA = -6)", imm_out);
        
        $display("=========================\n");
        $finish;
    end
endmodule