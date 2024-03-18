# Flute Refactor Project

A 5-stages pipeline risc-v processor implemented in bluespec verilog

Orignal code was quite large and complex, so refactor it.

## Documentation

check orignal [doc](intro.adoc) first

## Installation
- install [bluespec compiler](https://github.com/B-Lang-org/bsc.git) for compilation
  - install haskell by [ghcup](https://github.com/haskell/ghcup-hs.git) 
  - `cabal v1-install regex-compat` use v1-install instead
- install [verilator](https://github.com/verilator/verilator.git) for faster simulation
- install python for useful `scripts`

## Refactor Roadmap
refactor roadmap
- [ ] src_Core/ISA/
  - [ ] *.bsv -> *.bh, migrate to haskell
  - [ ] compressed extension convert_instr_c cleanups
  - [ ] tv_trace_data cleanups
  - [x] isa_defines.bsvi, isa_defines_bh.bsv
  - [x] [isa_types.bs](src_Core/ISA/isa_types.bs)
  - [x] [isa_base.bs](src_Core/ISA/isa_base.bs)
  - [x] [isa_cext.bs](src_Core/ISA/isa_cext.bs)
- [ ] src_Core/RegFiles
  - [x] {[GPR](src_Core/RegFiles/GPR_RegFile.bs),[FPR](src_Core/RegFiles/FPR_RegFile.bs)}_RegFile.{bsv->bs} 
- [ ] src_Core/tandem_verif/
  - [x] [tv_buffer](src_Core/tandem_verif/tv_buffer.bs).{bsv->bs} 