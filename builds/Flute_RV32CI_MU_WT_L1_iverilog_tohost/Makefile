###  -*-Makefile-*-

# *** This file is program-generated, not hand-written. ***
# *** Edit only if you need to tweak it! ***
# ================================================================

REPO   ?= ../..
ARCH   ?= RV32CI
PRIVS  ?= MU
CACHES ?= WT_L1

# ================================================================
# RISC-V config macros passed into Bluespec 'bsc' compiler

BSC_COMPILATION_FLAGS += \
	-D RV32 \
	-D ISA_I  -D ISA_C  \
	-D ISA_PRIV_M  -D ISA_PRIV_U  \
	-D SHIFT_BARREL    \
	-D MULT_SYNTH    \
	-D NEAR_MEM_CACHES    \
	-D FABRIC64    \
	-D WATCH_TOHOST    \

#================================================================
# Default ISA test

TEST ?= rv32ui-p-add

#================================================================
# Common boilerplate rules

include $(REPO)/builds/Resources/Include_Common.mk

#================================================================
# Makefile rules for building for specific simulator

include $(REPO)/builds/Resources/Include_iverilog.mk

