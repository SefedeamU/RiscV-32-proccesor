// -------------------------------------------------------------
// ID/EX pipeline register
// -------------------------------------------------------------
module pipe_id_ex (
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,    // FlushE

    // control desde D
    input  wire        RegWriteD,
    input  wire [1:0]  ResultSrcD,
    input  wire        MemWriteD,
    input  wire        BranchD,
    input  wire        JumpD,
    input  wire [2:0]  ALUControlD,
    input  wire        ALUSrcD,

    // datos desde D
    input  wire [31:0] PCD,
    input  wire [31:0] RD1D,
    input  wire [31:0] RD2D,
    input  wire [31:0] ImmExtD,
    input  wire [4:0]  Rs1D,
    input  wire [4:0]  Rs2D,
    input  wire [4:0]  RdD,
    input  wire [31:0] PCPlus4D,

    // salidas hacia E
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
    output reg  [31:0] PCPlus4E
);

    always @(posedge clk) begin
        if (reset || flush) begin
            RegWriteE   <= 1'b0;
            ResultSrcE  <= 2'b00;
            MemWriteE   <= 1'b0;
            BranchE     <= 1'b0;
            JumpE       <= 1'b0;
            ALUControlE <= 3'b000;
            ALUSrcE     <= 1'b0;
            PCE         <= 32'd0;
            RD1E        <= 32'd0;
            RD2E        <= 32'd0;
            ImmExtE     <= 32'd0;
            Rs1E        <= 5'd0;
            Rs2E        <= 5'd0;
            RdE         <= 5'd0;
            PCPlus4E    <= 32'd0;
        end else begin
            RegWriteE   <= RegWriteD;
            ResultSrcE  <= ResultSrcD;
            MemWriteE   <= MemWriteD;
            BranchE     <= BranchD;
            JumpE       <= JumpD;
            ALUControlE <= ALUControlD;
            ALUSrcE     <= ALUSrcD;
            PCE         <= PCD;
            RD1E        <= RD1D;
            RD2E        <= RD2D;   // <<< ESTO es lo crítico
            ImmExtE     <= ImmExtD;
            Rs1E        <= Rs1D;
            Rs2E        <= Rs2D;   // <<< y esto también
            RdE         <= RdD;
            PCPlus4E    <= PCPlus4D;
        end
    end

endmodule
