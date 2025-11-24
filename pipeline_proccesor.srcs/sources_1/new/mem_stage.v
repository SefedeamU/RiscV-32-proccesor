// -------------------------------------------------------------
// MEM stage: adaptación simple hacia data_mem
// (solo LW/SW palabra alineada por ahora)
// -------------------------------------------------------------
module mem_stage (
    input  wire        clk,
    input  wire        MemWriteM,
    input  wire [31:0] ALUResultM,
    input  wire [31:0] WriteDataM,
    input  wire [31:0] ReadDataMem,   // from data_mem

    // hacia memoria de datos física
    output wire        dmem_we,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wd,

    // de vuelta al pipeline
    output wire [31:0] ReadDataM      // hacia MEM/WB
);
    assign dmem_we   = MemWriteM;
    assign dmem_addr = ALUResultM;
    assign dmem_wd   = WriteDataM;

    // sin alineación especial por ahora
    assign ReadDataM = ReadDataMem;
endmodule
