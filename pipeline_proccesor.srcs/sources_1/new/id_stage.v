// -------------------------------------------------------------
// id_stage.v - Etapa ID: decode + regfile + immediate
// -------------------------------------------------------------
module id_stage (
    input  wire        clk,
    input  wire        reset,

    input  wire [31:0] PCD,
    input  wire [31:0] InstrD,

    // Señales de WB para escribir el banco de registros
    input  wire        RegWriteW,
    input  wire [4:0]  RdW,
    input  wire [31:0] ResultW,

    // Datos hacia EX
    output wire [31:0] RD1D,
    output wire [31:0] RD2D,
    output wire [31:0] ImmExtD,
    output wire [4:0]  Rs1D,
    output wire [4:0]  Rs2D,
    output wire [4:0]  RdD,

    // Control hacia EX/MEM/WB
    output wire        RegWriteD,
    output wire [1:0]  ResultSrcD,
    output wire        MemWriteD,
    output wire        BranchD,
    output wire        JumpD,
    output wire [2:0]  ALUControlD,
    output wire        ALUSrcD,
    output wire [1:0]  ImmSrcD
);

    // Campos de la instrucción
    wire [6:0] opcode = InstrD[6:0];
    wire [2:0] funct3 = InstrD[14:12];
    wire [6:0] funct7 = InstrD[31:25];

    assign RdD  = InstrD[11:7];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];

    // ---------------- Banco de registros ----------------
    regfile_int rf_u (
        .clk (clk),
        .we  (RegWriteW),
        .a1  (Rs1D),
        .a2  (Rs2D),
        .a3  (RdW),
        .wd3 (ResultW),
        .rd1 (RD1D),
        .rd2 (RD2D)
    );

    // ---------------- Generador de inmediatos ----------------
    immgen imm_u (
        .instr   (InstrD),
        .ImmSrcD (ImmSrcD),
        .ImmExtD (ImmExtD)
    );

    // ---------------- Unidad de control ----------------
    controller ctrl_u (
        .opcode      (opcode),
        .funct3      (funct3),
        .funct7      (funct7),
        .RegWriteD   (RegWriteD),
        .ResultSrcD  (ResultSrcD),
        .MemWriteD   (MemWriteD),
        .BranchD     (BranchD),
        .JumpD       (JumpD),
        .ALUControlD (ALUControlD),
        .ALUSrcD     (ALUSrcD),
        .ImmSrcD     (ImmSrcD)
    );

endmodule
