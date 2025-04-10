module hazard_detection_unit (
    input  wire        ID_EX_memRead,
    input  wire [4:0]  ID_EX_rd,
    input  wire [4:0]  IF_ID_rs,
    input  wire [4:0]  IF_ID_rt,
    output reg         pcWrite,
    output reg         if_idWrite,
    output reg         stall,
    output reg         pipelineFlush
);

    always @(*) begin
        pcWrite = 1;
        if_idWrite = 1;
        stall = 0;
        pipelineFlush = 0;


        if (ID_EX_memRead && ((ID_EX_rd == IF_ID_rs) || (ID_EX_rd == IF_ID_rt))) begin
            pcWrite = 0;
            if_idWrite = 0;
            stall = 1;
        end
    end

endmodule