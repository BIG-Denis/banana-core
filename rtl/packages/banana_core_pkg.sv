package banana_core_pkg

int unsigned DATA_WIDTH    = 32;

int unsigned RF_REGS_COUNT = 32;
int unsigned RF_ADDR_WIDTH = $clog2(RF_REGS_COUNT);

int unsigned ALU_OP1_COUNT = 2;
int unsigned ALU_OP1_SEL_WIDTH = $clog2(ALU_OP2_COUNT);

int unsigned ALU_OP2_COUNT = 6;
int unsigned ALU_OP2_SEL_WIDTH = $clog2(ALU_OP2_COUNT);

int unsigned OPCODE_WIDTH = 5;

typedef enum logic [ALU_OP1_SEL_WIDTH - 1:0] {RS1, CONST4} op1_sel_t;
typedef enum logic [ALU_OP2_SEL_WIDTH - 1:0] {RS2, PC, I_IMM, S_IMM, U_IMM, CONST0} op2_sel_t;

typedef enum logic [OPCODE_WIDTH - 1:0] {
  ADD,  
  SUB,  
  XOR,  
  OR,   
  AND,  
  SRA,  
  SRL,  
  SLL,  
  SLTS,
  SLTU,
  LTS,
  LTU,
  GES,
  GEU,
  EQ, 
  NE
} alu_opcode_t;

endpackage
