// pipe_ex_mem.v - Registro EX/MEM ampliado con FP + FLW/FSW
module pipe_ex_mem (
    input  wire        clk,
    input  wire        reset,

    // Entradas EX (enteras)
    input  wire        RegWriteE,
    input  wire [1:0]  ResultSrcE,
    input  wire        MemWriteE,
    input  wire [31:0] ALUResultE,
    input  wire [31:0] WriteDataE,
    input  wire [4:0]  RdE,
    input  wire [31:0] PCPlus4E,

    // Entradas EX (FP)
    input  wire        FPRegWriteE,
    input  wire        IsFLWE,
    input  wire        IsFSWE,
    input  wire        IsFPAluE,
    input  wire [31:0] FPResultE,
    input  wire [4:0]  FRdE,

    // Salidas hacia MEM (enteros)
    output reg         RegWriteM,
    output reg [1:0]   ResultSrcM,
    output reg         MemWriteM,
    output reg [31:0]  ALUResultM,
    output reg [31:0]  WriteDataM,
    output reg [4:0]   RdM,
    output reg [31:0]  PCPlus4M,

    // Salidas hacia MEM (FP)
    output reg         FPRegWriteM,
    output reg         IsFLWM,
    output reg         IsFSWM,
    output reg         IsFPAluM,
    output reg [31:0]  FPResultM,
    output reg [4:0]   FRdM
);

    always @(posedge clk) begin
        if (reset) begin
            RegWriteM    <= 1'b0;
            ResultSrcM   <= 2'b00;
            MemWriteM    <= 1'b0;
            ALUResultM   <= 32'd0;
            WriteDataM   <= 32'd0;
            RdM          <= 5'd0;
            PCPlus4M     <= 32'd0;

            FPRegWriteM  <= 1'b0;
            IsFLWM       <= 1'b0;
            IsFSWM       <= 1'b0;
            IsFPAluM     <= 1'b0;
            FPResultM    <= 32'd0;
            FRdM         <= 5'd0;
        end else begin
            RegWriteM    <= RegWriteE;
            ResultSrcM   <= ResultSrcE;
            MemWriteM    <= MemWriteE;
            ALUResultM   <= ALUResultE;
            WriteDataM   <= WriteDataE;
            RdM          <= RdE;
            PCPlus4M     <= PCPlus4E;

            FPRegWriteM  <= FPRegWriteE;
            IsFLWM       <= IsFLWE;
            IsFSWM       <= IsFSWE;
            IsFPAluM     <= IsFPAluE;
            FPResultM    <= FPResultE;
            FRdM         <= FRdE;
        end
    end

endmodule
