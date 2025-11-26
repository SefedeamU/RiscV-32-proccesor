// cpu_top.v
// Núcleo RV32I pipeline 5 etapas + extensión FP (FADD/FMUL/FDIV, FLW/FSW). Camino entero y camino FP cableados en paralelo.

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

    // memoria de instrucciones (solo lectura)
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
    // Camino entero
    wire [31:0] RD1D, RD2D, ImmExtD;
    wire [4:0]  Rs1D, Rs2D, RdD;

    // Camino FP
    wire [31:0] FRD1D, FRD2D;
    wire [4:0]  FRs1D, FRs2D, FRdD;

    // Control entero
    wire        RegWriteD, MemWriteD, BranchD, JumpD, ALUSrcD;
    wire [1:0]  ResultSrcD, ImmSrcD;
    wire [2:0]  ALUControlD;

    // Control FP
    wire        IsFPAluD;
    wire        FPRegWriteD;
    wire        IsFLWD, IsFSWD;

    // Señales WB entero
    wire        RegWriteW;
    wire [1:0]  ResultSrcW;
    wire [31:0] ReadDataW, ALUResultW, PCPlus4W;
    wire [4:0]  RdW;
    wire [31:0] ResultW;

    // Señales WB FP
    wire        FPRegWriteW;
    wire        IsFLWW, IsFSWW, IsFPAluW;
    wire [31:0] FPResultW;
    wire [4:0]  FRdW;
    wire [31:0] FPResultOutW;

    id_stage id_u (
        .clk         (clk),
        .reset       (reset),
        .PCD         (PCD),
        .InstrD      (InstrD),

        // WB entero
        .RegWriteW   (RegWriteW),
        .RdW         (RdW),
        .ResultW     (ResultW),

        // WB FP
        .FPRegWriteW (FPRegWriteW),
        .FRdW        (FRdW),
        .FPResultW   (FPResultOutW),

        // datos enteros
        .RD1D        (RD1D),
        .RD2D        (RD2D),
        .ImmExtD     (ImmExtD),
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdD         (RdD),

        // datos FP
        .FRD1D       (FRD1D),
        .FRD2D       (FRD2D),
        .FRs1D       (FRs1D),
        .FRs2D       (FRs2D),
        .FRdD        (FRdD),

        // control entero
        .RegWriteD   (RegWriteD),
        .ResultSrcD  (ResultSrcD),
        .MemWriteD   (MemWriteD),
        .BranchD     (BranchD),
        .JumpD       (JumpD),
        .ALUControlD (ALUControlD),
        .ALUSrcD     (ALUSrcD),
        .ImmSrcD     (ImmSrcD),

        // control FP
        .IsFPAluD    (IsFPAluD),
        .FPRegWriteD (FPRegWriteD),
        .IsFLWD      (IsFLWD),
        .IsFSWD      (IsFSWD)
    );

    // PC+4 en D (solo para ResultSrc=PC+4)
    wire [31:0] PCPlus4D = PCD + 32'd4;

    // ---------------- Señales hacia E/M/W ----------------
    // ID/EX -> EX (entero)
    wire        RegWriteE, MemWriteE, BranchE, JumpE, ALUSrcE;
    wire [1:0]  ResultSrcE;
    wire [2:0]  ALUControlE;
    wire [31:0] PCE, RD1E, RD2E, ImmExtE, PCPlus4E;
    wire [4:0]  Rs1E, Rs2E, RdE;

    // ID/EX -> EX (FP)
    wire        IsFPAluE, FPRegWriteE, IsFLWE, IsFSWE;
    wire [31:0] FRD1E, FRD2E;
    wire [4:0]  FRs1E, FRs2E, FRdE;

    // EX -> EX/MEM (entero)
    wire [31:0] ALUResultE, WriteDataE;
    wire        ZeroE;

    // EX -> EX/MEM (FP)
    wire [31:0] FPResultE;
    wire [4:0]  FPFlagsE;   // reservado

    // EX/MEM -> MEM (entero)
    wire        RegWriteM, MemWriteM;
    wire [1:0]  ResultSrcM;
    wire [31:0] ALUResultM, WriteDataM, PCPlus4M;
    wire [4:0]  RdM;

    // EX/MEM -> MEM (FP)
    wire        FPRegWriteM, IsFLWM, IsFSWM, IsFPAluM;
    wire [31:0] FPResultM;
    wire [4:0]  FRdM;

    // Memoria de datos
    wire        dmem_we;
    wire [31:0] dmem_addr, dmem_wd, dmem_rd;
    wire [31:0] ReadDataM;

    // ---------------- Hazard unit (entero + FP carga) ----------------
    hazard_unit hz_u (
        // entero
        .Rs1D       (Rs1D),
        .Rs2D       (Rs2D),
        .RdE        (RdE),
        .ResultSrcE (ResultSrcE),
        .PCSrcE     (PCSrcE),

        // FP (solo FLW)
        .FRs1D      (FRs1D),
        .FRs2D      (FRs2D),
        .FRdE       (FRdE),
        .IsFLWE     (IsFLWE),

        // tipo de instr FP en ID
        .IsFPAluD   (IsFPAluD),
        .IsFSWD     (IsFSWD),

        // salidas
        .StallF     (StallF),
        .StallD     (StallD),
        .FlushD     (FlushD),
        .FlushE     (FlushE)
    );

    // ---------------- ID/EX ----------------
    pipe_id_ex id_ex_reg (
        .clk         (clk),
        .reset       (reset),
        .flush       (FlushE),

        // control entero
        .RegWriteD   (RegWriteD),
        .ResultSrcD  (ResultSrcD),
        .MemWriteD   (MemWriteD),
        .BranchD     (BranchD),
        .JumpD       (JumpD),
        .ALUControlD (ALUControlD),
        .ALUSrcD     (ALUSrcD),

        // control FP
        .IsFPAluD    (IsFPAluD),
        .FPRegWriteD (FPRegWriteD),
        .IsFLWD      (IsFLWD),
        .IsFSWD      (IsFSWD),

        // datos enteros
        .PCD         (PCD),
        .RD1D        (RD1D),
        .RD2D        (RD2D),
        .ImmExtD     (ImmExtD),
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdD         (RdD),
        .PCPlus4D    (PCPlus4D),

        // datos FP
        .FRD1D       (FRD1D),
        .FRD2D       (FRD2D),
        .FRs1D       (FRs1D),
        .FRs2D       (FRs2D),
        .FRdD        (FRdD),

        // salidas enteras
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
        .PCPlus4E    (PCPlus4E),

        // salidas FP
        .IsFPAluE    (IsFPAluE),
        .FPRegWriteE (FPRegWriteE),
        .IsFLWE      (IsFLWE),
        .IsFSWE      (IsFSWE),
        .FRD1E       (FRD1E),
        .FRD2E       (FRD2E),
        .FRs1E       (FRs1E),
        .FRs2E       (FRs2E),
        .FRdE        (FRdE)
    );

    // ---------------- EX ----------------
    ex_stage ex_u (
        // control entero
        .BranchE     (BranchE),
        .JumpE       (JumpE),
        .ALUControlE (ALUControlE),
        .ALUSrcE     (ALUSrcE),

        // datos enteros
        .PCE         (PCE),
        .RD1E        (RD1E),
        .RD2E        (RD2E),
        .ImmExtE     (ImmExtE),
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),

        // control / operandos FP
        .IsFPAluE    (IsFPAluE),
        .IsFSWE      (IsFSWE),
        .FRD1E       (FRD1E),
        .FRD2E       (FRD2E),
        .FRs1E       (FRs1E),
        .FRs2E       (FRs2E),

        // forwarding entero
        .RegWriteM   (RegWriteM),
        .RegWriteW   (RegWriteW),
        .RdM         (RdM),
        .RdW         (RdW),
        .ALUResultM  (ALUResultM),
        .ResultW     (ResultW),

        // forwarding FP
        .FPRegWriteM (FPRegWriteM),
        .FRdM        (FRdM),
        .FPResultM   (FPResultM),
        .FPRegWriteW (FPRegWriteW),
        .FRdW        (FRdW),
        .FPResultW   (FPResultOutW),

        // salidas enteras
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .PCTargetE   (PCTargetE),
        .ZeroE       (ZeroE),
        .PCSrcE      (PCSrcE),

        // salidas FP
        .FPResultE   (FPResultE),
        .FPFlagsE    (FPFlagsE)
        
    );

    // ---------------- EX/MEM ----------------
    pipe_ex_mem ex_mem_reg (
        .clk         (clk),
        .reset       (reset),

        // entero
        .RegWriteE   (RegWriteE),
        .ResultSrcE  (ResultSrcE),
        .MemWriteE   (MemWriteE),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .RdE         (RdE),
        .PCPlus4E    (PCPlus4E),

        // FP
        .FPRegWriteE (FPRegWriteE),
        .IsFLWE      (IsFLWE),
        .IsFSWE      (IsFSWE),
        .IsFPAluE    (IsFPAluE),
        .FPResultE   (FPResultE),
        .FRdE        (FRdE),

        // salidas entero
        .RegWriteM   (RegWriteM),
        .ResultSrcM  (ResultSrcM),
        .MemWriteM   (MemWriteM),
        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .RdM         (RdM),
        .PCPlus4M    (PCPlus4M),

        // salidas FP
        .FPRegWriteM (FPRegWriteM),
        .IsFLWM      (IsFLWM),
        .IsFSWM      (IsFSWM),
        .IsFPAluM    (IsFPAluM),
        .FPResultM   (FPResultM),
        .FRdM        (FRdM)
    );

    // ---------------- MEM + data_mem ----------------
    mem_stage mem_stage_u (
        .clk         (clk),
        .MemWriteM   (MemWriteM),
        .IsFSWM      (IsFSWM),
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

        // entero
        .RegWriteM   (RegWriteM),
        .ResultSrcM  (ResultSrcM),
        .ReadDataM   (ReadDataM),
        .ALUResultM  (ALUResultM),
        .PCPlus4M    (PCPlus4M),
        .RdM         (RdM),

        // FP
        .FPRegWriteM (FPRegWriteM),
        .IsFLWM      (IsFLWM),
        .IsFSWM      (IsFSWM),
        .IsFPAluM    (IsFPAluM),
        .FPResultM   (FPResultM),
        .FRdM        (FRdM),

        // salidas entero
        .RegWriteW   (RegWriteW),
        .ResultSrcW  (ResultSrcW),
        .ReadDataW   (ReadDataW),
        .ALUResultW  (ALUResultW),
        .PCPlus4W    (PCPlus4W),
        .RdW         (RdW),

        // salidas FP
        .FPRegWriteW (FPRegWriteW),
        .IsFLWW      (IsFLWW),
        .IsFSWW      (IsFSWW),
        .IsFPAluW    (IsFPAluW),
        .FPResultW   (FPResultW),
        .FRdW        (FRdW)
    );

    // ---------------- WB ----------------
    wb_stage wb_u (
        // entero
        .ResultSrcW    (ResultSrcW),
        .ReadDataW     (ReadDataW),
        .ALUResultW    (ALUResultW),
        .PCPlus4W      (PCPlus4W),
        .ResultW       (ResultW),

        // FP
        .IsFLWW        (IsFLWW),
        .IsFPAluW      (IsFPAluW),
        .FPResultW_in  (FPResultW),
        .FPResultW  (FPResultOutW)
    );

endmodule
