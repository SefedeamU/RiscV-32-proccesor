// regfile_int.v

module regfile_int (
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
        if (we && (a3 != 5'd0))
            regs[a3] <= wd3;
    end

    // lectura combinacional con write-first
    assign rd1 = (a1 == 5'd0) ? 32'd0 :
                 (we && (a3 == a1) && (a3 != 5'd0)) ? wd3 : regs[a1];

    assign rd2 = (a2 == 5'd0) ? 32'd0 :
                 (we && (a3 == a2) && (a3 != 5'd0)) ? wd3 : regs[a2];
endmodule
