// fp_alu_comb.v - ALU FP combinacional (usa tus fp_addsub, fp_mul, fp_div)
// op_code: 000=ADD, 001=SUB, 010=MUL, 011=DIV
// mode_fp: 0=half (16 bits en op_a[15:0]/op_b[15:0]), 1=single (32 bits)
// flags[4:0] = {overflow, underflow, div_by_zero, invalid, inexact}
module alu_fp (
  input  wire        mode_fp,
  input  wire [1:0]  round_mode,
  input  wire [31:0] op_a,
  input  wire [31:0] op_b,
  input  wire [2:0]  op_code,
  output wire [31:0] result,
  output wire [4:0]  flags
);

  wire do_add = (op_code == 3'b000);
  wire do_sub = (op_code == 3'b001);
  wire do_mul = (op_code == 3'b010);
  wire do_div = (op_code == 3'b011);

  // Half (16)
  wire [31:0] res_add16, res_sub16, res_mul16, res_div16;
  wire [4:0]  flg_add16, flg_sub16, flg_mul16, flg_div16;

  fp_addsub #(.W(16), .E(5),  .M(10)) u_add16 (
    .a      (op_a[15:0]),
    .b      (op_b[15:0]),
    .is_sub (1'b0),
    .rnd    (round_mode),
    .y      (res_add16[15:0]),
    .flags  (flg_add16)
  );
  assign res_add16[31:16] = 16'b0;

  fp_addsub #(.W(16), .E(5),  .M(10)) u_sub16 (
    .a      (op_a[15:0]),
    .b      (op_b[15:0]),
    .is_sub (1'b1),
    .rnd    (round_mode),
    .y      (res_sub16[15:0]),
    .flags  (flg_sub16)
  );
  assign res_sub16[31:16] = 16'b0;

  fp_mul #(.W(16), .E(5), .M(10)) u_mul16 (
    .a     (op_a[15:0]),
    .b     (op_b[15:0]),
    .rnd   (round_mode),
    .y     (res_mul16[15:0]),
    .flags (flg_mul16)
  );
  assign res_mul16[31:16] = 16'b0;

  fp_div #(.W(16), .E(5), .M(10)) u_div16 (
    .a     (op_a[15:0]),
    .b     (op_b[15:0]),
    .rnd   (round_mode),
    .y     (res_div16[15:0]),
    .flags (flg_div16)
  );
  assign res_div16[31:16] = 16'b0;

  // Single (32)
  wire [31:0] res_add32, res_sub32, res_mul32, res_div32;
  wire [4:0]  flg_add32, flg_sub32, flg_mul32, flg_div32;

  fp_addsub #(.W(32), .E(8),  .M(23)) u_add32 (
    .a      (op_a),
    .b      (op_b),
    .is_sub (1'b0),
    .rnd    (round_mode),
    .y      (res_add32),
    .flags  (flg_add32)
  );

  fp_addsub #(.W(32), .E(8),  .M(23)) u_sub32 (
    .a      (op_a),
    .b      (op_b),
    .is_sub (1'b1),
    .rnd    (round_mode),
    .y      (res_sub32),
    .flags  (flg_sub32)
  );

  fp_mul #(.W(32), .E(8), .M(23)) u_mul32 (
    .a     (op_a),
    .b     (op_b),
    .rnd   (round_mode),
    .y     (res_mul32),
    .flags (flg_mul32)
  );

  fp_div #(.W(32), .E(8), .M(23)) u_div32 (
    .a     (op_a),
    .b     (op_b),
    .rnd   (round_mode),
    .y     (res_div32),
    .flags (flg_div32)
  );

  wire [31:0] res_half  = do_add ? res_add16 :
                          do_sub ? res_sub16 :
                          do_mul ? res_mul16 :
                          do_div ? res_div16 : 32'b0;

  wire [31:0] res_single = do_add ? res_add32 :
                           do_sub ? res_sub32 :
                           do_mul ? res_mul32 :
                           do_div ? res_div32 : 32'b0;

  wire [4:0] flags_half  = do_add ? flg_add16 :
                           do_sub ? flg_sub16 :
                           do_mul ? flg_mul16 :
                           do_div ? flg_div16 : 5'b0;

  wire [4:0] flags_single = do_add ? flg_add32 :
                            do_sub ? flg_sub32 :
                            do_mul ? flg_mul32 :
                            do_div ? flg_div32 : 5'b0;

  assign result = mode_fp ? res_single : res_half;
  assign flags  = mode_fp ? flags_single : flags_half;

endmodule
