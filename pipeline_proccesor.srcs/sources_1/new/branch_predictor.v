// =============================================================
// branch_predictor.v -- 1-bit predictor (Verilog-2005)
// =============================================================
module branch_predictor (
    input  wire         clk,
    input  wire         reset,

    // PC actual
    input  wire [31:0]  pc,

    // Desde EX: resolución real del branch
    input  wire         update_en,
    input  wire         branch_taken_real,

    // Output: predicción
    output reg          predict_taken
);

    // Predictor ultra simple: un solo bit
    always @(posedge clk) begin
        if (reset)
            predict_taken <= 1'b0;  // default: NO tomado
        else if (update_en)
            predict_taken <= branch_taken_real;
    end

endmodule
