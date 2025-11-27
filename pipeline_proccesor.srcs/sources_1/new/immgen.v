// immgen.v

module immgen (
    input  wire [31:0] instr,
    input  wire [1:0]  ImmSrcD,
    output reg  [31:0] ImmExtD
);
    // I-type: [31:20]
    wire [31:0] immI = {{20{instr[31]}}, instr[31:20]};

    // S-type: [31:25] y [11:7]
    wire [31:0] immS = {{20{instr[31]}},
                         instr[31:25],
                         instr[11:7]};

    // B-type: [31], [7], [30:25], [11:8], 0
    wire [31:0] immB = {{19{instr[31]}},
                         instr[31],
                         instr[7],
                         instr[30:25],
                         instr[11:8],
                         1'b0};

    // J-type (JAL): [31], [19:12], [20], [30:21], 0
    wire [31:0] immJ = {{11{instr[31]}},
                         instr[31],
                         instr[19:12],
                         instr[20],
                         instr[30:21],
                         1'b0};

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
