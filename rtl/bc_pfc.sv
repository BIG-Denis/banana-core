module bc_pfc
import banana_core_pkg::*;
(
  input  logic         clk_i,

  // BC 0 signals

  output logic        stall_bc0_o,

  // BC 1 signals

  input  dec_ctrls_t  dec_bc1_i,

  output logic        flush_bc1_o,
  output logic        stall_bc1_o,

  // BC 2 signals

  input  dec_ctrls_t  dec_bc2_i,

  output logic [1:0]  bypass_rs1_o,
  output logic [1:0]  bypass_rs2_o,

  output logic        flush_bc2_o,
  output logic        stall_bc2_o,

  // BC 3 signals

  input  dec_ctrls_t  dec_bc3_i,
  input  logic        alu_flag_i,

  output logic        flush_bc3_o,
  output logic        stall_bc3_o,

  // BC 4 signals

  input  dec_ctrls_t  dec_bc4_i,

  output logic        flush_bc4_o,
  output logic        stall_bc4_o

  // possible gate signal for rf wb valid

);





endmodule