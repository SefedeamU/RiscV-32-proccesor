// -------------------------------------------------------------
// wb_stage.v - Etapa WB: selección del resultado a escribir en regfile
// ResultSrcW:
//   00 -> ALUResultW
//   01 -> ReadDataW
//   10 -> PCPlus4W
// -------------------------------------------------------------
module wb_stage (
    input  wire [1:0]  ResultSrcW,
    input  wire [31:0] ReadDataW,
    input  wire [31:0] ALUResultW,
    input  wire [31:0] PCPlus4W,
    output reg  [31:0] ResultW
);

    always @* begin
        case (ResultSrcW)
            2'b00: ResultW = ALUResultW;  // operaciones ALU, addi, add, etc.
            2'b01: ResultW = ReadDataW;   // LW
            2'b10: ResultW = PCPlus4W;    // JAL
            default: ResultW = ALUResultW;
        endcase
    end

endmodule
