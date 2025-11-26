// wb_stage.v - Etapa WB para enteros + FP
// ResultSrcW (enteros):
//   00 -> ALUResultW
//   01 -> ReadDataW
//   10 -> PCPlus4W
module wb_stage (
    // camino entero
    input  wire [1:0]  ResultSrcW,
    input  wire [31:0] ReadDataW,
    input  wire [31:0] ALUResultW,
    input  wire [31:0] PCPlus4W,
    output reg  [31:0] ResultW,

    // control/entrada FP
    input  wire        IsFLWW,        // FLW
    input  wire        IsFPAluW,      // FADD/FMUL/...
    input  wire [31:0] FPResultW_in,  // resultado ALU FP desde MEM/WB

    // salida hacia regfile_fp
    output reg  [31:0] FPResultOutW
);

    always @* begin
        // entero (igual que en tu diseño original)
        case (ResultSrcW)
            2'b00: ResultW = ALUResultW;
            2'b01: ResultW = ReadDataW;
            2'b10: ResultW = PCPlus4W;
            default: ResultW = ALUResultW;
        endcase

        // FP:
        //   - OP-FP: escribir resultado de ALU FP
        //   - FLW:   escribir dato leído de memoria
        //   - FSW:   no escribe (FPRegWriteW=0)
        if (IsFPAluW) begin
            FPResultOutW = FPResultW_in;
        end else if (IsFLWW) begin
            FPResultOutW = ReadDataW;
        end else begin
            FPResultOutW = 32'd0;
        end
    end

endmodule
