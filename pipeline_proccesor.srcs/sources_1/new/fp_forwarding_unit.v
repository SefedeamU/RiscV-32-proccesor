// fp_forwarding_unit.v  (FP)

module fp_forwarding_unit (
    input  wire [4:0] FRs1E,
    input  wire [4:0] FRs2E,
    input  wire [4:0] FRdM,
    input  wire       FPRegWriteM,
    input  wire [4:0] FRdW,
    input  wire       FPRegWriteW,
    output reg  [1:0] FPForwardAE,
    output reg  [1:0] FPForwardBE
);
    always @* begin
        FPForwardAE = 2'b00;
        FPForwardBE = 2'b00;

        if (FPRegWriteM && (FRdM == FRs1E))
            FPForwardAE = 2'b10;
        else if (FPRegWriteW && (FRdW == FRs1E))
            FPForwardAE = 2'b01;

        if (FPRegWriteM && (FRdM == FRs2E))
            FPForwardBE = 2'b10;
        else if (FPRegWriteW && (FRdW == FRs2E))
            FPForwardBE = 2'b01;
    end
endmodule
