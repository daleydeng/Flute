###  -*-Makefile-*-

# *** DO NOT EDIT! ***
# *** This file is program-generated, not hand-written. ***
# ================================================================

REPO   ?= ../..
ARCH   ?= RV64ACDFIMSU
PRIVS  ?= MSU
CACHES ?= WT_L1

# Alternative cache organizations:
# Default (no definition for CACHES)    L1 only, write-through policy
# Define  CACHES=WB_L1                  L1 only, with write-back policy

# ================================================================
# RISC-V config macros passed into Bluespec 'bsc' compiler

# $(shell $(REPO)/scripts/gen_defs.py --arch=RV64 --float=D)
BSC_COMPILATION_FLAGS += \
        $(shell $(REPO)/scripts/gen_defs.py --arch=RV64 --float=D) \
	-D RV64 \
	-D ISA_I  -D ISA_M  -D ISA_A  -D ISA_C \
	-D ISA_F  -D ISA_D  -D INCLUDE_FDIV  -D INCLUDE_FSQRT \
	-D ISA_PRIV_M  -D ISA_PRIV_S  -D ISA_PRIV_U  \
	-D SV39  \
	-D SHIFT_BARREL    \
	-D MULT_SYNTH    \
	-D NEAR_MEM_CACHES    \
	-D FABRIC64    \
	-D WATCH_TOHOST    \
	-D INCLUDE_TANDEM_VERIF    \


# Default ISA test

# TEST ?= rv64ui-p-add
# TEST ?= rv64uc-p-rvc
TEST ?= rv64uc-v-rvc

#================================================================
# Common boilerplate rules

include $(REPO)/builds/Resources/Include_Common.mk

#================================================================
# Makefile rules for building for specific simulator

include $(REPO)/builds/Resources/Include_bluesim.mk
