// IF stage

module if_stage (
    input  wire        clk,
    input  wire        reset,
    input  wire        StallF,     // de hazard_unit
    input  wire        PCSrcE,     // branch/jump tomado en EX
    input  wire [31:0] PCTargetE,  // destino en EX
    output reg  [31:0] PCF,        // PC en IF
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
