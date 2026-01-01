//=====================================================
// RISC-V Educational Core - PC Unit (v0)
//=====================================================

module pc_unit (
  input  logic                    clk,
  input  logic                    rst_n,

  // Control
  input  riscv_defs::pc_sel_t      pc_sel,
  input  logic                    branch_taken,
  input  logic [31:0]             imm,

  // Outputs
  output logic [31:0]             pc,
  output logic [31:0]             pc_plus4
);

  import riscv_defs::*;

  logic [31:0] next_pc;

  // --------------------------------------------------
  // PC + 4
  // --------------------------------------------------
  assign pc_plus4 = pc + 32'd4;

  // --------------------------------------------------
  // Next PC selection (combinational)
  // --------------------------------------------------
  always_comb begin
    case (pc_sel)
      PC_PLUS_4: begin
        next_pc = pc_plus4;
      end

      PC_BRANCH: begin
        if (branch_taken)
          next_pc = pc + imm;
        else
          next_pc = pc_plus4;
      end

      PC_JUMP: begin
        next_pc = pc + imm;
      end

      default: begin
        next_pc = pc_plus4;
      end
    endcase
  end

  // --------------------------------------------------
  // PC register
  // --------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      pc <= 32'b0;
    else
      pc <= next_pc;
  end

endmodule
