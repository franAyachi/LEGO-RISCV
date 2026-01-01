//=====================================================
// RISC-V Educational Core - Instruction Decoder (v0)
//=====================================================

module decoder (
  input  logic [31:0] instr,

  // Decoded register indices
  output logic [2:0]  rs1_idx,
  output logic [2:0]  rs2_idx,
  output logic [2:0]  rd_idx,

  // Immediate
  output logic [31:0] imm,

  // Semantic control signals
  output logic        valid,
  output logic        uses_rs1,
  output logic        uses_rs2,
  output logic        writes_rd,

  output riscv_defs::alu_op_t   alu_op,
  output riscv_defs::wb_sel_t   wb_sel,
  output riscv_defs::pc_sel_t   pc_sel,
  output riscv_defs::instr_type_t instr_type,

  output logic        is_load,
  output logic        is_store,
  output logic        is_branch,
  output logic        is_jump
);

  import riscv_defs::*;

  // --------------------------------------------------
  // Instruction fields
  // --------------------------------------------------
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;

  assign opcode = instr[6:0];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];

  // Register fields (truncate to 3 bits)
  assign rs1_idx = instr[19:15][REG_ADDRW-1:0];
  assign rs2_idx = instr[24:20][REG_ADDRW-1:0];
  assign rd_idx  = instr[11:7][REG_ADDRW-1:0];

  // --------------------------------------------------
  // Default values (safe NOP-like behavior)
  // --------------------------------------------------
  always_comb begin
    valid       = 1'b0;

    uses_rs1    = 1'b0;
    uses_rs2    = 1'b0;
    writes_rd   = 1'b0;

    alu_op      = ALU_PASS;
    wb_sel      = WB_NONE;
    pc_sel      = PC_PLUS_4;
    instr_type  = INSTR_I;

    is_load     = 1'b0;
    is_store    = 1'b0;
    is_branch   = 1'b0;
    is_jump     = 1'b0;

    imm         = 32'b0;

    // ------------------------------------------------
    // Decode by opcode
    // ------------------------------------------------
    case (opcode)

      // -------------------------
      // R-Type: add, sub
      // -------------------------
      OPCODE_OP: begin
        valid      = 1'b1;
        instr_type = INSTR_R;

        uses_rs1  = 1'b1;
        uses_rs2  = 1'b1;
        writes_rd = 1'b1;

        wb_sel    = WB_ALU;

        case (funct7)
          FUNCT7_ADD: alu_op = ALU_ADD;
          FUNCT7_SUB: alu_op = ALU_SUB;
          default:    valid = 1'b0;
        endcase
      end

      // -------------------------
      // I-Type arithmetic: addi
      // -------------------------
      OPCODE_OP_IMM: begin
        if (funct3 == FUNCT3_ADDI) begin
          valid      = 1'b1;
          instr_type = INSTR_I;

          uses_rs1  = 1'b1;
          writes_rd = 1'b1;

          alu_op    = ALU_ADD;
          wb_sel    = WB_ALU;

          imm = {{20{instr[31]}}, instr[31:20]};
        end
      end

      // -------------------------
      // Load: lw
      // -------------------------
      OPCODE_LOAD: begin
        if (funct3 == FUNCT3_LW_SW) begin
          valid      = 1'b1;
          instr_type = INSTR_I;

          uses_rs1  = 1'b1;
          writes_rd = 1'b1;

          alu_op    = ALU_ADD;
          wb_sel    = WB_MEM;

          is_load   = 1'b1;

          imm = {{20{instr[31]}}, instr[31:20]};
        end
      end

      // -------------------------
      // Store: sw
      // -------------------------
      OPCODE_STORE: begin
        if (funct3 == FUNCT3_LW_SW) begin
          valid      = 1'b1;
          instr_type = INSTR_S;

          uses_rs1  = 1'b1;
          uses_rs2  = 1'b1;

          alu_op    = ALU_ADD;
          is_store  = 1'b1;

          imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        end
      end

      // -------------------------
      // Branch: beq
      // -------------------------
      OPCODE_BRANCH: begin
        if (funct3 == FUNCT3_BEQ) begin
          valid      = 1'b1;
          instr_type = INSTR_B;

          uses_rs1  = 1'b1;
          uses_rs2  = 1'b1;

          alu_op    = ALU_SUB;
          is_branch = 1'b1;
          pc_sel    = PC_BRANCH;

          imm = {{19{instr[31]}},
                 instr[31],
                 instr[7],
                 instr[30:25],
                 instr[11:8],
                 1'b0};
        end
      end

      // -------------------------
      // Jump: jal
      // -------------------------
      OPCODE_JAL: begin
        valid      = 1'b1;
        instr_type = INSTR_J;

        writes_rd = 1'b1;

        wb_sel    = WB_PC4;
        pc_sel    = PC_JUMP;
        is_jump   = 1'b1;

        imm = {{11{instr[31]}},
               instr[31],
               instr[19:12],
               instr[20],
               instr[30:21],
               1'b0};
      end

      default: begin
        valid = 1'b0;
      end

    endcase
  end

endmodule
