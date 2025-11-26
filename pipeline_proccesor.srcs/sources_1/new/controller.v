// -------------------------------------------------------------
// Unidad de control RV32I + FP
// Genera control entero, control FP y ALUOp.
// La decodificación fina de la ALU se mueve a alu_decoder.
// -------------------------------------------------------------
module controller (
    input  wire [6:0] opcode,

    // control entero
    output reg        RegWriteD,
    output reg [1:0]  ResultSrcD,
    output reg        MemWriteD,
    output reg        BranchD,
    output reg        JumpD,
    output reg        ALUSrcD,
    output reg [1:0]  ImmSrcD,
    output reg [1:0]  ALUOpD,

    // control FP
    output reg        IsFPAluD,
    output reg        FPRegWriteD,
    output reg        IsFLWD,
    output reg        IsFSWD
);

    always @* begin
        // defaults entero
        RegWriteD   = 1'b0;
        ResultSrcD  = 2'b00;
        MemWriteD   = 1'b0;
        BranchD     = 1'b0;
        JumpD       = 1'b0;
        ALUSrcD     = 1'b0;
        ImmSrcD     = 2'b00;
        ALUOpD      = 2'b00;

        // defaults FP
        IsFPAluD    = 1'b0;
        FPRegWriteD = 1'b0;
        IsFLWD      = 1'b0;
        IsFSWD      = 1'b0;

        case (opcode)
            // -------- entero --------
            7'b0110011: begin // R-type
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b0;
                ResultSrcD = 2'b00;
                ALUOpD     = 2'b10;
            end

            7'b0010011: begin // I-type ALU
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ResultSrcD = 2'b00;
                ImmSrcD    = 2'b00;
                ALUOpD     = 2'b11;
            end

            7'b0000011: begin // LW
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ResultSrcD = 2'b01;
                ImmSrcD    = 2'b00;
                ALUOpD     = 2'b00; // ADD
            end

            7'b0100011: begin // SW
                MemWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ImmSrcD    = 2'b01;
                ALUOpD     = 2'b00; // ADD
            end

            7'b1100011: begin // Branch
                BranchD    = 1'b1;
                ALUSrcD    = 1'b0;
                ImmSrcD    = 2'b10;
                ALUOpD     = 2'b01; // SUB / comparación
            end

            7'b1101111: begin // JAL
                RegWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                JumpD      = 1'b1;
                ResultSrcD = 2'b10;
                ImmSrcD    = 2'b11;
                ALUOpD     = 2'b00; // suma PC + imm
            end

            // -------- FP LOAD / STORE --------
            7'b0000111: begin // FLW
                FPRegWriteD = 1'b1;
                IsFLWD      = 1'b1;
                ALUSrcD     = 1'b1;
                ImmSrcD     = 2'b00; // I-type
                ALUOpD      = 2'b00; // ADD
            end

            7'b0100111: begin // FSW
                IsFSWD      = 1'b1;
                MemWriteD   = 1'b1;
                ALUSrcD     = 1'b1;
                ImmSrcD     = 2'b01; // S-type
                ALUOpD      = 2'b00; // ADD
            end

            // -------- OP-FP --------
            7'b1010011: begin
                FPRegWriteD = 1'b1;
                IsFPAluD    = 1'b1;
                // ALUControlD se resuelve en alu_decoder
            end

            default: ;
        endcase
    end

endmodule
