// fp_forwarding_unit.v
// Forwarding para registros de punto flotante.
// Codificación:
//   2'b00 -> usar FRD1E / FRD2E tal cual (ID/EX)
//   2'b10 -> usar resultado FPResultM (EX/MEM)
//   2'b01 -> usar resultado FPResultW (MEM/WB)

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

        // Operando A (rs1 FP)
        if (FPRegWriteM && (FRdM != 5'd0) && (FRdM == FRs1E)) begin
            // resultado en EX/MEM (OP-FP)
            FPForwardAE = 2'b10;
        end else if (FPRegWriteW && (FRdW != 5'd0) && (FRdW == FRs1E)) begin
            // resultado en MEM/WB (OP-FP o FLW)
            FPForwardAE = 2'b01;
        end

        // Operando B (rs2 FP)
        if (FPRegWriteM && (FRdM != 5'd0) && (FRdM == FRs2E)) begin
            FPForwardBE = 2'b10;
        end else if (FPRegWriteW && (FRdW != 5'd0) && (FRdW == FRs2E)) begin
            FPForwardBE = 2'b01;
        end
    end

endmodule
