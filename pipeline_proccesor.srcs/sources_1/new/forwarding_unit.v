// =============================================================
// forwarding_unit.v -- EX forwarding logic (Verilog-2005)
// =============================================================
module forwarding_unit (
    input  wire [4:0]  rs1_ex,
    input  wire [4:0]  rs2_ex,

    // MEM stage
    input  wire [4:0]  rd_mem,
    input  wire         reg_write_mem,

    // WB stage
    input  wire [4:0]  rd_wb,
    input  wire         reg_write_wb,

    output reg  [1:0]  forward_a,
    output reg  [1:0]  forward_b
);

    // forward_a:
    // 00 = use ID/EX
    // 01 = forward from MEM
    // 10 = forward from WB

    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        // ------- A (rs1) -------
        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs1_ex))
            forward_a = 2'b01;
        else if (reg_write_wb && (rd_wb != 0) && (rd_wb == rs1_ex))
            forward_a = 2'b10;

        // ------- B (rs2) -------
        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs2_ex))
            forward_b = 2'b01;
        else if (reg_write_wb && (rd_wb != 0) && (rd_wb == rs2_ex))
            forward_b = 2'b10;
    end

endmodule
