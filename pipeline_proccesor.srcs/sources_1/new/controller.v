// controller.v
// Unidad de control principal RV32I + FP + MATMUL.FP 

module controller (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,    
    input  wire [6:0] funct7,   

    // control entero
    output reg        RegWriteD,
    output reg [1:0]  ResultSrcD,
    output reg        MemWriteD,
    output reg        BranchD,
    output reg        JumpD,
    output reg        ALUSrcD,
    output reg [1:0]  ImmSrcD,
    output reg [1:0]  ALUOpD,

    // control FP
    output reg        IsFPAluD,
    output reg        FPRegWriteD,
    output reg        IsFLWD,
    output reg        IsFSWD,

    // control MATMUL.FP (pseudo-instrucción)
    output reg        IsMatmulD
);

    // OpCodes básicos
    localparam OP_R      = 7'b0110011; // R-type entero
    localparam OP_I      = 7'b0010011; // I-type ALU
    localparam OP_LW     = 7'b0000011; // LW
    localparam OP_SW     = 7'b0100011; // SW
    localparam OP_BRANCH = 7'b1100011; // BEQ
    localparam OP_JAL    = 7'b1101111; // JAL
    localparam OP_LUI    = 7'b0110111; // LUI (tipo U)
    localparam OP_FLW    = 7'b0000111; // FLW
    localparam OP_FSW    = 7'b0100111; // FSW
    localparam OP_FP     = 7'b1010011; // OP-FP (FADD/FMUL/FDIV/FSUB/MATMUL)

    // funct7 especial para MATMUL.FP (no se usa en otras FP)
    localparam [6:0] F7_MATMUL = 7'b0100001;

    always @* begin
        // Valores por defecto = NOP
        RegWriteD   = 1'b0;
        ResultSrcD  = 2'b00;
        MemWriteD   = 1'b0;
        BranchD     = 1'b0;
        JumpD       = 1'b0;
        ALUSrcD     = 1'b0;
        ImmSrcD     = 2'b00;
        ALUOpD      = 2'b00;

        IsFPAluD    = 1'b0;
        FPRegWriteD = 1'b0;
        IsFLWD      = 1'b0;
        IsFSWD      = 1'b0;
        IsMatmulD   = 1'b0;

        case (opcode)
            // ---------------- Entero ----------------
            OP_R: begin // R-type: ADD, SUB, AND, OR, XOR, SLT, SLTU
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b0;
                ResultSrcD = 2'b00;
                ALUOpD     = 2'b10;
            end

            OP_I: begin // I-type ALU: ADDI, ANDI, ORI, XORI, SLTI, SLTIU
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ResultSrcD = 2'b00;
                ImmSrcD    = 2'b00; // I-type
                ALUOpD     = 2'b11;
            end

            OP_LW: begin // LW
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ResultSrcD = 2'b01; // ReadData
                ImmSrcD    = 2'b00; // I-type
                ALUOpD     = 2'b00; // ADD
            end

            OP_SW: begin // SW
                MemWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ImmSrcD    = 2'b01; // S-type
                ALUOpD     = 2'b00; // ADD
            end

            OP_BRANCH: begin // BEQ
                BranchD    = 1'b1;
                ALUSrcD    = 1'b0;  // rs1 vs rs2
                ImmSrcD    = 2'b10; // B-type
                ALUOpD     = 2'b01; // SUB para comparación
            end

            OP_JAL: begin // JAL
                RegWriteD  = 1'b1;  // rd = PC+4
                ALUSrcD    = 1'b1;  // usa ImmExt para PCTargetE en EX
                JumpD      = 1'b1;  // selecciona PCTargetE
                ResultSrcD = 2'b10; // PCPlus4W en WB
                ImmSrcD    = 2'b11; // J/U (immgen decide J)
                ALUOpD     = 2'b00;
            end

            OP_LUI: begin // LUI: rd = imm[31:12] << 12
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;  // usa inmediato como operando B
                ResultSrcD = 2'b00; // resultado viene de ALU
                ImmSrcD    = 2'b11; // J/U (immgen decide U)
                ALUOpD     = 2'b00; // ADD: srcA=0 (x0), srcB=ImmExt
            end

            // ---------------- FP LOAD / STORE ----------------
            OP_FLW: begin // FLW
                FPRegWriteD = 1'b1;
                IsFLWD      = 1'b1;
                ALUSrcD     = 1'b1;
                ImmSrcD     = 2'b00; // I-type
                ALUOpD      = 2'b00; // ADD dirección
            end

            OP_FSW: begin // FSW
                IsFSWD      = 1'b1;
                MemWriteD   = 1'b1;
                ALUSrcD     = 1'b1;
                ImmSrcD     = 2'b01; // S-type
                ALUOpD      = 2'b00; // ADD dirección
            end

            // ---------------- OP-FP ----------------
            OP_FP: begin
                // MATMUL.FP: pseudo-instrucción con microsecuencia interna
                if ((funct7 == F7_MATMUL) && (funct3 == 3'b000)) begin
                    IsMatmulD = 1'b1;
                    // No se escribe ninguna FP register aquí, el trabajo
                    // lo hará el microsecuenciador con micro-ops FLW/FMUL/FADD/FSW.
                end else begin
                    // OP-FP normal: FADD/FMUL/FDIV/FSUB
                    FPRegWriteD = 1'b1;
                    IsFPAluD    = 1'b1;
                end
            end

            default: ;
        endcase
    end

endmodule
