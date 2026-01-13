import banana_core_pkg::*;

module bc_lsu_tb #( parameter SEED=123,
                    parameter TEST=WORD // Enable patterns: WORD, HALF, BYTE, HALF_U, BYTE_U
                  )
                  ();

  logic                        clk_i, rstn_i;
  logic                        lsu_req_i, lsu_we_i;
  logic [DM_ADDR_WIDTH - 1: 0] lsu_addr_i;
  logic [DM_WORD_WIDTH - 1: 0] lsu_data_i;
  logic [DM_WORD_WIDTH - 1: 0] lsu_data_o;
  dm_word_pt_t                 lsu_size_i;

  logic                        mem_valid_i;
  logic [DM_WORD_WIDTH - 1: 0] mem_rdata_i;

  logic                        mem_req_o, mem_we_o;
  logic [3:0]                  mem_be_o;
  logic [DM_ADDR_WIDTH - 1: 0] mem_addr_o;
  logic [DM_WORD_WIDTH - 1: 0] mem_wdata_o;

  logic [31:0]                 memory [0:63];
  logic                        mem_ready;
  logic [11:0]                 mem_addr_fr;

  logic [5:0]                  lsu_addr_tb;

  initial             clk_i = 1'b0;
  initial forever #10 clk_i = ~clk_i;

  initial             lsu_req_i   = 1'b0;
  initial             lsu_we_i    = 1'b0;
  initial             lsu_data_i  = 32'd0;

  initial             mem_addr_fr = 12'd0;

  integer passed_test = 0;
  integer failed_test = 0;
  integer read_task   = 0;
  integer iter        = 0;

  task reset();
    rstn_i = 1'b0;
    #50
    rstn_i = 1'b1;
  endtask

  task write_word();
    $display("Write Task was start at time: %D", $time);
    read_task          = 0;
    lsu_req_i          = 1'b1;
    lsu_size_i         = WORD;
    lsu_data_i         = $urandom();
    lsu_addr_tb        = $urandom();
    lsu_addr_i         = { 9'd0, lsu_addr_tb };

    wait( mem_ready == 1'b1 );

    mem_addr_fr        = mem_addr_o[DM_ADDR_WIDTH - 1: 2];

    lsu_we_i           = 1'b1;
    #25
    lsu_we_i           = 1'b0;
    lsu_req_i          = 1'b0;
  endtask

  task read_word();
    $display("Read Task was started at time: %D", $time);
    read_task  = 1;
    lsu_req_i  = 1'b1;
    lsu_size_i = WORD;
    lsu_we_i   = 1'b0;

    wait( mem_valid_i == 1'b1 );
    #25
    lsu_req_i  = 1'b0;
  endtask

  task comparator();
    wait( lsu_req_i == 1'b0 );
    if( ( lsu_data_o == mem_rdata_i ) && ( read_task ) ) begin
      passed_test = passed_test + 1;
    end
    else begin
      failed_test = failed_test + 1;
      $error("Wrong read data from addr=0x%0h at time: %D", lsu_addr_i, $time);
    end
  endtask

  initial forever begin
    reset();
    write_word();
    #50
    fork
      read_word();
      comparator();
    join
    #30
    iter = iter + 1;
    $display("Iteration %D was ended at time: %D", iter, $time);
  end

  always_ff @( posedge clk_i or negedge rstn_i ) begin
    if( !rstn_i )
      mem_ready <= 1'b0;
    else
      mem_ready <= $urandom_range(0,1);
  end

  always_ff @( posedge clk_i or negedge rstn_i ) begin
    if( !rstn_i )
      mem_valid_i <= 1'b0;
    else if( ( lsu_req_i ) && !( lsu_we_i ) && ( read_task ) )
      mem_valid_i <= $urandom_range(0,1);
  end

  always_ff @( posedge clk_i ) begin
    if( ( lsu_req_i ) && ( lsu_we_i ) )
      memory[mem_addr_fr] <= mem_wdata_o;
    else if( ( lsu_req_i ) && !( lsu_we_i ) )
      mem_rdata_i <= memory[mem_addr_fr];
  end

  bc_lsu DUT(
    .clk_i       ( clk_i       ),
    .rstn_i      ( rstn_i      ),

    .lsu_req_i   ( lsu_req_i   ),
    .lsu_data_i  ( lsu_data_i  ),
    .lsu_we_i    ( lsu_we_i    ),
    .lsu_addr_i  ( lsu_addr_i  ),
    .lsu_size_i  ( lsu_size_i  ),
    .lsu_data_o  ( lsu_data_o  ),

    .mem_valid_i ( mem_valid_i ),
    .mem_rdata_i ( mem_rdata_i ),
    .mem_wdata_o ( mem_wdata_o ),
    .mem_addr_o  ( mem_addr_o  )
  );

endmodule