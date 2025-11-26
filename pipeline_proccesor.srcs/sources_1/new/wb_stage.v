// WB stage: selección de resultado entero y FP
// Camino entero usa ResultSrcW.
// Camino FP decide entre resultado de ALU FP o dato de memoria

module wb_stage (
    // camino entero
    input  wire [1:0]  ResultSrcW,
    input  wire [31:0] ReadDataW,
    input  wire [31:0] ALUResultW,
    input  wire [31:0] PCPlus4W,
    output reg  [31:0] ResultW,

    // camino FP
    input  wire        IsFLWW,        // FLW
    input  wire        IsFPAluW,      // OP-FP
    input  wire [31:0] FPResultW_in,  // desde registro MEM/WB
    output reg  [31:0] FPResultW   // hacia regfile_fp
);

    always @* begin
        // entero
        case (ResultSrcW)
            2'b00: ResultW = ALUResultW;
            2'b01: ResultW = ReadDataW;
            2'b10: ResultW = PCPlus4W;
            default: ResultW = ALUResultW;
        endcase

        // FP
        if (IsFPAluW)
            FPResultW = FPResultW_in; // resultado OP-FP
        else if (IsFLWW)
            FPResultW = ReadDataW;    // dato de memoria (FLW)
        else
            FPResultW = 32'd0;
    end

endmodule
