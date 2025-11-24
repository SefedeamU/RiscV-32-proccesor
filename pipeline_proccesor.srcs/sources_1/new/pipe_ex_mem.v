// -------------------------------------------------------------
// EX/MEM pipeline register
// -------------------------------------------------------------
module pipe_ex_mem (
    input  wire        clk,
    input  wire        reset,

    // Entradas desde EX
    input  wire        RegWriteE,
    input  wire [1:0]  ResultSrcE,
    input  wire        MemWriteE,
    input  wire [31:0] ALUResultE,
    input  wire [31:0] WriteDataE,
    input  wire [4:0]  RdE,
    input  wire [31:0] PCPlus4E,

    // Salidas hacia MEM
    output reg         RegWriteM,
    output reg [1:0]   ResultSrcM,
    output reg         MemWriteM,
    output reg [31:0]  ALUResultM,
    output reg [31:0]  WriteDataM,
    output reg [4:0]   RdM,
    output reg [31:0]  PCPlus4M
);

    always @(posedge clk) begin
        if (reset) begin
            RegWriteM   <= 1'b0;
            ResultSrcM  <= 2'b00;
            MemWriteM   <= 1'b0;
            ALUResultM  <= 32'd0;
            WriteDataM  <= 32'd0;
            RdM         <= 5'd0;
            PCPlus4M    <= 32'd0;
        end else begin
            RegWriteM   <= RegWriteE;
            ResultSrcM  <= ResultSrcE;
            MemWriteM   <= MemWriteE;
            ALUResultM  <= ALUResultE;
            WriteDataM  <= WriteDataE;
            RdM         <= RdE;
            PCPlus4M    <= PCPlus4E;
        end
    end

endmodule
