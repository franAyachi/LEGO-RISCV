#!/bin/bash

mkdir -p waves

iverilog \
  -g2012 \
  -o sim.out \
  rtl/common/*.sv \
  rtl/core/*.sv \
  tb/tb_core.sv

vvp sim.out

gtkwave waves/core.vcd
