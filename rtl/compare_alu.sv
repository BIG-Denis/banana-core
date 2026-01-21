module compare_alu
import banana_core_pkg::*;
(
  // Control signals
  input  dec_ctrls_t              dec_ctrls,

  // RF ports
  input  logic [DATA_WIDTH - 1:0] rs1_i,
  input  logic [DATA_WIDTH - 1:0] rs2_i,

  // Output port
  output logic                    flag_o
);

logic flag;

always_comb begin : compare_block
  case ( dec_ctrls.alu_opcode )
    LTS: flag = $signed( rs1_i ) < $signed( rs2_i );
    LTU: flag = rs1_i < rs2_i;
    GES: flag = $signed( rs1_i ) >= $signed( rs2_i );
    GEU: flag = rs1_i >= rs2_i;
    EQ:  flag = rs1_i == rs2_i;
    NE:  flag = rs1_i != rs2_i;
  endcase
end : compare_block

assign flag_o = flag;

endmodule
