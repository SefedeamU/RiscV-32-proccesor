// mem_stage.v - Etapa MEM (LW/SW + FLW/FSW usan el mismo camino)
module mem_stage (
    input  wire        clk,
    input  wire        MemWriteM,
    input  wire        IsFSWM,       // <--- NUEVO
    input  wire [31:0] ALUResultM,
    input  wire [31:0] WriteDataM,
    input  wire [31:0] ReadDataMem,  // from data_mem

    // hacia memoria física
    output wire        dmem_we,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wd,

    // hacia MEM/WB
    output wire [31:0] ReadDataM
);

    // SW entero: MemWriteM=1, IsFSWM=0
    // FSW:       MemWriteM puede ser 0 pero IsFSWM=1
    assign dmem_we   = MemWriteM | IsFSWM;
    assign dmem_addr = ALUResultM;   // dirección calculada en EX
    assign dmem_wd   = WriteDataM;   // dato entero (SW) o FP (FSW)

    assign ReadDataM = ReadDataMem;  // LW y FLW leen por aquí
endmodule
