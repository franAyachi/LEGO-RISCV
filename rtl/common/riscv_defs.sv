//=====================================================
// RISC-V Educational Core - ISA Definitions (v0)
//=====================================================

package riscv_defs;

  // --------------------------------------------------
  // Global parameters
  // --------------------------------------------------
  parameter int XLEN      = 32;
  parameter int REG_COUNT = 8;
  parameter int REG_ADDRW = 3;   // log2(REG_COUNT)

  // --------------------------------------------------
  // Opcodes (RV32 base, subset)
// --------------------------------------------------
  localparam logic [6:0] OPCODE_OP     = 7'b0110011; // R-type
  localparam logic [6:0] OPCODE_OP_IMM = 7'b0010011; // I-type (addi)
  localparam logic [6:0] OPCODE_LOAD   = 7'b0000011; // lw
  localparam logic [6:0] OPCODE_STORE  = 7'b0100011; // sw
  localparam logic [6:0] OPCODE_BRANCH = 7'b1100011; // beq
  localparam logic [6:0] OPCODE_JAL    = 7'b1101111; // jal

  // --------------------------------------------------
  // funct3 values
  // --------------------------------------------------
  localparam logic [2:0] FUNCT3_ADD_SUB = 3'b000;
  localparam logic [2:0] FUNCT3_ADDI    = 3'b000;
  localparam logic [2:0] FUNCT3_LW_SW   = 3'b010;
  localparam logic [2:0] FUNCT3_BEQ     = 3'b000;

  // --------------------------------------------------
  // funct7 values (R-type)
  // --------------------------------------------------
  localparam logic [6:0] FUNCT7_ADD = 7'b0000000;
  localparam logic [6:0] FUNCT7_SUB = 7'b0100000;

  // --------------------------------------------------
  // ALU operations (semantic)
  // --------------------------------------------------
  typedef enum logic [2:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_PASS
  } alu_op_t;

  // --------------------------------------------------
  // Writeback source
  // --------------------------------------------------
  typedef enum logic [1:0] {
    WB_NONE,
    WB_ALU,
    WB_MEM,
    WB_PC4
  } wb_sel_t;

  // --------------------------------------------------
  // PC selection
  // --------------------------------------------------
  typedef enum logic [1:0] {
    PC_PLUS_4,
    PC_BRANCH,
    PC_JUMP
  } pc_sel_t;

  // --------------------------------------------------
  // Instruction type (optional, for debug/coverage)
  // --------------------------------------------------
  typedef enum logic [2:0] {
    INSTR_R,
    INSTR_I,
    INSTR_S,
    INSTR_B,
    INSTR_J
  } instr_type_t;

endpackage