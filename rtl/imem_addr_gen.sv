module imem_addr_gen
import banana_core_pkg::*;
(
  input  logic                              clk_i,
  input  logic                              arstn_i,

  input  logic                              stall_i,

  input  logic                              is_branch_instr,
  input  logic                              is_jal_instr,
  input  logic                              is_jalr_instr,
  input  logic                              alu_flag_i,

  input  logic [          DATA_WIDTH - 1:0] imm_b_i,
  input  logic [          DATA_WIDTH - 1:0] imm_j_i,
  input  logic [          DATA_WIDTH - 1:0] imm_i_i,
  input  logic [          DATA_WIDTH - 1:0] rf_rs1_data_i,

  output logic [INSTR_MEM_ADDR_WIDTH - 1:0] imem_addr_o
);


logic [INSTR_MEM_ADDR_WIDTH - 1:0] pc_ff;
logic [INSTR_MEM_ADDR_WIDTH - 1:0] pc_next;

assign pc_next = stall_i ? pc_ff :
                           is_branch_instr && alu_flag_i ? pc_ff + imm_b_i :
                                                           is_jal_instr ? pc_ff + imm_j_i :
                                                                          is_jalr_instr ? rf_rs1_data_i + imm_i_i :
                           pc_ff + INSTR_MEM_ADDR_WIDTH'(INSTR_BYTES_SIZE);

always_ff @( posedge clk_i or negedge arstn_i ) begin
  if ( ~arstn_i ) begin
    pc_ff <= INSTR_MEM_ADDR_WIDTH'b0;
  end
  else begin
    pc_ff <= pc_next;
  end
end

assign imem_addr_o = pc_ff;

endmodule
