// =============================================================
// pipe_id_ex.v -- Updated for Fase 3.5 (Verilog-2005)
// Ahora transporta pc_plus4, imm_j e is_jal.
// =============================================================
module pipe_id_ex (
    input  wire         clk,
    input  wire         reset,
    input  wire         enable,
    input  wire         flush,

    input  wire [31:0]  pc_in,
    input  wire [31:0]  pc_plus4_in,
    input  wire [31:0]  imm_i_in,
    input  wire [31:0]  imm_b_in,
    input  wire [31:0]  imm_j_in,
    input  wire [4:0]   rs1_in,
    input  wire [4:0]   rs2_in,
    input  wire [4:0]   rd_in,
    input  wire [3:0]   alu_ctrl_in,
    input  wire         alu_src_in,
    input  wire         mem_write_in,
    input  wire         mem_read_in,
    input  wire         reg_write_in,
    input  wire [1:0]   result_src_in,
    input  wire         is_branch_in,
    input  wire         is_jal_in,
    input  wire [2:0]   funct3_in,
    input  wire [31:0]  rf_r1_in,
    input  wire [31:0]  rf_r2_in,

    output reg [31:0]   pc_out,
    output reg [31:0]   pc_plus4_out,
    output reg [31:0]   imm_i_out,
    output reg [31:0]   imm_b_out,
    output reg [31:0]   imm_j_out,
    output reg [4:0]    rs1_out,
    output reg [4:0]    rs2_out,
    output reg [4:0]    rd_out,
    output reg [3:0]    alu_ctrl_out,
    output reg          alu_src_out,
    output reg          mem_write_out,
    output reg          mem_read_out,
    output reg          reg_write_out,
    output reg [1:0]    result_src_out,
    output reg          is_branch_out,
    output reg          is_jal_out,
    output reg [2:0]    funct3_out,
    output reg [31:0]   rf_r1_out,
    output reg [31:0]   rf_r2_out
);

    always @(posedge clk) begin
        if (reset || flush) begin
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            reg_write_out  <= 1'b0;
            is_branch_out  <= 1'b0;
            is_jal_out     <= 1'b0;
            result_src_out <= 2'b00;
        end else if (enable) begin
            pc_out         <= pc_in;
            pc_plus4_out   <= pc_plus4_in;
            imm_i_out      <= imm_i_in;
            imm_b_out      <= imm_b_in;
            imm_j_out      <= imm_j_in;
            rs1_out        <= rs1_in;
            rs2_out        <= rs2_in;
            rd_out         <= rd_in;
            alu_ctrl_out   <= alu_ctrl_in;
            alu_src_out    <= alu_src_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            reg_write_out  <= reg_write_in;
            result_src_out <= result_src_in;
            is_branch_out  <= is_branch_in;
            is_jal_out     <= is_jal_in;
            funct3_out     <= funct3_in;
            rf_r1_out      <= rf_r1_in;
            rf_r2_out      <= rf_r2_in;
        end
    end

endmodule
