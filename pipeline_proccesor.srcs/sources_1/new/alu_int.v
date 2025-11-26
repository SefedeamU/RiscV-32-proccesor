// -------------------------------------------------------------
// ALU entera RV32I 
// Operaciones soportadas por el pipeline:
//   000: ADD   (ADDI, LW, SW, FLW, FSW, dirección de branch)
//   001: SUB   (SUB, BEQ)
//   010: AND   (ANDI)
//   011: OR    (ORI)
//   100: XOR   (XORI)
// -------------------------------------------------------------
module alu_int (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_ctrl,
    output reg  [31:0] y,
    output wire        zero
);
    always @* begin
        case (alu_ctrl)
            3'b000: y = a + b;  // ADD / ADDI / cargas / stores
            3'b001: y = a - b;  // SUB / BEQ
            3'b010: y = a & b;  // AND / ANDI
            3'b011: y = a | b;  // OR / ORI
            3'b100: y = a ^ b;  // XOR / XORI
            default: y = 32'd0;
        endcase
    end

    assign zero = (y == 32'd0);   // usado en BEQ
endmodule
