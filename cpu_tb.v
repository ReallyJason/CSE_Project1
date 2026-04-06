`timescale 1ns/1ps

//==============================================================================
// Combined Testbench

//==============================================================================

module cpu_tb;

    // Clock
    reg clk;
    reg rst;

    // Teammate's test signals
    reg [3:0] opcode;
    reg [15:0] alu_a, alu_b;
    reg [2:0] alu_control;
    reg [15:0] mem_addr, mem_write_data;
    reg mem_write, mem_read;

    // Teammate's outputs
    wire reg_write, mem_to_reg, mem_write_out, mem_read_out;
    wire alu_src, branch, branch_ne, jump;
    wire [1:0] alu_op;
    wire [15:0] alu_result, mem_read_data;
    wire zero;

    // Joshika's instruction decode signals
    reg  [15:0] id_instruction;
    wire [3:0]  id_opcode, id_rt_rd, id_rs, id_funct, id_immediate;
    wire [11:0] id_jump_addr;
    wire [15:0] id_imm_sign_ext, id_branch_offset, id_jump_offset;

    // Joshika's branch/jump signals
    reg  [15:0] bj_pc_plus2;
    reg  [15:0] bj_branch_offset, bj_jump_offset;
    reg         bj_branch, bj_branch_ne, bj_jump, bj_zero;
    wire [15:0] bj_branch_target, bj_jump_target;
    wire        bj_pc_src;

    // Instantiate CPU
    cpu DUT (.clk(clk), .rst(rst));

    // Instantiate control unit
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

    // Instantiate ALU
    alu test_alu(
        .a(alu_a),
        .b(alu_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // Instantiate data memory
    data_memory dmem(
        .clk(clk),
        .address(mem_addr),
        .write_data(mem_write_data),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_read_data)
    );

    // Instantiate instruction decode
    instruction_decode id_test(
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

    // Instantiate branch_jump
    branch_jump bj(
        .read_data1(16'd0),
        .read_data2(16'd0),
        .pc_plus2(bj_pc_plus2),
        .branch_offset(bj_branch_offset),
        .jump_offset(bj_jump_offset),
        .branch(bj_branch),
        .branch_ne(bj_branch_ne),
        .jump(bj_jump),
        .zero(bj_zero),
        .branch_target(bj_branch_target),
        .jump_target(bj_jump_target),
        .pc_src(bj_pc_src)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize
        rst = 0;
        opcode = 4'b0000;
        alu_a = 0; alu_b = 0;
        alu_control = 3'b000;
        mem_addr = 0; mem_write_data = 0;
        mem_write = 0; mem_read = 0;
        id_instruction = 0;
        bj_pc_plus2 = 0; bj_branch_offset = 0;
        bj_jump_offset = 0;
        bj_branch = 0; bj_branch_ne = 0;
        bj_jump = 0; bj_zero = 0;
        #10;

        $display("===========================================");
        $display("Component Testing Started");
        $display("===========================================\n");

        //===================================
        // TEST 1: Control Unit - LW
        //===================================
        $display("TEST 1: Control Unit - LW Instruction");
        opcode = 4'b0001; #1;
        $display("  RegWrite=%b (expect 1)", reg_write);
        $display("  MemToReg=%b (expect 1)", mem_to_reg);
        $display("  MemRead=%b  (expect 1)", mem_read_out);
        $display("  MemWrite=%b (expect 0)", mem_write_out);
        $display("  ALUSrc=%b   (expect 1)", alu_src);
        $display("  ALUOp=%b    (expect 00)\n", alu_op);

        //===================================
        // TEST 2: Control Unit - SW
        //===================================
        $display("TEST 2: Control Unit - SW Instruction");
        opcode = 4'b0010; #1;
        $display("  RegWrite=%b (expect 0)", reg_write);
        $display("  MemWrite=%b (expect 1)", mem_write_out);
        $display("  MemRead=%b  (expect 0)", mem_read_out);
        $display("  ALUSrc=%b   (expect 1)", alu_src);
        $display("  ALUOp=%b    (expect 00)\n", alu_op);

        //===================================
        // TEST 3: Control Unit - ADDI
        //===================================
        $display("TEST 3: Control Unit - ADDI Instruction");
        opcode = 4'b0011; #1;
        $display("  RegWrite=%b (expect 1)", reg_write);
        $display("  MemToReg=%b (expect 0)", mem_to_reg);
        $display("  ALUSrc=%b   (expect 1)", alu_src);
        $display("  ALUOp=%b    (expect 00)\n", alu_op);

        //===================================
        // TEST 4: ALU - Addition
        //===================================
        $display("TEST 4: ALU - Addition");
        alu_a = 16'd10; alu_b = 16'd25;
        alu_control = 3'b000; #1;
        $display("  10 + 25 = %d (expect 35)", alu_result);
        $display("  Zero=%b (expect 0)\n", zero);

        //===================================
        // TEST 5: ALU - Subtraction
        //===================================
        $display("TEST 5: ALU - Subtraction");
        alu_a = 16'd50; alu_b = 16'd20;
        alu_control = 3'b001; #1;
        $display("  50 - 20 = %d (expect 30)", alu_result);
        $display("  Zero=%b (expect 0)\n", zero);

        //===================================
        // TEST 6: ALU - Zero Flag
        //===================================
        $display("TEST 6: ALU - Zero Flag");
        alu_a = 16'd15; alu_b = 16'd15;
        alu_control = 3'b001; #1;
        $display("  15 - 15 = %d (expect 0)", alu_result);
        $display("  Zero=%b (expect 1)\n", zero);

        //===================================
        // TEST 7: ALU - AND
        //===================================
        $display("TEST 7: ALU - AND Operation");
        alu_a = 16'hFF00; alu_b = 16'h0FFF;
        alu_control = 3'b010; #1;
        $display("  0xFF00 & 0x0FFF = 0x%h (expect 0x0F00)", alu_result);
        $display("  Zero=%b\n", zero);

        //===================================
        // TEST 8: ALU - Shift Left
        //===================================
        $display("TEST 8: ALU - Shift Left Logical");
        alu_a = 16'h0005; alu_b = 16'd2;
        alu_control = 3'b011; #1;
        $display("  0x0005 << 2 = 0x%h (expect 0x0014)", alu_result);
        $display("  Zero=%b\n", zero);

        //===================================
        // TEST 9: Data Memory - Write
        //===================================
        $display("TEST 9: Data Memory - Write");
        @(posedge clk);
        mem_addr = 16'd10; mem_write_data = 16'hABCD;
        mem_write = 1; mem_read = 0;
        @(posedge clk);
        mem_write = 0; #1;
        $display("  Wrote 0xABCD to address 10\n");

        //===================================
        // TEST 10: Data Memory - Read
        //===================================
        $display("TEST 10: Data Memory - Read");
        mem_addr = 16'd10; mem_write = 0; mem_read = 1; #1;
        $display("  Read from address 10: 0x%h (expect 0xABCD)\n", mem_read_data);

        //===================================
        // TEST 11: SW-LW Sequence
        //===================================
        $display("TEST 11: Complete SW-LW Sequence");
        @(posedge clk);
        mem_addr = 16'd20; mem_write_data = 16'd12345;
        mem_write = 1; mem_read = 0;
        $display("  Storing 12345 at address 20");
        @(posedge clk);
        mem_write = 0; #1;
        mem_addr = 16'd20; mem_read = 1; #1;
        $display("  Loading from address 20: %d (expect 12345)\n", mem_read_data);

        $display("===========================================");
        $display("Component Testing Completed");
        $display("===========================================\n");

        //===================================
        // JOSHIKA'S TESTS START HERE
        //===================================

        $display("===========================================");
        $display("Joshika's Tests - Instruction Decode");
        $display("===========================================\n");

        // TEST 12: Instruction Decode - ADDI
        $display("TEST 12: Instruction Decode - ADDI (0x3215)");
        id_instruction = 16'h3215; #1;
        $display("  Opcode     = %b (expect 0011)", id_opcode);
        $display("  RT/RD      = %b (expect 0010)", id_rt_rd);
        $display("  RS         = %b (expect 0001)", id_rs);
        $display("  Immediate  = %b (expect 0101)", id_immediate);
        $display("  ImmSignExt = 0x%h (expect 0x0005)", id_imm_sign_ext);
        $display("  BranchOff  = 0x%h (expect 0x000A)\n", id_branch_offset);

        // TEST 13: Negative Immediate
        $display("TEST 13: Instruction Decode - Negative Immediate (0x312F)");
        id_instruction = 16'h312F; #1;
        $display("  Immediate  = %b (expect 1111)", id_immediate);
        $display("  ImmSignExt = 0x%h (expect 0xFFFF)\n", id_imm_sign_ext);

        // TEST 14: BEQ decode
        $display("TEST 14: Instruction Decode - BEQ (0x4122)");
        id_instruction = 16'h4122; #1;
        $display("  Opcode    = %b (expect 0100)", id_opcode);
        $display("  Immediate = %b (expect 0010)", id_immediate);
        $display("  BranchOff = 0x%h (expect 0x0004)\n", id_branch_offset);

        // TEST 15: BNE decode
        $display("TEST 15: Instruction Decode - BNE (0x5122)");
        id_instruction = 16'h5122; #1;
        $display("  Opcode    = %b (expect 0101)", id_opcode);
        $display("  Immediate = %b (expect 0010)", id_immediate);
        $display("  BranchOff = 0x%h (expect 0x0004)\n", id_branch_offset);

        // TEST 16: JMP decode
        $display("TEST 16: Instruction Decode - JMP (0x6002)");
        id_instruction = 16'h6002; #1;
        $display("  Opcode     = %b (expect 0110)", id_opcode);
        $display("  JumpAddr   = %b (expect 000000000010)", id_jump_addr);
        $display("  JumpOffset = 0x%h (expect 0x0004)\n", id_jump_offset);

        $display("===========================================");
        $display("Joshika's Tests - BEQ, BNE, JMP, Branch Adder");
        $display("===========================================\n");

        // TEST 17: BEQ TAKEN
        $display("TEST 17: BEQ - Branch TAKEN (values equal)");
        bj_pc_plus2      = 16'h000E;
        bj_branch_offset = 16'h0004;
        bj_branch        = 1; bj_branch_ne = 0;
        bj_jump          = 0; bj_zero      = 1; #1;
        $display("  PC+2=0x000E offset=0x0004");
        $display("  BranchTarget = 0x%h (expect 0x0012)", bj_branch_target);
        $display("  pc_src = %b (expect 1)\n", bj_pc_src);

        // TEST 18: BEQ NOT TAKEN
        $display("TEST 18: BEQ - Branch NOT TAKEN (values not equal)");
        bj_branch = 1; bj_branch_ne = 0;
        bj_jump   = 0; bj_zero      = 0; #1;
        $display("  pc_src = %b (expect 0)\n", bj_pc_src);

        // TEST 19: BNE TAKEN
        $display("TEST 19: BNE - Branch TAKEN (values not equal)");
        bj_pc_plus2      = 16'h000E;
        bj_branch_offset = 16'h0004;
        bj_branch        = 1; bj_branch_ne = 1;
        bj_jump          = 0; bj_zero      = 0; #1;
        $display("  PC+2=0x000E offset=0x0004");
        $display("  BranchTarget = 0x%h (expect 0x0012)", bj_branch_target);
        $display("  pc_src = %b (expect 1)\n", bj_pc_src);

        // TEST 20: BNE NOT TAKEN
        $display("TEST 20: BNE - Branch NOT TAKEN (values equal)");
        bj_branch = 1; bj_branch_ne = 1;
        bj_jump   = 0; bj_zero      = 1; #1;
        $display("  pc_src = %b (expect 0)\n", bj_pc_src);

        // TEST 21: JMP
        $display("TEST 21: JMP - Unconditional Jump");
        bj_pc_plus2    = 16'h000E;
        bj_jump_offset = 16'h0004;
        bj_branch      = 0; bj_branch_ne = 0;
        bj_jump        = 1; bj_zero      = 0; #1;
        $display("  PC+2=0x000E jump_offset=0x0004");
        $display("  JumpTarget = 0x%h (expect 0x0012)", bj_jump_target);
        $display("  pc_src = %b (expect 1)\n", bj_pc_src);

        // TEST 22: Branch Adder
        $display("TEST 22: Branch Adder");
        bj_pc_plus2      = 16'h0010;
        bj_branch_offset = 16'h0006;
        bj_branch        = 1; bj_branch_ne = 0;
        bj_jump          = 0; bj_zero      = 1; #1;
        $display("  PC+2=0x0010 + offset=0x0006");
        $display("  BranchTarget = 0x%h (expect 0x0016)", bj_branch_target);
        $display("  pc_src = %b (expect 1)\n", bj_pc_src);

        $display("===========================================");
        $display("All Component Tests Done!");
        $display("===========================================\n");

        // Now run full CPU simulation
        $display("===========================================");
        $display("Full CPU Simulation Starting");
        $display("===========================================\n");
        rst = 1; #10; rst = 0;
        #200;

        $display("\n===========================================");
        $display("CPU Simulation Complete!");
        $display("===========================================");
        $finish;
    end

    // CPU monitor
    always @(posedge clk) begin
        if (!rst) begin
            $display("------------------------------------------");
            $display("Time=%0t PC=0x%h Instr=0x%h",
                $time, DUT.pc_out, DUT.instruction);
            $display("RegWrite=%b MemRead=%b MemWrite=%b",
                DUT.reg_write, DUT.mem_read, DUT.mem_write);
            $display("ALUResult=0x%h Zero=%b PC_Src=%b Branch=%b Jump=%b NextPC=0x%h",
                DUT.alu_result, DUT.zero, DUT.pc_src,
                DUT.branch, DUT.jump, DUT.next_pc);
        end
    end

endmodule