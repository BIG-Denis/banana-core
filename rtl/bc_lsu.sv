import banana_core_pkg::*;

module bc_lsu (
  input  logic                        clk_i,
  input  logic                        rstn_i,

  // Core pipeline signals
  input  logic                        lsu_req_i,
  input  logic                        lsu_we_i,
  input  logic [DM_ADDR_WIDTH - 1: 0] lsu_addr_i,
  input  logic [DM_WORD_WIDTH - 1: 0] lsu_data_i,
  input  dm_word_pt_t                 lsu_size_i,

  output logic [DM_WORD_WIDTH - 1: 0] lsu_data_o,

  // Data Memory Interface
  input  logic                        mem_valid_i,
  input  logic [DM_WORD_WIDTH - 1: 0] mem_rdata_i,

  output logic                        mem_req_o,
  output logic                        mem_we_o,
  output logic [3:0]                  mem_be_o,
  output logic [DM_ADDR_WIDTH - 1: 0] mem_addr_o,
  output logic [DM_WORD_WIDTH - 1: 0] mem_wdata_o,

  // Control and status signals
  output logic                        lsu_busy_o
);

  logic [DM_WORD_WIDTH - 1: 0] lsu_data_temp;
  logic [DM_WORD_WIDTH - 1: 0] lsu_data_ff;
  logic                        lsu_hs;

  assign mem_addr_o = { lsu_addr_i[DM_ADDR_WIDTH - 1: 2], 2'd0 };
  assign mem_req_o  = lsu_req_i;
  assign mem_we_o   = lsu_we_i;

  assign lsu_data_o = lsu_data_ff;
  assign lsu_busy_o = ( lsu_req_i ) && !( lsu_hs );

  assign lsu_hs     = ( mem_req_o ) && ( mem_valid_i );

  always_comb begin
    case( lsu_size_i )
      WORD:    mem_wdata_o = lsu_data_i;
      HALF:    mem_wdata_o = { { 2{ lsu_data_i[ ( DM_WORD_WIDTH / 2 ) - 1: 0] } } };
      BYTE:    mem_wdata_o = { { 4{ lsu_data_i[ ( DM_WORD_WIDTH / 4 ) - 1: 0] } } };
      default: mem_wdata_o = '0;
    endcase
  end

  always_comb begin
    case( lsu_size_i )
      WORD:    mem_be_o = 4'b1111;
      HALF:    mem_be_o = ( lsu_addr_i[1] ) ? ( 4'b1100 ) : ( 4'b0011 );
      BYTE:    mem_be_o = 4'b0001 << lsu_addr_i[1:0];
      default: mem_be_o = 4'b0000;
    endcase
  end

  always_comb begin
    case( lsu_size_i )
      WORD:        lsu_data_temp = mem_rdata_i;
      HALF:        lsu_data_temp = ( lsu_addr_i[1] ) ? ( { { 16{ mem_rdata_i[31] } }, mem_rdata_i[31:16] } ):
                                                       ( { { 16{ mem_rdata_i[15] } }, mem_rdata_i[15:0]  } );
      BYTE:
        begin
          case( lsu_addr_i[1:0] )
            2'b00: lsu_data_temp = { { 24{ mem_rdata_i[7]  } }, mem_rdata_i[7:0]   };
            2'b01: lsu_data_temp = { { 24{ mem_rdata_i[15] } }, mem_rdata_i[15:8]  };
            2'b10: lsu_data_temp = { { 24{ mem_rdata_i[23] } }, mem_rdata_i[23:16] };
            2'b11: lsu_data_temp = { { 24{ mem_rdata_i[31] } }, mem_rdata_i[31:24] };
          endcase
        end
      HALF_U:      lsu_data_temp = lsu_addr_i[1] ? ( { 16'd0, mem_rdata_i[31:16] } ):
                                                   ( { 16'd0, mem_rdata_i[15:0]  } );
      BYTE_U:
        begin
          case( lsu_addr_i[1:0] )
            2'b00: lsu_data_temp = { 24'd0, mem_rdata_i[7:0]   };
            2'b01: lsu_data_temp = { 24'd0, mem_rdata_i[15:8]  };
            2'b10: lsu_data_temp = { 24'd0, mem_rdata_i[23:16] };
            2'b11: lsu_data_temp = { 24'd0, mem_rdata_i[31:24] };
          endcase
        end
      default:     lsu_data_temp = 32'd0;
    endcase
  end

  // Datakeeper
  always_ff @( posedge clk_i or negedge rstn_i ) begin
    if( !rstn_i )
      lsu_data_ff <= 32'd0;
    else if( lsu_hs )
      lsu_data_ff <= lsu_data_temp;
  end

endmodule
