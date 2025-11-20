// =============================================================
// decoder.v -- RV32I Decoder (Verilog-2005)
// =============================================================
module decoder (
    input  wire [31:0] instr,

    output reg  [6:0]  opcode,
    output reg  [2:0]  funct3,
    output reg  [6:0]  funct7,

    output reg  [4:0]  rs1,
    output reg  [4:0]  rs2,
    output reg  [4:0]  rd,

    // Clases de instrucción
    output reg         is_rtype,
    output reg         is_itype,
    output reg         is_stype,
    output reg         is_btype,
    output reg         is_utype,
    output reg         is_jtype
);

    always @(*) begin
        opcode = instr[6:0];
        rd     = instr[11:7];
        funct3 = instr[14:12];
        rs1    = instr[19:15];
        rs2    = instr[24:20];
        funct7 = instr[31:25];

        // Clasificación
        is_rtype = (opcode == 7'b0110011);
        is_itype = (opcode == 7'b0010011) ||
                   (opcode == 7'b0000011);  // I-ALU + LOAD
        is_stype = (opcode == 7'b0100011); // STORE
        is_btype = (opcode == 7'b1100011); // BRANCH
        is_utype = (opcode == 7'b0110111) ||  // LUI
                   (opcode == 7'b0010111);    // AUIPC
        is_jtype = (opcode == 7'b1101111);    // JAL
    end

endmodule
