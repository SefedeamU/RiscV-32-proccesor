// =============================================================
// fpu_add.v -- Minimal stub so Vivado stops failing
// =============================================================
module fpu_add(
    input  wire clk,
    input  wire start,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire busy,
    output wire done,
    output wire [31:0] result
);

    assign busy  = 0;
    assign done  = start;
    assign result = a + b;   // suma entera temporal

endmodule
