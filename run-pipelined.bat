@echo off
mkdir build\pipelined 2>nul

iverilog -o build\pipelined\tea_sim.vvp DV\pipelined\tea_core_tb.v RTL\pipelined\tea_core.v
vvp build\pipelined\tea_sim.vvp
gtkwave build\pipelined\tea_waves.vcd