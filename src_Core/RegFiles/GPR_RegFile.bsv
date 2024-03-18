package GPR_RegFile;

export GPR_RegFile_IFC (..), mkGPR_RegFile;

import ConfigReg    :: *;
import RegFile      :: *;
import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;
import GetPut_Aux :: *;

import isa_base :: *;

interface GPR_RegFile_IFC;
   interface Server #(Token, Token) server_reset;

   (* always_ready *)
   method WordXL read_rs1 (RegIdx rs1);
   (* always_ready *)
   method WordXL read_rs1_port2 (RegIdx rs1);    // For debugger access only
   (* always_ready *)
   method WordXL read_rs2 (RegIdx rs2);

   // GPR write
   (* always_ready *)
   method Action write_rd (RegIdx rd, WordXL rd_val);

endinterface

// ================================================================
// Major states of mkGPR_RegFile module

typedef enum { RF_RESET_START, RF_RESETTING, RF_RUNNING } RF_State
deriving (Eq, Bits, FShow);

// ================================================================

(* synthesize *)
module mkGPR_RegFile (GPR_RegFile_IFC);

   Reg#(RF_State) rg_state      <- mkReg (RF_RESET_START);

   FIFOF#(Token) f_reset_rsps <- mkFIFOF;

   // General Purpose Registers
   // TODO: can we use Reg [0] for some other purpose?
   RegFile#(RegIdx, WordXL) regfile <- mkRegFileFull;

   // ----------------------------------------------------------------
   // Reset.
   // This loop initializes all GPRs to 0.
   // The spec does not require this, but it's useful for debugging
   // and tandem verification

`ifdef INCLUDE_TANDEM_VERIF
   Reg #(RegIdx) rg_j <- mkRegU;    // reset loop index
`endif

   rule rl_reset_start (rg_state == RF_RESET_START);
      rg_state <= RF_RESETTING;
`ifdef INCLUDE_TANDEM_VERIF
      rg_j <= 1;
`endif
   endrule

   rule rl_reset_loop (rg_state == RF_RESETTING);
`ifdef INCLUDE_TANDEM_VERIF
      regfile.upd (rg_j, 0);
      rg_j <= rg_j + 1;
      if (rg_j == 31)
	 rg_state <= RF_RUNNING;
`else
      rg_state <= RF_RUNNING;
`endif
   endrule

   // ----------------------------------------------------------------
   // INTERFACE

   // Reset
   interface Server server_reset;
      interface Put request;
	 method Action put (Token token);
	    rg_state <= RF_RESET_START;

	    // This response is placed here, and not in rl_reset_loop, because
	    // reset_loop can happen on power-up, where no response is expected.
	    f_reset_rsps.enq (?);
	 endmethod
      endinterface

      interface Get response;
	 method ActionValue #(Token) get if (rg_state == RF_RUNNING);
	    let token <- pop (f_reset_rsps);
	    return token;
	 endmethod
      endinterface
      
   endinterface

   // GPR read
   method WordXL read_rs1 (RegIdx rs1);
      return ((rs1 == 0) ? 0 : regfile.sub (rs1));
   endmethod

   // GPR read
   method WordXL read_rs1_port2 (RegIdx rs1);        // For debugger access only
      return ((rs1 == 0) ? 0 : regfile.sub (rs1));
   endmethod

   method WordXL read_rs2 (RegIdx rs2);
      return ((rs2 == 0) ? 0 : regfile.sub (rs2));
   endmethod

   // GPR write
   method Action write_rd (RegIdx rd, WordXL rd_val);
      if (rd != 0) regfile.upd (rd, rd_val);
   endmethod

endmodule

// ================================================================

endpackage
