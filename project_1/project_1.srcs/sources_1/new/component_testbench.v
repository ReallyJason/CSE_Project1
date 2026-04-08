`timescale 1ns/1ps
module component_testbench;

    reg clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

// ALU, Control unit , Data Memory Signals
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

// Inst Memory
    reg  [15:0] im_addr;
    wire [15:0] im_instruction;
// Inst Decode
    reg  [15:0] id_instruction;
    wire [3:0]  id_opcode, id_rt_rd, id_rs, id_funct, id_immediate;
    wire [11:0] id_jump_addr;
    wire [15:0] id_imm_sign_ext, id_branch_offset, id_jump_offset;

// Write Back MUX
    reg  [15:0] wb_alu_data;
    reg  [15:0] wb_mem_data;
    reg         wb_sel;
    wire [15:0] wb_write_data;

// Reg File
    reg  [3:0] rs, rt, rd;
    reg  [15:0] reg_write_data_in;
    wire [15:0] read_data1, read_data2;

// PC PATH SIGNALS
    reg  [15:0] pc_next;
    wire [15:0] pc_current;

    reg  [15:0] pc_plus2_in;
    reg  [15:0] pc_branch_addr;
    reg         pc_mux_sel;
    wire [15:0] pc_mux_out;

  // BRANCH, JMP UNITS
    reg  [15:0] bj_read_data1, bj_read_data2;
    reg  [15:0] bj_pc_plus2, bj_branch_offset, bj_jump_offset;
    reg         bj_branch_eq, bj_branch_ne, bj_jump;
    wire [15:0] bj_branch_target, bj_jump_target;
    wire        bj_pc_src;

//sign extension    
    reg [3:0] imm_in;
    wire [15:0] imm_out;
    
    
    // Instantiate original modules
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

   
    // Instantiate added modules
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
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(rd),
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
    
    SignExtension se_unit(
        .immediate_in(imm_in),
        .immediate_out(imm_out)
    );

    
    initial begin
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
        
        imm_in=4'b0000;

        #10;

      
        // TEST 1: Control Unit - LW
       
        opcode = 4'b0001;
        #1; 
        
        // TEST 2: Control Unit - SW
       
        opcode = 4'b0010;
        #1;

        // TEST 3: Control Unit - ADDI
       
        opcode = 4'b0011;
        #1;
        
        // TEST 4: ALU - Addition
     
        alu_a = 16'd10;
        alu_b = 16'd25;
        alu_control = 3'b000;
        #1;
     
        // TEST 5: ALU - Subtraction
      
        alu_a = 16'd50;
        alu_b = 16'd20;
        alu_control = 3'b001;
        #1;
      
        // TEST 6: ALU - Zero Flag
     
        alu_a = 16'd15;
        alu_b = 16'd15;
        alu_control = 3'b001;
        #1;
        
        // TEST 7: ALU - AND Operation
       
        alu_a = 16'hFF00;
        alu_b = 16'h0FFF;
        alu_control = 3'b010;
        #1;
     
        // TEST 8: ALU - Shift Left
       
        alu_a = 16'h0005;
        alu_b = 16'd2;
        alu_control = 3'b011;
        #1;
        
        // TEST 9: Data Memory - Write
      
        @(posedge clk);
        mem_addr = 16'd10;
        mem_write_data = 16'hABCD;
        mem_write = 1;
        mem_read = 0;
        @(posedge clk);
        mem_write = 0;
        #1;

        // TEST 10: Data Memory - Read
       
        mem_addr = 16'd10;
        mem_write = 0;
        mem_read = 1;
        #1;
       
        // TEST 11: Store and Load Sequence
      
        @(posedge clk);
        mem_addr = 16'd20;
        mem_write_data = 16'd12345;
        mem_write = 1;
        mem_read = 0;

        @(posedge clk);
        mem_write = 0;

        #1;
        mem_addr = 16'd20;
        mem_read = 1;
        #1;
      
        // TEST 12: Instruction Memory - Direct Fetch
        
        im_addr = 16'd0;  #1;

        im_addr = 16'd2;  #1;

        im_addr = 16'd4;  #1;

        im_addr = 16'd6;  #1;
        
        // TEST  Instruction Decode
      
        id_instruction = 16'h354F; #1;

        id_instruction = 16'h4122; #1;

        id_instruction = 16'h6004; #1;
      
        // TEST : Write-Back Mux
 
        wb_alu_data = 16'h001C;
        wb_mem_data = 16'hABCD;

        wb_sel = 1'b0; #1;

        wb_sel = 1'b1; #1;

       //  TEST 15: Register File - Write / Read
      
        opcode = 4'b0011; 

        rs = 4'd3;
        rt = 4'd0;
        rd = 4'd3;
        reg_write_data_in = 16'd55;
        @(posedge clk);
        #1;

        rs = 4'd7;
        rt = 4'd0;
        rd = 4'd7;
        reg_write_data_in = 16'd1234;
        @(posedge clk);
        #1;

    //  TEST 16: ALU -> WriteBack -> Register File
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

      // TEST 17: MEM -> WriteBack -> Register File
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
        
        //sign extension tests
        imm_in = 4'b0000; #1;

        imm_in = 4'b0101; #1;

        imm_in = 4'b0111; #1;

        imm_in = 4'b1111; #1;

        imm_in = 4'b1000; #1;

        imm_in = 4'b1010; #1;


     // PC TO MUX ROUTE
        pc_plus2_in = 16'd32;
        pc_branch_addr = 16'd42;

        pc_mux_sel = 1'b0; #1;

        pc_mux_sel = 1'b1; #1;

        // Pc REG 
        pc_next = 16'd100;
        @(posedge clk);
        #1;

        pc_next = 16'd102;
        @(posedge clk);
        #1;

        // BRANCH/ JMP UNIT

        bj_read_data1 = 16'd10;
        bj_read_data2 = 16'd10;
        bj_pc_plus2 = 16'd20;
        bj_branch_offset = 16'd6;
        bj_jump_offset = 16'd8;
        bj_branch_eq = 1'b1;
        bj_branch_ne = 1'b0;
        bj_jump = 1'b0;
        #1;

        bj_read_data1 = 16'd10;
        bj_read_data2 = 16'd5;
        bj_branch_eq = 1'b0;
        bj_branch_ne = 1'b1;
        bj_jump = 1'b0;
        #1;

        bj_read_data1 = 16'd0;
        bj_read_data2 = 16'd0;
        bj_branch_eq = 1'b0;
        bj_branch_ne = 1'b0;
        bj_jump = 1'b1;
        bj_pc_plus2 = 16'd20;
        bj_jump_offset = 16'd12;
        #1;


        // end
        #20;        

        $finish;
    end

endmodule