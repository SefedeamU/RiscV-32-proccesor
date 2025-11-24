// -------------------------------------------------------------
// immgen.v - Generador de inmediatos RV32I
// ImmSrcD:
//   00: I-type
//   01: S-type
//   10: B-type
//   11: J-type
// -------------------------------------------------------------
module immgen (
    input  wire [31:0] instr,
    input  wire [1:0]  ImmSrcD,
    output reg  [31:0] ImmExtD
);
    wire [31:0] immI = {{20{instr[31]}}, instr[31:20]};                                   // I
    wire [31:0] immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};                      // S
    wire [31:0] immB = {{19{instr[31]}}, instr[31], instr[7], instr[30:25],
                        instr[11:8], 1'b0};                                              // B
    wire [31:0] immJ = {{11{instr[31]}}, instr[31], instr[19:12], instr[20],
                        instr[30:21], 1'b0};                                             // J

    always @* begin
        case (ImmSrcD)
            2'b00: ImmExtD = immI;
            2'b01: ImmExtD = immS;
            2'b10: ImmExtD = immB;
            2'b11: ImmExtD = immJ;
            default: ImmExtD = immI;
        endcase
    end

endmodule
