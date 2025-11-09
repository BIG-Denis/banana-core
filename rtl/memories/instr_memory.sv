module instr_memory
import banana_core_pkg::*;
(
  input  logic                              clk_i,
  input  logic                              arstn_i,

  input  logic [INSTR_MEM_ADDR_WIDTH - 1:0] addr_i,
  output logic [         INSTR_WIDTH - 1:0] data_o
);


logic [INSTR_WIDTH - 1:0] instr_mem [0:INSTR_MEM_SIZE - 1];
logic [INSTR_WIDTH - 1:0] instr_egrs_reg;

always_ff @( posedge clk_i or negedge arstn_i ) begin
  if ( ~arstn_i ) begin
    instr_egrs_reg <= INSTR_WIDTH'b0;
  end
  else begin
    instr_egrs_reg <= instr_mem[addr_i];
  end
end

assign data_o = instr_egrs_reg;

endmodule
