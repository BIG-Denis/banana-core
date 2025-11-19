module compute_unit
import banana_core_pkg::*;
(
  // Control signals
  input alu_opcode_t              alu_opcode_i,

  // Data ports
  input comp_unit_data_t          comp_unit_data_i,
  output logic [DATA_WIDTH - 1:0] result_o,
  output logic                    flag_o
);



endmodule