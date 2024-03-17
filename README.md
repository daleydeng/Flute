# Installation
- install haskell by [ghcup](https://github.com/haskell/ghcup-hs.git)
- install [bluespec compiler](https://github.com/B-Lang-org/bsc.git)
  - `cabal v1-install regex-compat` use v1-install instead
- install [verilator](https://github.com/verilator/verilator.git)
- install python

# Refactor Flute

A 5-stages pipeline risc-v processor implemented in bluespec verilog

# Refactor Roadmap
refactor roadmap
- src_Core/ISA/* cleanups
  - [ ] *.bsv -> *.bh, migrate to haskell
  - [ ] compressed extension convert_instr_c cleanups
  - [ ] tv_trace_data cleanups