`timescale 1ns/1ps

module tb_core;

  logic clk;
  logic rst_n;

  // -------------------------
  // Clock generation
  // -------------------------
  initial clk = 0;
  always #5 clk = ~clk; // 100 MHz

  // -------------------------
  // DUT
  // -------------------------
  core_top dut (
    .clk   (clk),
    .rst_n (rst_n)
  );

  // -------------------------
  // Reset
  // -------------------------
  initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
  end

  // -------------------------
  // Simulation control
  // -------------------------
  initial begin
    $dumpfile("waves/core.vcd");
    $dumpvars(0, tb_core);

    #500;
    $finish;
  end

endmodule
