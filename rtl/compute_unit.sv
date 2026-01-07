module compute_alu
import banana_core_pkg::*;
(
  // Control signals
  input  dec_ctrls_t                     dec_ctrls,

  // RF ports
  input  logic [DATA_WIDTH - 1:0]        rs1_i,
  input  logic [DATA_WIDTH - 1:0]        rs2_i,

  // Immediates
  input  logic [DATA_WIDTH - 1:0]        i_imm_i,
  input  logic [DATA_WIDTH - 1:0]        u_imm_i,
  input  logic [DATA_WIDTH - 1:0]        s_imm_i,

  // PC value
  input  logic [DATA_WIDTH - 1:0]        pc_i,

  // Output port
  output logic [DATA_WIDTH - 1:0]        result_o
);


logic [DATA_WIDTH - 1:0] op1;
logic [DATA_WIDTH - 1:0] op2;

logic [DATA_WIDTH - 1:0] result;

always_comb begin : operands_select
  case ( dec_ctrls.op1_sel_i )
    RS1:    op1 = rs1_i; 
    CONST4: op1 = DATA_WIDTH'(4);
  endcase 
  case ( dec_ctrls.op2_sel_i )
    RS2:     op2 = rs2_i; 
    PC:      op2 = pc_i;
    I_IMM:   op2 = i_imm_i;
    U_IMM:   op2 = u_imm_i;
    S_IMM:   op2 = s_imm_i;
    CONST0:  op2 = DATA_WIDTH'(0);
    default: op2 = 'x;
  endcase
end : operands_select

always_comb begin : compute_block
  case ( dec_ctrls.alu_opcode ) 
  ADD:  result = op1 +   op2;
  SUB:  result = op1 -   op2;
  XOR:  result = op1 ^   op2; 
  OR:   result = op1 |   op2;
  AND:  result = op1 &   op2;
  SRA:  result = op1 <<  op2;
  SRL:  result = op1 <<< op2;
  SLL:  result = op1 >>  op2;
  SLTS: result = ( $signed(op1) < $signed(op2) ) ? DATA_WIDTH'(1) : DATA_WIDTH'(0);  
  SLTU: result = ( op1 < op2 )                   ? DATA_WIDTH'(1) : DATA_WIDTH'(0);  
  endcase
end : compute_block

assign result_o = result;

endmodule
