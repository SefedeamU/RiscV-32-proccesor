// -------------------------------------------------------------
// hazard_unit.v  - Load-use hazards para enteros (LW) y FP (FLW)
//                  + flush por branch/jump
// -------------------------------------------------------------
module hazard_unit (
    // --- camino entero (igual que antes) ---
    input  wire [4:0] Rs1D,        // registros fuente en ID
    input  wire [4:0] Rs2D,
    input  wire [4:0] RdE,         // destino de instrucción en EX
    input  wire [1:0] ResultSrcE,  // 01 = resultado viene de MEM (LW)
    input  wire       PCSrcE,      // branch/jump tomado en EX

    // --- NUEVO: camino FP para FLW ---
    input  wire [4:0] FRs1D,       // registros fuente FP en ID
    input  wire [4:0] FRs2D,
    input  wire [4:0] FRdE,        // destino FP de instrucción en EX
    input  wire       IsFLWE,      // 1 si instrucción en EX es FLW

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

    wire lwStall_fp  = isLoadE_fp &&
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
