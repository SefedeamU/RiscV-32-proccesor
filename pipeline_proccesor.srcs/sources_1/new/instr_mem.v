// Memoria de instrucciones (solo lectura)

module instr_mem #(
    parameter DEPTH = 1024
) (
    input  wire [31:0] a,
    output wire [31:0] rd
);
    reg [31:0] mem [0:DEPTH-1];

    // acceso palabra alineada (PC[1:0] = 00)
    assign rd = mem[a[31:2]];
endmodule
