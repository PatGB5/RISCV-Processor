VLOG_FILES = alu.v alu_control.v control_unit.v cpu.v cpu_tb.v \
             data_memory.v imm_gen.v instruction_memory.v \
             mux2x1.v register_file.v

TOP_MODULE = cpu_tb
WAVEFORM = cpu_dump.vcd

all: compile

compile:
	iverilog -o output $(VLOG_FILES)

run:
	vvp output
	gtkwave $(WAVEFORM) &

clean:
	rm -f output $(WAVEFORM)
