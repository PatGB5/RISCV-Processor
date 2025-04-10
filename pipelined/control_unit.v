module control_unit(
    input  [6:0] opcode,
    output       RegWrite,
    output       MemtoReg,
    output       MemRead,
    output       MemWrite,
    output       Branch,
    output       ALUSrc,
    output [1:0] ALUOp
);

    reg reg_write_r;
    reg mem_to_reg_r;
    reg mem_read_r;
    reg mem_write_r;
    reg branch_r;
    reg alu_src_r;
    reg [1:0] alu_op_r;

    always @(*) begin
        reg_write_r  = 0;
        mem_to_reg_r = 0;
        mem_read_r   = 0;
        mem_write_r  = 0;
        branch_r     = 0;
        alu_src_r    = 0;
        alu_op_r     = 2'b00;

        case (opcode)
            7'b0110011: begin  // R-type instructions
                reg_write_r  = 1;
                alu_src_r    = 0;
                mem_to_reg_r = 0;
                mem_read_r   = 0;
                mem_write_r  = 0;
                branch_r     = 0;
                alu_op_r     = 2'b10; 
            end
            7'b0000011: begin  // Load instructions
                reg_write_r  = 1;
                alu_src_r    = 1; 
                mem_to_reg_r = 1; 
                mem_read_r   = 1;
                mem_write_r  = 0;
                branch_r     = 0;
                alu_op_r     = 2'b00;
            end
            7'b0100011: begin  // Store instructions
                reg_write_r  = 0;
                alu_src_r    = 1;
                mem_to_reg_r = 0;
                mem_read_r   = 0;
                mem_write_r  = 1;
                branch_r     = 0;
                alu_op_r     = 2'b00;
            end
            7'b1100011: begin  // Branch instructions
                reg_write_r  = 0;
                alu_src_r    = 0;
                mem_to_reg_r = 0;
                mem_read_r   = 0;
                mem_write_r  = 0;
                branch_r     = 1;
                alu_op_r     = 2'b01;
            end
            default: begin
            end
        endcase
    end

    assign RegWrite = reg_write_r;
    assign MemtoReg = mem_to_reg_r;
    assign MemRead  = mem_read_r;
    assign MemWrite = mem_write_r;
    assign Branch   = branch_r;
    assign ALUSrc   = alu_src_r;
    assign ALUOp    = alu_op_r;

endmodule