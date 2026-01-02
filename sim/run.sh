#!/bin/bash

mkdir -p waves

iverilog \
  -g2012 \
  -o sim.out \
  rtl/*.sv \
  tb/tb_core.sv

vvp sim.out

gtkwave waves/core.vcd
