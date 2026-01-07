module pc_ctrl
import banana_core_pkg::*;
(
  input  logic                              clk_i,
  input  logic                              rstn_i,

  input  logic                              stall_i,
  input  dec_ctrls_t                        dec_ctrls,
  input  logic                              alu_flag_i,

  input  logic [          DATA_WIDTH - 1:0] imm_b_i,
  input  logic [          DATA_WIDTH - 1:0] imm_j_i,
  input  logic [          DATA_WIDTH - 1:0] imm_i_i,
  input  logic [          DATA_WIDTH - 1:0] rf_rs1_data_i,

  output logic [INSTR_MEM_ADDR_WIDTH - 1:0] imem_addr_o
);


logic [INSTR_MEM_ADDR_WIDTH - 1:0] pc_ff;
logic [INSTR_MEM_ADDR_WIDTH - 1:0] pc_next;
logic                              pc_en;


assign pc_en   = ~stall_i;

assign pc_next = dec_ctrls.is_branch_instr && alu_flag_i ? pc_ff + imm_b_i :
                 dec_ctrls.is_jal_instr                  ? pc_ff + imm_j_i :
                 dec_ctrls.is_jalr_instr                 ? rf_rs1_data_i + imm_i_i :
                                                           pc_ff + INSTR_MEM_ADDR_WIDTH'(INSTR_BYTES_SIZE);

always_ff @( posedge clk_i or negedge rstn_i ) begin
  if (~rstn_i) begin
    pc_ff <= INSTR_MEM_ADDR_WIDTH'b0;
  end
  else begin
    if (pc_en) begin
      pc_ff <= pc_next;
    end
  end
end

assign imem_addr_o = pc_ff;

endmodule
