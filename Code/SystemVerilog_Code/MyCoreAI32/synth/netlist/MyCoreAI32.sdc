###################################################################

# Created by write_sdc on Tue Feb  3 02:50:02 2026

###################################################################
set sdc_version 2.1

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA
create_clock [get_ports clk]  -period 10  -waveform {0 5}
set_clock_uncertainty 0.2  [get_clocks clk]
set_false_path   -from [get_ports rst_n]
