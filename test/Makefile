# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
FST ?= -fst # Use more efficient FST format
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(CURDIR)/../src
PROJECT_SOURCES = atompu_alu.v atompu_bus.v atompu_control.v atompu_decoder.v atompu_program_counter.v atompu_registers.v atompu_s1_top.v tt_um_atompu_s1.v

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# Gate level simulation:
SIM_BUILD = sim_build/gl$(SDF_MODE)
COMPILE_ARGS    += -DGL_TEST
ifeq ($(SDF_MODE),yes)
COMPILE_ARGS += -gspecify -ginterconnect -DSDF_TEST -Tmax
else
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DUNIT_DELAY=\#1
endif
ifneq ($(LOCAL_MAPPED),yes)
COMPILE_ARGS    += -DUSE_POWER_PINS
endif
COMPILE_ARGS    += -DSIM
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
GATE_LEVEL_NETLIST ?= $(CURDIR)/gate_level_netlist.v
VERILOG_SOURCES += $(GATE_LEVEL_NETLIST)

endif

# Allow sharing configuration between design and testbench via `include`:
COMPILE_ARGS 		+= -I$(SRC_DIR)

# Include the testbench sources:
VERILOG_SOURCES += $(CURDIR)/tb.v
TOPLEVEL = tb

# List test modules to run, separated by commas and without the .py suffix:
COCOTB_TEST_MODULES ?= test

ifneq ($(IVL_ROOT),)
COMPILE_ARGS += -B$(IVL_ROOT)
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
