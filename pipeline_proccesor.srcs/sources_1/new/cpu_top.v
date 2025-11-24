// -------------------------------------------------------------
// cpu_top.v - Top-level: núcleo RV32I pipeline + memorias
// -------------------------------------------------------------
module cpu_top (
    input  wire clk,
    input  wire reset
);

    // ---------------- IF ----------------
    wire [31:0] PCF;
    wire [31:0] PCPlus4F;
    wire        StallF, StallD, FlushD, FlushE;
    wire        PCSrcE;
    wire [31:0] PCTargetE;

    if_stage if_u (
        .clk       (clk),
        .reset     (reset),
        .StallF    (StallF),
        .PCSrcE    (PCSrcE),
        .PCTargetE (PCTargetE),
        .PCF       (PCF),
        .PCPlus4F  (PCPlus4F)
    );

    // Memoria de instrucciones
    wire [31:0] InstrF;
    instr_mem imem_u (
        .a  (PCF),
        .rd (InstrF)
    );

    // ---------------- IF/ID ----------------
    wire [31:0] PCD;
    wire [31:0] InstrD;

    pipe_if_id if_id_reg (
        .clk    (clk),
        .reset  (reset),
        .en     (~StallD),
        .flush  (FlushD),
        .PCF    (PCF),
        .InstrF (InstrF),
        .PCD    (PCD),
        .InstrD (InstrD)
    );

    // ---------------- ID ----------------
    wire [31:0] RD1D, RD2D, ImmExtD;
    wire [4:0]  Rs1D, Rs2D, RdD;
    wire        RegWriteD, MemWriteD, BranchD, JumpD, ALUSrcD;
    wire [1:0]  ResultSrcD, ImmSrcD;
    wire [2:0]  ALUControlD;

    // Señales de WB
    wire        RegWriteW;
    wire [1:0]  ResultSrcW;
    wire [31:0] ReadDataW, ALUResultW, PCPlus4W;
    wire [4:0]  RdW;
    wire [31:0] ResultW;

    id_stage id_u (
        .clk         (clk),
        .reset       (reset),
        .PCD         (PCD),
        .InstrD      (InstrD),
        .RegWriteW   (RegWriteW),
        .RdW         (RdW),
        .ResultW     (ResultW),
        .RD1D        (RD1D),
        .RD2D        (RD2D),
        .ImmExtD     (ImmExtD),
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdD         (RdD),
        .RegWriteD   (RegWriteD),
        .ResultSrcD  (ResultSrcD),
        .MemWriteD   (MemWriteD),
        .BranchD     (BranchD),
        .JumpD       (JumpD),
        .ALUControlD (ALUControlD),
        .ALUSrcD     (ALUSrcD),
        .ImmSrcD     (ImmSrcD)
    );

    // PC+4 en D
    wire [31:0] PCPlus4D = PCD + 32'd4;

    // ---------------- Señales de E/M/W ----------------
    // ID/EX -> EX
    wire        RegWriteE, MemWriteE, BranchE, JumpE, ALUSrcE;
    wire [1:0]  ResultSrcE;
    wire [2:0]  ALUControlE;
    wire [31:0] PCE, RD1E, RD2E, ImmExtE, PCPlus4E;
    wire [4:0]  Rs1E, Rs2E, RdE;

    // EX -> EX/MEM
    wire [31:0] ALUResultE, WriteDataE;
    wire        ZeroE;

    // EX/MEM -> MEM
    wire        RegWriteM, MemWriteM;
    wire [1:0]  ResultSrcM;
    wire [31:0] ALUResultM, WriteDataM, PCPlus4M;
    wire [4:0]  RdM;

    // MEM -> data_mem
    wire        dmem_we;
    wire [31:0] dmem_addr, dmem_wd, dmem_rd;
    wire [31:0] ReadDataM;

    // ---------------- Hazard unit ----------------
    // ATENCIÓN: hazard_unit usa PCSrcE (no BranchTakenE)
    hazard_unit hz_u (
        .Rs1D      (Rs1D),
        .Rs2D      (Rs2D),
        .RdE       (RdE),
        .ResultSrcE(ResultSrcE),
        .PCSrcE    (PCSrcE),
        .StallF    (StallF),
        .StallD    (StallD),
        .FlushD    (FlushD),
        .FlushE    (FlushE)
    );

    // ---------------- ID/EX ----------------
    pipe_id_ex id_ex_reg (
        .clk         (clk),
        .reset       (reset),
        .flush       (FlushE),
    
        .RegWriteD   (RegWriteD),
        .ResultSrcD  (ResultSrcD),
        .MemWriteD   (MemWriteD),
        .BranchD     (BranchD),
        .JumpD       (JumpD),
        .ALUControlD (ALUControlD),
        .ALUSrcD     (ALUSrcD),
    
        .PCD         (PCD),
        .RD1D        (RD1D),
        .RD2D        (RD2D),
        .ImmExtD     (ImmExtD),
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdD         (RdD),
        .PCPlus4D    (PCPlus4D),
    
        .RegWriteE   (RegWriteE),
        .ResultSrcE  (ResultSrcE),
        .MemWriteE   (MemWriteE),
        .BranchE     (BranchE),
        .JumpE       (JumpE),
        .ALUControlE (ALUControlE),
        .ALUSrcE     (ALUSrcE),
        .PCE         (PCE),
        .RD1E        (RD1E),
        .RD2E        (RD2E),
        .ImmExtE     (ImmExtE),
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .RdE         (RdE),
        .PCPlus4E    (PCPlus4E)
    );

    // ---------------- EX ----------------
    ex_stage ex_u (
        .BranchE     (BranchE),
        .JumpE       (JumpE),
        .ALUControlE (ALUControlE),
        .ALUSrcE     (ALUSrcE),
        .PCE         (PCE),
        .RD1E        (RD1E),
        .RD2E        (RD2E),
        .ImmExtE     (ImmExtE),
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .RegWriteM   (RegWriteM),
        .RegWriteW   (RegWriteW),
        .RdM         (RdM),
        .RdW         (RdW),
        .ALUResultM  (ALUResultM),
        .ResultW     (ResultW),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .PCTargetE   (PCTargetE),
        .ZeroE       (ZeroE),
        .PCSrcE      (PCSrcE),
        .ForwardAE   (),       // sin usar
        .ForwardBE   (),
        .srcA_fwd    (),
        .srcB_fwd    (),
        .srcB_alu    (),
        .y           ()
    );

    // ---------------- EX/MEM ----------------
    pipe_ex_mem ex_mem_reg (
        .clk         (clk),
        .reset       (reset),
        .RegWriteE   (RegWriteE),
        .ResultSrcE  (ResultSrcE),
        .MemWriteE   (MemWriteE),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .RdE         (RdE),
        .PCPlus4E    (PCPlus4E),
        .RegWriteM   (RegWriteM),
        .ResultSrcM  (ResultSrcM),
        .MemWriteM   (MemWriteM),
        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .RdM         (RdM),
        .PCPlus4M    (PCPlus4M)
    );

    // ---------------- MEM + data_mem ----------------
    mem_stage mem_stage_u (
        .clk         (clk),
        .MemWriteM   (MemWriteM),
        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .ReadDataMem (dmem_rd),
        .dmem_we     (dmem_we),
        .dmem_addr   (dmem_addr),
        .dmem_wd     (dmem_wd),
        .ReadDataM   (ReadDataM)
    );

    data_mem dmem_u (
        .clk (clk),
        .we  (dmem_we),
        .a   (dmem_addr),
        .wd  (dmem_wd),
        .rd  (dmem_rd)
    );

    // ---------------- MEM/WB ----------------
    pipe_mem_wb mem_wb_reg (
        .clk         (clk),
        .reset       (reset),
        .RegWriteM   (RegWriteM),
        .ResultSrcM  (ResultSrcM),
        .ReadDataM   (ReadDataM),
        .ALUResultM  (ALUResultM),
        .PCPlus4M    (PCPlus4M),
        .RdM         (RdM),
        .RegWriteW   (RegWriteW),
        .ResultSrcW  (ResultSrcW),
        .ReadDataW   (ReadDataW),
        .ALUResultW  (ALUResultW),
        .PCPlus4W    (PCPlus4W),
        .RdW         (RdW)
    );

    // ---------------- WB ----------------
    wb_stage wb_u (
        .ResultSrcW (ResultSrcW),
        .ReadDataW  (ReadDataW),
        .ALUResultW (ALUResultW),
        .PCPlus4W   (PCPlus4W),
        .ResultW    (ResultW)
    );

endmodule
