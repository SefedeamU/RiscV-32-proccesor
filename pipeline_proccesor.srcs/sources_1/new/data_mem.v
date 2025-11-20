// =============================================================
// data_mem.v  --  Data RAM (Verilog-2005)
// =============================================================
module data_mem (
    input  wire         clk,
    input  wire         mem_we,       // write enable
    input  wire [3:0]   mem_be,       // byte enables
    input  wire [31:0]  addr,
    input  wire [31:0]  wdata,
    output reg  [31:0]  rdata
);

    // RAM de 4096 palabras (16 KB)
    reg [31:0] ram [0:4095];

    wire [11:0] word_addr;
    assign word_addr = addr[13:2];

    // Lectura síncrona
    always @(posedge clk) begin
        rdata <= ram[word_addr];

        if (mem_we) begin
            if (mem_be[0]) ram[word_addr][ 7: 0] <= wdata[ 7: 0];
            if (mem_be[1]) ram[word_addr][15: 8] <= wdata[15: 8];
            if (mem_be[2]) ram[word_addr][23:16] <= wdata[23:16];
            if (mem_be[3]) ram[word_addr][31:24] <= wdata[31:24];
        end
    end

endmodule
