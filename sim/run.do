if {![file isdirectory work]} {
    vlib work
}

vlog ../hdl/sat_counter.v
vlog ../hdl/gpredict.v
vlog ../hdl/gselect.v
vlog ../hdl/gshare.v
vlog ../hdl/tb_predictors.v

vsim work.tb_predictors

add wave -divider "Inputs"
add wave -radix bin    sim:/tb_predictors/clk
add wave -radix bin    sim:/tb_predictors/rst
add wave -radix bin    sim:/tb_predictors/update
add wave -radix hex    sim:/tb_predictors/pc
add wave -radix bin    sim:/tb_predictors/actual_taken

add wave -divider "Predictions"
add wave -radix bin    sim:/tb_predictors/pred_g
add wave -radix bin    sim:/tb_predictors/pred_gs
add wave -radix bin    sim:/tb_predictors/pred_gh

add wave -divider "GHRs"
add wave -radix bin    sim:/tb_predictors/u_g/ghr
add wave -radix bin    sim:/tb_predictors/u_gs/ghr
add wave -radix bin    sim:/tb_predictors/u_gh/ghr

add wave -divider "Miss counters"
add wave -radix unsigned sim:/tb_predictors/miss_g
add wave -radix unsigned sim:/tb_predictors/miss_gs
add wave -radix unsigned sim:/tb_predictors/miss_gh

run -all

wave zoom full
