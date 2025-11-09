package banana_core_pkg

int unsigned DATA_WIDTH  = 32;
int unsigned INSTR_WIDTH = 32;

int unsigned RF_REGS_COUNT = 32;
int unsigned RF_ADDR_WIDTH = $clog2(RF_REGS_COUNT);

int unsigned INSTR_MEM_SIZE       = 1024;  // count of INSTR_WIDTH bits instructions
int unsigned INSTR_MEM_ADDR_WIDTH = $clog2(INSTR_MEM_SIZE);

endpackage
