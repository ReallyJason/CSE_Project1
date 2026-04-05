`timescale 1ns/1ps

module component_testbench;

    //=========================================================
    // Clock
    //=========================================================
    reg clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //=========================================================
    // Original signals: Control Unit / ALU / Data Memory
    //=========================================================
    reg [3:0] opcode;
    reg [15:0] alu_a, alu_b;
    reg [2:0] alu_control;
    reg [15:0] mem_addr, mem_write_data;
    reg mem_write, mem_read;

    wire reg_write, mem_to_reg, mem_write_out, mem_read_out;
    wire alu_src, branch, branch_ne, jump;
    wire [1:0] alu_op;
    wire [15:0] alu_result, mem_read_data;
    wire zero;

    //=========================================================
    // Extra signals: Instruction Memory
    //=========================================================
    reg  [15:0] im_addr;
    wire [15:0] im_instruction;

    //=========================================================
    // Extra signals: Instruction Decode
    //=========================================================
    reg  [15:0] id_instruction;
    wire [3:0]  id_opcode, id_rt_rd, id_rs, id_funct, id_immediate;
    wire [11:0] id_jump_addr;
    wire [15:0] id_imm_sign_ext, id_branch_offset, id_jump_offset;

    //=========================================================
    // Extra signals: Write-Back Mux
    //=========================================================
    reg  [15:0] wb_alu_data;
    reg  [15:0] wb_mem_data;
    reg         wb_sel;
    wire [15:0] wb_write_data;

    //=========================================================
    // Extra signals: Register File
    //=========================================================
    reg  [3:0] rs, rt, rd;
    reg  [15:0] reg_write_data_in;
    wire [15:0] read_data1, read_data2;

    //=========================================================
    // Extra signals: PC path
    //=========================================================
    reg  [15:0] pc_next;
    wire [15:0] pc_current;

    reg  [15:0] pc_plus2_in;
    reg  [15:0] pc_branch_addr;
    reg         pc_mux_sel;
    wire [15:0] pc_mux_out;

    //=========================================================
    // Extra signals: Branch / Jump Unit
    //=========================================================
    reg  [15:0] bj_read_data1, bj_read_data2;
    reg  [15:0] bj_pc_plus2, bj_branch_offset, bj_jump_offset;
    reg         bj_branch_eq, bj_branch_ne, bj_jump;
    wire [15:0] bj_branch_target, bj_jump_target;
    wire        bj_pc_src;

    //=========================================================
    // Instantiate original modules
    //=========================================================
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

    //=========================================================
    // Instantiate added modules
    //=========================================================
    instruction_memory imem(
        .address(im_addr),
        .instruction(im_instruction)
    );

    instruction_decode idec(
        .instruction(id_instruction),
        .opcode(id_opcode),
        .rt_rd(id_rt_rd),
        .rs(id_rs),
        .funct(id_funct),
        .immediate(id_immediate),
        .jump_addr(id_jump_addr),
        .imm_sign_ext(id_imm_sign_ext),
        .branch_offset(id_branch_offset),
        .jump_offset(id_jump_offset)
    );

    mux_wb writeback_mux(
        .alu_result(wb_alu_data),
        .mem_data(wb_mem_data),
        .sel(wb_sel),
        .write_data(wb_write_data)
    );

    register_file rf(
        .clk(clk),
        .reg_write(reg_write),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_data(reg_write_data_in),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    mux_pc pc_mux(
        .pc_plus2(pc_plus2_in),
        .branch_addr(pc_branch_addr),
        .sel(pc_mux_sel),
        .next_pc(pc_mux_out)
    );

    ProgramCounter_16bit pc_reg(
        .clk(clk),
        .next(pc_next),
        .current(pc_current)
    );

    branch_jump bj_unit(
        .read_data1(bj_read_data1),
        .read_data2(bj_read_data2),
        .pc_plus2(bj_pc_plus2),
        .branch_offset(bj_branch_offset),
        .jump_offset(bj_jump_offset),
        .branch_eq(bj_branch_eq),
        .branch_ne(bj_branch_ne),
        .jump(bj_jump),
        .branch_target(bj_branch_target),
        .jump_target(bj_jump_target),
        .pc_src(bj_pc_src)
    );

    //=========================================================
    // Test sequence
    //=========================================================
    initial begin
        $display("===========================================");
        $display("Full Component Testing Started");
        $display("===========================================\n");

        // Initialize original signals
        opcode = 4'b0000;
        alu_a = 16'd0;
        alu_b = 16'd0;
        alu_control = 3'b000;
        mem_addr = 16'd0;
        mem_write_data = 16'd0;
        mem_write = 0;
        mem_read = 0;

        // Initialize extra signals
        rs = 4'd0;
        rt = 4'd0;
        rd = 4'd0;
        reg_write_data_in = 16'd0;

        im_addr = 16'd0;
        id_instruction = 16'd0;

        wb_alu_data = 16'd0;
        wb_mem_data = 16'd0;
        wb_sel = 1'b0;

        pc_next = 16'd0;
        pc_plus2_in = 16'd0;
        pc_branch_addr = 16'd0;
        pc_mux_sel = 1'b0;

        bj_read_data1 = 16'd0;
        bj_read_data2 = 16'd0;
        bj_pc_plus2 = 16'd0;
        bj_branch_offset = 16'd0;
        bj_jump_offset = 16'd0;
        bj_branch_eq = 1'b0;
        bj_branch_ne = 1'b0;
        bj_jump = 1'b0;

        #10;

        //===================================
        // TEST 1: Control Unit - LW
        //===================================
        $display("TEST 1: Control Unit - LW Instruction");
        opcode = 4'b0001;
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
        opcode = 4'b0010;
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
        opcode = 4'b0011;
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
        alu_control = 3'b000;
        #1;
        $display("  10 + 25 = %d (expect 35)", alu_result);
        $display("  Zero flag = %b (expect 0)\n", zero);

        //===================================
        // TEST 5: ALU - Subtraction
        //===================================
        $display("TEST 5: ALU - Subtraction");
        alu_a = 16'd50;
        alu_b = 16'd20;
        alu_control = 3'b001;
        #1;
        $display("  50 - 20 = %d (expect 30)", alu_result);
        $display("  Zero flag = %b (expect 0)\n", zero);

        //===================================
        // TEST 6: ALU - Zero Flag
        //===================================
        $display("TEST 6: ALU - Zero Flag (for branches)");
        alu_a = 16'd15;
        alu_b = 16'd15;
        alu_control = 3'b001;
        #1;
        $display("  15 - 15 = %d (expect 0)", alu_result);
        $display("  Zero flag = %b (expect 1)\n", zero);

        //===================================
        // TEST 7: ALU - AND Operation
        //===================================
        $display("TEST 7: ALU - AND Operation");
        alu_a = 16'hFF00;
        alu_b = 16'h0FFF;
        alu_control = 3'b010;
        #1;
        $display("  0xFF00 & 0x0FFF = 0x%h (expect 0x0F00)", alu_result);
        $display("  Zero flag = %b\n", zero);

        //===================================
        // TEST 8: ALU - Shift Left
        //===================================
        $display("TEST 8: ALU - Shift Left Logical");
        alu_a = 16'h0005;
        alu_b = 16'd2;
        alu_control = 3'b011;
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
        @(posedge clk);
        mem_addr = 16'd20;
        mem_write_data = 16'd12345;
        mem_write = 1;
        mem_read = 0;
        $display("  Storing 12345 at address 20");

        @(posedge clk);
        mem_write = 0;

        #1;
        mem_addr = 16'd20;
        mem_read = 1;
        #1;
        $display("  Loading from address 20: %d (expect 12345)\n", mem_read_data);

        //===================================
        // TEST 12: Instruction Memory - Direct Fetch
        //===================================
        $display("TEST 12: Instruction Memory - Direct Fetch");
        im_addr = 16'd0;  #1;
        $display("  IMEM[0x0000] = 0x%h", im_instruction);

        im_addr = 16'd2;  #1;
        $display("  IMEM[0x0002] = 0x%h", im_instruction);

        im_addr = 16'd4;  #1;
        $display("  IMEM[0x0004] = 0x%h", im_instruction);

        im_addr = 16'd6;  #1;
        $display("  IMEM[0x0006] = 0x%h\n", im_instruction);

        //===================================
        // TEST 13: Instruction Decode
        //===================================
        $display("TEST 13: Instruction Decode");

        id_instruction = 16'h354F; #1;
        $display("  Instr=0x354F");
        $display("    opcode       = 0x%h (expect 3)", id_opcode);
        $display("    rt_rd        = 0x%h (expect 5)", id_rt_rd);
        $display("    rs           = 0x%h (expect 4)", id_rs);
        $display("    immediate    = 0x%h (expect F)", id_immediate);
        $display("    imm_sign_ext = 0x%h (expect FFFF)", id_imm_sign_ext);

        id_instruction = 16'h4122; #1;
        $display("  Instr=0x4122");
        $display("    opcode       = 0x%h (expect 4)", id_opcode);
        $display("    branch_offset= 0x%h", id_branch_offset);

        id_instruction = 16'h6004; #1;
        $display("  Instr=0x6004");
        $display("    opcode       = 0x%h (expect 6)", id_opcode);
        $display("    jump_addr    = 0x%h (expect 004)", id_jump_addr);
        $display("    jump_offset  = 0x%h (expect 0x0008)\n", id_jump_offset);

        //===================================
        // TEST 14: Write-Back Mux
        //===================================
        $display("TEST 14: Write-Back Mux");
        wb_alu_data = 16'h001C;
        wb_mem_data = 16'hABCD;

        wb_sel = 1'b0; #1;
        $display("  sel=0 -> wb_write_data = 0x%h (expect 0x001C)", wb_write_data);

        wb_sel = 1'b1; #1;
        $display("  sel=1 -> wb_write_data = 0x%h (expect 0xABCD)\n", wb_write_data);

        //===================================
        // TEST 15: Register File - Write / Read
        //===================================
        $display("TEST 15: Register File - Write / Read");

        opcode = 4'b0011; // use reg_write=1 from control unit

        rs = 4'd3;
        rt = 4'd0;
        rd = 4'd3;
        reg_write_data_in = 16'd55;
        @(posedge clk);
        #1;
        $display("  Read R3 = %d (expect 55)", read_data1);

        rs = 4'd7;
        rt = 4'd0;
        rd = 4'd7;
        reg_write_data_in = 16'd1234;
        @(posedge clk);
        #1;
        $display("  Read R7 = %d (expect 1234)\n", read_data1);

        //===================================
        // TEST 16: ALU -> WriteBack -> Register File
        //===================================
        $display("TEST 16: ALU -> WriteBack -> Register File");
        wb_alu_data = 16'd999;
        wb_mem_data = 16'd2222;
        wb_sel = 1'b0;

        rs = 4'd5;
        rt = 4'd0;
        rd = 4'd5;
        reg_write_data_in = wb_write_data;
        opcode = 4'b0011;
        @(posedge clk);
        #1;
        $display("  R5 after ALU write-back = %d (expect 999)\n", read_data1);

        //===================================
        // TEST 17: MEM -> WriteBack -> Register File
        //===================================
        $display("TEST 17: MEM -> WriteBack -> Register File");
        wb_alu_data = 16'd111;
        wb_mem_data = 16'd4321;
        wb_sel = 1'b1;

        rs = 4'd6;
        rt = 4'd0;
        rd = 4'd6;
        reg_write_data_in = wb_write_data;
        opcode = 4'b0011;
        @(posedge clk);
        #1;
        $display("  R6 after MEM write-back = %d (expect 4321)\n", read_data1);

        //===================================
        // TEST 18: PC Mux Route
        //===================================
        $display("TEST 18: PC Mux Route");
        pc_plus2_in = 16'd32;
        pc_branch_addr = 16'd42;

        pc_mux_sel = 1'b0; #1;
        $display("  sel=0 -> next_pc = %d (expect 32)", pc_mux_out);

        pc_mux_sel = 1'b1; #1;
        $display("  sel=1 -> next_pc = %d (expect 42)\n", pc_mux_out);

        //===================================
        // TEST 19: Program Counter Register
        //===================================
        $display("TEST 19: Program Counter Register");
        pc_next = 16'd100;
        @(posedge clk);
        #1;
        $display("  PC current = %d (expect 100)", pc_current);

        pc_next = 16'd102;
        @(posedge clk);
        #1;
        $display("  PC current = %d (expect 102)\n", pc_current);

        //===================================
        // TEST 20: Branch / Jump Unit
        //===================================
        $display("TEST 20: Branch / Jump Unit");

        bj_read_data1 = 16'd10;
        bj_read_data2 = 16'd10;
        bj_pc_plus2 = 16'd20;
        bj_branch_offset = 16'd6;
        bj_jump_offset = 16'd8;
        bj_branch_eq = 1'b1;
        bj_branch_ne = 1'b0;
        bj_jump = 1'b0;
        #1;
        $display("  BEQ case: pc_src=%b (expect 1), branch_target=%d (expect 26)",
                 bj_pc_src, bj_branch_target);

        bj_read_data1 = 16'd10;
        bj_read_data2 = 16'd5;
        bj_branch_eq = 1'b0;
        bj_branch_ne = 1'b1;
        bj_jump = 1'b0;
        #1;
        $display("  BNE case: pc_src=%b (expect 1), branch_target=%d (expect 26)",
                 bj_pc_src, bj_branch_target);

        bj_read_data1 = 16'd0;
        bj_read_data2 = 16'd0;
        bj_branch_eq = 1'b0;
        bj_branch_ne = 1'b0;
        bj_jump = 1'b1;
        bj_pc_plus2 = 16'd20;
        bj_jump_offset = 16'd12;
        #1;
        $display("  JMP case: pc_src=%b (expect 1), jump_target=%d (expect 32)\n",
                 bj_pc_src, bj_jump_target);

        //===================================
        // Summary
        //===================================
        #20;
        $display("===========================================");
        $display("Full Component Testing Completed");
        $display("===========================================");

        $finish;
    end

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

        imm_in = 4'b0000; #1;
        $display("0000 -> 0x%h (expect 0x0000)", imm_out);

        imm_in = 4'b0101; #1;
        $display("0101 -> 0x%h (expect 0x0005)", imm_out);

        imm_in = 4'b0111; #1;
        $display("0111 -> 0x%h (expect 0x0007)", imm_out);

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

