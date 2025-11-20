// =============================================================
// immgen.v -- Immediate Generator (Verilog-2005)
// =============================================================
module immgen (
    input  wire [31:0] instr,
    output reg  [31:0] imm_i,
    output reg  [31:0] imm_s,
    output reg  [31:0] imm_b,
    output reg  [31:0] imm_u,
    output reg  [31:0] imm_j
);

    wire [31:0] signext_11_0  = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] signext_11_5  = {{20{instr[31]}}, instr[31:25]};
    wire [31:0] signext_4_0   = {{27{1'b0}}, instr[11:7]};
    
    always @(*) begin
        // I-type
        imm_i = {{20{instr[31]}}, instr[31:20]};

        // S-type
        imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};

        // B-type
        imm_b = {{19{instr[31]}},
                 instr[31],
                 instr[7],
                 instr[30:25],
                 instr[11:8],
                 1'b0};

        // U-type
        imm_u = {instr[31:12], 12'b0};

        // J-type
        imm_j = {{11{instr[31]}},
                 instr[31],
                 instr[19:12],
                 instr[20],
                 instr[30:21],
                 1'b0};
    end

endmodule
