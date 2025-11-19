package banana_core_pkg

int unsigned DATA_WIDTH    = 32;

int unsigned RF_REGS_COUNT = 32;
int unsigned RF_ADDR_WIDTH = $clog2(RF_REGS_COUNT);

typedef struct packed {
  // Register operands
  logic [DATA_WIDTH - 1:0] rs1;
  logic [DATA_WIDTH - 1:0] rs2;

  // Immediates
  logic [DATA_WIDTH - 1:0] i_imm;
  logic [DATA_WIDTH - 1:0] u_imm;
  logic [DATA_WIDTH - 1:0] s_imm;

  // PC value
  logic [DATA_WIDTH - 1:0] pc;
} comp_unit_data_t;

endpackage
