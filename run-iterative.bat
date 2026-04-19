@echo off
mkdir build\iterative 2>nul

iverilog -o build\iterative\tea_sim.vvp DV\iterative\tea_core_tb.v RTL\iterative\tea_core.v
vvp build\iterative\tea_sim.vvp
gtkwave build\iterative\tea_waves.vcd