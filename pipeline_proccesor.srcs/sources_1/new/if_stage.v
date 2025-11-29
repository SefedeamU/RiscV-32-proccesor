// if_stage.v
// Etapa IF con soporte de branch/jump y override de PC para MATMUL

module if_stage (
    input  wire        clk,
    input  wire        reset,

    // control normal de PC
    input  wire        StallF,       // desde lógica global (hazard + micro)
    input  wire        PCSrcE,       // branch/jump tomado desde EX
    input  wire [31:0] PCTargetE,    // destino calculado en EX

    // override desde microsecuenciador MATMUL
    input  wire        PCOverride,   // 1 => usar PCOverrideVal
    input  wire [31:0] PCOverrideVal,

    // salidas de IF
    output reg  [31:0] PCF,          // PC actual (IF)
    output wire [31:0] PCPlus4F,     // PCF + 4
    output wire [31:0] InstrF        // instrucción leída
);
    // PC + 4
    wire [31:0] pc_plus4  = PCF + 32'd4;

    // selección normal (branch/jump o secuencial)
    wire [31:0] pc_br_jmp = PCSrcE ? PCTargetE : pc_plus4;

    // selección final: microsecuenciador puede forzar PC
    wire [31:0] pc_next   = PCOverride ? PCOverrideVal : pc_br_jmp;

    // registro de PC
    always @(posedge clk) begin
        if (reset)
            PCF <= 32'd0;
        else if (!StallF)
            PCF <= pc_next;
    end

    assign PCPlus4F = pc_plus4;

    // Memoria de instrucciones
    instr_mem imem_u (
        .a  (PCF),
        .rd (InstrF)
    );

endmodule
