module instruction_memory (
    input [63:0] addr,
    output reg [31:0] instruction
);
    reg [31:0] memory [63:0]; 

    initial begin
        // Load instructions from a text file
        $readmemb("topale.txt", memory);
    end

    always @(*) begin
        instruction = memory[addr[63:0]];
    end
endmodule