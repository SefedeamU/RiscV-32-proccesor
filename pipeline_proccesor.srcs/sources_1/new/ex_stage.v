// -------------------------------------------------------------
// ex_stage.v - Etapa EX: ALU + cálculo de PCTargetE + forwarding
// -------------------------------------------------------------
module ex_stage (
    // Control
    input  wire        BranchE,
    input  wire        JumpE,
    input  wire [2:0]  ALUControlE,
    input  wire        ALUSrcE,

    // Datos desde ID/EX
    input  wire [31:0] PCE,
    input  wire [31:0] RD1E,
    input  wire [31:0] RD2E,
    input  wire [31:0] ImmExtE,
    input  wire [4:0]  Rs1E,
    input  wire [4:0]  Rs2E,

    // Info de etapas posteriores para forwarding
    input  wire        RegWriteM,
    input  wire        RegWriteW,
    input  wire [4:0]  RdM,
    input  wire [4:0]  RdW,
    input  wire [31:0] ALUResultM,
    input  wire [31:0] ResultW,

    // Salidas
    output wire [31:0] ALUResultE,
    output wire [31:0] WriteDataE,   // valor que va a MEM (stores)
    output wire [31:0] PCTargetE,
    output wire        ZeroE,
    output wire        PCSrcE,

    // Señales de depuración (opcionales)
    output wire [1:0]  ForwardAE,
    output wire [1:0]  ForwardBE,
    output wire [31:0] srcA_fwd,
    output wire [31:0] srcB_fwd,
    output wire [31:0] srcB_alu,
    output wire [31:0] y              // salida ALU
);

    // ---------------- Forwarding ----------------
    forwarding_unit fwd_u (
        .Rs1E      (Rs1E),
        .Rs2E      (Rs2E),
        .RdM       (RdM),
        .RdW       (RdW),
        .RegWriteM (RegWriteM),
        .RegWriteW (RegWriteW),
        .ForwardAE (ForwardAE),
        .ForwardBE (ForwardBE)
    );

    // Selección de operandos con forwarding
    reg [31:0] srcA, srcB;

    always @* begin
        // Operando A
        case (ForwardAE)
            2'b00: srcA = RD1E;
            2'b10: srcA = ALUResultM;
            2'b01: srcA = ResultW;
            default: srcA = RD1E;
        endcase

        // Operando B (antes de ALUSrc)
        case (ForwardBE)
            2'b00: srcB = RD2E;
            2'b10: srcB = ALUResultM;
            2'b01: srcB = ResultW;
            default: srcB = RD2E;
        endcase
    end

    // Señales de depuración
    assign srcA_fwd = srcA;
    assign srcB_fwd = srcB;

    // Si ALUSrcE=1, usar inmediato; si no, usar srcB (con forwarding)
    assign srcB_alu = ALUSrcE ? ImmExtE : srcB;

    // ---------------- ALU ----------------
    alu_int alu_u (
        .a        (srcA),
        .b        (srcB_alu),
        .alu_ctrl (ALUControlE),
        .y        (y),
        .zero     (ZeroE)
    );

    assign ALUResultE = y;

    // Dato que se envía a MEM en stores (sin Imm)
    assign WriteDataE = srcB;   // importante: sin ALUSrc

    // ---------------- Branch / Jump ----------------
    assign PCTargetE = PCE + ImmExtE;
    assign PCSrcE    = (BranchE & ZeroE) | JumpE;

endmodule
