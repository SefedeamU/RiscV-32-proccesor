// -------------------------------------------------------------
// instr_mem.v - Memoria de instrucciones (solo lectura)
// -------------------------------------------------------------
module instr_mem #(
    parameter DEPTH = 1024
) (
    input  wire [31:0] a,  
    output wire [31:0] rd
);
    // IMPORTANTE: nombre 'mem' para poder usar DUT.imem_u.mem
    reg [31:0] mem [0:DEPTH-1];

    // palabras alineadas (PC[1:0] = 00)
    assign rd = mem[a[31:2]];
endmodule
