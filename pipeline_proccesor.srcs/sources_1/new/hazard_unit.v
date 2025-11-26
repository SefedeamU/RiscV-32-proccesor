// -------------------------------------------------------------
// hazard_unit.v  - Load-use hazards para enteros (LW) y FP (FLW)
//                  + flush por branch/jump
//                  (versión afinada: no mete stall entre FLW consecutivos)
// -------------------------------------------------------------
module hazard_unit (
    // --- camino entero ---
    input  wire [4:0] Rs1D,        // registros fuente en ID (enteros)
    input  wire [4:0] Rs2D,
    input  wire [4:0] RdE,         // destino de instrucción en EX
    input  wire [1:0] ResultSrcE,  // 01 = resultado viene de MEM (LW entero)
    input  wire       PCSrcE,      // branch/jump tomado en EX

    // --- camino FP en ID/EX ---
    input  wire [4:0] FRs1D,       // registros fuente FP en ID
    input  wire [4:0] FRs2D,
    input  wire [4:0] FRdE,        // destino FP de instrucción en EX
    input  wire       IsFLWE,      // 1 si instrucción en EX es FLW

    // NUEVO: tipo de instrucción FP en ID
    input  wire       IsFPAluD,    // 1 si instr en ID es FADD/FMUL/...
    input  wire       IsFSWD,      // 1 si instr en ID es FSW

    // --- salidas de control ---
    output wire       StallF,
    output wire       StallD,
    output wire       FlushD,
    output wire       FlushE
);
    // ---------------- Load-use entero (LW) ----------------
    wire isLoadE_int = (ResultSrcE == 2'b01);  // LW entero en EX

    wire lwStall_int = isLoadE_int &&
                       (RdE != 5'd0) &&
                       ((RdE == Rs1D) || (RdE == Rs2D));

    // ---------------- Load-use FP (FLW) -------------------
    wire isLoadE_fp  = IsFLWE;  // FLW en EX

    // Solo consideramos dependencia FP si la instr en ID realmente
    // LEE registros FP (OP-FP o FSW). FLW no lee FRs1/FRs2.
    wire uses_fp_srcD = IsFPAluD | IsFSWD;

    wire lwStall_fp  = isLoadE_fp &&
                       uses_fp_srcD &&
                       (FRdE != 5'd0) &&
                       ((FRdE == FRs1D) || (FRdE == FRs2D));

    // Stall si hay load-use entero O FP
    wire lwStall = lwStall_int | lwStall_fp;

    // IF e ID se congelan
    assign StallF = lwStall;
    assign StallD = lwStall;

    // EX se "burbujea" (todas las señales de control a 0 en ID/EX)
    assign FlushE = lwStall | PCSrcE;

    // ID se limpia sólo cuando hay cambio de PC
    assign FlushD = PCSrcE;

endmodule
