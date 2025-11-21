// =============================================================
// mem_stage.v -- MEM Stage (Verilog-2005)
// =============================================================
module mem_stage (
    input  wire         clk,

    input  wire         mem_read,
    input  wire         mem_write,
    input  wire [2:0]   funct3,

    input  wire [31:0]  alu_y,
    input  wire [31:0]  rf_r2,

    // RAM interface
    output wire         ram_we,
    output wire [3:0]   ram_be,
    output wire [31:0]  ram_addr,
    output wire [31:0]  ram_wdata,
    input  wire [31:0]  ram_rdata,

    // Resultado hacia WB
    output wire [31:0]  mem_rdata_out
);

    wire [31:0] load_data;

    lsu u_lsu (
        .clk      (clk),
        .mem_read (mem_read),
        .mem_write(mem_write),
        .funct3   (funct3),
        .addr     (alu_y),
        .wdata    (rf_r2),

        .ram_we   (ram_we),
        .ram_be   (ram_be),
        .ram_addr (ram_addr),
        .ram_wdata(ram_wdata),
        .ram_rdata(ram_rdata),

        .load_data(load_data)
    );

    assign mem_rdata_out = load_data;

endmodule
