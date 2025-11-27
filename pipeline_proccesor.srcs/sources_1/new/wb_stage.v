// wb_stage.v

module wb_stage (
    // entero
    input  wire [1:0]  ResultSrcW,
    input  wire [31:0] ReadDataW,
    input  wire [31:0] ALUResultW,
    input  wire [31:0] PCPlus4W,
    output reg  [31:0] ResultW,

    // FP
    input  wire        IsFLWW,        // 1 en FLW
    input  wire        IsFPAluW,      // 1 en OP-FP
    input  wire [31:0] FPResultW_in,  // viene de MEM/WB
    output reg  [31:0] FPResultW
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
            FPResultW = FPResultW_in; // resultado FADD/FMUL/FDIV/FSUB
        else if (IsFLWW)
            FPResultW = ReadDataW;    // dato cargado (FLW)
        else
            FPResultW = 32'd0;
    end
endmodule

