// alu_decoder.v

module alu_decoder (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    input  wire [1:0] ALUOpD,
    output reg  [2:0] ALUControlD
);
    always @* begin
        ALUControlD = 3'b000;

        // --- Camino FP (OP-FP) ---
        if (opcode == 7'b1010011) begin
            case (funct7)
                7'b0000000: ALUControlD = 3'b000; // FADD.S
                7'b0000100: ALUControlD = 3'b001; // FSUB.S
                7'b0001000: ALUControlD = 3'b010; // FMUL.S
                7'b0001100: ALUControlD = 3'b011; // FDIV.S
                default:    ALUControlD = 3'b000;
            endcase
        end else begin
            // --- Camino entero ---
            case (ALUOpD)
                2'b00: ALUControlD = 3'b000; // ADD
                2'b01: ALUControlD = 3'b001; // SUB (BEQ)

                2'b10: begin // R-type
                    case (funct3)
                        3'b000: ALUControlD = funct7[5] ? 3'b001 : 3'b000; // SUB/ADD
                        3'b111: ALUControlD = 3'b010; // AND
                        3'b110: ALUControlD = 3'b011; // OR
                        3'b100: ALUControlD = 3'b100; // XOR
                        3'b010: ALUControlD = 3'b101; // SLT
                        3'b011: ALUControlD = 3'b110; // SLTU
                        default: ALUControlD = 3'b000;
                    endcase
                end

                2'b11: begin // I-type ALU
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
