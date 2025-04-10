module reg_file (
    input  wire         clk,
    input  wire         regWrite,
    input  wire [4:0]   readReg1,
    input  wire [4:0]   readReg2,
    input  wire [4:0]   writeReg,
    input  wire [63:0]  writeData,
    output reg [63:0]  readData1,
    output reg [63:0]  readData2
);
    reg [63:0] registers [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 64'b0;
        
        registers[5'b00101] <= 64'b101;    // 5
        registers[5'b00110] <= 64'b110;   // 10
        registers[5'b00111] <= 64'b111;  // 20
        registers[5'b01000] <= 64'b1000;     // 2
        registers[5'b01001] <= 64'b1001;    // 5
        registers[5'b01010] <= 64'b1010;   // 10
        registers[5'b01011] <= 64'b1011;  // 20
    end

    always @(negedge clk) begin
        if (regWrite && (writeReg != 0))
            registers[writeReg] <= writeData;
    end

    always @(*) begin
        if (readReg1 == 0)
            readData1 = 64'b0;
        else
            readData1 = registers[readReg1];
    end

    always @(*) begin
        if (readReg2 == 0)
            readData2 = 64'b0;
        else
            readData2 = registers[readReg2];
    end
endmodule




