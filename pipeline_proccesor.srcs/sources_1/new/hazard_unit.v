// Hazard unit: load-use para enteros (LW) y FP (FLW) + flush por branch/jump tomado.
// Camino entero usa Rs*, Rd*; camino FP usa FRs*, FRd*.

module hazard_unit (
    // camino entero (ID y EX)
    input  wire [4:0] Rs1D,
    input  wire [4:0] Rs2D,
    input  wire [4:0] RdE,
    input  wire [1:0] ResultSrcE,  // 01 => resultado viene de MEM (LW)
    input  wire       PCSrcE,      // branch/jump tomado en EX

    // camino FP (ID y EX) para FLW
    input  wire [4:0] FRs1D,
    input  wire [4:0] FRs2D,
    input  wire [4:0] FRdE,
    input  wire       IsFLWE,      // 1 si instrucción en EX es FLW

    // tipo de instr FP en ID
    input  wire       IsFPAluD,    // OP-FP en ID
    input  wire       IsFSWD,      // FSW  en ID

    // salidas de control
    output wire       StallF,
    output wire       StallD,
    output wire       FlushD,
    output wire       FlushE
);
    // ---------- load-use entero (LW) ----------
    wire isLoadE_int = (ResultSrcE == 2'b01);

    wire lwStall_int = isLoadE_int &&
                       (RdE != 5'd0) &&
                       ((RdE == Rs1D) || (RdE == Rs2D));

    // ---------- load-use FP (FLW) -------------
    wire isLoadE_fp  = IsFLWE;

    // solo si la instr en ID realmente lee registros FP
    wire uses_fp_srcD = IsFPAluD | IsFSWD;

    wire lwStall_fp  = isLoadE_fp &&
                       uses_fp_srcD &&
                       (FRdE != 5'd0) &&
                       ((FRdE == FRs1D) || (FRdE == FRs2D));

    wire lwStall = lwStall_int | lwStall_fp;

    // IF e ID se congelan
    assign StallF = lwStall;
    assign StallD = lwStall;

    // EX se burbujea; también se limpia ante branch/jump tomado
    assign FlushE = lwStall | PCSrcE;

    // ID se limpia solo cuando hay cambio de PC
    assign FlushD = PCSrcE;

endmodule
