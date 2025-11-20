// =============================================================
// pipe_ex_mem.v -- EX/MEM Pipeline Register (Verilog-2005)
// Ahora incluye pc_plus4 para JAL.
// =============================================================
module pipe_ex_mem (
    input  wire         clk,
    input  wire         reset,
    input  wire         enable,
    input  wire         flush,

    input  wire [31:0]  alu_y_in,
    input  wire [31:0]  rf_r2_in,
    input  wire [4:0]   rd_in,
    input  wire         mem_write_in,
    input  wire         mem_read_in,
    input  wire         reg_write_in,
    input  wire [1:0]   result_src_in,
    input  wire [2:0]   funct3_in,
    input  wire [31:0]  pc_plus4_in,

    output reg  [31:0]  alu_y_out,
    output reg  [31:0]  rf_r2_out,
    output reg  [4:0]   rd_out,
    output reg          mem_write_out,
    output reg          mem_read_out,
    output reg          reg_write_out,
    output reg  [1:0]   result_src_out,
    output reg  [2:0]   funct3_out,
    output reg  [31:0]  pc_plus4_out
);

    always @(posedge clk) begin
        if (reset || flush) begin
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            reg_write_out  <= 1'b0;
            result_src_out <= 2'b00;
            funct3_out     <= 3'b000;
            pc_plus4_out   <= 32'd0;
        end else if (enable) begin
            alu_y_out      <= alu_y_in;
            rf_r2_out      <= rf_r2_in;
            rd_out         <= rd_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            reg_write_out  <= reg_write_in;
            result_src_out <= result_src_in;
            funct3_out     <= funct3_in;
            pc_plus4_out   <= pc_plus4_in;
        end
    end

endmodule
