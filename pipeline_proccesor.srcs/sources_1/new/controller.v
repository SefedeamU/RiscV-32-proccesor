// -------------------------------------------------------------
// controller.v - Unidad de control RV32I (entero)
// -------------------------------------------------------------
module controller (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg        RegWriteD,
    output reg [1:0]  ResultSrcD,
    output reg        MemWriteD,
    output reg        BranchD,
    output reg        JumpD,
    output reg [2:0]  ALUControlD,
    output reg        ALUSrcD,
    output reg [1:0]  ImmSrcD
);

    // ALUOp interno
    reg [1:0] ALUOp;

    // ---------------- Main decode ----------------
    always @* begin
        // valores por defecto
        RegWriteD   = 1'b0;
        ResultSrcD  = 2'b00;
        MemWriteD   = 1'b0;
        BranchD     = 1'b0;
        JumpD       = 1'b0;
        ALUSrcD     = 1'b0;
        ImmSrcD     = 2'b00;
        ALUOp       = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type: add, sub, and, or, xor, slt, sltu
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b0;
                ResultSrcD = 2'b00;
                ALUOp      = 2'b10;
            end

            7'b0010011: begin // I-type ALU: addi, andi, ori, xori, slti...
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ResultSrcD = 2'b00;
                ImmSrcD    = 2'b00;  // imm I
                ALUOp      = 2'b11;
            end

            7'b0000011: begin // LW
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ResultSrcD = 2'b01; // resultado viene de MEM
                ImmSrcD    = 2'b00; // imm I
                ALUOp      = 2'b00; // ADD para dirección
            end

            7'b0100011: begin // SW
                RegWriteD  = 1'b0;
                ALUSrcD    = 1'b1;
                MemWriteD  = 1'b1;
                ImmSrcD    = 2'b01; // imm S
                ALUOp      = 2'b00; // ADD para dirección
            end

            7'b1100011: begin // Branches (BEQ, BNE, BLT...)
                RegWriteD  = 1'b0;
                ALUSrcD    = 1'b0;
                BranchD    = 1'b1;
                ImmSrcD    = 2'b10; // imm B
                ALUOp      = 2'b01; // SUB para comparar
            end

            7'b1101111: begin // JAL
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;   // PC + imm
                JumpD      = 1'b1;
                ResultSrcD = 2'b10;  // PC+4
                ImmSrcD    = 2'b11;  // imm J
                ALUOp      = 2'b00;  // ADD
            end

            default: begin
                // ya están en cero los defaults
            end
        endcase
    end

    // ---------------- ALU decoder ----------------
    always @* begin
        case (ALUOp)
            2'b00: ALUControlD = 3'b000; // ADD
            2'b01: ALUControlD = 3'b001; // SUB
            2'b10: begin                // R-type
                case (funct3)
                    3'b000: ALUControlD = (funct7[5]) ? 3'b001 : 3'b000; // SUB vs ADD
                    3'b111: ALUControlD = 3'b010; // AND
                    3'b110: ALUControlD = 3'b011; // OR
                    3'b100: ALUControlD = 3'b100; // XOR
                    3'b010: ALUControlD = 3'b101; // SLT
                    3'b011: ALUControlD = 3'b110; // SLTU
                    default: ALUControlD = 3'b000;
                endcase
            end
            2'b11: begin                // I-type ALU
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

endmodule
