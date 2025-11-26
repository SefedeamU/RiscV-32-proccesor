// Unidad de control RV32I + FP (FADD/FMUL/FDIV, FLW, FSW)
// Separa control entero y FP. 
// El camino FP usa IsFPAluD, IsFLWD, IsFSWD y FPRegWriteD; el camino entero usa el resto.

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
    output reg [2:0]  ALUControlD,
    output reg        ALUSrcD,
    output reg [1:0]  ImmSrcD,

    // control FP
    output reg        IsFPAluD,
    output reg        FPRegWriteD,
    output reg        IsFLWD,
    output reg        IsFSWD
);

    reg [1:0] ALUOp;

    always @* begin
        // defaults entero
        RegWriteD   = 1'b0;
        ResultSrcD  = 2'b00;
        MemWriteD   = 1'b0;
        BranchD     = 1'b0;
        JumpD       = 1'b0;
        ALUSrcD     = 1'b0;
        ImmSrcD     = 2'b00;
        ALUOp       = 2'b00;

        // defaults FP
        IsFPAluD    = 1'b0;
        FPRegWriteD = 1'b0;
        IsFLWD      = 1'b0;
        IsFSWD      = 1'b0;

        case (opcode)
            // -------- entero --------
            7'b0110011: begin // R-type
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b0;
                ResultSrcD = 2'b00;
                ALUOp      = 2'b10;
            end
            7'b0010011: begin // I-type ALU
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ResultSrcD = 2'b00;
                ImmSrcD    = 2'b00;
                ALUOp      = 2'b11;
            end
            7'b0000011: begin // LW
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ResultSrcD = 2'b01;
                ImmSrcD    = 2'b00;
                ALUOp      = 2'b00;
            end
            7'b0100011: begin // SW
                MemWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ImmSrcD    = 2'b01;
                ALUOp      = 2'b00;
            end
            7'b1100011: begin // Branch
                BranchD    = 1'b1;
                ALUSrcD    = 1'b0;
                ImmSrcD    = 2'b10;
                ALUOp      = 2'b01;
            end
            7'b1101111: begin // JAL
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                JumpD      = 1'b1;
                ResultSrcD = 2'b10;
                ImmSrcD    = 2'b11;
                ALUOp      = 2'b00;
            end

            // -------- FP LOAD / STORE --------
            7'b0000111: begin // FLW
                FPRegWriteD = 1'b1;
                IsFLWD      = 1'b1;
                ALUSrcD     = 1'b1;   // base entero + imm
                ImmSrcD     = 2'b00;  // I-type
                ALUOp       = 2'b00;  // ADD
            end
            7'b0100111: begin // FSW
                IsFSWD      = 1'b1;
                MemWriteD   = 1'b1;
                ALUSrcD     = 1'b1;
                ImmSrcD     = 2'b01;  // S-type
                ALUOp       = 2'b00;  // ADD
            end

            // -------- OP-FP --------
            7'b1010011: begin
                FPRegWriteD = 1'b1;
                IsFPAluD    = 1'b1;
                // ALUControlD se decodifica abajo
            end

            default: ;
        endcase
    end

    // decodificador de ALU (entera + FP)
    always @* begin
        ALUControlD = 3'b000;

        if (opcode == 7'b1010011) begin
            // OP-FP: FADD.S / FSUB.S / FMUL.S / FDIV.S
            case (funct7)
                7'b0000000: ALUControlD = 3'b000; // FADD.S
                7'b0000100: ALUControlD = 3'b001; // FSUB.S
                7'b0001000: ALUControlD = 3'b010; // FMUL.S
                7'b0001100: ALUControlD = 3'b011; // FDIV.S
                default:    ALUControlD = 3'b000;
            endcase
        end else begin
            // ALU entero
            case (ALUOp)
                2'b00: ALUControlD = 3'b000; // ADD
                2'b01: ALUControlD = 3'b001; // SUB (branches)
                2'b10: begin               // R-type
                    case (funct3)
                        3'b000: ALUControlD = funct7[5] ? 3'b001 : 3'b000;
                        3'b111: ALUControlD = 3'b010; // AND
                        3'b110: ALUControlD = 3'b011; // OR
                        3'b100: ALUControlD = 3'b100; // XOR
                        3'b010: ALUControlD = 3'b101; // SLT
                        3'b011: ALUControlD = 3'b110; // SLTU
                        default: ALUControlD = 3'b000;
                    endcase
                end
                2'b11: begin               // I-type ALU
                    case (funct3)
                        3'b000: ALUControlD = 3'b000; // ADDI
                        3'b111: ALUControlD = 3'b010; // ANDI
                        3'b110: ALUControlD = 3'b011; // ORI
                        3'b100: ALUControlD = 3'b100; // XORI
                        3'b010: ALUControlD = 3'b101; // SLTI
                        3'b011: ALUControlD = 3'b110; // SLTIU
                        default: ALUControlD = 3'b000;
                    endcase
                end
                default: ALUControlD = 3'b000;
            endcase
        end
    end

endmodule
