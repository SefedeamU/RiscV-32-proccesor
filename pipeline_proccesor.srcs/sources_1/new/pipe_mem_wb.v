// -------------------------------------------------------------
// MEM/WB pipeline register
// -------------------------------------------------------------
module pipe_mem_wb (
    input  wire        clk,
    input  wire        reset,

    // Entradas desde MEM
    input  wire        RegWriteM,
    input  wire [1:0]  ResultSrcM,
    input  wire [31:0] ReadDataM,
    input  wire [31:0] ALUResultM,
    input  wire [31:0] PCPlus4M,
    input  wire [4:0]  RdM,

    // Salidas hacia WB
    output reg         RegWriteW,
    output reg [1:0]   ResultSrcW,
    output reg [31:0]  ReadDataW,
    output reg [31:0]  ALUResultW,
    output reg [31:0]  PCPlus4W,
    output reg [4:0]   RdW
);

    always @(posedge clk) begin
        if (reset) begin
            RegWriteW   <= 1'b0;
            ResultSrcW  <= 2'b00;
            ReadDataW   <= 32'd0;
            ALUResultW  <= 32'd0;
            PCPlus4W    <= 32'd0;
            RdW         <= 5'd0;
        end else begin
            RegWriteW   <= RegWriteM;
            ResultSrcW  <= ResultSrcM;
            ReadDataW   <= ReadDataM;
            ALUResultW  <= ALUResultM;
            PCPlus4W    <= PCPlus4M;
            RdW         <= RdM;
        end
    end

endmodule
