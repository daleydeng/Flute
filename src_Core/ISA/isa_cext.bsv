package isa_cext;
// ================================================================
//
// Contains RISC-V ISA defs for the 'C' ("compressed") extension
// i.e., 16-bit instructions
//
// ================================================================
// Instruction field encodings

export isa_types::*, isa_cext::*;
import isa_types ::*;

InstrCBits illegal_instr_c = 16'h0000;

typedef enum {
   CR, CI, CSS, CIW, CL, CS, CA, CB, CJ
} InstrCFmt deriving (Bits, Eq, FShow);

typedef union tagged {
   InstrCBits Raw;
   struct {
      Bit#(4) funct4;
      Bit#(5) rd_rs1;
      Bit#(5) rs2;
      Bit#(2) op;
   } Instr_CR;
   struct {
      Bit#(3) funct3;
      Bit#(1) imm_12;
      Bit#(5) rd_rs1;
      Bit#(5) imm_6_2;
      Bit#(2) op;
   } Instr_CI;
   struct {
      Bit#(3) funct3;
      Bit#(6) imm_12_7;
      Bit#(5) rs2;
      Bit#(2) op;
   } Instr_CSS;
   struct {
      Bit#(3) funct3;
      Bit#(8) imm_12_5;
      Bit#(3) rd_C;
      Bit#(2) op;
   } Instr_CIW;
   struct {
      Bit#(3) funct3;
      Bit#(3) imm_12_10;
      Bit#(3) rs1_C;
      Bit#(2) imm_6_5;
      Bit#(3) rd_C;
      Bit#(2) op;
   } Instr_CL;
   struct {
      Bit#(3) funct3;
      Bit#(3) imm_12_10;
      Bit#(3) rs1_C;
      Bit#(2) imm_6_5;
      Bit#(3) rs2_C;
      Bit#(2) op;
   } Instr_CS;
   struct {
      Bit#(6) funct6;
      Bit#(3) rd_rs1_C;
      Bit#(2) funct2;
      Bit#(3) rs2_C;
      Bit#(2) op;
   } Instr_CA;
   struct {
      Bit#(3) funct3;
      Bit#(3) imm_12_10;
      Bit#(3) rs1_C;
      Bit#(5) imm_6_2;
      Bit#(2) op;
   } Instr_CB;
   struct {
      Bit#(3) funct3;
      Bit#(11) imm_12_2;
      Bit#(2) op;
   } Instr_CJ;
} InstructionC deriving (Bits, FShow);

function InstructionC parse_instr_C(InstrCBits bits, InstrCFmt fmt);
   return case (fmt) 
      CR: tagged Instr_CR(unpack(bits));
      CI: tagged Instr_CI(unpack(bits));
      CSS: tagged Instr_CSS(unpack(bits));
      CIW: tagged Instr_CIW(unpack(bits));
      CL: tagged Instr_CL(unpack(bits));
      CS: tagged Instr_CS(unpack(bits));
      CA: tagged Instr_CA(unpack(bits));
      CB: tagged Instr_CB(unpack(bits));
      CJ: tagged Instr_CJ(unpack(bits));
   endcase;
endfunction

function Bit#(5) get_creg(Bit#(3) r_c);
   return {2'b01, r_c};
endfunction

Bit#(2) opcode_C0 = 2'b00;
Bit#(2) opcode_C1 = 2'b01;
Bit#(2) opcode_C2 = 2'b10;

Bit#(3) f3_C_LWSP     = 3'b_010;
Bit#(3) f3_C_LDSP     = 3'b_011;     // RV64 and RV128
Bit#(3) f3_C_LQSP     = 3'b_001;     // RV128
Bit#(3) f3_C_FLWSP    = 3'b_011;     // RV32FC
Bit#(3) f3_C_FLDSP    = 3'b_001;     // RV32DC, RV64DC

Bit#(3) f3_C_SWSP     = 3'b_110;

Bit#(3) f3_C_SQSP     = 3'b_101;     // RV128
Bit#(3) f3_C_FSDSP    = 3'b_101;     // RV32DC, RV64DC

Bit#(3) f3_C_SDSP     = 3'b_111;     // RV64 and RV128
Bit#(3) f3_C_FSWSP    = 3'b_111;     // RV32FC

Bit#(3) f3_C_LQ       = 3'b_001;     // RV128
Bit#(3) f3_C_FLD      = 3'b_001;     // RV32DC, RV64DC

Bit#(3) f3_C_LW       = 3'b_010;

Bit#(3) f3_C_LD       = 3'b_011;     // RV64 and RV128
Bit#(3) f3_C_FLW      = 3'b_011;     // RV32FC

Bit#(3) f3_C_FSD      = 3'b_101;     // RV32DC, RV64DC
Bit#(3) f3_C_SQ       = 3'b_101;     // RV128

Bit#(3) f3_C_SW       = 3'b_110;

Bit#(3) f3_C_SD       = 3'b_111;     // RV64 and RV128
Bit#(3) f3_C_FSW      = 3'b_111;     // RV32FC

Bit#(3) f3_C_JAL      = 3'b_001;     // RV32
Bit#(3) f3_C_J        = 3'b_101;
Bit#(3) f3_C_BEQZ     = 3'b_110;
Bit#(3) f3_C_BNEZ     = 3'b_111;

Bit#(4) f4_C_JR       = 4'b_1000;
Bit#(4) f4_C_JALR     = 4'b_1001;

Bit#(3) f3_C_LI       = 3'b_010;
Bit#(3) f3_C_LUI      = 3'b_011;     // RV64 and RV128

Bit#(3) f3_C_NOP      = 3'b_000;
Bit#(3) f3_C_ADDI     = 3'b_000;
Bit#(3) f3_C_ADDIW    = 3'b_001;
Bit#(3) f3_C_ADDI16SP = 3'b_011;
Bit#(3) f3_C_ADDI4SPN = 3'b_000;
Bit#(3) f3_C_SLLI     = 3'b_000;

Bit#(3) f3_C_SRLI     = 3'b_100;
Bit#(2) f2_C_SRLI     = 2'b_00;

Bit#(3) f3_C_SRAI     = 3'b_100;
Bit#(2) f2_C_SRAI     = 2'b_01;

Bit#(3) f3_C_ANDI     = 3'b_100;
Bit#(2) f2_C_ANDI     = 2'b_10;

Bit#(4) f4_C_MV       = 4'b_1000;
Bit#(4) f4_C_ADD      = 4'b_1001;

Bit#(6) f6_C_AND      = 6'b_100_0_11;
Bit#(2) f2_C_AND      = 2'b_11;

Bit#(6) f6_C_OR       = 6'b_100_0_11;
Bit#(2) f2_C_OR       = 2'b_10;

Bit#(6) f6_C_XOR      = 6'b_100_0_11;
Bit#(2) f2_C_XOR      = 2'b_01;

Bit#(6) f6_C_SUB      = 6'b_100_0_11;
Bit#(2) f2_C_SUB      = 2'b_00;

Bit#(6) f6_C_ADDW     = 6'b_100_1_11;
Bit#(2) f2_C_ADDW     = 2'b_01;

Bit#(6) f6_C_SUBW     = 6'b_100_1_11;
Bit#(2) f2_C_SUBW     = 2'b_00;

Bit#(4) f4_C_EBREAK   = 4'b_1001;

endpackage