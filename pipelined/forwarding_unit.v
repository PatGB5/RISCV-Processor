module forwarding_unit (
    input  wire       EX_MEM_regWrite,
    input  wire [4:0] EX_MEM_writeReg,
    input  wire       MEM_WB_regWrite,
    input  wire [4:0] MEM_WB_writeReg,
    input  wire [4:0] ID_EX_rs,
    input  wire [4:0] ID_EX_rt,
    output reg [1:0]  forwardA,
    output reg [1:0]  forwardB
);
    always @(*) begin
        forwardA = 2'b00;
        forwardB = 2'b00;
        
        // Forward from EX/MEM stage if needed:
        if (EX_MEM_regWrite && (EX_MEM_writeReg != 0) &&
            (EX_MEM_writeReg == ID_EX_rs))
            forwardA = 2'b10;
        if (EX_MEM_regWrite && (EX_MEM_writeReg != 0) &&
            (EX_MEM_writeReg == ID_EX_rt))
            forwardB = 2'b10;


        // Otherwise, forward from MEM/WB stage if necessary:
        if (MEM_WB_regWrite && (MEM_WB_writeReg != 0) &&
            (MEM_WB_writeReg == ID_EX_rs) &&
            ~(EX_MEM_regWrite && (EX_MEM_writeReg != 0) &&
              (EX_MEM_writeReg == ID_EX_rs)))
            forwardA = 2'b01;
        if (MEM_WB_regWrite && (MEM_WB_writeReg != 0) &&
            (MEM_WB_writeReg == ID_EX_rt) &&
            ~(EX_MEM_regWrite && (EX_MEM_writeReg != 0) &&
              (EX_MEM_writeReg == ID_EX_rt)))
            forwardB = 2'b01;
    end
endmodule
