// -------------------------------------------------------------
// IF stage: PC register + PC+4
// -------------------------------------------------------------
module if_stage (
    input  wire        clk,
    input  wire        reset,
    input  wire        StallF,     // from hazard_unit
    input  wire        PCSrcE,     // taken branch/jump (stage EX)
    input  wire [31:0] PCTargetE,  // target address from EX
    output reg  [31:0] PCF,        // PC in IF
    output wire [31:0] PCPlus4F    // PCF + 4
);
    wire [31:0] pc_plus4 = PCF + 32'd4;
    wire [31:0] pc_next  = PCSrcE ? PCTargetE : pc_plus4;

    always @(posedge clk) begin
        if (reset)
            PCF <= 32'd0;
        else if (!StallF)
            PCF <= pc_next;
    end

    assign PCPlus4F = pc_plus4;
endmodule
