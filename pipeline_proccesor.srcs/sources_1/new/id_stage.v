// id_stage.v - Etapa ID con registros enteros + FP
module id_stage (
    input  wire        clk,
    input  wire        reset,

    input  wire [31:0] PCD,
    input  wire [31:0] InstrD,

    // write-back entero
    input  wire        RegWriteW,
    input  wire [4:0]  RdW,
    input  wire [31:0] ResultW,

    // write-back FP
    input  wire        FPRegWriteW,
    input  wire [4:0]  FRdW,
    input  wire [31:0] FPResultW,

    // Datos hacia EX (enteros)
    output wire [31:0] RD1D,
    output wire [31:0] RD2D,
    output wire [31:0] ImmExtD,
    output wire [4:0]  Rs1D,
    output wire [4:0]  Rs2D,
    output wire [4:0]  RdD,

    // Datos hacia EX (FP)
    output wire [31:0] FRD1D,
    output wire [31:0] FRD2D,
    output wire [4:0]  FRs1D,
    output wire [4:0]  FRs2D,
    output wire [4:0]  FRdD,

    // Control entero
    output wire        RegWriteD,
    output wire [1:0]  ResultSrcD,
    output wire        MemWriteD,
    output wire        BranchD,
    output wire        JumpD,
    output wire [2:0]  ALUControlD,
    output wire        ALUSrcD,
    output wire [1:0]  ImmSrcD,

    // Control FP
    output wire        IsFPAluD,
    output wire        FPRegWriteD,
    output wire        IsFLWD,
    output wire        IsFSWD
);

    wire [6:0] opcode = InstrD[6:0];
    wire [2:0] funct3 = InstrD[14:12];
    wire [6:0] funct7 = InstrD[31:25];

    assign RdD  = InstrD[11:7];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];

    // índices FP (misma codificación que RISC-V F)
    assign FRdD  = InstrD[11:7];
    assign FRs1D = InstrD[19:15];
    assign FRs2D = InstrD[24:20];

    // Banco de registros entero
    regfile_int rf_int_u (
        .clk (clk),
        .we  (RegWriteW),
        .a1  (Rs1D),
        .a2  (Rs2D),
        .a3  (RdW),
        .wd3 (ResultW),
        .rd1 (RD1D),
        .rd2 (RD2D)
    );

    // Banco de registros FP
    regfile_fp rf_fp_u (
        .clk (clk),
        .we  (FPRegWriteW),
        .a1  (FRs1D),
        .a2  (FRs2D),
        .a3  (FRdW),
        .wd3 (FPResultW),
        .rd1 (FRD1D),
        .rd2 (FRD2D)
    );

    // Inmediatos
    immgen imm_u (
        .instr   (InstrD),
        .ImmSrcD (ImmSrcD),
        .ImmExtD (ImmExtD)
    );

    // Control
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
        .ImmSrcD     (ImmSrcD),
        .IsFPAluD    (IsFPAluD),
        .FPRegWriteD (FPRegWriteD),
        .IsFLWD      (IsFLWD),
        .IsFSWD      (IsFSWD)
    );

endmodule
