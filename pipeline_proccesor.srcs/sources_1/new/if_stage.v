// =============================================================
// if_stage.v -- Updated for Fase 3 (Verilog-2005)
// =============================================================
module if_stage (
    input  wire         clk,
    input  wire         reset,
    input  wire         stall,
    input  wire         flush,

    input  wire [31:0]  redirect_pc,
    input  wire         redirect_en,

    input  wire [31:0]  instr_in,
    output reg  [31:0]  instr_out,

    output reg  [31:0]  pc,
    output reg  [31:0]  pc_plus4
);

    wire [31:0] next_pc = redirect_en ? redirect_pc : (pc + 32'd4);

    always @(posedge clk) begin
        if (reset)
            pc <= 32'd0;
        else if (!stall)
            pc <= next_pc;
    end

    always @(posedge clk) begin
        if (reset)
            pc_plus4 <= 32'd4;
        else if (!stall)
            pc_plus4 <= pc + 32'd4;
    end

    always @(posedge clk) begin
        if (reset)
            instr_out <= 32'h00000013;
        else if (flush)
            instr_out <= 32'h00000013;
        else if (!stall)
            instr_out <= instr_in;
    end

endmodule
