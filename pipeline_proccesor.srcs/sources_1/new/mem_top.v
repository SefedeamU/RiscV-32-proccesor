// =============================================================
// mem_top.v -- Sub-sistema de memorias (Verilog-2005)
// =============================================================
module mem_top (
    input  wire         clk,

    // Interfaz a memoria de instrucciones
    input  wire [31:0]  imem_addr,
    output wire [31:0]  imem_rdata,

    // Interfaz a memoria de datos
    input  wire         dmem_we,
    input  wire [3:0]   dmem_be,
    input  wire [31:0]  dmem_addr,
    input  wire [31:0]  dmem_wdata,
    output wire [31:0]  dmem_rdata
);

    // -----------------------------
    // Instruction ROM
    // -----------------------------
    instr_mem u_instr_mem (
        .addr  (imem_addr),
        .instr (imem_rdata)
    );

    // -----------------------------
    // Data RAM
    // -----------------------------
    data_mem u_data_mem (
        .clk    (clk),
        .mem_we (dmem_we),
        .mem_be (dmem_be),
        .addr   (dmem_addr),
        .wdata  (dmem_wdata),
        .rdata  (dmem_rdata)
    );

endmodule
