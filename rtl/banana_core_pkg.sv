package banana_core_pkg;

////////////////////////////// GENERIC PARAMETERS /////////////////////////////

// common
parameter int unsigned DATA_WIDTH  = 32;
parameter int unsigned INSTR_WIDTH = 32;  // until no C extension
parameter int unsigned BYTE_WIDTH  = 8;

// RF - register file
parameter int unsigned RF_REGS_COUNT = 32;
parameter int unsigned RF_ADDR_WIDTH = $clog2(RF_REGS_COUNT);

// IM - instruction memory
parameter int unsigned IM_BYTES_SIZE = 2**14;  // size of IM in bytes, 14 -> 16 kB
parameter int unsigned IM_ADDR_WIDTH = $clog2(IM_BYTES_SIZE);

// DM - data memory
parameter int unsigned DM_BYTES_SIZE = 2**14;  // size of DM in bytes, 14 -> 16 kB
parameter int unsigned DM_WORD_WIDTH = DATA_WIDTH;
parameter int unsigned DM_WORDS_SIZE = DM_BYTES_SIZE / DM_WORD_WIDTH;  // size of DM in words
parameter int unsigned DM_BE_WIDTH   = DM_WORD_WIDTH / BYTE_WIDTH;


//////////////////////////////// INTERNAL TYPES ///////////////////////////////

// ALU

typedef enum logic [ALU_OP1_SEL_WIDTH - 1:0] {RS1, CONST4, U_IMM} alu_op1_sel_t;
typedef enum logic [ALU_OP2_SEL_WIDTH - 1:0] {RS2, PC, I_IMM, S_IMM, CONST0} alu_op2_sel_t;

typedef enum logic [ALU_OPCODE_WIDTH - 1:0] {
  ADD,  SUB,  XOR, OR,
  AND,  SRA,  SRL, SLL,
  SLTS, SLTU, LTS, LTU,
  GES,  GEU,  EQ,  NE
} alu_opcode_t;

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
