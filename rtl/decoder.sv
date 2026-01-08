module decoder
import banana_core_pkg::*;
(
  input logic [DATA_WIDTH - 1:0] instr_i,

  output dec_ctrls_t             dec_o,
  output logic                   illegal_instr_o
);

// Instruction fields

logic [ALU_OPCODE_WIDTH - 1:0] opcode;
logic [2:0]                    funct3;
logic [6:0]                    funct7

logic [RF_ADDR_WIDTH - 1:0]    rd;
logic [RF_ADDR_WIDTH - 1:0]    rs1; 
logic [RF_ADDR_WIDTH - 1:0]    rs2;

assign opcode = instr_i[6:2];
assign funct3 = instr_i[14:12];
assign funct7 = instr_i[31:25];

assign rd     = instr_i[11:7];
assign rs1    = instr_i[19:15];
assign rs2    = instr_i[24:20];

always_comb begin : decode_block
  
  illegal_instr_o       = 1'b0;
  
  if ( instr_i[1:0] == 2'b11 ) begin
    case( opcode )

    5'b01101:  // LUI

      dec_o.alu_opcode      = ADD;
      dec_o.alu_op1_sel     = U_IMM;
      dec_o.alu_op2_sel     = CONST0;

      dec_o.rf_wb_we        = 1'b1;
      dec_o.rf_wb_addr      = rd;

      dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(0);
      dec_o.rf_rs1_v        = 1'b0;
      dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(0);
      dec_o.rf_rs2_v        = 1'b0;

      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

    5'b00101:  // AUIPC

      dec_o.alu_opcode      = ADD;
      dec_o.alu_op1_sel     = U_IMM;
      dec_o.alu_op2_sel     = PC;

      dec_o.rf_wb_we        = 1'b1;
      dec_o.rf_wb_addr      = rd;

      dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(0);
      dec_o.rf_rs1_v        = 1'b0;
      dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(0);
      dec_o.rf_rs2_v        = 1'b0;

      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

    5'b00100:  // I-type
  
      dec_o.alu_op1_sel     = RS1;
      dec_o.alu_op2_sel     = I_IMM;

      dec_o.rf_wb_we        = 1'b1;
      dec_o.rf_wb_addr      = rd;

      dec_o.rf_rs1_addr     = rs1;
      dec_o.rf_rs1_v        = 1'b1;
      dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(0);
      dec_o.rf_rs2_v        = 1'b0;

      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

      case ( funct3 )

      3'b000: dec_o.alu_opcode = ADD     // addi
      3'b001: dec_o.alu_opcode = SLL     // slli
      3'b010: dec_o.alu_opcode = SLTS    // slti
      3'b011: dec_o.alu_opcode = SLTU    // sltiu
      3'b100: dec_o.alu_opcode = XOR     // xori
      3'b101: dec_o.alu_opcode =  begin  // sr_i

        case( funct7 )

          7'd0:  dec_o.alu_opcode = SRL;
          7'd32: dec_o.alu_opcode = SRA;

          default: begin  // Illegal instruction - Wrong funct7

            dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(x);
            dec_o.alu_op1_sel     =  'bx;
            dec_o.alu_op2_sel     =  'bx;

            dec_o.rf_wb_we        = 1'b0;
            dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);

            dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
            dec_o.rf_rs1_v        = 1'b0;
            dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
            dec_o.rf_rs2_v        = 1'b0;

            dec_o.dm_we           = 1'b0;
            dec_o.dm_re           = 1'b0;
            dec_o.dm_word_pt      =  'bx;

            dec_o.is_branch_instr = 1'b0;
            dec_o.is_jal_instr    = 1'b0;
            dec_o.is_jalr_instr   = 1'b0;

            illegal_instr_o       = 1'b1;

          end
        endcase
        
      end 

      3'b110: dec_o.alu_opcode = OR     // ori
      3'b111: dec_o.alu_opcode = AND    // andi

      default:  // Illegal instruction - Wrong funct3

        dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(x);
        dec_o.alu_op1_sel     = 'x;
        dec_o.alu_op2_sel     = 'x;

        dec_o.rf_wb_we        = 1'b0;
        dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);

        dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
        dec_o.rf_rs1_v        = 1'b0;
        dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
        dec_o.rf_rs2_v        = 1'b0;

        dec_o.dm_we           = 1'b0;
        dec_o.dm_re           = 1'b0;
        dec_o.dm_word_pt      =  'bx;

        dec_o.is_branch_instr = 1'b0;
        dec_o.is_jal_instr    = 1'b0;
        dec_o.is_jalr_instr   = 1'b0;

        illegal_instr_o       = 1'b1;

      endcase

    5'b01100:  // R-type

      dec_o.alu_op1_sel     = RS1;
      dec_o.alu_op2_sel     = RS2;

      dec_o.rf_wb_we        = 1'b1;
      dec_o.rf_wb_addr      = rd;

      dec_o.rf_rs1_addr     = rs1;
      dec_o.rf_rs1_v        = 1'b1;
      dec_o.rf_rs2_addr     = rs2;
      dec_o.rf_rs2_v        = 1'b1;

      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

      case ( funct3 )

      3'b000: begin:  // add/sub
        case( funct7 )

          7'd0:  dec_o.alu_opcode = ADD;
          7'd48: dec_o.alu_opcode = SUB;

          default: begin  // Illegal instruction - Wrong funct3

            dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(x);
            dec_o.alu_op1_sel     =  'bx;
            dec_o.alu_op2_sel     =  'bx;

            dec_o.rf_wb_we        = 1'b0;
            dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);

            dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
            dec_o.rf_rs1_v        = 1'b0;
            dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
            dec_o.rf_rs2_v        = 1'b0;

            dec_o.dm_we           = 1'b0;
            dec_o.dm_re           = 1'b0;
            dec_o.dm_word_pt      =  'bx;

            dec_o.is_branch_instr = 1'b0;
            dec_o.is_jal_instr    = 1'b0;
            dec_o.is_jalr_instr   = 1'b0;

            illegal_instr_o       = 1'b1;

          end
        endcase
      end

      3'b001: dec_o.alu_opcode = SLL   // sll
      3'b010: dec_o.alu_opcode = SLTS  // slt
      3'b011: dec_o.alu_opcode = SLTU  // sltu
      3'b100: dec_o.alu_opcode = XOR   // xor
      3'b101: begin                    // sr

        case( funct7 )

          7'd0:  dec_o.alu_opcode = SRL;
          7'd32: dec_o.alu_opcode = SRA;

          default: begin  // Illegal instruction - Wrong funct7

            dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(x);
            dec_o.alu_op1_sel     =  'bx;
            dec_o.alu_op2_sel     =  'bx;

            dec_o.rf_wb_we        = 1'b0;
            dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);

            dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
            dec_o.rf_rs1_v        = 1'b0;
            dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
            dec_o.rf_rs2_v        = 1'b0;

            dec_o.dm_we           = 1'b0;
            dec_o.dm_re           = 1'b0;
            dec_o.dm_word_pt      =  'bx;

            dec_o.is_branch_instr = 1'b0;
            dec_o.is_jal_instr    = 1'b0;
            dec_o.is_jalr_instr   = 1'b0;

            illegal_instr_o       = 1'b1;

          end
        endcase
      end
      
      3'b110: dec_o.alu_opcode = OR    // or
      3'b111: dec_o.alu_opcode = AND   // and

      default:  // Illegal instruction - Wrong funct3

        dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(x);
        dec_o.alu_op1_sel     =  'bx;
        dec_o.alu_op2_sel     =  'bx;

        dec_o.rf_wb_we        = 1'b0;
        dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);

        dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
        dec_o.rf_rs1_v        = 1'b0;
        dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
        dec_o.rf_rs2_v        = 1'b0;

        dec_o.dm_we           = 1'b0;
        dec_o.dm_re           = 1'b0;
        dec_o.dm_word_pt      =  'bx;

        dec_o.is_branch_instr = 1'b0;
        dec_o.is_jal_instr    = 1'b0;
        dec_o.is_jalr_instr   = 1'b0;

        illegal_instr_o       = 1'b1;

      endcase

    5'b00011:  // fence

      dec_o.alu_op1_sel     = RS1;
      dec_o.alu_op2_sel     = CONST0;

      dec_o.rf_wb_we        = 1'b1;
      dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(0);

      dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(0);
      dec_o.rf_rs1_v        = 1'b1;
      dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
      dec_o.rf_rs2_v        = 1'b0;

      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

    5'b11100:  // ecall

      dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(0);
      dec_o.alu_op1_sel     =  'bx;
      dec_o.alu_op2_sel     =  'bx;
        
      dec_o.rf_wb_we        = 1'b0;
      dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);
          
      dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
      dec_o.rf_rs1_v        = 1'b0;
      dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
      dec_o.rf_rs2_v        = 1'b0;
        
      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

      illegal_instr_o       = 1'b1;

    5'b00000:  // Load 

      dec_o.alu_opcode      = ADD;
      dec_o.alu_op1_sel     = RS1;
      dec_o.alu_op2_sel     = I_IMM;
        
      dec_o.rf_wb_we        = 1'b1;
      dec_o.rf_wb_addr      = rd;
          
      dec_o.rf_rs1_addr     = rs1;
      dec_o.rf_rs1_v        = 1'b1;
      dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
      dec_o.rf_rs2_v        = 1'b0;
        
      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b1;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

      case( funct3 )

      3'b000: dec_o.dm_word_pt = BYTE;
      3'b001: dec_o.dm_word_pt = HALF;
      3'b010: dec_o.dm_word_pt = WORD;
      3'b100: dec_o.dm_word_pt = BYTE_U;
      3'b101: dec_o.dm_word_pt = HALF_U;

      default: begin // Illegal instruction - Wrong funct3

        dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(0);
        dec_o.alu_op1_sel     =  'bx;
        dec_o.alu_op2_sel     =  'bx;

        dec_o.rf_wb_we        = 1'b0;
        dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(0);

        dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(0);
        dec_o.rf_rs1_v        = 1'b0;
        dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(0);
        dec_o.rf_rs2_v        = 1'b0;

        dec_o.dm_we           = 1'b0;
        dec_o.dm_re           = 1'b0;
        dec_o.dm_word_pt      =  'bx;

        dec_o.is_branch_instr = 1'b0;
        dec_o.is_jal_instr    = 1'b0;
        dec_o.is_jalr_instr   = 1'b0;

        illegal_instr_o       = 1'b1;

      end
      endcase

    5'b01000:  // S-type

      dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(0);
      dec_o.alu_op1_sel     = RS1;
      dec_o.alu_op2_sel     = S_IMM;
        
      dec_o.rf_wb_we        = 1'b0;
      dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(0);
          
      dec_o.rf_rs1_addr     = rs1;
      dec_o.rf_rs1_v        = 1'b1;
      dec_o.rf_rs2_addr     = rs2;
      dec_o.rf_rs2_v        = 1'b1;
        
      dec_o.dm_we           = 1'b1;
      dec_o.dm_re           = 1'b0;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

      case( funct3 )

      3'b000: dec_o.dm_word_pt = BYTE;
      3'b001: dec_o.dm_word_pt = HALF;
      3'b010: dec_o.dm_word_pt = WORD;

      default: begin // Illegal instruction - Wrong funct3

        dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(0);
        dec_o.alu_op1_sel     =  'bx;
        dec_o.alu_op2_sel     =  'bx;

        dec_o.rf_wb_we        = 1'b0;
        dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(0);

        dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(0);
        dec_o.rf_rs1_v        = 1'b0;
        dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(0);
        dec_o.rf_rs2_v        = 1'b0;

        dec_o.dm_we           = 1'b0;
        dec_o.dm_re           = 1'b0;
        dec_o.dm_word_pt      =  'bx;

        dec_o.is_branch_instr = 1'b0;
        dec_o.is_jal_instr    = 1'b0;
        dec_o.is_jalr_instr   = 1'b0;

        illegal_instr_o       = 1'b1;

      end
      endcase

    5'b11011:  // J-type

      dec_o.alu_opcode      = ADD;
      dec_o.alu_op1_sel     = CONST4;
      dec_o.alu_op2_sel     = PC;

      dec_o.rf_wb_we        = 1'b1;
      dec_o.rf_wb_addr      = rd;

      dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
      dec_o.rf_rs1_v        = 1'b0;
      dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
      dec_o.rf_rs2_v        = 1'b0;

      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b1;
      dec_o.is_jalr_instr   = 1'b0;

    5'b11001:  // jalr

      dec_o.alu_opcode      = ADD;
      dec_o.alu_op1_sel     = CONST4;
      dec_o.alu_op2_sel     = PC;

      dec_o.rf_wb_we        = 1'b1;
      dec_o.rf_wb_addr      = rd;

      dec_o.rf_rs1_addr     = rs1;
      dec_o.rf_rs1_v        = 1'b1;
      dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
      dec_o.rf_rs2_v        = 1'b0;

      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b1;

    5'b11000:  // B-type

      dec_o.alu_op1_sel     = RS1;
      dec_o.alu_op2_sel     = RS2;

      dec_o.rf_wb_we        = 1'b0;
      dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);

      dec_o.rf_rs1_addr     = rs1;
      dec_o.rf_rs1_v        = 1'b1;
      dec_o.rf_rs2_addr     = rs2;
      dec_o.rf_rs2_v        = 1'b1;

      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b1;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

      case ( funct3 )

      3'b000: dec_o.alu_opcode = EQ;
      3'b001: dec_o.alu_opcode = NEQ;
      3'b100: dec_o.alu_opcode = LTS;
      3'b101: dec_o.alu_opcode = GES;
      3'b110: dec_o.alu_opcode = LTU;
      3'b111: dec_o.alu_opcode = GEU;

      default: begin // Illegal instruction - Wrong funct3

        dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(x);
        dec_o.alu_op1_sel     =  'bx;
        dec_o.alu_op2_sel     =  'bx;

        dec_o.rf_wb_we        = 1'b0;
        dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);

        dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
        dec_o.rf_rs1_v        = 1'b0;
        dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
        dec_o.rf_rs2_v        = 1'b0;

        dec_o.dm_we           = 1'b0;
        dec_o.dm_re           = 1'b0;
        dec_o.dm_word_pt      =  'bx;

        dec_o.is_branch_instr = 1'b0;
        dec_o.is_jal_instr    = 1'b0;
        dec_o.is_jalr_instr   = 1'b0;

        illegal_instr_o       = 1'b1;

      end
      endcase

    default: begin // Illegal instruction - Wrong opcode

      dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(x);
      dec_o.alu_op1_sel     =  'bx;
      dec_o.alu_op2_sel     =  'bx;
        
      dec_o.rf_wb_we        = 1'b0;
      dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);
          
      dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
      dec_o.rf_rs1_v        = 1'b0;
      dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
      dec_o.rf_rs2_v        = 1'b0;
        
      dec_o.dm_we           = 1'b0;
      dec_o.dm_re           = 1'b0;
      dec_o.dm_word_pt      =  'bx;

      dec_o.is_branch_instr = 1'b0;
      dec_o.is_jal_instr    = 1'b0;
      dec_o.is_jalr_instr   = 1'b0;

      illegal_instr_o       = 1'b1;
      
    end 
    endcase
  end else begin  // Illegal instruction - No 11 at lsb

    dec_o.alu_opcode      = ALU_OPCODE_WIDTH'(x);
    dec_o.alu_op1_sel     =  'bx;
    dec_o.alu_op2_sel     =  'bx;

    dec_o.rf_wb_we        = 1'b0;
    dec_o.rf_wb_addr      = RF_ADDR_WIDTH'(x);

    dec_o.rf_rs1_addr     = RF_ADDR_WIDTH'(x);
    dec_o.rf_rs1_v        = 1'b0;
    dec_o.rf_rs2_addr     = RF_ADDR_WIDTH'(x);
    dec_o.rf_rs2_v        = 1'b0;

    dec_o.dm_we           = 1'b0;
    dec_o.dm_re           = 1'b0;
    dec_o.dm_word_pt      =  'bx;

    dec_o.is_branch_instr = 1'b0;
    dec_o.is_jal_instr    = 1'b0;
    dec_o.is_jalr_instr   = 1'b0;

    illegal_instr_o       = 1'b1;

  end
end : decode_block

endmodule