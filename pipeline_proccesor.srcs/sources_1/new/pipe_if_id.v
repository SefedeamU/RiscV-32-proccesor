// =============================================================
// pipe_if_id.v -- Updated for Fase 3.5 (Verilog-2005)
// Ahora también transporta pc_plus4.
// =============================================================
module pipe_if_id (
    input  wire         clk,
    input  wire         reset,
    input  wire         enable,
    input  wire         flush,

    input  wire [31:0]  pc_in,
    input  wire [31:0]  pc_plus4_in,
    input  wire [31:0]  instr_in,

    output reg  [31:0]  pc_out,
    output reg  [31:0]  pc_plus4_out,
    output reg  [31:0]  instr_out
);

    always @(posedge clk) begin
        if (reset) begin
            pc_out       <= 32'd0;
            pc_plus4_out <= 32'd4;
            instr_out    <= 32'h00000013; // NOP
        end else if (flush) begin
            // Se anula la instrucción, pero se puede conservar PC
            instr_out <= 32'h00000013;
        end else if (enable) begin
            pc_out       <= pc_in;
            pc_plus4_out <= pc_plus4_in;
            instr_out    <= instr_in;
        end
    end

endmodule
