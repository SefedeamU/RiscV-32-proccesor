// =============================================================
// id_stage.v -- Updated Fase 3.5 (Verilog-2005)
// Ahora exporta imm_j e is_jal para JAL.
// =============================================================
module id_stage (
    input  wire [31:0] instr,

    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [4:0]  rd,
    output wire [2:0]  funct3,

    input  wire [31:0] rf_r1,
    input  wire [31:0] rf_r2,

    output wire [31:0] imm_i,
    output wire [31:0] imm_b,
    output wire [31:0] imm_j,

    output wire [3:0]  alu_ctrl,
    output wire        alu_src,
    output wire        mem_write,
    output wire        mem_read,
    output wire        reg_write,
    output wire [1:0]  result_src,
    output wire        is_branch,
    output wire        is_jal
);

    wire [6:0] opcode;
    wire [6:0] funct7;

    decoder u_decoder (
        .instr   (instr),
        .opcode  (opcode),
        .funct3  (funct3),
        .funct7  (funct7),
        .rs1     (rs1),
        .rs2     (rs2),
        .rd      (rd),
        .is_rtype(),
        .is_itype(),
        .is_stype(),
        .is_btype(),
        .is_utype(),
        .is_jtype()
    );

    immgen u_immgen (
        .instr (instr),
        .imm_i (imm_i),
        .imm_s (),
        .imm_b (imm_b),
        .imm_u (),
        .imm_j (imm_j)
    );

    controller u_ctrl (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .alu_src    (alu_src),
        .mem_write  (mem_write),
        .mem_read   (mem_read),
        .reg_write  (reg_write),
        .result_src (result_src),
        .alu_ctrl   (alu_ctrl),
        .is_branch  (is_branch),
        .is_jal     (is_jal)
    );

endmodule
