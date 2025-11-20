// =============================================================
// regfile_fp.v -- Floating-Point Register File (Verilog-2005)
// =============================================================
module regfile_fp (
    input  wire         clk,
    input  wire         we,
    input  wire [4:0]   raddr1,
    input  wire [4:0]   raddr2,
    input  wire [4:0]   waddr,
    input  wire [31:0]  wdata,
    output reg  [31:0]  rdata1,
    output reg  [31:0]  rdata2
);

    reg [31:0] fregs [0:31];

    always @(*) begin
        rdata1 = fregs[raddr1];
        rdata2 = fregs[raddr2];
    end

    always @(posedge clk) begin
        if (we)
            fregs[waddr] <= wdata;
    end

endmodule
