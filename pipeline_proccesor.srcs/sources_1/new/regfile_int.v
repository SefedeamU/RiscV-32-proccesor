// =============================================================
// regfile_int.v -- Integer Register File (Verilog-2005)
// =============================================================
module regfile_int (
    input  wire         clk,
    input  wire         we,      // write enable
    input  wire [4:0]   raddr1,
    input  wire [4:0]   raddr2,
    input  wire [4:0]   waddr,
    input  wire [31:0]  wdata,
    output reg  [31:0]  rdata1,
    output reg  [31:0]  rdata2
);

    reg [31:0] regs [0:31];

    // Lectura combinacional
    always @(*) begin
        rdata1 = (raddr1 == 5'd0) ? 32'd0 : regs[raddr1];
        rdata2 = (raddr2 == 5'd0) ? 32'd0 : regs[raddr2];
    end

    // Escritura sincrónica
    always @(posedge clk) begin
        if (we && (waddr != 5'd0))
            regs[waddr] <= wdata;
    end

endmodule
