package banana_core_pkg

////////////////////////////// GENERIC PARAMETERS /////////////////////////////

int unsigned DATA_WIDTH    = 32;

int unsigned RF_REGS_COUNT = 32;
int unsigned RF_ADDR_WIDTH = $clog2(RF_REGS_COUNT);


/////////////////////////////// INTERFACE TYPES ///////////////////////////////

typedef struct packed {
  alu_opcode_t                       alu_opcode;
  logic                              wb_rf_we;
  logic        [RF_ADDR_WIDTH - 1:0] wb_rf_addr;
  // TODO: all more fields
  logic                              is_jump_instr;
  logic                              is_branch_instr;
} decoded_signals_t;

typedef struct packed {
  logic                       rd_we;
  logic [RF_ADDR_WIDTH - 1:0] rd_addr;
  logic [DATA_WIDTH - 1:0]    rd_data;
} rf_wb_t;

endpackage
