// =============================================================
// core_pipeline.v -- RV32I 5-stage pipeline core (Verilog-2005)
// Fase 3.5: entero, MEM, hazards, forwarding, JAL y pc+4 en WB.
// =============================================================
module core_pipeline (
    input  wire         clk,
    input  wire         reset,

    // Interfaz memoria de instrucciones
    output wire [31:0]  imem_addr,
    input  wire [31:0]  imem_rdata,

    // Interfaz memoria de datos
    output wire         dmem_we,
    output wire [3:0]   dmem_be,
    output wire [31:0]  dmem_addr,
    output wire [31:0]  dmem_wdata,
    input  wire [31:0]  dmem_rdata
);

    // =========================================================
    // Señales de control de hazards
    // =========================================================
    wire stall_if;
    wire stall_id;
    wire flush_ex;

    // Branch / JAL resuelto en EX
    wire        branch_taken_ex;
    wire [31:0] branch_target_ex;

    wire        redirect_en;
    wire [31:0] redirect_pc;
    wire        if_flush;

    assign redirect_en = branch_taken_ex;    // Predict-not-taken simple
    assign redirect_pc = branch_target_ex;   // PC objetivo cuando se toma
    assign if_flush    = redirect_en;        // Flush IF/ID en branch/jump tomado

    // =========================================================
    // IF stage
    // =========================================================
    wire [31:0] if_pc;
    wire [31:0] if_pc_plus4;
    wire [31:0] if_instr;

    if_stage u_if (
        .clk         (clk),
        .reset       (reset),
        .stall       (stall_if),
        .flush       (if_flush),
        .redirect_pc (redirect_pc),
        .redirect_en (redirect_en),
        .instr_in    (imem_rdata),
        .instr_out   (if_instr),
        .pc          (if_pc),
        .pc_plus4    (if_pc_plus4)
    );

    assign imem_addr = if_pc;

    // =========================================================
    // IF/ID pipeline register
    // =========================================================
    wire [31:0] id_pc;
    wire [31:0] id_pc_plus4;
    wire [31:0] id_instr;

    wire if_id_enable;
    assign if_id_enable = ~stall_id; // si ID se estanca, IF/ID se congela

    pipe_if_id u_if_id (
        .clk         (clk),
        .reset       (reset),
        .enable      (if_id_enable),
        .flush       (if_flush),
        .pc_in       (if_pc),
        .pc_plus4_in (if_pc_plus4),
        .instr_in    (if_instr),
        .pc_out      (id_pc),
        .pc_plus4_out(id_pc_plus4),
        .instr_out   (id_instr)
    );

    // =========================================================
    // ID stage + decoder + controlador
    // =========================================================
    wire [4:0]  id_rs1;
    wire [4:0]  id_rs2;
    wire [4:0]  id_rd;
    wire [2:0]  id_funct3;
    wire [31:0] id_imm_i;
    wire [31:0] id_imm_b;
    wire [31:0] id_imm_j;
    wire [3:0]  id_alu_ctrl;
    wire        id_alu_src;
    wire        id_mem_write;
    wire        id_mem_read;
    wire        id_reg_write;
    wire [1:0]  id_result_src;
    wire        id_is_branch;
    wire        id_is_jal;

    id_stage u_id (
        .instr      (id_instr),
        .rs1        (id_rs1),
        .rs2        (id_rs2),
        .rd         (id_rd),
        .funct3     (id_funct3),
        .rf_r1      (32'd0),   // no usado dentro de id_stage
        .rf_r2      (32'd0),
        .imm_i      (id_imm_i),
        .imm_b      (id_imm_b),
        .imm_j      (id_imm_j),
        .alu_ctrl   (id_alu_ctrl),
        .alu_src    (id_alu_src),
        .mem_write  (id_mem_write),
        .mem_read   (id_mem_read),
        .reg_write  (id_reg_write),
        .result_src (id_result_src),
        .is_branch  (id_is_branch),
        .is_jal     (id_is_jal)
    );

    // =========================================================
    // Banco de registros entero (regfile_int)
    // =========================================================
    wire [31:0] rf_r1;
    wire [31:0] rf_r2;

    // Señales de WB (desde MEM/WB)
    wire [31:0] wb_alu_y;
    wire [31:0] wb_mem_rdata;
    wire [4:0]  wb_rd;
    wire        wb_reg_write;
    wire [1:0]  wb_result_src;
    wire [31:0] wb_wdata;
    wire [31:0] wb_pc_plus4;

    regfile_int u_regfile_int (
        .clk    (clk),
        .we     (wb_reg_write),
        .raddr1 (id_rs1),
        .raddr2 (id_rs2),
        .waddr  (wb_rd),
        .wdata  (wb_wdata),
        .rdata1 (rf_r1),
        .rdata2 (rf_r2)
    );

    // =========================================================
    // ID/EX pipeline register
    // =========================================================
    wire [31:00] ex_pc;
    wire [31:00] ex_pc_plus4;
    wire [31:00] ex_imm_i;
    wire [31:00] ex_imm_b;
    wire [31:00] ex_imm_j;
    wire [4:0]   ex_rs1;
    wire [4:0]   ex_rs2;
    wire [4:0]   ex_rd;
    wire [3:0]   ex_alu_ctrl;
    wire         ex_alu_src;
    wire         ex_mem_write;
    wire         ex_mem_read;
    wire         ex_reg_write;
    wire [1:0]   ex_result_src;
    wire         ex_is_branch;
    wire         ex_is_jal;
    wire [2:0]   ex_funct3;
    wire [31:0]  ex_rf_r1;
    wire [31:0]  ex_rf_r2;

    wire id_ex_enable;
    wire id_ex_flush;

    assign id_ex_enable = ~stall_id;
    assign id_ex_flush  = flush_ex | redirect_en; // burbuja por load-use o branch/jump

    pipe_id_ex u_id_ex (
        .clk            (clk),
        .reset          (reset),
        .enable         (id_ex_enable),
        .flush          (id_ex_flush),

        .pc_in          (id_pc),
        .pc_plus4_in    (id_pc_plus4),
        .imm_i_in       (id_imm_i),
        .imm_b_in       (id_imm_b),
        .imm_j_in       (id_imm_j),
        .rs1_in         (id_rs1),
        .rs2_in         (id_rs2),
        .rd_in          (id_rd),
        .alu_ctrl_in    (id_alu_ctrl),
        .alu_src_in     (id_alu_src),
        .mem_write_in   (id_mem_write),
        .mem_read_in    (id_mem_read),
        .reg_write_in   (id_reg_write),
        .result_src_in  (id_result_src),
        .is_branch_in   (id_is_branch),
        .is_jal_in      (id_is_jal),
        .funct3_in      (id_funct3),
        .rf_r1_in       (rf_r1),
        .rf_r2_in       (rf_r2),

        .pc_out         (ex_pc),
        .pc_plus4_out   (ex_pc_plus4),
        .imm_i_out      (ex_imm_i),
        .imm_b_out      (ex_imm_b),
        .imm_j_out      (ex_imm_j),
        .rs1_out        (ex_rs1),
        .rs2_out        (ex_rs2),
        .rd_out         (ex_rd),
        .alu_ctrl_out   (ex_alu_ctrl),
        .alu_src_out    (ex_alu_src),
        .mem_write_out  (ex_mem_write),
        .mem_read_out   (ex_mem_read),
        .reg_write_out  (ex_reg_write),
        .result_src_out (ex_result_src),
        .is_branch_out  (ex_is_branch),
        .is_jal_out     (ex_is_jal),
        .funct3_out     (ex_funct3),
        .rf_r1_out      (ex_rf_r1),
        .rf_r2_out      (ex_rf_r2)
    );

    // =========================================================
    // Unidad de hazards (load-use)
    // =========================================================
    hazard_unit u_hazard (
        .mem_read_ex (ex_mem_read),
        .rd_ex       (ex_rd),
        .rs1_id      (id_rs1),
        .rs2_id      (id_rs2),
        .stall_if    (stall_if),
        .stall_id    (stall_id),
        .flush_ex    (flush_ex)
    );

    // =========================================================
    // Unidad de forwarding
    // =========================================================
    wire [31:0] mem_alu_y;
    wire [31:0] mem_rf_r2;
    wire [4:0]  mem_rd;
    wire        mem_mem_write;
    wire        mem_mem_read;
    wire        mem_reg_write;
    wire [1:0]  mem_result_src;
    wire [2:0]  mem_funct3;
    wire [31:0] mem_pc_plus4;

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    forwarding_unit u_forward (
        .rs1_ex        (ex_rs1),
        .rs2_ex        (ex_rs2),
        .rd_mem        (mem_rd),
        .reg_write_mem (mem_reg_write),
        .rd_wb         (wb_rd),
        .reg_write_wb  (wb_reg_write),
        .forward_a     (forward_a),
        .forward_b     (forward_b)
    );

    // =========================================================
    // EX stage
    // =========================================================
    wire [31:0] ex_alu_y;

    ex_stage u_ex (
        .rf_r1         (ex_rf_r1),
        .rf_r2         (ex_rf_r2),
        .imm_i         (ex_imm_i),
        .imm_b         (ex_imm_b),
        .imm_j         (ex_imm_j),
        .alu_src       (ex_alu_src),
        .alu_ctrl      (ex_alu_ctrl),
        .is_branch     (ex_is_branch),
        .is_jal        (ex_is_jal),
        .pc            (ex_pc),
        .funct3        (ex_funct3),

        .mem_alu_y     (mem_alu_y),
        .wb_wdata      (wb_wdata),
        .forward_a     (forward_a),
        .forward_b     (forward_b),

        .alu_y         (ex_alu_y),
        .branch_taken  (branch_taken_ex),
        .branch_target (branch_target_ex)
    );

    // Predictor de branch 1-bit (solo se actualiza, no se usa para PC aún)
    branch_predictor u_bp (
        .clk               (clk),
        .reset             (reset),
        .pc                (ex_pc),
        .update_en         (ex_is_branch),
        .branch_taken_real (branch_taken_ex),
        .predict_taken     ()
    );

    // =========================================================
    // EX/MEM pipeline register
    // =========================================================
    pipe_ex_mem u_ex_mem (
        .clk            (clk),
        .reset          (reset),
        .enable         (1'b1),
        .flush          (1'b0),

        .alu_y_in       (ex_alu_y),
        .rf_r2_in       (ex_rf_r2),
        .rd_in          (ex_rd),
        .mem_write_in   (ex_mem_write),
        .mem_read_in    (ex_mem_read),
        .reg_write_in   (ex_reg_write),
        .result_src_in  (ex_result_src),
        .funct3_in      (ex_funct3),
        .pc_plus4_in    (ex_pc_plus4),

        .alu_y_out      (mem_alu_y),
        .rf_r2_out      (mem_rf_r2),
        .rd_out         (mem_rd),
        .mem_write_out  (mem_mem_write),
        .mem_read_out   (mem_mem_read),
        .reg_write_out  (mem_reg_write),
        .result_src_out (mem_result_src),
        .funct3_out     (mem_funct3),
        .pc_plus4_out   (mem_pc_plus4)
    );

    // =========================================================
    // MEM stage + LSU -> Memoria de datos
    // =========================================================
    wire [31:0] mem_load_data;

    mem_stage u_mem_stage (
        .clk            (clk),
        .mem_read       (mem_mem_read),
        .mem_write      (mem_mem_write),
        .funct3         (mem_funct3),
        .alu_y          (mem_alu_y),
        .rf_r2          (mem_rf_r2),
        .ram_we         (dmem_we),
        .ram_be         (dmem_be),
        .ram_addr       (dmem_addr),
        .ram_wdata      (dmem_wdata),
        .ram_rdata      (dmem_rdata),
        .mem_rdata_out  (mem_load_data)
    );

    // =========================================================
    // MEM/WB pipeline register
    // =========================================================
    pipe_mem_wb u_mem_wb (
        .clk            (clk),
        .reset          (reset),
        .enable         (1'b1),

        .alu_y_in       (mem_alu_y),
        .mem_rdata_in   (mem_load_data),
        .rd_in          (mem_rd),
        .reg_write_in   (mem_reg_write),
        .result_src_in  (mem_result_src),
        .pc_plus4_in    (mem_pc_plus4),

        .alu_y_out      (wb_alu_y),
        .mem_rdata_out  (wb_mem_rdata),
        .rd_out         (wb_rd),
        .reg_write_out  (wb_reg_write),
        .result_src_out (wb_result_src),
        .pc_plus4_out   (wb_pc_plus4)
    );

    // =========================================================
    // WB stage
    // =========================================================
    wb_stage u_wb (
        .alu_y      (wb_alu_y),
        .mem_rdata  (wb_mem_rdata),
        .pc_plus4   (wb_pc_plus4),
        .result_src (wb_result_src),
        .wb_data    (wb_wdata)
    );

endmodule
