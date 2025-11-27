// Memoria de datos palabra alineada

module data_mem #(
    parameter DEPTH = 100
) (
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] a,
    input  wire [31:0] wd,
    output wire [31:0] rd
);
    reg [31:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we)
            mem[a[31:2]] <= wd;
    end

    assign rd = mem[a[31:2]];
endmodule
