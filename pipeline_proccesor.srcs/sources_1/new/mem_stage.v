// mem_stage.v + data_mem.v

module mem_stage (
    input  wire        clk,
    input  wire        MemWriteM,     // SW entero
    input  wire        IsFSWM,        // FSW FP
    input  wire [31:0] ALUResultM,    // dirección
    input  wire [31:0] WriteDataM,    // dato (entero o FP)
    output wire [31:0] ReadDataM      // dato leído
);
    wire        dmem_we;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wd;
    wire [31:0] dmem_rd;

    assign dmem_we   = MemWriteM | IsFSWM;
    assign dmem_addr = ALUResultM;
    assign dmem_wd   = WriteDataM;

    data_mem dmem_u (
        .clk (clk),
        .we  (dmem_we),
        .a   (dmem_addr),
        .wd  (dmem_wd),
        .rd  (dmem_rd)
    );

    assign ReadDataM = dmem_rd;
endmodule