module mux2x1_64 (
    input  [63:0] a,
    input  [63:0] b,
    input  sel,
    output [63:0] y
);
  wire not_sel;
  wire [63:0] w1, w2;
  not (not_sel, sel);
  assign w1 = a & {64{not_sel}};
  assign w2 = b & {64{sel}};
  assign y = w1 | w2;
endmodule


module cpu (
    input clk,
    input reset,
    output reg [63:0] pc,
    output [63:0] alu_result,
    output alu_zero
);
    wire [63:0] reg_data1, reg_data2, imm_out, alu_in2, mem_read_data, write_data;
    wire [31:0] instruction;
    wire [4:0] rs1, rs2, rd;
    wire [1:0] ALUOp;
    wire ALUSrc, MemRead, MemWrite, MemtoReg, Branch, RegWrite;
    wire [1:0] ALUControl;
    wire [63:0] next_pc;

    //=========================
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 64'b0;
        else
            pc <= next_pc;
    end

    //=========================
    wire [63:0] pc_plus_4, branch_target;
    assign pc_plus_4 = pc + 1;
    assign branch_target = pc + (imm_out);

    wire branch_taken;
    and (branch_taken, Branch, alu_zero);

    mux2x1_64 mux_next_pc (
        .a(pc_plus_4),
        .b(branch_target),
        .sel(branch_taken),
        .y(next_pc)
    );

    //=========================
    instruction_memory instr_mem (
        .addr(pc),
        .instruction(instruction)
    );

    //=========================
    control_unit ctrl_unit (
        .opcode(instruction[6:0]),
        .ALUOp(ALUOp),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .RegWrite(RegWrite)
    );

    //=========================
    register_file reg_file (
        .clk(clk),
        .reset(reset),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .write_data(write_data),
        .RegWrite(RegWrite),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    //=========================
    immediate_gen immgen (
        .instruction(instruction),
        .imm_out(imm_out)
    );

    //=========================
    alu_control alu_ctrl (
        .ALUOp(ALUOp),
        .func3(instruction[14:12]),
        .func7_5(instruction[30]),
        .ALUControl(ALUControl)
    );

    //=========================
    mux2x1_64 alu_mux (
        .a(reg_data2),
        .b(imm_out),
        .sel(ALUSrc),
        .y(alu_in2)
    );

    //=========================
    alu my_alu (
        .a(reg_data1),
        .b(alu_in2),
        .ALUControl(ALUControl),
        .result(alu_result),
        .zero_flag(alu_zero)
    );

    //=========================
    data_memory dmem (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(alu_result),
        .write_data(reg_data2),
        .read_data(mem_read_data)
    );

    //=========================
    mux2x1_64 write_data_mux (
        .a(alu_result),
        .b(mem_read_data),
        .sel(MemtoReg),
        .y(write_data)
    );

    
endmodule