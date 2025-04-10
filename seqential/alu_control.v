module alu_control(
    input  [1:0] ALUOp,
    input  [2:0] func3,
    input        func7_5,
    output reg [1:0] ALUControl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 2'b00; // Load/Store (ADD)
            2'b01: ALUControl = 2'b01; // Branch (SUB)
            2'b10: begin
                case (func3)
                    3'b000: begin
                        if (func7_5) ALUControl = 2'b01;  // SUB
                        else ALUControl = 2'b00;  // ADD
                    end
                    3'b111: ALUControl = 2'b11;  // AND
                    3'b110: ALUControl = 2'b10;  // OR
                endcase
            end
        endcase
    end
endmodule
