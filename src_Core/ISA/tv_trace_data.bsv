// ================================================================
// Definition of Tandem Verifier Packets.
// The CPU sends out such a packet for each instruction retired.
// A Tandem Verifier contains a "golden model" simulator of the RISC-V
// ISA, and verifies that the information in the packet is correct,
// instruction by instruction.

// ================================================================

package tv_trace_data;


import isa_decls    :: *;

typedef enum {// These are not from instruction flow and do not have a PC or instruction
   TRACE_RESET,
   TRACE_GPR_WRITE,
   TRACE_FPR_WRITE,
   TRACE_CSR_WRITE,
   TRACE_MEM_WRITE,

   // These are from instruction flow and have a PC and instruction
   TRACE_OTHER,
   TRACE_I_RD,   
   TRACE_F_GRD,   
   TRACE_F_FRD,
   TRACE_I_LOAD,  
   TRACE_F_LOAD,
   TRACE_I_STORE, 
   TRACE_F_STORE,
   TRACE_AMO,
   TRACE_TRAP,
   TRACE_RET,
   TRACE_CSRRX,

   // These are from an interrupt and has a PC but no instruction
   TRACE_INTR
} TraceOp deriving (Bits, Eq, FShow);

typedef struct {
   TraceOp    op;
   WordXL     pc;
   WordXL     next_pc;

   ISize      instr_sz;
   Bit#(32)   instr;
   RegIdx     rd;
   WordXL     word1;
   WordXL     word2;
   Bit#(64)   word3;    // Wider than WordXL because can contain paddr (in RV32, paddr can be 34 bits)
   WordXL     word4;
`ifdef ISA_F
   Bit#(64)   word5;    // For changed RV64 MSTATUS in ISA_F system; for FPR val in RV32D
`endif
   } TraceData
deriving (Bits);

// RESET
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x
function TraceData mkTrace_RESET ();
   TraceData td = ?;
   td.op       = TRACE_RESET;
   return td;
endfunction

// GPR_WRITE
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x                                 x    rdval
function TraceData mkTrace_GPR_WRITE (RegIdx rd, WordXL rdval);
   TraceData td = ?;
   td.op       = TRACE_GPR_WRITE;
   td.rd       = rd;
   td.word1    = rdval;
   return td;
endfunction

`ifdef ISA_F

// FPR_WRITE
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4   word5
// x                                 x                                       rdval
function TraceData mkTrace_FPR_WRITE (RegIdx rd, WordFL rdval);
   TraceData td = ?;
   td.op       = TRACE_FPR_WRITE;
   td.rd       = rd;
   td.word5    = zeroExtend (rdval);    // Can be 64b double in RV32D
   return td;
endfunction

`endif

// CSR_WRITE
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x                                                        csraddr  csrval
function TraceData mkTrace_CSR_WRITE (CSRAddr csraddr, WordXL csrval);
   TraceData td = ?;
   td.op       = TRACE_CSR_WRITE;
   td.word3    = zeroExtend (csraddr);
   td.word4    = csrval;
   return td;
endfunction

// MEM_WRITE
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x                                         sz    stval    paddr
function TraceData mkTrace_MEM_WRITE (MemReqSize sz, WordXL stval, Bit#(64) paddr);
   TraceData td = ?;
   td.op       = TRACE_MEM_WRITE;
   td.word1    = zeroExtend (sz);
   td.word2    = stval;
   td.word3    = paddr;
   return td;
endfunction

// OTHER
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x     x     x           x
function TraceData mkTrace_OTHER (WordXL pc, WordXL next_pc, ISize isize, Bit#(32) instr);
   TraceData td = ?;
   td.op       = TRACE_OTHER;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   return td;
endfunction

// I_RD
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x     x     x           x        x     rdval
function TraceData mkTrace_I_RD (WordXL pc, WordXL next_pc, ISize isize, Bit#(32) instr, RegIdx rd, WordXL rdval);
   TraceData td = ?;
   td.op       = TRACE_I_RD;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.rd       = rd;
   td.word1    = rdval;
   return td;
endfunction

`ifdef ISA_F
// F_FRD
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4    word5
// x     x     x           x        x              fflags            mstatus  rdval
function TraceData mkTrace_F_FRD (WordXL pc, WordXL next_pc, ISize isize, Bit#(32) instr, RegIdx rd, WordFL rdval, Bit#(5) fflags, WordXL mstatus);
   TraceData td = ?;
   td.op       = TRACE_F_FRD;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.rd       = rd;
   td.word2    = extend (fflags);
   td.word4    = mstatus;
`ifdef ISA_D
   td.word5    = rdval;
`else
   td.word5    = extend (rdval);
`endif
   return td;
endfunction

// F_GRD
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4    word5
// x     x     x           x        x     rdval    fflags            mstatus
function TraceData mkTrace_F_GRD (WordXL pc, WordXL next_pc, ISize isize, Bit#(32) instr, RegIdx rd, WordXL rdval, Bit#(5) fflags, WordXL mstatus);
   TraceData td = ?;
   td.op       = TRACE_F_GRD;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.rd       = rd;
   td.word1    = rdval;
   td.word2    = extend (fflags);
   td.word4    = mstatus;
   return td;
endfunction
`endif

// I_LOAD
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x     x     x           x        x     rdval             eaddr
function TraceData mkTrace_I_LOAD (WordXL pc, WordXL next_pc, ISize isize, Bit#(32) instr, RegIdx rd, WordXL rdval, WordXL eaddr);
   TraceData td = ?;
   td.op       = TRACE_I_LOAD;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.rd       = rd;
   td.word1    = rdval;
   td.word3    = zeroExtend (eaddr);
   return td;
endfunction

// I_STORE
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x     x     x           x              funct3   stval    eaddr
function TraceData mkTrace_I_STORE (WordXL pc, WordXL next_pc, Bit#(3) funct3, ISize isize, Bit#(32) instr, WordXL stval, WordXL eaddr);
   TraceData td = ?;
   td.op       = TRACE_I_STORE;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.word1    = zeroExtend (funct3);
   td.word2    = stval;
   td.word3    = zeroExtend (eaddr);
   return td;
endfunction

`ifdef ISA_F
// F_LOAD
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4    word5
// x     x     x           x        x                       eaddr    mstatus  rdval
function TraceData mkTrace_F_LOAD (WordXL pc, WordXL next_pc, ISize isize, Bit#(32) instr, RegIdx rd, WordFL rdval, WordXL eaddr, WordXL mstatus);
   TraceData td = ?;
   td.op       = TRACE_F_LOAD;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.rd       = rd;
   td.word3    = zeroExtend (eaddr);
   td.word4    = mstatus;
`ifdef ISA_D
   td.word5    = rdval;
`else
   td.word5    = extend (rdval);
`endif
   return td;
endfunction

// F_STORE
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4    word5
// x     x     x           x              funct3            eaddr             stval
function TraceData mkTrace_F_STORE (WordXL pc, WordXL next_pc, Bit#(3) funct3, ISize isize, Bit#(32) instr, WordFL stval, WordXL eaddr);
   TraceData td = ?;
   td.op       = TRACE_F_STORE;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.word3    = zeroExtend (eaddr);
`ifdef ISA_D
   td.word5    = stval;
`else
   td.word5    = extend (stval);
`endif
   return td;
endfunction

function TraceData trace_update_mstatus_fs (TraceData td, WordXL new_mstatus);
   let ntd = td;
   ntd.word4 = new_mstatus;
   return ntd;
endfunction

function TraceData trace_update_fcsr_fflags (TraceData td, Bit#(5) fflags);
   let ntd = td;
   ntd.word2 = (td.word2 | extend (fflags));
   return ntd;
endfunction
`endif

// AMO
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x     x     x           x        x     rdval    stval    eaddr    funct3
function TraceData mkTrace_AMO (WordXL pc, WordXL next_pc, Bit#(3) funct3, ISize isize, Bit#(32) instr,
				 RegIdx rd, WordXL rdval, WordXL stval, WordXL eaddr);
   TraceData td = ?;
   td.op       = TRACE_AMO;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.rd       = rd;
   td.word1    = rdval;
   td.word2    = stval;
   td.word3    = zeroExtend (eaddr);
   td.word4    = zeroExtend (funct3);
   return td;
endfunction

// TRAP
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x     x     x           x        priv  mstatus  mcause   mepc     mtval
function TraceData mkTrace_TRAP (WordXL pc, WordXL next_pc, ISize isize, Bit#(32) instr,
				  PrivMode  priv, WordXL mstatus, WordXL mcause, WordXL mepc, WordXL mtval);
   TraceData td = ?;
   td.op       = TRACE_TRAP;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.rd       = zeroExtend (priv);
   td.word1    = mstatus;
   td.word2    = mcause;
   td.word3    = zeroExtend (mepc);
   td.word4    = mtval;
   return td;
endfunction

// RET
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x     x     x           x        priv  mstatus
function TraceData mkTrace_RET (WordXL pc, WordXL next_pc, ISize isize, Bit#(32) instr, PrivMode  priv, WordXL mstatus);
   TraceData td = ?;
   td.op       = TRACE_RET;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.rd       = zeroExtend (priv);
   td.word1    = mstatus;
   return td;
endfunction

// CSRRX
// op    pc    instr_sz    instr    rd    word1    word2              word3    word4   word5
// x     x     x           x        x     rdval    [1] mstatus_valid  csraddr  csrval  mstatus
//                                                 [0] csrvalid
function TraceData mkTrace_CSRRX (WordXL pc, WordXL next_pc, ISize isize, Bit#(32) instr,
				   RegIdx rd, WordXL rdval,
				   Bool csrvalid, CSRAddr csraddr, WordXL csrval,
				   Bool   mstatus_valid,
				   WordXL mstatus);
   TraceData td = ?;
   td.op       = TRACE_CSRRX;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.instr_sz = isize;
   td.instr    = instr;
   td.rd       = rd;
   td.word1    = rdval;
   td.word2    = ((mstatus_valid ? 2 : 0) | (csrvalid ? 1 : 0));
   td.word3    = zeroExtend (csraddr);
   td.word4    = csrval;
`ifdef ISA_F
`ifdef RV32
   td.word5    = extend (mstatus);
`else
   td.word5    = mstatus;
`endif
`endif
   return td;
endfunction

// INTR
// op    pc    instr_sz    instr    rd    word1    word2    word3    word4
// x     x                          priv  mstatus  mcause   mepc     mtval
function TraceData mkTrace_INTR (WordXL pc, WordXL next_pc,
				  PrivMode  priv, WordXL mstatus, WordXL mcause, WordXL mepc, WordXL mtval);
   TraceData td = ?;
   td.op       = TRACE_INTR;
   td.pc       = pc;
   td.next_pc  = next_pc;
   td.rd       = zeroExtend (priv);
   td.word1    = mstatus;
   td.word2    = mcause;
   td.word3    = zeroExtend (mepc);
   td.word4    = mtval;
   return td;
endfunction

instance FShow#(TraceData);
   function Fmt fshow (TraceData td);
      Fmt fmt = $format ("TraceData{", fshow (td.op));

      if (td.op == TRACE_RESET) begin
      end

      else if ((td.op == TRACE_GPR_WRITE) || (td.op == TRACE_FPR_WRITE))
	 fmt = fmt + $format (" rd %0d  rdval %0h", td.rd, td.word1);

      else if (td.op == TRACE_CSR_WRITE)
	 fmt = fmt + $format (" csraddr %0h  csrval %0h", td.word3, td.word4);

      else if (td.op == TRACE_MEM_WRITE)
	 fmt = fmt + $format (" sz %0d  stval %0h  paddr %0h", td.word1, td.word2, td.word3);

      else begin
	 fmt = fmt + $format (" pc %0h", td.pc);

	 if (td.op != TRACE_INTR)
	    fmt = fmt + $format (" instr.%0d %0h:", pack (td.instr_sz), td.instr);

	 if (td.op == TRACE_I_RD)
	    fmt = fmt + $format (" rd %0d  rdval %0h", td.rd, td.word1);
`ifdef ISA_F
	 else if (td.op == TRACE_F_FRD)
	    fmt = fmt + $format (" rd %0d  rdval %0h  fflags %05b", td.rd, td.word5, td.word2);

	 else if (td.op == TRACE_F_GRD)
	    fmt = fmt + $format (" rd %0d  rdval %0h  fflags %05b", td.rd, td.word1, td.word2);

	 else if (td.op == TRACE_F_LOAD)
	    fmt = fmt + $format (" rd %0d  rdval %0h  eaddr %0h",
				 td.rd, td.word5, td.word3);

	 else if (td.op == TRACE_F_STORE)
	    fmt = fmt + $format (" stval %0h  eaddr %0h", td.word5, td.word3);
`endif
	 else if (td.op == TRACE_I_LOAD)
	    fmt = fmt + $format (" rd %0d  rdval %0h  eaddr %0h",
				 td.rd, td.word1, td.word3);

	 else if (td.op == TRACE_I_STORE)
	    fmt = fmt + $format (" stval %0h  eaddr %0h", td.word2, td.word3);

	 else if (td.op == TRACE_AMO)
	    fmt = fmt + $format (" rd %0d  rdval %0h  stval %0h  eaddr %0h",
				 td.rd, td.word1, td.word2, td.word3);

	 else if (td.op == TRACE_CSRRX)
	    fmt = fmt + $format (" rd %0d  rdval %0h  csraddr %0h  csrval %0h",
				 td.rd, td.word1, td.word3, td.word4);

	 else if ((td.op == TRACE_TRAP) || (td.op == TRACE_INTR))
	    fmt = fmt + $format (" priv %0d  mstatus %0h  mcause %0h  mepc %0h  mtval %0h",
				 td.rd, td.word1, td.word2, td.word3, td.word4);

	 else if (td.op == TRACE_RET)
	    fmt = fmt + $format (" priv %0d  mstatus %0h", td.rd, td.word1);
      end

      fmt = fmt + $format ("}");
      return fmt;
   endfunction
endinstance


endpackage
