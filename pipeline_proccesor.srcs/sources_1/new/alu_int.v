// alu_int.v

module alu_int (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_ctrl,
    output reg  [31:0] y,
    output wire        zero
);
    always @* begin
        case (alu_ctrl)
            3'b000: y = a + b;                            // ADD / dirección
            3'b001: y = a - b;                            // SUB / BEQ
            3'b010: y = a & b;                            // AND 
            3'b011: y = a | b;                            // OR
            3'b100: y = a ^ b;                            // XOR
            3'b101: y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            3'b110: y = (a < b) ? 32'd1 : 32'd0;          // SLTU
            default: y = 32'd0;
        endcase
    end

    assign zero = (y == 32'd0); // usado en BEQ

endmodule
