#proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib} }

set CUSTOM_DO_FILE  "wave.do"
set run_do_file [file isfile $CUSTOM_DO_FILE]
set LIB_DIR         ./libs
set WORK_DIR        work
set TOP tb

vlib         $LIB_DIR
vlib         [subst $LIB_DIR/$WORK_DIR/]
vmap work    [subst $LIB_DIR/$WORK_DIR/]

vlog -work work "./Mem.sv"
vlog -work work "./Block.sv"
vlog -work work "./MatMat.sv"
vlog -work work "./MatMult.sv"
vlog -work work "./SimWrapper.sv"
vlog -work work "./tb.sv"


if {$run_do_file == 1} {
	vsim -novopt -t ps -L work $TOP -do $CUSTOM_DO_FILE 
} else {
	vsim -novopt -t ps -L work $TOP 
}

log /* -r

run -all

