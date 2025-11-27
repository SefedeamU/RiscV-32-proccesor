// controller.v 
//  - Decodifica RV32I + subset FP (FLW, FSW, FADD.S, FSUB.S, FMUL.S, FDIV.S).
//  - Genera control entero + FP y ALUControlD.

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
    output wire [2:0] ALUControlD,

    // control FP
    output reg        IsFPAluD,
    output reg        FPRegWriteD,
    output reg        IsFLWD,
    output reg        IsFSWD
);
    // opcodes según RISC-V
    localparam OP_R      = 7'b0110011;
    localparam OP_I      = 7'b0010011;
    localparam OP_LW     = 7'b0000011;
    localparam OP_SW     = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_FLW    = 7'b0000111;
    localparam OP_FSW    = 7'b0100111;
    localparam OP_FP     = 7'b1010011;

    reg [1:0] ALUOpD_int;

    always @* begin
        // valores por defecto (NOP)
        RegWriteD   = 1'b0;
        ResultSrcD  = 2'b00;
        MemWriteD   = 1'b0;
        BranchD     = 1'b0;
        JumpD       = 1'b0;
        ALUSrcD     = 1'b0;
        ImmSrcD     = 2'b00;
        ALUOpD_int  = 2'b00;

        IsFPAluD    = 1'b0;
        FPRegWriteD = 1'b0;
        IsFLWD      = 1'b0;
        IsFSWD      = 1'b0;

        case (opcode)
            //----------- Entero -----------
            OP_R: begin          // R-type
                RegWriteD   = 1'b1;
                ALUSrcD     = 1'b0;
                ResultSrcD  = 2'b00;
                ALUOpD_int  = 2'b10;
            end

            OP_I: begin         // I-type ALU
                RegWriteD   = 1'b1;
                ALUSrcD     = 1'b1;
                ResultSrcD  = 2'b00;
                ImmSrcD     = 2'b00; // I-type
                ALUOpD_int  = 2'b11;
            end

            OP_LW: begin        // LW
                RegWriteD   = 1'b1;
                ALUSrcD     = 1'b1;
                ResultSrcD  = 2'b01; // ReadData
                ImmSrcD     = 2'b00; // I-type
                ALUOpD_int  = 2'b00; // ADD
            end

            OP_SW: begin        // SW
                MemWriteD   = 1'b1;
                ALUSrcD     = 1'b1;
                ImmSrcD     = 2'b01; // S-type
                ALUOpD_int  = 2'b00; // ADD
            end

            OP_BRANCH: begin    // BEQ
                BranchD     = 1'b1;
                ALUSrcD     = 1'b0;
                ImmSrcD     = 2'b10; // B-type
                ALUOpD_int  = 2'b01; // SUB (comparación)
            end

            OP_JAL: begin       // JAL
                RegWriteD   = 1'b1;
                ALUSrcD     = 1'b1;
                JumpD       = 1'b1;
                ResultSrcD  = 2'b10; // PC+4
                ImmSrcD     = 2'b11; // J-type
                ALUOpD_int  = 2'b00;
            end

            //----------- FP LOAD / STORE -----------
            OP_FLW: begin       // FLW (funct3=010 en RV32F)
                if (funct3 == 3'b010) begin
                    FPRegWriteD = 1'b1;
                    IsFLWD      = 1'b1;
                    ALUSrcD     = 1'b1;
                    ImmSrcD     = 2'b00; // I-type
                    ALUOpD_int  = 2'b00; // ADD dirección
                end
            end

            OP_FSW: begin       // FSW (funct3=010)
                if (funct3 == 3'b010) begin
                    IsFSWD      = 1'b1;
                    MemWriteD   = 1'b1;
                    ALUSrcD     = 1'b1;
                    ImmSrcD     = 2'b01; // S-type
                    ALUOpD_int  = 2'b00; // ADD dirección
                end
            end

            //----------- OP-FP (FADD/FMUL/FDIV/FSUB) -----------
            OP_FP: begin
                FPRegWriteD = 1'b1;
                IsFPAluD    = 1'b1;
                // para FP no necesitamos ALUOpD_int, alu_decoder
                // se guiará por opcode=OP_FP y funct7
                ALUOpD_int  = 2'b00;
            end

            default: ;
        endcase
    end

    // decoder de ALU (entera + FP)
    alu_decoder dec_u (
        .opcode      (opcode),
        .funct3      (funct3),
        .funct7      (funct7),
        .ALUOpD      (ALUOpD_int),
        .ALUControlD (ALUControlD)
    );

endmodule
