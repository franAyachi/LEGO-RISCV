//=====================================================
// RISC-V Educational Core - Register File (v0)
//=====================================================

module regfile (
  input  logic                    clk,
  input  logic                    rst_n,

  // Read port 1
  input  logic [2:0]              rs1_idx,
  output logic [31:0]             rs1_data,

  // Read port 2
  input  logic [2:0]              rs2_idx,
  output logic [31:0]             rs2_data,

  // Write port
  input  logic                    we,
  input  logic [2:0]              rd_idx,
  input  logic [31:0]             rd_data
);

  import riscv_defs::*;

  // --------------------------------------------------
  // Register storage
  // --------------------------------------------------
  logic [XLEN-1:0] regs [REG_COUNT-1:0];

  // --------------------------------------------------
  // Read logic (combinational)
  // --------------------------------------------------
  always_comb begin
    // rs1
    if (rs1_idx == '0)
      rs1_data = '0;
    else
      rs1_data = regs[rs1_idx];

    // rs2
    if (rs2_idx == '0)
      rs2_data = '0;
    else
      rs2_data = regs[rs2_idx];
  end

  // --------------------------------------------------
  // Write logic (synchronous)
  // --------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      integer i;
      for (i = 0; i < REG_COUNT; i = i + 1)
        regs[i] <= '0;
    end else begin
      if (we && (rd_idx != '0)) begin
        regs[rd_idx] <= rd_data;
      end
    end
  end

endmodule
