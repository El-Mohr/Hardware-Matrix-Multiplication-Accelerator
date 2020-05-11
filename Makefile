vmodule=MatMult.sv
cppfile=MatMult_tb.cpp
dirName=sim
verilated=VMatMult

modelsim:
	vsim -do modelsim.tcl

verilate: $(vmodule) $(cppfile)
	verilator -trace -CFLAGS "-DTRACE" -Wno-WIDTH -Wno-COMBDLY --Mdir $(dirName) --cc $(vmodule) --exe $(cppfile)
	cd $(dirName) && $(MAKE) -j -f $(verilated).mk $(verilated)
	$(dirName)/$(verilated)

yosys:




