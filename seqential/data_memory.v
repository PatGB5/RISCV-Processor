module data_memory (
    input clk,
    input MemRead,
    input MemWrite,
    input [63:0] addr,
    input [63:0] write_data,
    output reg [63:0] read_data
);
    reg [63:0] memory [0:1023];

    always @(posedge clk) begin
        if (MemWrite) begin
            memory[addr[9:0]] <= write_data;
        end
    end

    always @(*) begin
        if (MemRead) begin
            read_data = memory[addr[9:0]];
        end else begin
            read_data = 64'b0;
        end
    end
endmodule