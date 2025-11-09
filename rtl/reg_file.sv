module reg_file
import banana_core_pkg::*;
(
  input  logic                       clk_i,

  input  logic [RF_ADDR_WIDTH - 1:0] rs1_addr_i,
  output logic [   DATA_WIDTH - 1:0] rs1_data_o,

  input  logic [RF_ADDR_WIDTH - 1:0] rs2_addr_i,
  output logic [   DATA_WIDTH - 1:0] rs2_data_o,

  input  logic                       rd_we_i,
  input  logic [RF_ADDR_WIDTH - 1:0] rd_addr_i,
  input  logic [   DATA_WIDTH - 1:0] rd_data_i
);


logic [DATA_WIDTH - 1:0] reg_array [0:RF_REGS_COUNT - 1];

always_ff @( posedge clk_i ) begin
  if ( rd_we_i ) begin
    reg_array[rd_addr_i] <= rd_data_i;
  end
end

assign rs1_data_o = rs1_addr_i == 'b0 ? DATA_WIDTH'b0 : reg_array[rs1_addr_i];
assign rs2_data_o = rs2_addr_i == 'b0 ? DATA_WIDTH'b0 : reg_array[rs2_addr_i];

endmodule
