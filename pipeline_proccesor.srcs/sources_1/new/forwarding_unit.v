// forwarding_unit.v  (enteros)

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
        ForwardAE = 2'b00;
        ForwardBE = 2'b00;

        // operando A
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E))
            ForwardAE = 2'b10;
        else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E))
            ForwardAE = 2'b01;

        // operando B
        if (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E))
            ForwardBE = 2'b10;
        else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E))
            ForwardBE = 2'b01;
    end
endmodule
