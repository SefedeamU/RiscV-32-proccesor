// -------------------------------------------------------------
// ID/EX pipeline register ampliado con FP + FLW/FSW
// -------------------------------------------------------------
module pipe_id_ex (
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,    // FlushE

    // ------ control desde D (enteros) ------
    input  wire        RegWriteD,
    input  wire [1:0]  ResultSrcD,
    input  wire        MemWriteD,
    input  wire        BranchD,
    input  wire        JumpD,
    input  wire [2:0]  ALUControlD,
    input  wire        ALUSrcD,

    // ------ control FP desde D ------
    input  wire        IsFPAluD,
    input  wire        FPRegWriteD,
    input  wire        IsFLWD,
    input  wire        IsFSWD,

    // ------ datos enteros desde D ------
    input  wire [31:0] PCD,
    input  wire [31:0] RD1D,
    input  wire [31:0] RD2D,
    input  wire [31:0] ImmExtD,
    input  wire [4:0]  Rs1D,
    input  wire [4:0]  Rs2D,
    input  wire [4:0]  RdD,
    input  wire [31:0] PCPlus4D,

    // ------ datos FP desde D ------
    input  wire [31:0] FRD1D,
    input  wire [31:0] FRD2D,
    input  wire [4:0]  FRs1D,
    input  wire [4:0]  FRs2D,
    input  wire [4:0]  FRdD,

    // ------ salidas hacia E (enteros) ------
    output reg         RegWriteE,
    output reg  [1:0]  ResultSrcE,
    output reg         MemWriteE,
    output reg         BranchE,
    output reg         JumpE,
    output reg  [2:0]  ALUControlE,
    output reg         ALUSrcE,
    output reg  [31:0] PCE,
    output reg  [31:0] RD1E,
    output reg  [31:0] RD2E,
    output reg  [31:0] ImmExtE,
    output reg  [4:0]  Rs1E,
    output reg  [4:0]  Rs2E,
    output reg  [4:0]  RdE,
    output reg  [31:0] PCPlus4E,

    // ------ salidas hacia E (FP) ------
    output reg         IsFPAluE,
    output reg         FPRegWriteE,
    output reg         IsFLWE,
    output reg         IsFSWE,
    output reg  [31:0] FRD1E,
    output reg  [31:0] FRD2E,
    output reg  [4:0]  FRs1E,
    output reg  [4:0]  FRs2E,
    output reg  [4:0]  FRdE
);

    always @(posedge clk) begin
        if (reset || flush) begin
            // ---- controles enteros ----
            RegWriteE   <= 1'b0;
            ResultSrcE  <= 2'b00;
            MemWriteE   <= 1'b0;
            BranchE     <= 1'b0;
            JumpE       <= 1'b0;
            ALUControlE <= 3'b000;
            ALUSrcE     <= 1'b0;

            // ---- datos enteros ----
            PCE         <= 32'd0;
            RD1E        <= 32'd0;
            RD2E        <= 32'd0;
            ImmExtE     <= 32'd0;
            Rs1E        <= 5'd0;
            Rs2E        <= 5'd0;
            RdE         <= 5'd0;
            PCPlus4E    <= 32'd0;

            // ---- controles FP ----
            IsFPAluE    <= 1'b0;
            FPRegWriteE <= 1'b0;
            IsFLWE      <= 1'b0;
            IsFSWE      <= 1'b0;

            // ---- datos FP ----
            FRD1E       <= 32'd0;
            FRD2E       <= 32'd0;
            FRs1E       <= 5'd0;
            FRs2E       <= 5'd0;
            FRdE        <= 5'd0;
        end else begin
            // ---- controles enteros ----
            RegWriteE   <= RegWriteD;
            ResultSrcE  <= ResultSrcD;
            MemWriteE   <= MemWriteD;
            BranchE     <= BranchD;
            JumpE       <= JumpD;
            ALUControlE <= ALUControlD;
            ALUSrcE     <= ALUSrcD;

            // ---- datos enteros ----
            PCE         <= PCD;
            RD1E        <= RD1D;
            RD2E        <= RD2D;
            ImmExtE     <= ImmExtD;
            Rs1E        <= Rs1D;
            Rs2E        <= Rs2D;
            RdE         <= RdD;
            PCPlus4E    <= PCPlus4D;

            // ---- controles FP ----
            IsFPAluE    <= IsFPAluD;
            FPRegWriteE <= FPRegWriteD;
            IsFLWE      <= IsFLWD;
            IsFSWE      <= IsFSWD;

            // ---- datos FP ----
            FRD1E       <= FRD1D;
            FRD2E       <= FRD2D;
            FRs1E       <= FRs1D;
            FRs2E       <= FRs2D;
            FRdE        <= FRdD;
        end
    end

endmodule
