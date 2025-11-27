// matmul_microseq.v
// Pseudo-instrucción MATMUL.FP 2x2 en FP simple precisión (camino 2)
//
// Formato de MATMUL.FP en el ISA:
//   rs1 = base A
//   rs2 = base B
//   rd  = base C
//
// Matrices 2x2 en memoria (float, 4 bytes, row-major):
//   A: A00@0, A01@4, A10@8,  A11@12  desde baseA
//   B: B00@0, B01@4, B10@8,  B11@12  desde baseB
//   C: C00@0, C01@4, C10@8,  C11@12  desde baseC
//
// Estrategia (optimizada para el pipeline):
//   1) Cargar una sola vez todos los elementos de A y B en registros FP:
//        f0=A00, f1=A01, f2=A10, f3=A11,
//        f4=B00, f5=B01, f6=B10, f7=B11.
//   2) Calcular C00,C01,C10,C11 solo con FMUL/FADD y luego FSW.
//   3) No hay OP-FP inmediatamente después de un FLW -> se evitan stalls
//      por hazards FLW→OP-FP en la hazard_unit.
//
// Total: 24 micro-operaciones (8 FLW + 8 FMUL + 4 FADD + 4 FSW).

module matmul_microseq #(
    parameter NUM_UOPS = 24
) (
    input  wire        clk,
    input  wire        reset,

    // disparo desde ID (cuando se detecta MATMUL.FP)
    input  wire        start,       // pulso cuando IsMatmulD=1
    input  wire        stall,       // StallD_hz desde hazard_unit
    input  wire [31:0] pc_after,    // PC+4 de la instrucción MATMUL

    // registros base (índices del regfile entero)
    input  wire [4:0]  baseA_reg,   // rs1 de MATMUL
    input  wire [4:0]  baseB_reg,   // rs2 de MATMUL
    input  wire [4:0]  baseC_reg,   // rd  de MATMUL

    // estado global
    output reg         busy,        // 1 mientras corre la microsecuencia

    // inyección de instrucciones en ID
    output reg         micro_valid, // 1 => micro_instr es válido para ID
    output reg [31:0]  micro_instr,

    // control de PC al finalizar
    output reg         PCOverride,
    output reg [31:0]  PCOverrideVal
);

    // micro-PC (0..NUM_UOPS-1)
    reg [5:0]  uaddr;

    // registros internos para las bases y PC+4
    reg [4:0]  r_baseA;
    reg [4:0]  r_baseB;
    reg [4:0]  r_baseC;
    reg [31:0] r_pc_after;

    // --------------------------------------------------------
    // Funciones de codificación de instrucciones RISC-V
    // --------------------------------------------------------

    // FLW rd, imm(rs1)
    function [31:0] ENCOD_FLW;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
            ENCOD_FLW = {imm[11:0], rs1, 3'b010, rd, 7'b0000111};
        end
    endfunction

    // FSW rs2, imm(rs1)
    function [31:0] ENCOD_FSW;
        input [4:0] rs2;
        input [4:0] rs1;
        input [11:0] imm;
        reg   [6:0] imm_hi;
        reg   [4:0] imm_lo;
        begin
            imm_lo    = imm[4:0];
            imm_hi    = imm[11:5];
            ENCOD_FSW = {imm_hi, rs2, rs1, 3'b010, imm_lo, 7'b0100111};
        end
    endfunction

    // OP-FP (FADD.S, FMUL.S) : rd = op(rs1, rs2)
    //   funct7:
    //      0000000 -> FADD.S
    //      0001000 -> FMUL.S
    function [31:0] ENCOD_OPFP;
        input [6:0] funct7;
        input [4:0] rd;
        input [4:0] rs1;
        input [4:0] rs2;
        begin
            ENCOD_OPFP = {funct7, rs2, rs1, 3'b000, rd, 7'b1010011};
        end
    endfunction

    // --------------------------------------------------------
    // Generación combinacional de la micro-instrucción actual
    //
    // Convención de registros FP usados en la microsecuencia:
    //   f0  = A00
    //   f1  = A01
    //   f2  = A10
    //   f3  = A11
    //   f4  = B00
    //   f5  = B01
    //   f6  = B10
    //   f7  = B11
    //   f8  = producto parcial 0
    //   f9  = producto parcial 1
    //   f10 = acumulador (Cij)
    // --------------------------------------------------------
    always @* begin
        // por defecto, NOP = ADDI x0,x0,0
        micro_instr = 32'h00000013;

        case (uaddr)

            // ---------------- CARGA DE A Y B ----------------
            // A00, A01, A10, A11
            6'd0:  micro_instr = ENCOD_FLW(5'd0, r_baseA, 12'd0);   // FLW f0,  0(baseA)  A00
            6'd1:  micro_instr = ENCOD_FLW(5'd1, r_baseA, 12'd4);   // FLW f1,  4(baseA)  A01
            6'd2:  micro_instr = ENCOD_FLW(5'd2, r_baseA, 12'd8);   // FLW f2,  8(baseA)  A10
            6'd3:  micro_instr = ENCOD_FLW(5'd3, r_baseA, 12'd12);  // FLW f3, 12(baseA)  A11

            // B00, B01, B10, B11
            6'd4:  micro_instr = ENCOD_FLW(5'd4, r_baseB, 12'd0);   // FLW f4,  0(baseB)  B00
            6'd5:  micro_instr = ENCOD_FLW(5'd5, r_baseB, 12'd4);   // FLW f5,  4(baseB)  B01
            6'd6:  micro_instr = ENCOD_FLW(5'd6, r_baseB, 12'd8);   // FLW f6,  8(baseB)  B10
            6'd7:  micro_instr = ENCOD_FLW(5'd7, r_baseB, 12'd12);  // FLW f7, 12(baseB)  B11

            // ---------------- C00 = A00*B00 + A01*B10 ----------------
            6'd8:  micro_instr = ENCOD_OPFP(7'b0001000, 5'd8,  5'd0, 5'd4); // FMUL f8,  f0,f4  (A00*B00)
            6'd9:  micro_instr = ENCOD_OPFP(7'b0001000, 5'd9,  5'd1, 5'd6); // FMUL f9,  f1,f6  (A01*B10)
            6'd10: micro_instr = ENCOD_OPFP(7'b0000000, 5'd10, 5'd8, 5'd9); // FADD f10, f8,f9
            6'd11: micro_instr = ENCOD_FSW (5'd10, r_baseC, 12'd0);        // FSW  f10, 0(baseC)  C00

            // ---------------- C01 = A00*B01 + A01*B11 ----------------
            6'd12: micro_instr = ENCOD_OPFP(7'b0001000, 5'd8,  5'd0, 5'd5); // FMUL f8,  f0,f5  (A00*B01)
            6'd13: micro_instr = ENCOD_OPFP(7'b0001000, 5'd9,  5'd1, 5'd7); // FMUL f9,  f1,f7  (A01*B11)
            6'd14: micro_instr = ENCOD_OPFP(7'b0000000, 5'd10, 5'd8, 5'd9); // FADD f10, f8,f9
            6'd15: micro_instr = ENCOD_FSW (5'd10, r_baseC, 12'd4);        // FSW  f10, 4(baseC)  C01

            // ---------------- C10 = A10*B00 + A11*B10 ----------------
            6'd16: micro_instr = ENCOD_OPFP(7'b0001000, 5'd8,  5'd2, 5'd4); // FMUL f8,  f2,f4  (A10*B00)
            6'd17: micro_instr = ENCOD_OPFP(7'b0001000, 5'd9,  5'd3, 5'd6); // FMUL f9,  f3,f6  (A11*B10)
            6'd18: micro_instr = ENCOD_OPFP(7'b0000000, 5'd10, 5'd8, 5'd9); // FADD f10, f8,f9
            6'd19: micro_instr = ENCOD_FSW (5'd10, r_baseC, 12'd8);        // FSW  f10, 8(baseC)  C10

            // ---------------- C11 = A10*B01 + A11*B11 ----------------
            6'd20: micro_instr = ENCOD_OPFP(7'b0001000, 5'd8,  5'd2, 5'd5); // FMUL f8,  f2,f5  (A10*B01)
            6'd21: micro_instr = ENCOD_OPFP(7'b0001000, 5'd9,  5'd3, 5'd7); // FMUL f9,  f3,f7  (A11*B11)
            6'd22: micro_instr = ENCOD_OPFP(7'b0000000, 5'd10, 5'd8, 5'd9); // FADD f10, f8,f9
            6'd23: micro_instr = ENCOD_FSW (5'd10, r_baseC, 12'd12);       // FSW  f10,12(baseC) C11

            default: ;
        endcase
    end

    // --------------------------------------------------------
    // FSM: recorrido de la microsecuencia y control de PC
    // --------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            busy          <= 1'b0;
            micro_valid   <= 1'b0;
            uaddr         <= 6'd0;
            PCOverride    <= 1'b0;
            PCOverrideVal <= 32'd0;
            r_baseA       <= 5'd0;
            r_baseB       <= 5'd0;
            r_baseC       <= 5'd0;
            r_pc_after    <= 32'd0;
        end else begin
            // por defecto no forzamos el PC (solo un pulso al final)
            PCOverride <= 1'b0;

            if (start && !busy) begin
                // iniciar microsecuencia
                busy        <= 1'b1;
                micro_valid <= 1'b1;
                uaddr       <= 6'd0;

                r_baseA     <= baseA_reg;
                r_baseB     <= baseB_reg;
                r_baseC     <= baseC_reg;
                r_pc_after  <= pc_after;

            end else if (busy) begin
                // avanzamos micro-PC solo si ID no está en stall
                if (!stall) begin
                    if (uaddr == (NUM_UOPS-1)) begin
                        // última micro-instrucción
                        busy        <= 1'b0;
                        micro_valid <= 1'b0;
                        uaddr       <= 6'd0;

                        // al terminar, saltamos a PC+4 (siguiente del MATMUL)
                        PCOverride    <= 1'b1;
                        PCOverrideVal <= r_pc_after;
                    end else begin
                        uaddr <= uaddr + 6'd1;
                    end
                end
                // si hay stall, mantenemos misma micro_instr y uaddr
            end
        end
    end

endmodule
