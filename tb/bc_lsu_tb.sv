import banana_core_pkg::*;

module bc_lsu_tb #( parameter SEED=123,
                    parameter TEST=BYTE // Enable patterns: WORD, HALF, BYTE
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

  ///////////////
  // WORD Test //
  ///////////////

  task write_word();
    $display("Word Write Task was start at time: %D", $time);
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
    $display("Word Read Task was started at time: %D", $time);
    read_task  = 1;
    lsu_req_i  = 1'b1;
    lsu_size_i = WORD;
    lsu_we_i   = 1'b0;

    wait( mem_valid_i == 1'b1 );
    #25
    lsu_req_i  = 1'b0;
  endtask

  task comparator_word();
    wait( lsu_req_i == 1'b0 );
    if( ( lsu_data_o == mem_rdata_i ) && ( read_task ) )
      passed_test = passed_test + 1;
    else begin
      failed_test = failed_test + 1;
      $error("Wrong read data from addr=0x%0h at time: %D", lsu_addr_i, $time);
    end
  endtask

  ////////////////////
  // HALF Word Test //
  ////////////////////

  task write_half();
    $display("Half Word Write Task was start at time: %D", $time);
    read_task          = 0;
    lsu_req_i          = 1'b1;
    lsu_size_i         = HALF;
    lsu_data_i         = $urandom();
    lsu_addr_tb        = $urandom();
    mem_be_o           = ( iter % 2 == 0 ) ? ( 4'b0011 ) : ( 4'b1100 );
    lsu_addr_i         = { 9'd0, lsu_addr_tb };

    wait( mem_ready == 1'b1 );

    mem_addr_fr        = mem_addr_o[DM_ADDR_WIDTH - 1: 2];

    lsu_we_i           = 1'b1;
    #25
    lsu_we_i           = 1'b0;
    lsu_req_i          = 1'b0;
  endtask

  task read_half();
    $display("Half Read Task was started at time: %D", $time);
    read_task  = 1;
    lsu_req_i  = 1'b1;
    lsu_size_i = HALF;
    lsu_we_i   = 1'b0;

    wait( mem_valid_i == 1'b1 );
    #25
    lsu_req_i  = 1'b0;
  endtask

  task comparator_half();
    wait( lsu_req_i == 1'b0 );
    if( ( lsu_data_o == { { 16{ mem_rdata_i[31] } }, mem_rdata_i[31:16] } ) && ( read_task ) && ( mem_be_o == 4'b1100 ) )
      passed_test = passed_test + 1;
    else if( ( lsu_data_o == { { 16{ mem_rdata_i[15] } }, mem_rdata_i[15:0]  } ) && ( read_task ) && ( mem_be_o == 4'b0011 ) )
      passed_test = passed_test + 1;
    else begin
      failed_test = failed_test + 1;
      $error("Wrong read data from addr=0x%0h at time: %D", lsu_addr_i, $time);
    end
  endtask

  ///////////////
  // Byte Test //
  ///////////////

  task write_byte();
    $display("Byte Word Write Task was start at time: %D", $time);
    read_task          = 0;
    lsu_req_i          = 1'b1;
    lsu_size_i         = BYTE;
    lsu_data_i         = $urandom();
    lsu_addr_tb        = $urandom();
    case( iter % 4 )
      0: mem_be_o = 4'b0001;
      1: mem_be_o = 4'b0010;
      2: mem_be_o = 4'b0100;
      3: mem_be_o = 4'b1000;
    endcase
    lsu_addr_i         = { 9'd0, lsu_addr_tb };

    wait( mem_ready == 1'b1 );

    mem_addr_fr        = mem_addr_o[DM_ADDR_WIDTH - 1: 2];

    lsu_we_i           = 1'b1;
    #25
    lsu_we_i           = 1'b0;
    lsu_req_i          = 1'b0;
  endtask

  task read_byte();
    $display("Byte Read Task was started at time: %D", $time);
    read_task  = 1;
    lsu_req_i  = 1'b1;
    lsu_size_i = BYTE;
    lsu_we_i   = 1'b0;

    wait( mem_valid_i == 1'b1 );
    #25
    lsu_req_i  = 1'b0;
  endtask

  task comparator_byte();
    wait( lsu_req_i == 1'b0 );
    if( ( lsu_data_o == { { 24{ mem_rdata_i[31] } }, mem_rdata_i[31:24] } ) && ( read_task ) && ( mem_be_o == 4'b1000 ) )
      passed_test = passed_test + 1;
    else if( ( lsu_data_o == { { 24{ mem_rdata_i[23] } }, mem_rdata_i[23:16] } ) && ( read_task ) && ( mem_be_o == 4'b0100 ) )
      passed_test = passed_test + 1;
    else if( ( lsu_data_o == { { 24{ mem_rdata_i[15] } }, mem_rdata_i[15:8]  } ) && ( read_task ) && ( mem_be_o == 4'b0010 ) )
      passed_test = passed_test + 1;
    else if( ( lsu_data_o == { { 24{ mem_rdata_i[7] }  }, mem_rdata_i[7:0]   } ) && ( read_task ) && ( mem_be_o == 4'b0001 ) )
      passed_test = passed_test + 1;
    else begin
      failed_test = failed_test + 1;
      $error("Wrong read data from addr=0x%0h at time: %D", lsu_addr_i, $time);
    end
  endtask

  ///////////////
  // Main Test //
  ///////////////

  initial begin
    fork
      begin: test
        forever begin
          reset();
          if( TEST == WORD ) begin
            write_word();
            #50
            fork
              read_word();
              comparator_word();
            join
          end
          else if( TEST == HALF ) begin
            write_half();
            #50
            fork
              read_half();
              comparator_half();
            join
          end
          else if( TEST == BYTE ) begin
            write_byte();
            #50
            fork
              read_byte();
              comparator_byte();
            join
          end
          #30
          iter = iter + 1;
          $display("Iteration %D was ended at time: %D", iter, $time);
        end
      end
      begin: timeout
        #100000
        $display("[%0t] Timeout reached!", $time);
      end
    join_any
    disable test;
    if( failed_test == 0 ) begin
      $display("===========================");
      $display("= Test ended with success =");
      $display("===========================");
    end
    else begin
      $display("===============");
      $display("= Test failed =");
      $display("===============");
    end
    $finish;
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