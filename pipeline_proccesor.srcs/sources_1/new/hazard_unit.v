// =============================================================
// hazard_unit.v -- Load-Use Hazard Detection (Verilog-2005)
// =============================================================
module hazard_unit (
    // EX stage
    input  wire        mem_read_ex,
    input  wire [4:0]  rd_ex,

    // ID stage
    input  wire [4:0]  rs1_id,
    input  wire [4:0]  rs2_id,

    // Output stalls
    output reg         stall_if,
    output reg         stall_id,
    output reg         flush_ex
);

    always @(*) begin
        // defaults
        stall_if  = 1'b0;
        stall_id  = 1'b0;
        flush_ex  = 1'b0;

        // LOAD-USE hazard
        if (mem_read_ex &&
           ((rd_ex == rs1_id) || (rd_ex == rs2_id)) &&
            rd_ex != 0)
        begin
            stall_if  = 1'b1;
            stall_id  = 1'b1;
            flush_ex  = 1'b1;
        end
    end

endmodule
