// immgen.v - Generador de inmediatos RV32I
// ImmSrcD:
//   00: I-type   (ADDI, LW, FLW, etc.)
//   01: S-type   (SW, FSW)
//   10: B-type   (BEQ)
//   11: J/U-type:
//        - JAL   (J-type) -> salto relativo
//        - LUI   (U-type) -> imm[31:12] << 12

module immgen (
    input  wire [31:0] instr,
    input  wire [1:0]  ImmSrcD,
    output reg  [31:0] ImmExtD
);
    wire [6:0] opcode = instr[6:0];

    // I-type: [31:20]
    wire [31:0] immI = {{20{instr[31]}}, instr[31:20]};

    // S-type: [31:25] y [11:7]
    wire [31:0] immS = {{20{instr[31]}},
                         instr[31:25],
                         instr[11:7]};

    // B-type: [31], [7], [30:25], [11:8], 0
    // offset = {instr[31],instr[7],instr[30:25],instr[11:8],0}
    wire [31:0] immB = {{19{instr[31]}},
                         instr[31],
                         instr[7],
                         instr[30:25],
                         instr[11:8],
                         1'b0};

    // J-type (JAL): [31], [19:12], [20], [30:21], 0
    // offset = {instr[31],instr[19:12],instr[20],instr[30:21],0}
    wire [31:0] immJ = {{11{instr[31]}},
                         instr[31],
                         instr[19:12],
                         instr[20],
                         instr[30:21],
                         1'b0};

    // U-type (LUI): imm[31:12] << 12
    wire [31:0] immU = {instr[31:12], 12'b0};

    always @* begin
        case (ImmSrcD)
            2'b00: ImmExtD = immI; // I-type
            2'b01: ImmExtD = immS; // S-type
            2'b10: ImmExtD = immB; // B-type

            2'b11: begin
                // Se comparte el código 11 para J-type (JAL) y U-type (LUI)
                if (opcode == 7'b1101111)      // JAL
                    ImmExtD = immJ;
                else if (opcode == 7'b0110111) // LUI
                    ImmExtD = immU;
                else
                    ImmExtD = immI;            
            end

            default: ImmExtD = immI;
        endcase
    end

endmodule
