module data_memory (
    input  wire         clk,
    input  wire         memRead,
    input  wire         memWrite,
    input  wire [63:0]  addr,
    input  wire [63:0]  writeData,
    output reg  [63:0]  readData
);
    reg [63:0] ram [0:1023];
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            ram[i] = 64'b0;
    end

    always @(posedge clk) begin
        if (memWrite)
            ram[addr[63:0]] <= writeData;
    end

    always @(*) begin
        if (memRead)
            readData = ram[addr[63:0]];
        else
            readData = 64'b0;
    end
endmodule
