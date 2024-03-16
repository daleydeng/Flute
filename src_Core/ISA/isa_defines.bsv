package isa_defines;

// classic bluespec haskell dont support macro, put them here to fix around
`ifdef RV32
typedef 32 XLEN;

`elsif RV64
typedef 64 XLEN;

`elsif RV128
typedef 128 XLEN
`endif

`ifdef ISA_F

`ifdef ISA_D
typedef 64 FLEN;
`else
typedef 32 FLEN;
`endif

`else
typedef 0 FLEN;
`endif

endpackage