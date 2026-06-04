vdel -lib work -all
vlib work

vlog -sv -work work rtl/mycoreai32_pkg.sv
vlog -sv -work work rtl/*.sv
vlog -sv -work work tb/*.sv

# WLF waveform output
vsim -wlf waves.wlf work.tb_MyCoreAI32

# Log everything + add key waves
log -r /*

add wave -divider "TOP"
add wave sim:/tb_MyCoreAI32/clk
add wave sim:/tb_MyCoreAI32/rst_n

add wave -divider "DUT PC/IF"
add wave sim:/tb_MyCoreAI32/dut/pc_q
add wave sim:/tb_MyCoreAI32/dut/if_id_instr
add wave sim:/tb_MyCoreAI32/dut/pc_redirect
add wave sim:/tb_MyCoreAI32/dut/pc_target
add wave sim:/tb_MyCoreAI32/dut/stall_lu
add wave sim:/tb_MyCoreAI32/dut/stall_m
add wave sim:/tb_MyCoreAI32/dut/stall

add wave -divider "WB"
add wave sim:/tb_MyCoreAI32/dut/wb_we
add wave sim:/tb_MyCoreAI32/dut/wb_rd
add wave sim:/tb_MyCoreAI32/dut/wb_wdata

add wave -divider "DMEM"
add wave sim:/tb_MyCoreAI32/dmem_we
add wave sim:/tb_MyCoreAI32/dmem_re
add wave sim:/tb_MyCoreAI32/dmem_addr
add wave sim:/tb_MyCoreAI32/dmem_wdata
add wave sim:/tb_MyCoreAI32/dmem_rdata

add wave -divider "RV32M M-Unit"
add wave sim:/tb_MyCoreAI32/dut/id_ex_is_muldiv
add wave sim:/tb_MyCoreAI32/dut/m_req_valid
add wave sim:/tb_MyCoreAI32/dut/m_ready
add wave sim:/tb_MyCoreAI32/dut/m_done
add wave sim:/tb_MyCoreAI32/dut/m_result

add wave -divider "AI Unit"
add wave sim:/tb_MyCoreAI32/dut/id_ex_do_vdot4
add wave sim:/tb_MyCoreAI32/dut/id_ex_do_vmax4
add wave sim:/tb_MyCoreAI32/dut/ex_op_a_raw
add wave sim:/tb_MyCoreAI32/dut/ex_op_b_raw
add wave sim:/tb_MyCoreAI32/dut/ex_ai_y

run -all