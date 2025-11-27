// ex_stage.v
//  - ALU entera + ALU FP
//  - Forwarding entero y FP simétricos
//  - WriteDataE multiplexa entre dato entero y FP (FSW)

module ex_stage (
    // control entero
    input  wire        BranchE,
    input  wire        JumpE,
    input  wire [2:0]  ALUControlE,
    input  wire        ALUSrcE,

    // datos entero desde ID/EX
    input  wire [31:0] PCE,
    input  wire [31:0] RD1E,
    input  wire [31:0] RD2E,
    input  wire [31:0] ImmExtE,
    input  wire [4:0]  Rs1E,
    input  wire [4:0]  Rs2E,

    // control / operandos FP desde ID/EX
    input  wire        IsFPAluE,
    input  wire        IsFSWE,
    input  wire [31:0] FRD1E,
    input  wire [31:0] FRD2E,
    input  wire [4:0]  FRs1E,
    input  wire [4:0]  FRs2E,

    // forwarding entero
    input  wire        RegWriteM,
    input  wire        RegWriteW,
    input  wire [4:0]  RdM,
    input  wire [4:0]  RdW,
    input  wire [31:0] ALUResultM,
    input  wire [31:0] ResultW,

    // forwarding FP
    input  wire        FPRegWriteM,
    input  wire [4:0]  FRdM,
    input  wire [31:0] FPResultM,
    input  wire        FPRegWriteW,
    input  wire [4:0]  FRdW,
    input  wire [31:0] FPResultW,

    // salidas entero
    output wire [31:0] ALUResultE,
    output wire [31:0] WriteDataE,
    output wire [31:0] PCTargetE,
    output wire        ZeroE,
    output wire        PCSrcE,

    // salidas FP
    output wire [31:0] FPResultE,
    output wire [4:0]  FPFlagsE
);

    //---------- Forwarding entero ----------
    wire [1:0] ForwardAE;
    wire [1:0] ForwardBE;

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

    reg [31:0] srcA;
    reg [31:0] srcB;

    always @* begin
        case (ForwardAE)
            2'b10: srcA = ALUResultM;  // EX/MEM
            2'b01: srcA = ResultW;     // MEM/WB
            default: srcA = RD1E;      // ID/EX
        endcase

        case (ForwardBE)
            2'b10: srcB = ALUResultM;
            2'b01: srcB = ResultW;
            default: srcB = RD2E;
        endcase
    end

    wire [31:0] srcB_alu = ALUSrcE ? ImmExtE : srcB;

    // ALU entero
    wire [31:0] y_int;
    alu_int alu_u (
        .a        (srcA),
        .b        (srcB_alu),
        .alu_ctrl (ALUControlE),
        .y        (y_int),
        .zero     (ZeroE)
    );

    assign ALUResultE = y_int;

    //---------- Forwarding FP ----------
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
    reg [31:0] fp_srcB_store;

    always @* begin
        // rs1 FP
        case (FPForwardAE)
            2'b10: fp_srcA = FPResultM;
            2'b01: fp_srcA = FPResultW;
            default: fp_srcA = FRD1E;
        endcase

        // rs2 FP (para ALU)
        case (FPForwardBE)
            2'b10: fp_srcB = FPResultM;
            2'b01: fp_srcB = FPResultW;
            default: fp_srcB = FRD2E;
        endcase

        // rs2 FP (dato a almacenar en FSW)
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
        .op_code    (ALUControlE),
        .result     (fp_res),
        .flags      (fp_flags)
    );

    assign FPResultE = fp_res;
    assign FPFlagsE  = fp_flags;

    // dato hacia memoria: SW entero o FSW FP
    assign WriteDataE = IsFSWE ? fp_srcB_store : srcB;

    //---------- cálculo de PC ----------
    assign PCTargetE = PCE + ImmExtE;
    assign PCSrcE    = (BranchE & ZeroE) | JumpE;

endmodule
