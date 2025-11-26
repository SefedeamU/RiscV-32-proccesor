// Registro pipeline MEM/WB con señales entero + FP

module pipe_mem_wb (
    input  wire        clk,
    input  wire        reset,

    // entradas desde MEM (entero)
    input  wire        RegWriteM,
    input  wire [1:0]  ResultSrcM,
    input  wire [31:0] ReadDataM,
    input  wire [31:0] ALUResultM,
    input  wire [31:0] PCPlus4M,
    input  wire [4:0]  RdM,

    // entradas desde MEM (FP)
    input  wire        FPRegWriteM,
    input  wire        IsFLWM,
    input  wire        IsFSWM,
    input  wire        IsFPAluM,
    input  wire [31:0] FPResultM,
    input  wire [4:0]  FRdM,

    // salidas hacia WB (entero)
    output reg         RegWriteW,
    output reg [1:0]   ResultSrcW,
    output reg [31:0]  ReadDataW,
    output reg [31:0]  ALUResultW,
    output reg [31:0]  PCPlus4W,
    output reg [4:0]   RdW,

    // salidas hacia WB (FP)
    output reg         FPRegWriteW,
    output reg         IsFLWW,
    output reg         IsFSWW,
    output reg         IsFPAluW,
    output reg [31:0]  FPResultW,
    output reg [4:0]   FRdW
);

    always @(posedge clk) begin
        if (reset) begin
            RegWriteW   <= 1'b0;
            ResultSrcW  <= 2'b00;
            ReadDataW   <= 32'd0;
            ALUResultW  <= 32'd0;
            PCPlus4W    <= 32'd0;
            RdW         <= 5'd0;

            FPRegWriteW <= 1'b0;
            IsFLWW      <= 1'b0;
            IsFSWW      <= 1'b0;
            IsFPAluW    <= 1'b0;
            FPResultW   <= 32'd0;
            FRdW        <= 5'd0;
        end else begin
            RegWriteW   <= RegWriteM;
            ResultSrcW  <= ResultSrcM;
            ReadDataW   <= ReadDataM;
            ALUResultW  <= ALUResultM;
            PCPlus4W    <= PCPlus4M;
            RdW         <= RdM;

            FPRegWriteW <= FPRegWriteM;
            IsFLWW      <= IsFLWM;
            IsFSWW      <= IsFSWM;
            IsFPAluW    <= IsFPAluM;
            FPResultW   <= FPResultM;
            FRdW        <= FRdM;
        end
    end

endmodule
