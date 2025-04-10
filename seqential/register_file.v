module register_file(
    input              clk,
    input              reset,
    input              RegWrite,
    input      [4:0]   rs1,
    input      [4:0]   rs2,
    input      [4:0]   rd,
    input      [63:0]  write_data,
    output     [63:0]  read_data1,
    output     [63:0]  read_data2
);

    reg [63:0] regs [31:0];
    integer i;

    always @(posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 64'b0;
            end
            regs[5'b01]<=64'b101;//5
            regs[5'b10]<=64'b01010;//10
            regs[5'b11]<=64'b10100;//20
            regs[5'b100]<=64'b10;//1
        end
    end

    always @(posedge clk) begin
        if (RegWrite && (rd != 5'd0)) begin
            regs[rd] <= write_data;
        end
    end

    wire [63:0] rs1_data, rs2_data;
    assign rs1_data = regs[rs1];
    assign rs2_data = regs[rs2];

    mux2x1 mux_read_data1 [63:0] (
        .a(64'b0),
        .b(rs1_data),
        .sel(rs1 != 5'd0),
        .y(read_data1)
    );

    mux2x1 mux_read_data2 [63:0] (
        .a(64'b0),
        .b(rs2_data),
        .sel(rs2 != 5'd0),
        .y(read_data2)
    );

endmodule

