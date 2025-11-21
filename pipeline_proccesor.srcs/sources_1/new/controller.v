// =============================================================
// controller.v -- Updated for Fase 3.5 (Verilog-2005)
// Soporta R, I (ADDI, ANDI, ORI), LOAD/STORE, BRANCH y JAL.
// =============================================================
module controller (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg        alu_src,
    output reg        mem_write,
    output reg        mem_read,
    output reg        reg_write,
    output reg [1:0]  result_src,
    output reg [3:0]  alu_ctrl,

    output reg        is_branch,
    output reg        is_jal
);

    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLT = 4'b0101;  // reservado si luego quieres SLT

    always @(*) begin
        // Valores por defecto (NOP)
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        reg_write  = 1'b0;
        result_src = 2'b00;
        alu_ctrl   = ALU_ADD;
        is_branch  = 1'b0;
        is_jal     = 1'b0;

        case (opcode)

            // -------------------------------------------------
            // BRANCH (BEQ/BNE)
            // -------------------------------------------------
            7'b1100011: begin
                is_branch = 1'b1;
                alu_ctrl  = ALU_SUB; // comparación
            end

            // -------------------------------------------------
            // R-TYPE
            // -------------------------------------------------
            7'b0110011: begin
                reg_write = 1'b1;
                case ({funct7,funct3})
                    10'b0000000_000: alu_ctrl = ALU_ADD; // ADD
                    10'b0100000_000: alu_ctrl = ALU_SUB; // SUB
                    10'b0000000_111: alu_ctrl = ALU_AND; // AND
                    10'b0000000_110: alu_ctrl = ALU_OR;  // OR
                    10'b0000000_100: alu_ctrl = ALU_XOR; // XOR
                    default:          alu_ctrl = ALU_ADD;
                endcase
            end

            // -------------------------------------------------
            // I-TYPE aritmético-lógicas: ADDI, ANDI, ORI
            // -------------------------------------------------
            7'b0010011: begin
                alu_src   = 1'b1;  // usar inmediato
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = ALU_ADD; // ADDI
                    3'b111: alu_ctrl = ALU_AND; // ANDI
                    3'b110: alu_ctrl = ALU_OR;  // ORI
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            // -------------------------------------------------
            // LOAD (LB/LH/LW/LBU/LHU)
            // -------------------------------------------------
            7'b0000011: begin
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                reg_write  = 1'b1;
                result_src = 2'b01; // viene de memoria
                alu_ctrl   = ALU_ADD; // base + offset
            end

            // -------------------------------------------------
            // STORE (SB/SH/SW)
            // -------------------------------------------------
            7'b0100011: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_ctrl  = ALU_ADD; // base + offset
            end

            // -------------------------------------------------
            // JAL (J-type)
            // rd = PC+4 (via result_src=2'b10), PC = PC + imm_j
            // -------------------------------------------------
            7'b1101111: begin
                reg_write  = 1'b1;   // escribe rd
                result_src = 2'b10;  // selecciona PC+4 en WB
                is_jal     = 1'b1;   // salto incondicional tipo J
            end

            default: begin
                // NOP
            end
        endcase
    end

endmodule
