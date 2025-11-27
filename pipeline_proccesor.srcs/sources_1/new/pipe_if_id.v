// pipe_if_id.v

module pipe_if_id (
    input  wire        clk,
    input  wire        reset,
    input  wire        en,      // ~StallD
    input  wire        flush,   // FlushD
    input  wire [31:0] PCF,
    input  wire [31:0] InstrF,
    output reg  [31:0] PCD,
    output reg  [31:0] InstrD
);
    always @(posedge clk) begin
        if (reset || flush) begin
            PCD    <= 32'd0;
            // NOP = ADDI x0,x0,0
            InstrD <= 32'h00000013;
        end else if (en) begin
            PCD    <= PCF;
            InstrD <= InstrF;
        end
    end
endmodule
