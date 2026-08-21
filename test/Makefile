# Tiny Tapeout Cocotb test Makefile

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

SRC_DIR = $(PWD)/../src

PROJECT_SOURCES = \
    project.v \
    adaptive_lfsr_prng.v \
    lfsr16.v \
    repetition_monitor.v \
    adaptive_controller.v \
    seed_generator.v

VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

VERILOG_SOURCES += $(PWD)/tb.v

TOPLEVEL = tb

COCOTB_TEST_MODULES = test

COMPILE_ARGS += -I$(SRC_DIR)

include $(shell cocotb-config --makefiles)/Makefile.sim
