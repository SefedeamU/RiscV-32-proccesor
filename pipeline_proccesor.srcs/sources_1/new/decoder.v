// Decodificador de la ALU (entera + FP)
// Usa opcode, funct3, funct7 y ALUOpD del controller.

module alu_decoder (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    input  wire [1:0] ALUOpD,
    output reg  [2:0] ALUControlD
);

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
            // ALU entera
            case (ALUOpD)
                2'b00: ALUControlD = 3'b000; // ADD
                2'b01: ALUControlD = 3'b001; // SUB (branches)
                2'b10: begin                 // R-type
                    case (funct3)
                        3'b000: ALUControlD = funct7[5] ? 3'b001 : 3'b000;
                        3'b111: ALUControlD = 3'b010; // AND
                        3'b110: ALUControlD = 3'b011; // OR
                        3'b100: ALUControlD = 3'b100; // XOR
                        default: ALUControlD = 3'b000;
                    endcase
                end
                2'b11: begin                 // I-type ALU
                    case (funct3)
                        3'b000: ALUControlD = 3'b000; // ADDI
                        3'b111: ALUControlD = 3'b010; // ANDI
                        3'b110: ALUControlD = 3'b011; // ORI
                        3'b100: ALUControlD = 3'b100; // XORI
                        default: ALUControlD = 3'b000;
                    endcase
                end
                default: ALUControlD = 3'b000;
            endcase
        end
    end

endmodule
