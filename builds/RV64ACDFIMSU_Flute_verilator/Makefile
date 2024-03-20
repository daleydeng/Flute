###  -*-Makefile-*-

# *** DO NOT EDIT! ***
# *** This file is program-generated, not hand-written. ***
# ================================================================

REPO ?= ../..
ARCH ?= RV64ACDFIMSU
PRIVS  ?= MSU

# ================================================================
# RISC-V config macros passed into Bluespec 'bsc' compiler

BSC_COMPILATION_FLAGS += \
	-cpp -Xcpp -Wno-endif-labels $(shell $(REPO)/scripts/gen_defs.py \
		--arch=RV64 \
		--ext  ACDFIMSU \
		--satp SV39 \
                -D INCLUDE_FDIV \
		-D INCLUDE_FSQRT \
		-D SHIFT_BARREL    \
		-D MULT_SYNTH    \
		-D NEAR_MEM_CACHES    \
		-D FABRIC64    \
		-D WATCH_TOHOST    \
		-D INCLUDE_TANDEM_VERIF \
	)

# Default ISA test

# TEST ?= rv64ui-p-add
TEST ?= rv64uc-p-rvc
#================================================================
# Common boilerplate rules

include $(REPO)/builds/Resources/Include_Common.mk

#================================================================
# Makefile rules for building for specific simulator: verilator

include $(REPO)/builds/Resources/Include_verilator.mk

