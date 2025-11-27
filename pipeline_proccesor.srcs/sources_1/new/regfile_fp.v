// regfile_fp.v

module regfile_fp (
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  a1,
    input  wire [4:0]  a2,
    input  wire [4:0]  a3,
    input  wire [31:0] wd3,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    reg [31:0] regs [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'd0;
    end

    always @(posedge clk) begin
        if (we)
            regs[a3] <= wd3;
    end

    // lectura combinacional con write-first
    assign rd1 = (we && (a3 == a1)) ? wd3 : regs[a1];
    assign rd2 = (we && (a3 == a2)) ? wd3 : regs[a2];
endmodule
