// -------------------------------------------------------------
// forwarding_unit.v - Unidad de forwarding
// Codificación de ForwardA/ForwardB:
//   2'b00: usar RD1E/RD2E (sin forwarding)
//   2'b10: usar ALUResultM (EX/MEM)
//   2'b01: usar ResultW   (MEM/WB)
// -------------------------------------------------------------
module forwarding_unit (
    input  wire [4:0] Rs1E,
    input  wire [4:0] Rs2E,
    input  wire [4:0] RdM,
    input  wire [4:0] RdW,
    input  wire       RegWriteM,
    input  wire       RegWriteW,
    output reg  [1:0] ForwardAE,
    output reg  [1:0] ForwardBE
);
    always @* begin
        // Por defecto no hay forwarding
        ForwardAE = 2'b00;
        ForwardBE = 2'b00;

        // -------- Operando A --------
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E)) begin
            ForwardAE = 2'b10;               // desde EX/MEM
        end else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E)) begin
            ForwardAE = 2'b01;               // desde MEM/WB
        end

        // -------- Operando B --------
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E)) begin
            ForwardBE = 2'b10;               // desde EX/MEM
        end else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E)) begin
            ForwardBE = 2'b01;               // desde MEM/WB
        end
    end

endmodule
