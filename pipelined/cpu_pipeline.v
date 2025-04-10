module cpu_pipeline (
    input  wire         clk,
    input  wire         reset,
    output wire [63:0]  writeBackData
);

    //==================================================
    // Pipeline Registers
    //==================================================
    // IF/ID registers
    reg [31:0] IF_ID_instr;
    reg [63:0] IF_ID_pcPlus4;

    // ID/EX registers
    reg [63:0] ID_EX_regData1;
    reg [63:0] ID_EX_regData2;
    reg [63:0] ID_EX_signExtImm;
    reg [4:0]  ID_EX_rs, ID_EX_rt, ID_EX_rd;
    reg [63:0] ID_EX_pcPlus4;
    // control signals:
    reg        ID_EX_regWrite, ID_EX_memToReg, ID_EX_memRead, ID_EX_memWrite;
    reg [1:0]  ID_EX_aluOp;
    reg        ID_EX_aluSrc, ID_EX_regDst;
    reg        ID_EX_branch;

    // EX/MEM registers
    reg [63:0] EX_MEM_aluResult;
    reg [63:0] EX_MEM_writeData;
    reg [4:0]  EX_MEM_writeReg;
    reg        EX_MEM_regWrite, EX_MEM_memToReg, EX_MEM_memRead, EX_MEM_memWrite;
    reg        EX_MEM_branch;
    reg [63:0] EX_MEM_pcBranch;
    reg        EX_MEM_zero;
    reg [63:0] EX_MEM_pcPlus4;
    reg [63:0] EX_MEM_signExtImm;

    // MEM/WB registers
    reg [63:0] MEM_WB_aluResult;
    reg [63:0] MEM_WB_memReadData;
    reg [63:0] MEM_WB_pcPlus4;
    reg [4:0]  MEM_WB_writeReg;
    reg        MEM_WB_regWrite, MEM_WB_memToReg;

    //==================================================
    // Hazard and Forwarding signals
    //==================================================
    wire pcWrite, if_idWrite, stall, pipelineFlush;
    reg branchFlush;
    wire [1:0] forwardA, forwardB;

    //==================================================
    // Write Back Mux
    //==================================================
    reg [63:0] wbData;
    always @(*) begin
        if (MEM_WB_memToReg) begin
            wbData = MEM_WB_memReadData;
        end else begin
            wbData = MEM_WB_aluResult;
        end
    end
    assign writeBackData = wbData;

    //==================================================
    // PC and IF Stage
    //==================================================
    reg [63:0] PC_reg;
    wire [63:0] pcCurrent = PC_reg;
    wire [63:0] pcPlus4   = pcCurrent + 1;

    // Next PC Logic:
    // If branch is taken.
    wire branchTaken = (EX_MEM_branch && EX_MEM_zero);

    reg [63:0] nextPC;
    always @(*) begin
        if (branchTaken) begin
            nextPC = EX_MEM_pcBranch;
        end else begin
            nextPC = pcPlus4;
        end
    end
    // Update PC
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC_reg <= 64'b0;
        else if (pcWrite)
            PC_reg <= nextPC;
    end

    //==================================================
    // Instruction Memory (IF Stage)
    //==================================================
    wire [31:0] instruction;
    instruction_memory iMem (
        .addr(pcCurrent[63:0]),
        .instruction(instruction)
    );

    // IF/ID Pipeline Register update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IF_ID_instr   <= 32'b0;
            IF_ID_pcPlus4 <= 64'b0;
        end else if (if_idWrite) begin
            IF_ID_instr   <= instruction;
            IF_ID_pcPlus4 <= pcCurrent;
        end
        if (pipelineFlush || branchFlush) begin
            IF_ID_instr <= 32'b0; // flush to NOP
            // regWrite <= 1'b0;
        end
    end

    //==================================================
    // ID Stage: Decode
    //==================================================
    // Instruction fields extraction
    wire [6:0] opcode      = IF_ID_instr[6:0];
    wire [4:0] rs          = IF_ID_instr[19:15];
    wire [4:0] rt          = IF_ID_instr[24:20];
    wire [4:0] rd          = IF_ID_instr[11:7];
    wire [2:0] funct3      = IF_ID_instr[14:12];
    wire       funct7_5    = IF_ID_instr[30];

    // Read registers
    wire [63:0] regData1, regData2;
    reg_file regFile (
        .clk       (clk),
        .regWrite  (MEM_WB_regWrite),
        .readReg1  (rs),
        .readReg2  (rt),
        .writeReg  (MEM_WB_writeReg),
        .writeData (wbData),
        .readData1 (regData1),
        .readData2 (regData2)
    );

    // Immediate Generation
    wire [63:0] signExtImm;
    immediate_gen immGen (
        .instruction(IF_ID_instr),
        .imm_out(signExtImm)
    );

    // Control Unit
    wire       regWrite;
    wire       memToReg;
    wire       memRead;
    wire       memWrite;
    wire [1:0] aluOp;
    wire       aluSrc;
    wire       branch;
    control_unit ctrl (
        .opcode     (opcode),
        .RegWrite   (regWrite),
        .MemtoReg   (memToReg),
        .MemRead    (memRead),
        .MemWrite   (memWrite),
        .ALUOp      (aluOp),
        .ALUSrc     (aluSrc),
        .Branch     (branch)
    );

    // ALU Control
    wire [1:0] aluControl;
    alu_control aluCtrl (
        .ALUOp(aluOp),
        .func3(funct3),
        .func7_5(funct7_5),
        .ALUControl(aluControl)
    );

    // Hazard Detection Unit
    hazard_detection_unit hazardUnit (
        .ID_EX_memRead  (ID_EX_memRead),
        .ID_EX_rd       (ID_EX_rd),
        .IF_ID_rs       (rs),
        .IF_ID_rt       (rt),
        .pcWrite        (pcWrite),
        .if_idWrite     (if_idWrite),
        .stall          (stall),
        .pipelineFlush  (pipelineFlush)
    );

    // ID/EX Pipeline Register update
    always @(posedge clk or posedge reset) begin
        if (reset || branchFlush ) begin
            ID_EX_regData1   <= 64'b0;
            ID_EX_regData2   <= 64'b0;
            ID_EX_signExtImm <= 64'b0;
            ID_EX_rs         <= 5'b0;
            ID_EX_rt         <= 5'b0;
            ID_EX_rd         <= 5'b0;
            ID_EX_pcPlus4    <= 64'b0;
            
            ID_EX_regWrite   <= 1'b0;
            ID_EX_memToReg   <= 1'b0;
            ID_EX_memRead    <= 1'b0;
            ID_EX_memWrite   <= 1'b0;
            ID_EX_aluOp      <= 2'b0;
            ID_EX_aluSrc     <= 1'b0;
            ID_EX_branch     <= 1'b0;
        end else if (!stall ) begin
            ID_EX_regData1   <= regData1;
            ID_EX_regData2   <= regData2;
            ID_EX_signExtImm <= signExtImm;
            ID_EX_rs         <= rs;
            ID_EX_rt         <= rt;
            ID_EX_rd         <= rd;
            ID_EX_pcPlus4    <= IF_ID_pcPlus4;

            ID_EX_regWrite   <= regWrite;
            ID_EX_memToReg   <= memToReg;
            ID_EX_memRead    <= memRead;
            ID_EX_memWrite   <= memWrite;
            ID_EX_aluOp      <= aluControl;
            ID_EX_aluSrc     <= aluSrc;
            ID_EX_branch     <= branch;
        end else begin
            // Insert bubble by setting control signals to 0
            ID_EX_regWrite   <= 1'b0;
            ID_EX_memToReg   <= 1'b0;
            ID_EX_memRead    <= 1'b0;
            ID_EX_memWrite   <= 1'b0;
            ID_EX_aluOp      <= 2'b0;
            ID_EX_aluSrc     <= 1'b0;
            ID_EX_branch     <= 1'b0;
        end
    end

    //==================================================
    // EX Stage: Execute, Forwarding, ALU, and Exception
    //==================================================
    forwarding_unit fwdUnit (
        .EX_MEM_regWrite (EX_MEM_regWrite),
        .EX_MEM_writeReg (EX_MEM_writeReg),
        .MEM_WB_regWrite (MEM_WB_regWrite),
        .MEM_WB_writeReg (MEM_WB_writeReg),
        .ID_EX_rs        (ID_EX_rs),
        .ID_EX_rt        (ID_EX_rt),
        .forwardA        (forwardA),
        .forwardB        (forwardB)
    );

    // Mux for ALU input A with forwarding
    reg [63:0] ex_aluInputA;
    always @(*) begin
        if (forwardA == 2'b10) begin
            ex_aluInputA = EX_MEM_aluResult;
        end else if (forwardA == 2'b01) begin
            ex_aluInputA = wbData;
        end else begin
            ex_aluInputA = ID_EX_regData1;
        end
    end

    // Mux for ALU input B (with forwarding and immediate selection)
    reg [63:0] ex_regData2Forwarded;
    always @(*) begin
        if (forwardB == 2'b10) begin
            ex_regData2Forwarded = EX_MEM_aluResult;
        end else if (forwardB == 2'b01) begin
            ex_regData2Forwarded = wbData;
        end else begin
            ex_regData2Forwarded = ID_EX_regData2;
        end
    end

    reg [63:0] ex_aluInputB;
    always @(*) begin
        if (ID_EX_aluSrc) begin
            ex_aluInputB = ID_EX_signExtImm;
        end else begin
            ex_aluInputB = ex_regData2Forwarded;
        end
    end

    // ALU instantiation
    wire [63:0] aluResult;
    wire        zeroFlag;
    alu mainALU (
        .a        (ex_aluInputA),
        .b        (ex_aluInputB),
        .ALUControl  (ID_EX_aluOp),
        .result   (aluResult),
        .zero_flag     (zeroFlag)
    );

    // Branch target calculation: PC+4 + (immediate << 2)
    wire [63:0] pcBranchEX = ID_EX_pcPlus4 + (ID_EX_signExtImm );
    wire [4:0] writeReg_EX = ID_EX_rd;

    // EX/MEM Pipeline Register update
    always @(posedge clk or posedge reset) begin
        if (reset || branchFlush) begin
            EX_MEM_aluResult  <= 64'b0;
            EX_MEM_writeData  <= 64'b0;
            EX_MEM_writeReg   <= 5'b0;
            EX_MEM_regWrite   <= 1'b0;
            EX_MEM_memToReg   <= 1'b0;
            EX_MEM_memRead    <= 1'b0;
            EX_MEM_memWrite   <= 1'b0;
            EX_MEM_branch     <= 1'b0;
            EX_MEM_pcBranch   <= 64'b0;
            EX_MEM_zero       <= 1'b0;
            EX_MEM_pcPlus4    <= 64'b0;
            EX_MEM_signExtImm <= 64'b0;
        end else begin
            EX_MEM_aluResult  <= aluResult;
            EX_MEM_writeData  <= ex_regData2Forwarded;
            EX_MEM_writeReg   <= writeReg_EX;
            EX_MEM_regWrite   <= ID_EX_regWrite;
            EX_MEM_memToReg   <= ID_EX_memToReg;
            EX_MEM_memRead    <= ID_EX_memRead;
            EX_MEM_memWrite   <= ID_EX_memWrite;
            EX_MEM_branch     <= ID_EX_branch;
            EX_MEM_pcBranch   <= pcBranchEX;
            EX_MEM_zero       <= zeroFlag;
            EX_MEM_pcPlus4    <= ID_EX_pcPlus4;
            EX_MEM_signExtImm <= ID_EX_signExtImm;
        end
    end

    //==================================================
    // MEM Stage: Data Memory Access
    //==================================================
    wire [63:0] memReadData;
    data_memory dMem (
        .clk       (clk),
        .memRead   (EX_MEM_memRead),
        .memWrite  (EX_MEM_memWrite),
        .addr      (EX_MEM_aluResult),
        .writeData (EX_MEM_writeData),
        .readData  (memReadData)
    );

    // MEM/WB Pipeline Register update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_aluResult   <= 64'b0;
            MEM_WB_memReadData <= 64'b0;
            MEM_WB_pcPlus4     <= 64'b0;
            MEM_WB_writeReg    <= 5'b0;
            MEM_WB_regWrite    <= 1'b0;
            MEM_WB_memToReg    <= 1'b0;
        end else begin
            MEM_WB_aluResult   <= EX_MEM_aluResult;
            MEM_WB_memReadData <= memReadData;
            MEM_WB_pcPlus4     <= EX_MEM_pcPlus4;
            MEM_WB_writeReg    <= EX_MEM_writeReg;
            MEM_WB_regWrite    <= EX_MEM_regWrite;
            MEM_WB_memToReg    <= EX_MEM_memToReg;
        end
    end

    //==================================================
    // WB Stage: Write Back (Handled by reg_file)
    //==================================================
    // (The register file is updated on the rising edge with MEM_WB signals.)
    always @(*) begin
        branchFlush = 0;
        if (branchTaken) begin
            branchFlush = 1;
        end
    end

endmodule