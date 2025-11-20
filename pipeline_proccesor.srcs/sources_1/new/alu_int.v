// =============================================================
// alu_int.v -- Integer ALU (Verilog-2005)
// =============================================================
module alu_int (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] y
);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: y = a + b;
            4'b0001: y = a - b;
            4'b0010: y = a & b;
            4'b0011: y = a | b;
            4'b0100: y = a ^ b;
            4'b0101: y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            4'b0110: y = a << b[4:0];
            4'b0111: y = a >> b[4:0];
            default: y = 32'd0;
        endcase
    end

endmodule
