// -------------------------------------------------------------
// Hazard unit: load-use stall + flush por branch/jump
// -------------------------------------------------------------
module hazard_unit (
    input  wire [4:0] Rs1D,
    input  wire [4:0] Rs2D,
    input  wire [4:0] RdE,
    input  wire [1:0] ResultSrcE,   // código completo de ResultSrcE en EX
    input  wire       PCSrcE,       // 1 si en EX hay branch tomado o jump
    output wire       StallF,
    output wire       StallD,
    output wire       FlushD,
    output wire       FlushE
);
    // --- load-use hazard: instrucción en EX es load y su RD se usa en ID ---
    wire isLoadE = (ResultSrcE == 2'b01);  // 01 = resultado desde MEM

    wire lwStall = isLoadE &&
                   (RdE != 5'd0) &&
                   ((RdE == Rs1D) || (RdE == Rs2D));

    // Stalls sólo por load-use
    assign StallF = lwStall;
    assign StallD = lwStall;

    // Flush de E:
    //  - cuando hay burbuja por load-use
    //  - cuando hay cambio de PC (branch tomado o jump) en EX
    assign FlushE = lwStall | PCSrcE;

    // Flush de D:
    //  - sólo cuando hay cambio de PC (branch tomado o jump)
    assign FlushD = PCSrcE;
endmodule
