# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= verilator
FST ?= -fst
TOPLEVEL_LANG ?= verilog

SRC_DIR = $(PWD)/../src

# Verilator needs timing because tb.v contains # delays
COMPILE_ARGS += --timing
COMPILE_ARGS += --Wno-TIMESCALEMOD
# ---------------------------------------------------------
# All RTL source files
# ---------------------------------------------------------
PROJECT_SOURCES = \
	project.v \
	adaptive_lfsr_prng.v \
	lfsr16.v \
	repetition_monitor.v \
	adaptive_controller.v \
	seed_generator.v

ifneq ($(GATES),yes)

# ---------------------------------------------------------
# RTL simulation
# ---------------------------------------------------------
SIM_BUILD = sim_build/rtl

VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# ---------------------------------------------------------
# Gate-level simulation
# ---------------------------------------------------------
SIM_BUILD = sim_build/gl

COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DUSE_POWER_PINS
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1

VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# This gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# ---------------------------------------------------------
# Allow sharing configuration between design and testbench
# ---------------------------------------------------------
COMPILE_ARGS += -I$(SRC_DIR)

# ---------------------------------------------------------
# Include testbench
# ---------------------------------------------------------
VERILOG_SOURCES += $(PWD)/tb.v

TOPLEVEL = tb

# ---------------------------------------------------------
# Cocotb test
# ---------------------------------------------------------
COCOTB_TEST_MODULES = test

# ---------------------------------------------------------
# Cocotb Makefile
# ---------------------------------------------------------
include $(shell cocotb-config --makefiles)/Makefile.sim
