//=====================================================
// RISC-V Educational Core - Core Top (v0)
//=====================================================

module core_top (
  input  logic clk,
  input  logic rst_n
);

  import riscv_defs::*;

  // --------------------------------------------------
  // PC signals
  // --------------------------------------------------
  logic [31:0] pc;
  logic [31:0] pc_plus4;

  // --------------------------------------------------
  // Instruction memory (simple ROM)
  // --------------------------------------------------
  logic [31:0] instr_mem [0:255];
  logic [31:0] instr;

  assign instr = instr_mem[pc[9:2]]; // word-aligned

  // --------------------------------------------------
  // Decoder outputs
  // --------------------------------------------------
  logic        valid;
  logic        uses_rs1;
  logic        uses_rs2;
  logic        writes_rd;

  logic [2:0]  rs1_idx;
  logic [2:0]  rs2_idx;
  logic [2:0]  rd_idx;

  logic [31:0] imm;

  alu_op_t     alu_op;
  wb_sel_t     wb_sel;
  pc_sel_t     pc_sel;
  instr_type_t instr_type;

  logic        is_load;
  logic        is_store;
  logic        is_branch;
  logic        is_jump;

  // --------------------------------------------------
  // Regfile signals
  // --------------------------------------------------
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;

  // --------------------------------------------------
  // Execute signals
  // --------------------------------------------------
  logic [31:0] alu_result;
  logic        branch_taken;
  logic [31:0] mem_addr;

  // --------------------------------------------------
  // Memory unit signals
  // --------------------------------------------------
  logic [31:0] load_data;

  // --------------------------------------------------
  // Writeback data
  // --------------------------------------------------
  logic [31:0] wb_data;

  // ==================================================
  // Module instantiations
  // ==================================================

  // -------------------------
  // PC Unit
  // -------------------------
  pc_unit u_pc (
    .clk          (clk),
    .rst_n        (rst_n),
    .pc_sel       (pc_sel),
    .branch_taken (branch_taken),
    .imm          (imm),
    .pc           (pc),
    .pc_plus4     (pc_plus4)
  );

  // -------------------------
  // Decoder
  // -------------------------
  decoder u_decoder (
    .instr        (instr),

    .rs1_idx      (rs1_idx),
    .rs2_idx      (rs2_idx),
    .rd_idx       (rd_idx),

    .imm          (imm),

    .valid        (valid),
    .uses_rs1     (uses_rs1),
    .uses_rs2     (uses_rs2),
    .writes_rd    (writes_rd),

    .alu_op       (alu_op),
    .wb_sel       (wb_sel),
    .pc_sel       (pc_sel),
    .instr_type   (instr_type),

    .is_load      (is_load),
    .is_store     (is_store),
    .is_branch    (is_branch),
    .is_jump      (is_jump)
  );

  // -------------------------
  // Register File
  // -------------------------
  regfile u_regfile (
    .clk          (clk),
    .rst_n        (rst_n),

    .rs1_idx     (rs1_idx),
    .rs1_data    (rs1_data),

    .rs2_idx     (rs2_idx),
    .rs2_data    (rs2_data),

    .we          (writes_rd),
    .rd_idx      (rd_idx),
    .rd_data     (wb_data)
  );

  // -------------------------
  // Execute
  // -------------------------
  execute u_execute (
    .rs1_data    (rs1_data),
    .rs2_data    (rs2_data),
    .imm         (imm),

    .alu_op      (alu_op),
    .uses_rs2    (uses_rs2),
    .is_branch   (is_branch),
    .is_load     (is_load),
    .is_store    (is_store),

    .alu_result  (alu_result),
    .branch_taken(branch_taken),
    .mem_addr    (mem_addr)
  );

  // -------------------------
  // Data Memory
  // -------------------------
  memory_unit u_memory (
    .clk         (clk),

    .is_load     (is_load),
    .is_store    (is_store),

    .addr        (mem_addr),
    .store_data (rs2_data),
    .load_data  (load_data)
  );

  initial begin
    $readmemh("programs/program.hex", instr_mem);
  end

  // ==================================================
  // Writeback selection
  // ==================================================
  always_comb begin
    case (wb_sel)
      WB_ALU:  wb_data = alu_result;
      WB_MEM:  wb_data = load_data;
      WB_PC4:  wb_data = pc_plus4;
      default: wb_data = 32'b0;
    endcase
  end

  always_ff @(posedge clk) begin
  $display("PC=%08x instr=%08x rd=%0d wb=%08x",
           pc, instr, rd_idx, wb_data);
  end


endmodule
