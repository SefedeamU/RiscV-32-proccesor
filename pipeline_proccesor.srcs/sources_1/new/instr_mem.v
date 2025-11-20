// =============================================================
// instr_mem.v  --  Instruction ROM (Verilog-2005)
// =============================================================
module instr_mem (
    input  wire [31:0] addr,     // PC
    output reg  [31:0] instr
);

    // Memoria de 1024 palabras (4 KB)
    reg [31:0] rom [0:1023];

    initial begin
        // Puedes reemplazar esto por:
        // $readmemh("program.hex", rom);
        rom[0] = 32'h00000013; // NOP = addi x0,x0,0
        rom[1] = 32'h00000013;
    end

    wire [9:0] word_addr;
    assign word_addr = addr[11:2];

    always @(*) begin
        instr = rom[word_addr];
    end

endmodule
