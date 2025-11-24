// -------------------------------------------------------------
// alu_int.v  - ALU entera RV32I
// alu_ctrl:
//   000: ADD
//   001: SUB
//   010: AND
//   011: OR
//   100: XOR
//   101: SLT  (signed)
//   106: SLTU (unsigned)
//   111: PASS B
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
            3'b000: y = a + b;                              // ADD / ADDI / LW / SW
            3'b001: y = a - b;                              // SUB / BEQ, etc.
            3'b010: y = a & b;                              // AND / ANDI
            3'b011: y = a | b;                              // OR / ORI
            3'b100: y = a ^ b;                              // XOR / XORI
            3'b101: y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT / SLTI
            3'b110: y = (a < b) ? 32'd1 : 32'd0;            // SLTU / SLTIU
            3'b111: y = b;                                  // PASS B (p.ej. LUI)
            default: y = 32'd0;
        endcase
    end

    assign zero = (y == 32'd0);

endmodule
