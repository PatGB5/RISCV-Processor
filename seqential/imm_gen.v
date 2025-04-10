module immediate_gen(
    input  [31:0] instruction,
    output reg [63:0] imm_out
);

    wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        if (opcode == 7'b0000011) begin
            imm_out = {{52{instruction[31]}}, instruction[31:20]};
        end else if (opcode == 7'b0100011) begin
            imm_out = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
        end else if (opcode == 7'b1100011) begin
            imm_out = {{52{instruction[31]}}, instruction[31], instruction[7],
                       instruction[30:25], instruction[11:8]};
        end else begin
            imm_out = 64'b0;
        end
    end

endmodule
