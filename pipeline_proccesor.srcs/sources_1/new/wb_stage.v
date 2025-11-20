// =============================================================
// wb_stage.v -- Writeback Stage (Verilog-2005)
// =============================================================
module wb_stage (
    input  wire [31:0] alu_y,
    input  wire [31:0] mem_rdata,
    input  wire [31:0] pc_plus4,
    input  wire [1:0]  result_src,
    output reg  [31:0] wb_data
);

    always @(*) begin
        case (result_src)
            2'b00: wb_data = alu_y;
            2'b01: wb_data = mem_rdata;
            2'b10: wb_data = pc_plus4;
            default: wb_data = alu_y;
        endcase
    end

endmodule
