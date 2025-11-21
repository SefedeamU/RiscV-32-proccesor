// =============================================================
// ex_stage.v -- Updated Fase 3.5 (Verilog-2005)
// Ahora también maneja JAL (is_jal + imm_j).
// =============================================================
module ex_stage (
    // From ID/EX pipeline
    input  wire [31:0]  rf_r1,
    input  wire [31:0]  rf_r2,
    input  wire [31:0]  imm_i,
    input  wire [31:0]  imm_b,
    input  wire [31:0]  imm_j,
    input  wire         alu_src,
    input  wire [3:0]   alu_ctrl,
    input  wire         is_branch,
    input  wire         is_jal,
    input  wire [31:0]  pc,
    input  wire [2:0]   funct3,

    // Forwarding data
    input  wire [31:0]  mem_alu_y,
    input  wire [31:0]  wb_wdata,
    input  wire [1:0]   forward_a,
    input  wire [1:0]   forward_b,

    // Outputs
    output wire [31:0]  alu_y,
    output reg          branch_taken,
    output reg  [31:0]  branch_target
);

    // ------------------------------
    // Forwarding multiplexers
    // ------------------------------
    reg [31:0] srcA;
    reg [31:0] srcB_pre;
    reg [31:0] srcB;

    always @(*) begin
        // Forward A
        case (forward_a)
            2'b00: srcA = rf_r1;
            2'b01: srcA = mem_alu_y;
            2'b10: srcA = wb_wdata;
            default: srcA = rf_r1;
        endcase

        // Forward B (before alu_src)
        case (forward_b)
            2'b00: srcB_pre = rf_r2;
            2'b01: srcB_pre = mem_alu_y;
            2'b10: srcB_pre = wb_wdata;
            default: srcB_pre = rf_r2;
        endcase

        // srcB final (inmediato vs registro)
        srcB = (alu_src) ? imm_i : srcB_pre;
    end

    // ------------------------------
    // ALU
    // ------------------------------
    alu_int u_alu (
        .a        (srcA),
        .b        (srcB),
        .alu_ctrl (alu_ctrl),
        .y        (alu_y)
    );

    // ------------------------------
    // Branch / Jump evaluation
    // - BEQ/BNE usan imm_b
    // - JAL usa imm_j
    // ------------------------------
    always @(*) begin
        branch_taken  = 1'b0;
        branch_target = pc + imm_b; // por defecto, target de branch condicional

        if (is_branch) begin
            // BRANCH condicional (BEQ/BNE)
            case (funct3)
                3'b000: branch_taken = (srcA == srcB_pre); // BEQ
                3'b001: branch_taken = (srcA != srcB_pre); // BNE
                default: branch_taken = 1'b0;
            endcase
        end else if (is_jal) begin
            // JAL: salto incondicional a PC + imm_j
            branch_taken  = 1'b1;
            branch_target = pc + imm_j;
        end
    end

endmodule
