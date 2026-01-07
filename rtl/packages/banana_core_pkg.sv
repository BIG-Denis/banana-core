package banana_core_pkg;

////////////////////////////// GENERIC PARAMETERS /////////////////////////////

int unsigned DATA_WIDTH    = 32;
int unsigned BYTE_WIDTH    = 8;

int unsigned RF_REGS_COUNT = 32;
int unsigned RF_ADDR_WIDTH = $clog2(RF_REGS_COUNT);

int unsigned DM_WORD_WIDTH = DATA_WIDTH;
int unsigned DM_BE_WIDTH   = DM_WORD_WIDTH / BYTE_WIDTH;


//////////////////////////////// INTERNAL TYPES ///////////////////////////////

// decoder

typedef enum logic [1:0] { WORD, HALF, BYTE } dm_word_pt_t;

typedef struct packed {
  // alu
  alu_opcode_t                alu_opcode;
  alu_op1_sel_t               alu_op1_sel;
  alu_op2_sel_t               alu_op2_sel;
  // rf writeback
  logic                       rf_wb_we;
  logic [RF_ADDR_WIDTH - 1:0] rf_wb_addr;
  // rf reads (for data hazards detection)
  logic [RF_ADDR_WIDTH - 1:0] rf_rs1_addr;
  logic                       rf_rs1_v;
  logic [RF_ADDR_WIDTH - 1:0] rf_rs2_addr;
  logic                       rf_rs2_v;
  // data mem
  logic                       dm_we;
  dm_word_pt_t                dm_word_pt;
  // pc ctrl
  logic                       is_branch_instr;
  logic                       is_jal_instr;
  logic                       is_jalr_instr;
} dec_ctrls_t;

// writeback

typedef struct packed {
  logic                       rd_we;
  logic [RF_ADDR_WIDTH - 1:0] rd_addr;
  logic    [DATA_WIDTH - 1:0] rd_data;
} rf_wb_t;

endpackage
