// ex_stage.v - Etapa EX: ALU entera + ALU FP + Forwarding entero y FP
module ex_stage (
    // Control entero
    input  wire        BranchE,
    input  wire        JumpE,
    input  wire [2:0]  ALUControlE,
    input  wire        ALUSrcE,

    // Datos enteros desde ID/EX
    input  wire [31:0] PCE,
    input  wire [31:0] RD1E,
    input  wire [31:0] RD2E,
    input  wire [31:0] ImmExtE,
    input  wire [4:0]  Rs1E,
    input  wire [4:0]  Rs2E,

    // Control/operandos FP desde ID/EX
    input  wire        IsFPAluE,   // FADD/FSUB/FMUL/FDIV
    input  wire        IsFSWE,     // FSW (para elegir dato correcto)
    input  wire [31:0] FRD1E,      // rs1 FP
    input  wire [31:0] FRD2E,      // rs2 FP
    input  wire [4:0]  FRs1E,
    input  wire [4:0]  FRs2E,

    // Forwarding entero
    input  wire        RegWriteM,
    input  wire        RegWriteW,
    input  wire [4:0]  RdM,
    input  wire [4:0]  RdW,
    input  wire [31:0] ALUResultM,
    input  wire [31:0] ResultW,

    // Forwarding FP
    input  wire        FPRegWriteM,
    input  wire [4:0]  FRdM,
    input  wire [31:0] FPResultM,      // resultado FP en EX/MEM (OP-FP)
    input  wire        FPRegWriteW,
    input  wire [4:0]  FRdW,
    input  wire [31:0] FPResultW,      // resultado FP ya listo en MEM/WB (OP-FP o FLW)

    // Salidas enteras
    output wire [31:0] ALUResultE,
    output wire [31:0] WriteDataE,
    output wire [31:0] PCTargetE,
    output wire        ZeroE,
    output wire        PCSrcE,

    // Salidas FP
    output wire [31:0] FPResultE,
    output wire [4:0]  FPFlagsE,

    // Señales de depuración
    output wire [1:0]  ForwardAE,
    output wire [1:0]  ForwardBE,
    output wire [31:0] srcA_fwd,
    output wire [31:0] srcB_fwd,
    output wire [31:0] srcB_alu,
    output wire [31:0] y
);

    // ---------------- Forwarding ENTERO ----------------
    forwarding_unit fwd_int_u (
        .Rs1E      (Rs1E),
        .Rs2E      (Rs2E),
        .RdM       (RdM),
        .RdW       (RdW),
        .RegWriteM (RegWriteM),
        .RegWriteW (RegWriteW),
        .ForwardAE (ForwardAE),
        .ForwardBE (ForwardBE)
    );

    reg [31:0] srcA, srcB;

    always @* begin
        // Operando A entero
        case (ForwardAE)
            2'b00: srcA = RD1E;        // ID/EX
            2'b10: srcA = ALUResultM;  // EX/MEM
            2'b01: srcA = ResultW;     // MEM/WB (también cubre LW)
            default: srcA = RD1E;
        endcase

        // Operando B entero
        case (ForwardBE)
            2'b00: srcB = RD2E;
            2'b10: srcB = ALUResultM;
            2'b01: srcB = ResultW;
            default: srcB = RD2E;
        endcase
    end

    assign srcA_fwd = srcA;
    assign srcB_fwd = srcB;
    assign srcB_alu = ALUSrcE ? ImmExtE : srcB;

    // ALU entera
    alu_int alu_u (
        .a        (srcA),
        .b        (srcB_alu),
        .alu_ctrl (ALUControlE),
        .y        (y),
        .zero     (ZeroE)
    );

    assign ALUResultE = y;

    // ---------------- Forwarding FP ----------------
    wire [1:0] FPForwardAE;
    wire [1:0] FPForwardBE;

    fp_forwarding_unit fwd_fp_u (
        .FRs1E       (FRs1E),
        .FRs2E       (FRs2E),
        .FRdM        (FRdM),
        .FPRegWriteM (FPRegWriteM),
        .FRdW        (FRdW),
        .FPRegWriteW (FPRegWriteW),
        .FPForwardAE (FPForwardAE),
        .FPForwardBE (FPForwardBE)
    );

    reg [31:0] fp_srcA;
    reg [31:0] fp_srcB;
    reg [31:0] fp_srcB_store;  // valor correcto a guardar en FSW

    always @* begin
        // Operando A FP (rs1)
        case (FPForwardAE)
            2'b10: fp_srcA = FPResultM;  // resultado en EX/MEM (OP-FP)
            2'b01: fp_srcA = FPResultW;  // resultado en MEM/WB (OP-FP o FLW)
            default: fp_srcA = FRD1E;    // valor desde ID/EX
        endcase

        // Operando B FP (rs2) para ALU
        case (FPForwardBE)
            2'b10: fp_srcB = FPResultM;
            2'b01: fp_srcB = FPResultW;
            default: fp_srcB = FRD2E;
        endcase

        // Operando B FP (rs2) para FSW (dato a memoria)
        case (FPForwardBE)
            2'b10: fp_srcB_store = FPResultM;
            2'b01: fp_srcB_store = FPResultW;
            default: fp_srcB_store = FRD2E;
        endcase
    end

    // ALU FP (combinacional, modo single, RNE)
    wire [31:0] fp_res;
    wire [4:0]  fp_flags;

    alu_fp fp_u (
        .mode_fp    (1'b1),       // 1 = single (32 bits)
        .round_mode (2'b00),      // RNE
        .op_a       (fp_srcA),
        .op_b       (fp_srcB),
        .op_code    (ALUControlE),  // 000 add, 001 sub, 010 mul, 011 div
        .result     (fp_res),
        .flags      (fp_flags)
    );

    assign FPResultE = IsFPAluE ? fp_res   : 32'd0;
    assign FPFlagsE  = IsFPAluE ? fp_flags : 5'd0;

    // Dato que se envía a MEM:
    //   - SW entero: srcB
    //   - FSW: valor FP (con forwarding)
    assign WriteDataE = IsFSWE ? fp_srcB_store : srcB;

    // ---------------- Branch / Jump ----------------
    assign PCTargetE = PCE + ImmExtE;
    assign PCSrcE    = (BranchE & ZeroE) | JumpE;

endmodule
