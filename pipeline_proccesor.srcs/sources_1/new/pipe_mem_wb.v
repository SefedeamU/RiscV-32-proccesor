// =============================================================
// pipe_mem_wb.v -- MEM/WB Pipeline Register (Verilog-2005)
// Ahora incluye pc_plus4 para JAL.
// =============================================================
module pipe_mem_wb (
    input  wire         clk,
    input  wire         reset,
    input  wire         enable,

    input  wire [31:0]  alu_y_in,
    input  wire [31:0]  mem_rdata_in,
    input  wire [4:0]   rd_in,
    input  wire         reg_write_in,
    input  wire [1:0]   result_src_in,
    input  wire [31:0]  pc_plus4_in,

    output reg [31:0]   alu_y_out,
    output reg [31:0]   mem_rdata_out,
    output reg [4:0]    rd_out,
    output reg          reg_write_out,
    output reg [1:0]    result_src_out,
    output reg [31:0]   pc_plus4_out
);

    always @(posedge clk) begin
        if (reset) begin
            reg_write_out  <= 1'b0;
            result_src_out <= 2'b00;
            pc_plus4_out   <= 32'd0;
        end else if (enable) begin
            alu_y_out      <= alu_y_in;
            mem_rdata_out  <= mem_rdata_in;
            rd_out         <= rd_in;
            reg_write_out  <= reg_write_in;
            result_src_out <= result_src_in;
            pc_plus4_out   <= pc_plus4_in;
        end
    end

endmodule
