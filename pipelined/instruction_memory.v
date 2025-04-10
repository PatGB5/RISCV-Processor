module instruction_memory (
    input [63:0] addr,
    output reg [31:0] instruction
);
    reg [31:0] memory [63:0]; 

    initial begin
        // Load instructions from a text file
        $readmemb("new.txt", memory);
    end

    always @(*) begin
        instruction = memory[addr[63:0]];
    end
endmodule




// STRUCTURAL IMPLEMENTATION

// module memory (
//     input [5:0] addr,
//     output [31:0] data
// );
//     reg [31:0] mem [63:0];

//     initial begin
//         $readmemb("inst.txt", mem);
//     end

//     assign data = mem[addr];
// endmodule

// module address_decoder (
//     input [63:0] addr,
//     output [5:0] decoded_addr
// );
//     assign decoded_addr = addr[5:0];
// endmodule

// module instruction_memory (
//     input [63:0] addr,
//     output [31:0] instruction
// );
//     wire [5:0] decoded_addr;
//     wire [31:0] mem_data;

//     address_decoder addr_dec (
//         .addr(addr),
//         .decoded_addr(decoded_addr)
//     );

//     memory mem (
//         .addr(decoded_addr),
//         .data(mem_data)
//     );

//     assign instruction = mem_data;
// endmodule