// MEM stage: interfaz común para LW/SW y FLW/FSW
// Camino entero y FP comparten la memoria física pero usan señales separadas: MemWriteM (SW) e IsFSWM (FSW).

module mem_stage (
    input  wire        clk,        
    input  wire        MemWriteM,     // SW entero
    input  wire        IsFSWM,        // FSW
    input  wire [31:0] ALUResultM,    // dirección
    input  wire [31:0] WriteDataM,    // dato (entero o FP)
    input  wire [31:0] ReadDataMem,   // dato leído de memoria

    // hacia memoria física
    output wire        dmem_we,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wd,

    // hacia registro MEM/WB
    output wire [31:0] ReadDataM
);
    // SW entero: MemWriteM=1, IsFSWM=0
    // FSW:       IsFSWM=1 (camino FP)
    assign dmem_we   = MemWriteM | IsFSWM;
    assign dmem_addr = ALUResultM;
    assign dmem_wd   = WriteDataM;
    assign ReadDataM = ReadDataMem;
endmodule
