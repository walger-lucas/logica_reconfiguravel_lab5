transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vcom -93 -work work {flux_control.vho}

vcom -93 -work work {D:/Files/Proj5/flux_control_tb.vhd}

vsim -t 1ps +transport_int_delays +transport_path_delays -sdftyp /uut=flux_control_vhd.sdo -L cycloneii -L gate_work -L work -voptargs="+acc"  flux_control_tb

add wave *
view structure
view signals
run 2000000 ns
