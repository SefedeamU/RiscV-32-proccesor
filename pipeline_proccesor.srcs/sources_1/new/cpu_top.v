// =============================================================
// cpu_top.v -- Top-level: core + memories (Verilog-2005)
// Fases 0-3: RV32I pipeline sin FP ni SIMD aún.
// =============================================================
module cpu_top (
    input  wire clk,
    input  wire reset
);

    // ---------------------------------
    // Interfaz entre core y memorias
    // ---------------------------------
    wire [31:0] imem_addr;
    wire [31:0] imem_rdata;

    wire        dmem_we;
    wire [3:0]  dmem_be;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    wire [31:0] dmem_rdata;

    // ---------------------------------
    // Núcleo pipeline RV32I
    // ---------------------------------
    core_pipeline u_core (
        .clk        (clk),
        .reset      (reset),
        // Instr mem
        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),
        // Data mem
        .dmem_we    (dmem_we),
        .dmem_be    (dmem_be),
        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_rdata (dmem_rdata)
    );

    // ---------------------------------
    // Subsistema de memorias
    // ---------------------------------
    mem_top u_mem (
        .clk        (clk),
        // Instr mem
        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),
        // Data mem
        .dmem_we    (dmem_we),
        .dmem_be    (dmem_be),
        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_rdata (dmem_rdata)
    );

    // ---------------------------------
    // Acelerador SIMD (stub por ahora)
    // Se integrará en Fases 5-6.
    // ---------------------------------
    // simd_accel u_simd (
    //     .clk   (clk),
    //     .reset (reset)
    // );

endmodule
