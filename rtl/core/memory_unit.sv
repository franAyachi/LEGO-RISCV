//=====================================================
// RISC-V Educational Core - Data Memory Unit (v0)
//=====================================================

module memory_unit #(
  parameter int MEM_WORDS = 256   // number of 32-bit words
)(
  input  logic                    clk,

  // Control
  input  logic                    is_load,
  input  logic                    is_store,

  // Address and data
  input  logic [31:0]             addr,
  input  logic [31:0]             store_data,
  output logic [31:0]             load_data
);

  import riscv_defs::*;

  // --------------------------------------------------
  // Memory array (word-addressed internally)
  // --------------------------------------------------
  logic [31:0] mem [0:MEM_WORDS-1];

  // --------------------------------------------------
  // Address translation
  // --------------------------------------------------
  // Byte address -> word index
  logic [$clog2(MEM_WORDS)-1:0] word_addr;

  assign word_addr = addr[($clog2(MEM_WORDS)+1):2];

  // --------------------------------------------------
  // Load (combinational)
  // --------------------------------------------------
  always_comb begin
    if (is_load)
      load_data = mem[word_addr];
    else
      load_data = 32'b0;
  end

  // --------------------------------------------------
  // Store (synchronous)
  // --------------------------------------------------
  always_ff @(posedge clk) begin
    if (is_store) begin
      mem[word_addr] <= store_data;
    end
  end

endmodule
