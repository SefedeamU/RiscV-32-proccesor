// hazard_unit.v
//  - Maneja hazards de carga-uso para enteros (LW) y FP (FLW)
//  - Stalls: congelan IF/ID
//  - Flush: burbujea EX y limpia ID en branch/jump tomado

module hazard_unit (
    // camino entero (ID y EX)
    input  wire [4:0] Rs1D,
    input  wire [4:0] Rs2D,
    input  wire [4:0] RdE,
    input  wire [1:0] ResultSrcE,  // 01 => resultado desde MEM (LW)
    input  wire       PCSrcE,      // branch/jump tomado en EX

    // camino FP (ID y EX) para FLW
    input  wire [4:0] FRs1D,
    input  wire [4:0] FRs2D,
    input  wire [4:0] FRdE,
    input  wire       IsFLWE,      // 1 si instrucción en EX es FLW

    // tipo de instrucción FP en ID
    input  wire       IsFPAluD,    // OP-FP en ID
    input  wire       IsFSWD,      // FSW en ID

    // salidas de control globales
    output wire       StallF,
    output wire       StallD,
    output wire       FlushD,
    output wire       FlushE
);
    //---------------- load-use entero (LW) ----------------
    wire int_isLoadE = (ResultSrcE == 2'b01);

    wire int_load_use_hazard =
        int_isLoadE &&
        (RdE != 5'd0) &&
        ((RdE == Rs1D) || (RdE == Rs2D));

    //---------------- load-use FP (FLW) -------------------
    wire fp_isLoadE  = IsFLWE;

    // solo si la instrucción en ID realmente lee registros FP
    wire fp_uses_srcD = IsFPAluD | IsFSWD;

    wire fp_load_use_hazard =
        fp_isLoadE &&
        fp_uses_srcD &&
        ((FRdE == FRs1D) || (FRdE == FRs2D));

    // hazard combinado (entero + FP)
    wire load_use_hazard = int_load_use_hazard | fp_load_use_hazard;

    // IF e ID se congelan ante cualquier load-use
    assign StallF = load_use_hazard;
    assign StallD = load_use_hazard;

    // EX se burbujea en load-use o cuando hay salto tomado
    assign FlushE = load_use_hazard | PCSrcE;

    // ID se limpia solo cuando cambia el PC por branch/jump tomado
    assign FlushD = PCSrcE;

endmodule
