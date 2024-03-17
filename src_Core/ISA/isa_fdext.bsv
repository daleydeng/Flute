package isa_fdext;
// ================================================================
//
// Contains RISC-V ISA defs for the 'FD' ("Single/Double Precision Floating Point") extension
//
// ================================================================

export isa_types:: *, isa_fdext:: *;

import isa_types:: *;

`ifdef ISA_F
// ================================================================
// Floating Point Instructions

// ----------------------------------------------------------------
// TODO: the following are FPU implementation choices; shouldn't be in isa
// Enumeration of floating point opcodes for decode within the FPU
typedef enum {FPAdd,
	      FPSub,
	      FPMul,
	      FPDiv,
	      FPSqrt,
	      FPMAdd,
	      FPMSub,
	      FPNMAdd,
	      FPNMSub
   } FpuOp
   deriving (Bits, Eq, FShow);

// ----------------------------------------------------------------
// Floating point Load-Store

Opcode   op_LOAD_FP  = 7'b_00_001_11;
Opcode   op_STORE_FP = 7'b_01_001_11;

Bit#(3) f3_FSW = 3'b010;
Bit#(3) f3_FLW = 3'b010;

Bit#(3) f3_FSD = 3'b011;
Bit#(3) f3_FLD = 3'b011;

// ----------------------------------------------------------------
// Fused FP Multiply Add/Sub instructions (FM/FNM)

Opcode   op_FMADD  = 7'b10_00_011;
Opcode   op_FMSUB  = 7'b10_00_111;
Opcode   op_FNMSUB = 7'b10_01_011;
Opcode   op_FNMADD = 7'b10_01_111;

Bit#(2) f2_S = 2'b00;
Bit#(2) f2_D = 2'b01;
Bit#(2) f2_Q = 2'b11;

// ----------------------------------------------------------------
// All other FP intructions

Opcode  op_FP = 7'b10_10_011;

// ----------------
// RV32F

Bit#(7) f7_FADD_S      = 7'h0 ;
Bit#(7) f7_FSUB_S      = 7'h4 ;
Bit#(7) f7_FMUL_S      = 7'h8 ;
Bit#(7) f7_FDIV_S      = 7'hC ;
Bit#(7) f7_FSQRT_S     = 7'h2C; Bit#(5) rs2_FSQRT_S   = 5'b00000;

Bit#(7) f7_FSGNJ_S     = 7'h10;                                    Bit#(3) f3_FSGNJ_S  = 3'b000;
Bit#(7) f7_FSGNJN_S    = 7'h10;                                    Bit#(3) f3_FSGNJN_S = 3'b001;
Bit#(7) f7_FSGNJX_S    = 7'h10;                                    Bit#(3) f3_FSGNJX_S = 3'b010;

Bit#(7) f7_FMIN_S      = 7'h14;                                    Bit#(3) f3_FMIN_S   = 3'b000;
Bit#(7) f7_FMAX_S      = 7'h14;                                    Bit#(3) f3_FMAX_S   = 3'b001;

Bit#(7) f7_FCVT_W_S    = 7'h60; Bit#(5) rs2_FCVT_W_S  = 5'b00000;
Bit#(7) f7_FCVT_WU_S   = 7'h60; Bit#(5) rs2_FCVT_WU_S = 5'b00001;
Bit#(7) f7_FMV_X_W     = 7'h70; Bit#(5) rs2_FMV_X_W   = 5'b00000; Bit#(3) f3_FMV_X_W  = 3'b000;

Bit#(7) f7_FCMP_S      = 7'h50;
Bit#(7) f7_FEQ_S       = 7'h50;                                    Bit#(3) f3_FEQ_S    = 3'b010;
Bit#(7) f7_FLT_S       = 7'h50;                                    Bit#(3) f3_FLT_S    = 3'b001;
Bit#(7) f7_FLE_S       = 7'h50;                                    Bit#(3) f3_FLE_S    = 3'b000;

Bit#(7) f7_FCLASS_S    = 7'h70; Bit#(5) rs2_FCLASS_S  = 5'b00000; Bit#(3) f3_FCLASS_S = 3'b001;
Bit#(7) f7_FCVT_S_W    = 7'h68; Bit#(5) rs2_FCVT_S_W  = 5'b00000;
Bit#(7) f7_FCVT_S_WU   = 7'h68; Bit#(5) rs2_FCVT_S_WU = 5'b00001;
Bit#(7) f7_FMV_W_X     = 7'h78; Bit#(5) rs2_FMV_W_X   = 5'b00000; Bit#(3) f3_FMV_W_X  = 3'b000;

// ----------------
// RV64F

Bit#(7) f7_FCVT_L_S    = 7'h60; Bit#(5) rs2_FCVT_L_S  = 5'b00010;
Bit#(7) f7_FCVT_LU_S   = 7'h60; Bit#(5) rs2_FCVT_LU_S = 5'b00011;
Bit#(7) f7_FCVT_S_L    = 7'h68; Bit#(5) rs2_FCVT_S_L  = 5'b00010;
Bit#(7) f7_FCVT_S_LU   = 7'h68; Bit#(5) rs2_FCVT_S_LU = 5'b00011;

// ----------------
// RV32D

Bit#(7) f7_FADD_D      = 7'h1 ;
Bit#(7) f7_FSUB_D      = 7'h5 ;
Bit#(7) f7_FMUL_D      = 7'h9 ;
Bit#(7) f7_FDIV_D      = 7'hD ;
Bit#(7) f7_FSQRT_D     = 7'h2D; Bit#(5) rs2_FSQRT_D  = 5'b00000;

Bit#(7) f7_FSGNJ_D     = 7'h11;                                    Bit#(3) f3_FSGNJ_D  = 3'b000;
Bit#(7) f7_FSGNJN_D    = 7'h11;                                    Bit#(3) f3_FSGNJN_D = 3'b001;
Bit#(7) f7_FSGNJX_D    = 7'h11;                                    Bit#(3) f3_FSGNJX_D = 3'b010;

Bit#(7) f7_FMIN_D      = 7'h15;                                    Bit#(3) f3_FMIN_D   = 3'b000;
Bit#(7) f7_FMAX_D      = 7'h15;                                    Bit#(3) f3_FMAX_D   = 3'b001;

Bit#(7) f7_FCVT_S_D    = 7'h20; Bit#(5) rs2_FCVT_S_D = 5'b00001;
Bit#(7) f7_FCVT_D_S    = 7'h21; Bit#(5) rs2_FCVT_D_S = 5'b00000;

Bit#(7) f7_FCMP_D      = 7'h51;
Bit#(7) f7_FEQ_D       = 7'h51;                                    Bit#(3) f3_FEQ_D    = 3'b010;
Bit#(7) f7_FLT_D       = 7'h51;                                    Bit#(3) f3_FLT_D    = 3'b001;
Bit#(7) f7_FLE_D       = 7'h51;                                    Bit#(3) f3_FLE_D    = 3'b000;

Bit#(7) f7_FCLASS_D    = 7'h71; Bit#(5) rs2_FCLASS_D  = 5'b00000; Bit#(3) f3_FCLASS_D = 3'b001;
Bit#(7) f7_FCVT_W_D    = 7'h61; Bit#(5) rs2_FCVT_W_D  = 5'b00000;
Bit#(7) f7_FCVT_WU_D   = 7'h61; Bit#(5) rs2_FCVT_WU_D = 5'b00001;
Bit#(7) f7_FCVT_D_W    = 7'h69; Bit#(5) rs2_FCVT_D_W  = 5'b00000;
Bit#(7) f7_FCVT_D_WU   = 7'h69; Bit#(5) rs2_FCVT_D_WU = 5'b00001;

// ----------------
// RV64D

Bit#(7) f7_FCVT_L_D    = 7'h61; Bit#(5) rs2_FCVT_L_D  = 5'b00010;
Bit#(7) f7_FCVT_LU_D   = 7'h61; Bit#(5) rs2_FCVT_LU_D = 5'b00011;
Bit#(7) f7_FMV_X_D     = 7'h71; Bit#(5) rs2_FMV_X_D   = 5'b00000; Bit#(3) f3_FMV_X_D = 3'b000;
Bit#(7) f7_FCVT_D_L    = 7'h69; Bit#(5) rs2_FCVT_D_L  = 5'b00010;
Bit#(7) f7_FCVT_D_LU   = 7'h69; Bit#(5) rs2_FCVT_D_LU = 5'b00011;
Bit#(7) f7_FMV_D_X     = 7'h79; Bit#(5) rs2_FMV_D_X   = 5'b00000; Bit#(3) f3_FMV_D_X = 3'b000;

// ----------------------------------------------------------------
// is_fop_rd_in_gpr: Checks if the request generates a result which
// should be written into the GPR
function Bool is_fop_rd_in_gpr (Bit#(7) funct7, RegIdx rs2);

`ifdef ISA_D
    let is_FCVT_W_D  =    (funct7 == f7_FCVT_W_D)
                       && (rs2 == 0);
    let is_FCVT_WU_D =    (funct7 == f7_FCVT_WU_D)
                       && (rs2 == 1);
`ifdef RV64
    let is_FCVT_L_D  =    (funct7 == f7_FCVT_L_D)
                       && (rs2 == 2);
    let is_FCVT_LU_D =    (funct7 == f7_FCVT_LU_D)
                       && (rs2 == 3);

`endif
   // FCLASS.D also maps to this -- both write to GPR
   let is_FMV_X_D    =    (funct7 == f7_FMV_X_D);
   // FEQ.D, FLE.D, FLT.D map to this
   let is_FCMP_D     =    (funct7 == f7_FCMP_D);
`endif

    let is_FCVT_W_S  =    (funct7 == f7_FCVT_W_S)
                       && (rs2 == 0);
    let is_FCVT_WU_S =    (funct7 == f7_FCVT_WU_S)
                       && (rs2 == 1);
`ifdef RV64
    let is_FCVT_L_S  =    (funct7 == f7_FCVT_L_S)
                       && (rs2 == 2);
    let is_FCVT_LU_S =    (funct7 == f7_FCVT_LU_S)
                       && (rs2 == 3);
`endif

   // FCLASS.S also maps to this -- both write to GPR
   let is_FMV_X_W    =    (funct7 == f7_FMV_X_W);

   // FEQ.S, FLE.S, FLT.S map to this
   let is_FCMP_S     =    (funct7 == f7_FCMP_S);

    return (
          False
`ifdef ISA_D
       || is_FCVT_W_D
       || is_FCVT_WU_D
`ifdef RV64
       || is_FCVT_L_D
       || is_FCVT_LU_D
`endif
       || is_FMV_X_D
       || is_FCMP_D
`endif
`ifdef RV64
       || is_FCVT_L_S
       || is_FCVT_LU_S
`endif
       || is_FCVT_W_S
       || is_FCVT_WU_S
       || is_FMV_X_W
       || is_FCMP_S
    );
endfunction

// Check if a rounding mode value in the FCSR.FRM is valid
function Bool is_fcsr_frm_valid (Bit#(3) frm);
   return (   (frm != 3'b101) 
           && (frm != 3'b110)
           && (frm != 3'b111)
          );
endfunction 

// Check if a rounding mode value in the instr is valid
function Bool is_inst_frm_valid (Bit#(3) frm);
   return (   (frm != 3'b101) 
           && (frm != 3'b110)
          );
endfunction

// fv_rounding_mode_check
// Returns the correct rounding mode considering the values in the
// FCSR and the instruction and checks legality
function Tuple2# (Bit#(3), Bool) fop_rmode_check (
   Bit#(3) inst_frm, Bit#(3) fcsr_frm);
   let rm = (inst_frm == 3'h7) ? fcsr_frm : inst_frm;
   let rm_is_legal  = (inst_frm == 3'h7) ? is_fcsr_frm_valid (fcsr_frm)
                                         : is_inst_frm_valid (inst_frm);
   return (tuple2 (rm, rm_is_legal));
endfunction

// TODO: Check misa.f and misa.d
function Bool is_fp_instr_legal (Bit#(7) funct7,
				    Bit#(3) rm,
				    RegIdx  rs2,
				    Opcode   opcode);
   // These compile-time constants (which will be optimized out) avoid ugly ifdefs later
   Bool rv64 = False;
`ifdef RV64
   rv64 = True;
`endif

   Bool isa_F = False;
   Bool isa_D = False;
`ifdef ISA_F
   isa_F = True;
`ifdef ISA_D
   isa_D = True;
`endif
`endif

   // ----------------
   // For FM.../FNM... check funct7 [1:0] (i.e., instr[26:25])
   Bool ok_instr_26_25 = (isa_D    // Both SP and DP are legal
			  ? ((funct7 [1:0] == f2_S) || (funct7 [1:0] == f2_D))
			  : (isa_F    // Only SP is legal
			     ? (funct7 [1:0] == f2_S)
			     : False));
   Bool is_legal_FM_FNM = (   ok_instr_26_25
			   && (   (opcode == op_FMADD )
			       || (opcode == op_FMSUB )
			       || (opcode == op_FNMADD)
			       || (opcode == op_FNMSUB)));
   // ----------------
   Bool is_legal_other_RV32F
   = (   isa_F
      && (opcode == op_FP)
      && (   (funct7== f7_FADD_S)
	  || (funct7== f7_FSUB_S)
	  || (funct7== f7_FMUL_S)
`ifdef INCLUDE_FDIV
	  || (funct7== f7_FDIV_S)
`endif
`ifdef INCLUDE_FSQRT
	  || ((funct7== f7_FSQRT_S)   && (rs2 == rs2_FSQRT_S))
`endif
	  || ((funct7== f7_FSGNJ_S)                              && (rm == f3_FSGNJ_S))
	  || ((funct7== f7_FSGNJN_S)                             && (rm == f3_FSGNJN_S))
	  || ((funct7== f7_FSGNJX_S)                             && (rm == f3_FSGNJX_S))
	  || ((funct7== f7_FMIN_S)                               && (rm == f3_FMIN_S))
	  || ((funct7== f7_FMAX_S)                               && (rm == f3_FMAX_S))
	  || ((funct7== f7_FCVT_W_S)  && (rs2 == rs2_FCVT_W_S))
	  || ((funct7== f7_FCVT_WU_S) && (rs2 == rs2_FCVT_WU_S))
	  || ((funct7== f7_FMV_X_W)   && (rs2 == rs2_FMV_X_W)    && (rm == f3_FMV_X_W))
	  || ((funct7== f7_FEQ_S)     &&                            (rm == f3_FEQ_S))
	  || ((funct7== f7_FLT_S)     &&                            (rm == f3_FLT_S))
	  || ((funct7== f7_FLE_S)     &&                            (rm == f3_FLE_S))
	  || ((funct7== f7_FCLASS_S)  && (rs2 == rs2_FCLASS_S)   && (rm == f3_FCLASS_S))
	  || ((funct7== f7_FCVT_S_W)  && (rs2 == rs2_FCVT_S_W))
	  || ((funct7== f7_FCVT_S_WU) && (rs2 == rs2_FCVT_S_WU))
	  || ((funct7== f7_FMV_W_X)   && (rs2 == rs2_FMV_W_X)    && (rm == f3_FMV_W_X))
	 ));

   // ----------------
   Bool is_legal_other_RV64F
   = (   isa_F
      && (opcode == op_FP)
      && rv64
      && (   ((funct7== f7_FCVT_L_S)  && (rs2 == rs2_FCVT_L_S))
	  || ((funct7== f7_FCVT_LU_S) && (rs2 == rs2_FCVT_LU_S))
	  || ((funct7== f7_FCVT_S_L)  && (rs2 == rs2_FCVT_S_L))
	  || ((funct7== f7_FCVT_S_LU) && (rs2 == rs2_FCVT_S_LU))
	  ));

   // ----------------
   Bool is_legal_other_RV32D
   = (   isa_D
      && (opcode == op_FP)
      && (   (funct7== f7_FADD_D)
	  || (funct7== f7_FSUB_D)
	  || (funct7== f7_FMUL_D)
`ifdef INCLUDE_FDIV
	  || (funct7== f7_FDIV_D)
`endif
`ifdef INCLUDE_FSQRT
	  || ((funct7== f7_FSQRT_D)   && (rs2 == rs2_FSQRT_D))
`endif
	  || ((funct7== f7_FSGNJ_D)                              && (rm == f3_FSGNJ_D))
	  || ((funct7== f7_FSGNJN_D)                             && (rm == f3_FSGNJN_D))
	  || ((funct7== f7_FSGNJX_D)                             && (rm == f3_FSGNJX_D))
	  || ((funct7== f7_FMIN_D)                               && (rm == f3_FMIN_D))
	  || ((funct7== f7_FMAX_D)                               && (rm == f3_FMAX_D))
	  || ((funct7== f7_FCVT_S_D)  && (rs2 == rs2_FCVT_S_D))
	  || ((funct7== f7_FCVT_D_S)  && (rs2 == rs2_FCVT_D_S))
	  || ((funct7== f7_FEQ_D)                                && (rm == f3_FEQ_D))
	  || ((funct7== f7_FLT_D)                                && (rm == f3_FLT_D))
	  || ((funct7== f7_FLE_D)                                && (rm == f3_FLE_D))
	  || ((funct7== f7_FCLASS_D)  && (rs2 == rs2_FCLASS_D))  && (rm == f3_FCLASS_D)
	  || ((funct7== f7_FCVT_W_D)  && (rs2 == rs2_FCVT_W_D))
	  || ((funct7== f7_FCVT_WU_D) && (rs2 == rs2_FCVT_WU_D))
	  || ((funct7== f7_FCVT_D_W)  && (rs2 == rs2_FCVT_D_W))
	  || ((funct7== f7_FCVT_D_WU) && (rs2 == rs2_FCVT_D_WU))
	  ));

   // ----------------
   Bool is_legal_other_RV64D
   = (   isa_D
      && (opcode == op_FP)
      && rv64
      && (   ((funct7== f7_FCVT_L_D)  && (rs2 == rs2_FCVT_L_D))
	  || ((funct7== f7_FCVT_LU_D) && (rs2 == rs2_FCVT_LU_D))
	  || ((funct7== f7_FMV_X_D)   && (rs2 == rs2_FMV_X_D))   && (rm == f3_FMV_X_D)
	  || ((funct7== f7_FCVT_D_L)  && (rs2 == rs2_FCVT_D_L))
	  || ((funct7== f7_FCVT_D_LU) && (rs2 == rs2_FCVT_D_LU))
	  || ((funct7== f7_FMV_D_X)   && (rs2 == rs2_FMV_D_X))   && (rm == f3_FMV_D_X)
	  ));

   // ----------------
   return (   is_legal_FM_FNM
	   || is_legal_other_RV32F
	   || is_legal_other_RV64F
	   || is_legal_other_RV32D
	   || is_legal_other_RV64D);
endfunction

// Returns True if the first operand (val1) should be taken from the GPR
// instead of the FPR for a FP opcode
function Bool is_fp_val1_from_gpr (Opcode opcode, Bit#(7) f7, RegIdx rs2);
   return (
         (opcode == op_FP)
      && (   False
`ifdef ISA_D
          || ((f7 == f7_FCVT_D_W)  && (rs2 == 0))
          || ((f7 == f7_FCVT_D_WU) && (rs2 == 1))
`ifdef RV64
          || ((f7 == f7_FCVT_D_L)  && (rs2 == 2))
          || ((f7 == f7_FCVT_D_LU) && (rs2 == 3))
`endif
          || ((f7 == f7_FMV_D_X))
`endif
          || ((f7 == f7_FCVT_S_W)  && (rs2 == 0))
          || ((f7 == f7_FCVT_S_WU) && (rs2 == 1))
`ifdef RV64
          || ((f7 == f7_FCVT_S_L)  && (rs2 == 2))
          || ((f7 == f7_FCVT_S_LU) && (rs2 == 3))
`endif
          || ((f7 == f7_FMV_W_X))
          )
   );
endfunction
`endif

endpackage