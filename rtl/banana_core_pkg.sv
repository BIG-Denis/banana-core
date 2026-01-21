package banana_core_pkg;

parameter int unsigned DATA_WIDTH    = 32;

parameter int unsigned RF_REGS_COUNT = 32;
parameter int unsigned RF_ADDR_WIDTH = $clog2(RF_REGS_COUNT);

parameter int unsigned ALU_OP1_COUNT = 3;
parameter int unsigned ALU_OP1_SEL_WIDTH = $clog2(ALU_OP2_COUNT);

parameter int unsigned ALU_OP2_COUNT = 5;
parameter int unsigned ALU_OP2_SEL_WIDTH = $clog2(ALU_OP2_COUNT);

parameter int unsigned OPCODE_WIDTH = 5;

typedef enum logic [ALU_OP1_SEL_WIDTH - 1:0] {RS1, CONST4, U_IMM} alu_op1_sel_t;
typedef enum logic [ALU_OP2_SEL_WIDTH - 1:0] {RS2, PC, I_IMM, S_IMM, CONST0} alu_op2_sel_t;

typedef enum logic [OPCODE_WIDTH - 1:0] {
  ADD,  SUB,  XOR, OR,
  AND,  SRA,  SRL, SLL,
  SLTS, SLTU, LTS, LTU,
  GES,  GEU,  EQ,  NE
} alu_opcode_t;

endpackage
