//=====================================================
// RISC-V Educational Core - Execute / ALU (v0)
//=====================================================

module execute (
  // Operands
  input  logic [31:0]              rs1_data,
  input  logic [31:0]              rs2_data,
  input  logic [31:0]              imm,

  // Control
  input  riscv_defs::alu_op_t       alu_op,
  input  logic                     uses_rs2,
  input  logic                     is_branch,
  input  logic                     is_load,
  input  logic                     is_store,

  // Results
  output logic [31:0]              alu_result,
  output logic                     branch_taken,
  output logic [31:0]              mem_addr
);

  import riscv_defs::*;

  // --------------------------------------------------
  // ALU operand selection
  // --------------------------------------------------
  logic [31:0] alu_b;

  assign alu_b = uses_rs2 ? rs2_data : imm;

  // --------------------------------------------------
  // ALU
  // --------------------------------------------------
  always_comb begin
    case (alu_op)
      ALU_ADD:  alu_result = rs1_data + alu_b;
      ALU_SUB:  alu_result = rs1_data - alu_b;
      ALU_PASS: alu_result = alu_b;
      default:  alu_result = 32'b0;
    endcase
  end

  // --------------------------------------------------
  // Branch decision (beq only)
  // --------------------------------------------------
  always_comb begin
    if (is_branch)
      branch_taken = (rs1_data == rs2_data);
    else
      branch_taken = 1'b0;
  end

  // --------------------------------------------------
  // Memory address calculation
  // --------------------------------------------------
  always_comb begin
    if (is_load || is_store)
      mem_addr = rs1_data + imm;
    else
      mem_addr = 32'b0;
  end

endmodule
