# Makefile for Pipelined CPU Simulation

# Target executable name
TARGET = output

# Source files list
SRC = cpu_pipeline.v \
      instruction_memory.v \
      reg_file.v \
      alu.v \
      data_memory.v \
      control_unit.v \
      hazard_detection_unit.v \
      forwarding_unit.v \
      tb_cpu_pipeline.v \
      alu_control.v \
      mux2x1.v \
      immediate_gen.v

# Icarus Verilog compiler and simulation command
IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

# Default target: compile the design
all: $(TARGET)

$(TARGET): $(SRC)
	$(IVERILOG) -o $(TARGET) $(SRC)

# Run the simulation
run: $(TARGET)
	$(VVP) $(TARGET)
	$(GTKWAVE) $(TARGET).vcd &

# Clean generated files
clean:
	rm -f $(TARGET) *.vcd

.PHONY: all run clean