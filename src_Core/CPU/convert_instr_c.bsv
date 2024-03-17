package convert_instr_c;
// ================================================================
// convert_instr_C() is a function that decodes and expands a 16-bit
// "compressed" RISC-V instruction ('C' extension) into its full
// 32-bit equivalent.
// ================================================================

export convert_instr_C;

import isa_priv_M   :: *;
import isa_cext     :: *;
import isa_fdext    :: *;
import convert_instr_c_bh :: *;

`include "isa_defines.bsvi"

`define check(val) \
   case (val) matches \
      tagged Valid .x: if (!illegal && !found) begin \
         found = True; \
         out = x; \
      end \
   endcase

`define check_n(val, n) \
   case (val) matches \
      tagged Valid .x: if (!illegal && !found && xl == n) begin \
         found = True; \
         out = x; \
      end \
   endcase

`define check_n2(val, n1, n2) \
   case (val) matches \
      tagged Valid .x: if (!illegal && !found && (xl == n1 || xl == n2)) begin \
         found = True; \
         out = x; \
      end \
   endcase

`define check_nf(val, n) \
   case (val) matches \
      tagged Valid .x: if (!illegal && !found && xl == n && misa.f == 1) begin \
         found = True; \
         out = x; \
      end \
   endcase

`define check_n2f(val, n1, n2) \
   case (val) matches \
      tagged Valid .x: if (!illegal && !found && (xl == n1 || xl == n2) && misa.f == 1) begin \
         found = True; \
         out = x; \
      end \
   endcase

`define check_nd(val, n) \
   case (val) matches \
      tagged Valid .x: if (!illegal && !found && xl == n && misa.d == 1) begin \
         found = True; \
         out = x; \
      end \
   endcase

`define check_n2d(val, n1, n2) \
   case (val) matches \
      tagged Valid .x: if (!illegal && !found && (xl == n1 || xl == n2) && misa.d == 1) begin \
         found = True; \
         out = x; \
      end \
   endcase

`define check_32(val) `check_n(val, misa_mxl_32)
`define check_64(val) `check_n(val, misa_mxl_64)
`define check_128(val) `check_n(val, misa_mxl_128)

`define check_32_64(val) `check_n2(val, misa_mxl_32, misa_mxl_64)
`define check_32_64_d(val) `check_n2d(val, misa_mxl_32, misa_mxl_64)
`define check_64_128(val) `check_n2(val, misa_mxl_64, misa_mxl_128)

function InstrBits convert_instr_C (MISA misa, Bit #(2) xl, InstrCBits instr_C);
   InstrBits out = illegal_instr;
   Bool illegal = misa.c != 1;
   Bool found = False;

   `check(decode_C_ADDI4SPN(instr_C))

`ifdef RV_32_64_D
   `check_32_64(decode_C_FLD(instr_C))
`endif

`ifdef RV128
   `check_128(decode_C_LQ(instr_C))
`endif

   `check(decode_C_LW(instr_C))

`ifdef RV_32_F
   `check(decode_C_FLW(instr_C))
`endif

`ifdef RV_64_128
   `check_64_128(decode_C_LD(instr_C))
`endif

`ifdef RV_32_64_F
   `check_32_64(decode_C_FSD(instr_C))
`endif

`ifdef RV128
   `check_128(decode_C_SQ(instr_C))
`endif

   `check(decode_C_SW(instr_C))

`ifdef RV_32_F
   `check(decode_C_FSW(instr_C)) 
`endif

`ifdef RV_64_128
   `check_64_128(decode_C_SD(instr_C))
`endif

   `check(decode_C_NOP(instr_C))
   `check(decode_C_ADDI(instr_C))

`ifdef RV_32
   `check(decode_C_JAL(instr_C))
`endif

`ifdef RV_64_128
   `check_64_128(decode_C_ADDIW(instr_C))
`endif

   `check(decode_C_LI(instr_C))
   `check(decode_C_ADDI16SP(instr_C))
   `check(decode_C_LUI(instr_C))
`ifdef RV_32_64
   `check(decode_C_SRLI(instr_C, xl))
   `check(decode_C_SRAI(instr_C, xl))
`endif
   // ignore SRLI64
   // skip SRAI64
   `check(decode_C_ANDI(instr_C))
   `check(decode_C_SUB(instr_C))
   `check(decode_C_XOR(instr_C))
   `check(decode_C_OR(instr_C))
   `check(decode_C_AND(instr_C))

`ifdef RV_64_128
   `check_64_128(decode_C_SUBW(instr_C))
   `check_64_128(decode_C_ADDW(instr_C))
`endif
   `check(decode_C_J(instr_C))
   `check(decode_C_BEQZ(instr_C))
   `check(decode_C_BNEZ(instr_C))

`ifdef RV_32_64
   `check(decode_C_SLLI(instr_C, xl))
`endif

`ifdef RV_32_64_D
   `check_32_64_d(decode_C_FLDSP(instr_C))
`endif

`ifdef RV_128_D
   `check_128(decode_C_LQSP(instr_C))
`endif

   `check(decode_C_LWSP(instr_C))

`ifdef RV_32_F
   `check_32_f(decode_C_FLWSP(instr_C))
`endif

`ifdef RV_64_128
   `check_64_128(decode_C_LDSP(instr_C))
`endif

   `check(decode_C_JR(instr_C))
   `check(decode_C_MV(instr_C))
   `check(decode_C_EBREAK(instr_C))
   `check(decode_C_JALR(instr_C))
   `check(decode_C_ADD(instr_C))

`ifdef RV_32_64_D
   `check(decode_C_FSDSP(instr_C))
`endif

`ifdef RV_128
   `check_128(decode_C_SQSP(instr_C))
`endif

   `check(decode_C_SWSP(instr_C))

`ifdef RV_32_F
   `check(decode_C_FSWSP(instr_C))
`endif

`ifdef RV_64_128
   `check_64_128(decode_C_SDSP(instr_C))
`endif

   return out;
endfunction

// ================================================================
// 'C' Extension Stack-Pointer-Based Loads

// LWSP: expands into LW
function Maybe#(InstrBits) decode_C_LWSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(12) offset = {0, i.imm_6_2[1:0], i.imm_12, i.imm_6_2[4:2], 2'b0};

      let is_legal = ((i.op == opcode_C2)
		       && (i.rd_rs1 != 0)
		       && (i.funct3 == f3_C_LWSP));

      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         /*rs1*/reg_sp,  
         f3_LW,  
         i.rd_rs1,  
         op_LOAD
      )) : tagged Invalid;
   end
endfunction

`ifdef RV_64_128
// LDSP: expands into LD
function Maybe#(InstrBits) decode_C_LDSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(12) offset = {0, i.imm_6_2[2:0], i.imm_12, i.imm_6_2[4:3], 3'b0 };

      let is_legal = ((i.op == opcode_C2)
		       && (i.rd_rs1 != 0)
		       && (i.funct3 == f3_C_LDSP));

      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         /*rs1*/reg_sp,  
         f3_LD,  
         i.rd_rs1,  
         op_LOAD
      )) : tagged Invalid;
   end
endfunction
`endif

`ifdef RV128
// LQSP: expands into LQ
function Maybe#(InstrBits) decode_C_LQSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(12) offset = {0, i.imm_6_2 [3:0], i.imm_12, i.imm_6_2 [4], 4'b0 };

      let is_legal = ((i.op == opcode_C2)
		       && (i.rd_rs1 != 0)
		       && (i.funct3 == f3_C_LQSP));

      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         /*rs1*/reg_sp,  
         f3_LQ,  
         i.rd_rs1,  
         op_LOAD
      )) : tagged Invalid;
   end
endfunction
`endif

`ifdef RV_32_F
// FLWSP: expands into FLW
function Maybe#(InstrBits) decode_C_FLWSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(12) offset = {0, i.imm_6_2 [1:0], i.imm_12, i.imm_6_2 [4:2], 2'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_FLWSP;
      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         /*rs1*/reg_sp,  
         f3_FLW,  
         i.rd_rs1,  
         op_LOAD_FP
      )) : tagged Invalid;
   end
endfunction
`endif

`ifdef RV_64_128_D
// FLDSP: expands into FLD
function Maybe#(InstrBits) decode_C_FLDSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(12) offset = {0, i.imm_6_2[2:0], i.imm_12, i.imm_6_2[4:3], 3'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_FLDSP;

      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         /*rs1*/reg_sp,  
         f3_FLD,  
         i.rd_rs1,  
         op_LOAD_FP
      )) : tagged Invalid;
   end
endfunction
`endif

// ================================================================
// 'C' Extension Stack-Pointer-Based Stores

// SWSP: expands to SW
function Maybe#(InstrBits) decode_C_SWSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = `PAT(parse_instr_C(instr_C, CSS), Instr_CSS);
      Bit#(12) offset = {0, i.imm_12_7 [1:0], i.imm_12_7 [5:2], 2'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_SWSP;

      return is_legal ? Valid(encode_instr_S (
         offset, 
         i.rs2, 
         /*rs1*/reg_sp, 
         f3_SW, 
         op_STORE
      )): tagged Invalid;
   end
endfunction

`ifdef RV_64_128
// SDSP: expands to SD
function Maybe#(InstrBits) decode_C_SDSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = `PAT(parse_instr_C(instr_C, CSS), Instr_CSS);
      Bit#(12) offset = {0, i.imm_12_7[2:0], i.imm_12_7[5:3], 3'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_SDSP;

      return is_legal ? Valid(encode_instr_S (
         offset, 
         i.rs2, 
         /*rs1*/reg_sp, 
         f3_SD, 
         op_STORE
      )): tagged Invalid;
   end
endfunction
`endif

`ifdef RV128
// SQSP: expands to SQ
function Maybe#(InstrBits) decode_C_SQSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = `PAT(parse_instr_C(instr_C, CSS), Instr_CSS);
      Bit#(12) offset = {0, i.imm_12_7[3:0], i.imm_12_7[5:4], 4'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_SQSP;

      return is_legal ? Valid(encode_instr_S (
         offset, 
         i.rs2, 
         /*rs1*/reg_sp, 
         f3_SQ, 
         op_STORE
      )): tagged Invalid;
   end
endfunction
`endif

`ifdef RV_32_F
// FSWSP: expands to FSW
function Maybe#(InstrBits) decode_C_FSWSP(InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = `PAT(parse_instr_C(instr_C, CSS), Instr_CSS);
      Bit#(12) offset = {0, i.imm_12_7 [1:0], i.imm_12_7 [5:2], 2'b0 };

      let is_legal = op == opcode_C2 && funct3 == f3_C_FSWSP;

      return is_legal ? Valid(encode_instr_S (
         offset, 
         i.rs2, 
         /*rs1*/reg_sp, 
         f3_FSW, 
         op_STORE_FP
      )): tagged Invalid;
   end
endfunction
`endif

`ifdef RV_32_64_D
// FSDSP: expands to FSD
function Maybe#(InstrBits) decode_C_FSDSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = `PAT(parse_instr_C(instr_C, CSS), Instr_CSS);
      Bit#(12) offset = {0, i.imm_12_7 [2:0], i.imm_12_7 [5:3], 3'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_FSDSP;
      return is_legal ? Valid(encode_instr_S (
         offset, 
         i.rs2, 
         /*rs1*/reg_sp, 
         f3_FSD, 
         op_STORE_FP
      )): tagged Invalid;
   end
endfunction
`endif

// ================================================================
// 'C' Extension Register-Based Loads

// C_LW: expands to LW
function Maybe#(InstrBits) decode_C_LW (InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = `PAT(parse_instr_C(instr_C, CL), Instr_CL);
      Bit#(12) offset = {0, i.imm_6_5 [0], i.imm_12_10, i.imm_6_5 [1], 2'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_LW;

      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         get_creg(i.rs1_C),  
         f3_LW,  
         get_creg(i.rd_C),  
         op_LOAD
      )) : tagged Invalid;
   end
endfunction

`ifdef RV_64_128
// C_LD: expands to LD
function Maybe#(InstrBits) decode_C_LD (InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = `PAT(parse_instr_C(instr_C, CL), Instr_CL);
      Bit#(12) offset = {0, i.imm_6_5, i.imm_12_10, 3'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_LD;

      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         get_creg(i.rs1_C),  
         f3_LD,  
         get_creg(i.rd_C),  
         op_LOAD
      )) : tagged Invalid;
   end
endfunction
`endif

`ifdef RV128
// C_LQ: expands to LQ
function Maybe#(InstrBits) decode_C_LQ (InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = `PAT(parse_instr_C(instr_C, CL), Instr_CL);
      Bit#(12) offset = {0, i.imm_12_10 [0], i.imm_6_5, i.imm_12_10 [2], i.imm_12_10 [1], 4'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_LQ;

      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         get_creg(i.rs1_C),  
         f3_LQ,  
         get_creg(i.rd_C),  
         op_LOAD
      )) : tagged Invalid;
   end
endfunction
`endif

`ifdef RV_32_F
// C_FLW: expands to FLW
function Maybe#(InstrBits) decode_C_FLW(InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = `PAT(parse_instr_C(instr_C, CL), Instr_CL);
      Bit#(12) offset = {0, i.imm_6_5[0], i.imm_12_10, i.imm_6_5[1], 2'b0 };

      let is_legal =i.op == opcode_C0 && i.funct3 == f3_C_FLW;

      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         get_creg(i.rs1_C),  
         f3_FLW,  
         get_creg(i.rd_C),  
         op_LOAD_FP
      )) : tagged Invalid;
   end
endfunction
`endif

`ifdef RV_32_64_D
// C_FLD: expands to FLD
function Maybe#(InstrBits) decode_C_FLD (InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = `PAT(parse_instr_C(instr_C, CL), Instr_CL);
      Bit#(12) offset = {0, i.imm_6_5, i.imm_12_10, 3'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_FLD;

      return is_legal ? tagged Valid(encode_instr_I(
         offset,  
         get_creg(i.rs1_C),  
         f3_FLD,  
         get_creg(i.rd_C),  
         op_LOAD_FP
      )) : tagged Invalid;
   end
endfunction
`endif

// ================================================================
// 'C' Extension Register-Based Stores

// C_SW: expands to SW
function Maybe#(InstrBits) decode_C_SW (InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = `PAT(parse_instr_C(instr_C, CS), Instr_CS);
      Bit#(12) offset = {0, i.imm_6_5[0], i.imm_12_10, i.imm_6_5[1], 2'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_SW;

      return is_legal ? Valid(encode_instr_S (
         offset, 
         get_creg(i.rs2_C), 
         get_creg(i.rs1_C), 
         f3_SW, 
         op_STORE
      )): tagged Invalid;
   end
endfunction

`ifdef RV_64_128
// C_SD: expands to SD
function Maybe#(InstrBits) decode_C_SD (InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = `PAT(parse_instr_C(instr_C, CS), Instr_CS);
      Bit#(12) offset = {0, i.imm_6_5, i.imm_12_10, 3'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_SD;

      return is_legal ? Valid(encode_instr_S (
         offset, 
         get_creg(i.rs2_C), 
         get_creg(i.rs1_C), 
         f3_SD, 
         op_STORE
      )): tagged Invalid;
   end
endfunction
`endif

`ifdef RV128
// C_SQ: expands to SQ
function Maybe#(InstrBits) decode_C_SQ (InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = `PAT(parse_instr_C(instr_C, CS), Instr_CS);
      Bit#(9) offset = { i.imm_12_10[0], i.imm_6_5, i.imm_12_10[2], i.imm_12_10[1], 4'b0 };

      let is_legal = op == opcode_C0 && funct3 == f3_C_SQ;

      return is_legal ? Valid(encode_instr_S (
         offset, 
         get_creg(i.rs2_C), 
         get_creg(i.rs1_C), 
         f3_SQ, 
         op_STORE
      )): tagged Invalid;
   end
endfunction
`endif

`ifdef RV_32_F
// C_FSW: expands to FSW
function Maybe#(InstrBits) decode_C_FSW(InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = `PAT(parse_instr_C(instr_C, CS), Instr_CS);
      Bit#(12) offset = {0, i.imm_6_5 [0], i.imm_12_10, i.imm_6_5 [1], 2'b0 };

      let is_legal = op == opcode_C0 && funct3 == f3_C_FSW;

      return is_legal ? Valid(encode_instr_S (
         offset, 
         get_creg(i.rs2_C), 
         get_creg(i.rs1_C), 
         f3_FSW, 
         op_STORE_FP
      )): tagged Invalid;
   end
endfunction
`endif

`ifdef RV_32_64_F
// C_FSD: expands to FSD
function Maybe#(InstrBits) decode_C_FSD(InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = `PAT(parse_instr_C(instr_C, CS), Instr_CS);
      Bit#(12) offset = {0, i.imm_6_5, i.imm_12_10, 3'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_FSD;

      return is_legal ? Valid(encode_instr_S (
         offset, 
         get_creg(i.rs2_C), 
         get_creg(i.rs1_C), 
         f3_FSD, 
         op_STORE_FP
      )): tagged Invalid;
   end
endfunction
`endif

// ================================================================
// 'C' Extension Control Transfer
// C.J, C.JAL, C.JR, C.JALR, C.BEQZ, C.BNEZ

// C.J: expands to JAL
function Maybe#(InstrBits) decode_C_J(InstrCBits  instr_C);
   begin
      // InstrBits fields: CJ-type
      let i = `PAT(parse_instr_C(instr_C, CJ), Instr_CJ);
      Bit#(21) imm21 = signExtend({
         i.imm_12_2 [10],
         i.imm_12_2 [6],
         i.imm_12_2 [8:7],
         i.imm_12_2 [4],
         i.imm_12_2 [5],
         i.imm_12_2 [0],
         i.imm_12_2 [9],
         i.imm_12_2 [3:1],
      1'b0});

      let is_legal = i.op == opcode_C1 && i.funct3 == f3_C_J;

      return is_legal ? tagged Valid(encode_instr_J(
         imm21, /*rd*/ reg_zero, op_JAL
      )) : tagged Invalid;
   end
endfunction

`ifdef RV_32
// C.JAL: expands to JAL
function Maybe#(InstrBits) decode_C_JAL (InstrCBits  instr_C);
   begin
      // InstrBits fields: CJ-type
      let i = `PAT(parse_instr_C(instr_C, CJ), Instr_CJ);
      Bit#(21) imm21 = signExtend({
         i.imm_12_2 [10],
         i.imm_12_2 [6],
         i.imm_12_2 [8:7],
         i.imm_12_2 [4],
         i.imm_12_2 [5],
         i.imm_12_2 [0],
         i.imm_12_2 [9],
         i.imm_12_2 [3:1],
         1'b0});

      let is_legal = i.op == opcode_C1 && i.funct3 == f3_C_JAL;

      return is_legal ? tagged Valid(encode_instr_J(
         imm21, /*rd*/ reg_ra, op_JAL
      )) : tagged Invalid;
   end
endfunction
`endif

// C.JR: expands to JALR
function Maybe#(InstrBits) decode_C_JR (InstrCBits  instr_bits);
   begin
      let i = `PAT(parse_instr_C(instr_bits, CR), Instr_CR);

      let is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_JR)
		       && (i.rd_rs1 != 0)
		       && (i.rs2 == 0));

      return is_legal ? tagged Valid(encode_instr_I(
         0, 
         /*rs1*/i.rd_rs1, 
         f3_JALR, 
         reg_zero, 
         op_JALR
      )) : tagged Invalid;
   end
endfunction

// C.JALR: expands to JALR
function Maybe#(InstrBits) decode_C_JALR (InstrCBits  instr_bits);
   begin
      let i = `PAT(parse_instr_C(instr_bits, CR), Instr_CR);

      let is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_JALR)
		       && (i.rd_rs1 != 0)
		       && (i.rs2 == 0));

      return is_legal ? tagged Valid(encode_instr_I(
         0, 
         /*rs1*/i.rd_rs1, 
         f3_JALR, 
         reg_ra, 
         op_JALR
      )) : tagged Invalid;
   end
endfunction

// C.BEQZ: expands to BEQ
function Maybe#(InstrBits) decode_C_BEQZ (InstrCBits  instr_C);
   begin
      // InstrBits fields: CB-type
      let i = `PAT(parse_instr_C(instr_C, CB), Instr_CB);
      Bit#(13) imm13 = signExtend({ 
         i.imm_12_10[2], i.imm_6_2[4:3], i.imm_6_2[0], 
         i.imm_12_10[1:0], i.imm_6_2[2:1], 1'b0 });
      
      let is_legal = i.op == opcode_C1 && i.funct3 == f3_C_BEQZ;

      return is_legal ? tagged Valid(encode_instr_B(
         imm13,
         reg_zero,
         get_creg(i.rs1_C),
         f3_BEQ,
         op_BRANCH
      )) : tagged Invalid;
   end
endfunction

// C.BNEZ: expands to BNE
function Maybe#(InstrBits) decode_C_BNEZ (InstrCBits  instr_C);
   begin
      // InstrBits fields: CB-type
      let i = `PAT(parse_instr_C(instr_C, CB), Instr_CB);
      Bit#(13) imm13 = signExtend({ 
         i.imm_12_10[2], i.imm_6_2[4:3], i.imm_6_2[0], 
         i.imm_12_10[1:0], i.imm_6_2 [2:1], 1'b0 });
      
      let is_legal = i.op == opcode_C1 && i.funct3 == f3_C_BNEZ;

      return is_legal ? tagged Valid(encode_instr_B(
         imm13,
         reg_zero,
         get_creg(i.rs1_C),
         f3_BNE,
         op_BRANCH
      )) : tagged Invalid;
   end
endfunction

// ================================================================
// 'C' Extension Integer Constant-Generation

// C.LI: expands to ADDI
function Maybe#(InstrBits) decode_C_LI (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(12) imm12 = signExtend({ i.imm_12, i.imm_6_2 });

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_LI)
		       && (i.rd_rs1 != 0));

      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         reg_zero,
         f3_ADDI,
         i.rd_rs1,
         op_OP_IMM
      )) : tagged Invalid;
   end
endfunction

// C.LUI: expands to LUI
function Maybe#(InstrBits) decode_C_LUI (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(6) nzimm6 = { i.imm_12, i.imm_6_2 };

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_LUI)
		       && (i.rd_rs1 != 0)
		       && (i.rd_rs1 != 2)
		       && (nzimm6 != 0));

      Bit#(20) imm20 = signExtend (nzimm6);

      return is_legal ? tagged Valid(encode_instr_U(
         imm20,
         i.rd_rs1,
         op_LUI
      )) : tagged Invalid;
   end
endfunction

// ================================================================
// 'C' Extension Integer Register-Immediate Operations

// C.ADDI: expands to ADDI
function Maybe#(InstrBits) decode_C_ADDI (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(6) nzimm6 = { i.imm_12, i.imm_6_2 };

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_ADDI)
		       && (i.rd_rs1 != 0)
		       && (nzimm6 != 0));

      Bit#(12) imm12 = signExtend (nzimm6);
      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         i.rd_rs1,
         f3_ADDI,
         i.rd_rs1,
         op_OP_IMM
      )) : tagged Invalid;
   end
endfunction

// C.NOP: expands to ADDI
function Maybe#(InstrBits) decode_C_NOP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(6) nzimm6 = { i.imm_12, i.imm_6_2 };

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_NOP)
		       && (i.rd_rs1 == 0)
		       && (nzimm6 == 0));

      Bit#(12) imm12 = signExtend (nzimm6);

      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         i.rd_rs1,
         f3_ADDI,
         i.rd_rs1,
         op_OP_IMM
      )) : tagged Invalid;
   end
endfunction

`ifdef RV_64_128
// C.ADDIW: expands to ADDIW
function Maybe#(InstrBits) decode_C_ADDIW (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(6) imm6 = { i.imm_12, i.imm_6_2 };

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_ADDIW)
		       && (i.rd_rs1 != 0));

      Bit#(12) imm12 = signExtend (imm6);

      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         i.rd_rs1,
         f3_ADDIW,
         i.rd_rs1,
         op_OP_IMM_32
      )) : tagged Invalid;
   end
endfunction
`endif

// C.ADDI16SP: expands to ADDI
function Maybe#(InstrBits) decode_C_ADDI16SP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(10) nzimm10 = { i.imm_12, i.imm_6_2[2:1], i.imm_6_2[3], i.imm_6_2[0], i.imm_6_2[4], 4'b0 };

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_ADDI16SP)
		       && (i.rd_rs1 == reg_sp)
		       && (nzimm10 != 0));

      Bit#(12) imm12 = signExtend(nzimm10);

      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         i.rd_rs1,
         f3_ADDI,
         i.rd_rs1,
         op_OP_IMM
      )) : tagged Invalid;
   end
endfunction

// C.ADDI4SPN: expands to ADDI
function Maybe#(InstrBits) decode_C_ADDI4SPN (InstrCBits  instr_C);
   begin
      // InstrBits fields: CIW-type
      let i = `PAT(parse_instr_C(instr_C, CIW), Instr_CIW);
      Bit#(10) nzimm10 = {i.imm_12_5 [5:2], i.imm_12_5 [7:6], i.imm_12_5 [0], i.imm_12_5 [1], 2'b0 };

      let is_legal = ((i.op == opcode_C0)
		       && (i.funct3 == f3_C_ADDI4SPN)
		       && (nzimm10 != 0));

      Bit#(12) imm12 = zeroExtend(nzimm10);
      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         reg_sp,
         f3_ADDI,
         get_creg(i.rd_C),
         op_OP_IMM
      )) : tagged Invalid;

   end
endfunction

// C.SLLI: expands to SLLI
function Maybe#(InstrBits) decode_C_SLLI (InstrCBits  instr_C, Bit#(2)  xl);
   begin
      // InstrBits fields: CI-type
      let i = `PAT(parse_instr_C(instr_C, CI), Instr_CI);
      Bit#(6) shamt6 = { i.imm_12, i.imm_6_2 };

      let is_legal = ((i.op == opcode_C2)
		       && (i.funct3 == f3_C_SLLI)
		       && (i.rd_rs1 != 0)
             && (shamt6 != 0)
		       && ((xl == misa_mxl_32) ? (i.imm_12 == 0) : True));

      Bit#(12) imm12 = (  (xl == misa_mxl_32)
			 ? { msbs7_SLLI, i.imm_6_2 }
			 : { msbs6_SLLI, shamt6 } );

      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         i.rd_rs1,
         f3_SLLI,
         i.rd_rs1,
         op_OP_IMM
      )) : tagged Invalid;
   end
endfunction

`ifdef RV_32_64
// C.SRLI: expands to SRLI
function Maybe#(InstrBits) decode_C_SRLI(InstrCBits  instr_C, Bit#(2)  xl);
   begin
      // InstrBits fields: CB-type
      let i = `PAT(parse_instr_C(instr_C, CB), Instr_CB);      
      Bit#(1) shamt6_5 = i.imm_12_10 [2];
      Bit#(2) funct2   = i.imm_12_10 [1:0];
      Bit#(6) shamt6   = { shamt6_5, i.imm_6_2 };

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_SRLI)
		       && (funct2 == f2_C_SRLI)
             && (shamt6 != 0)
		       && ((xl == misa_mxl_32) ? (shamt6_5 == 0) : True));

      Bit#(12) imm12 = ((xl == misa_mxl_32)
			 ? { msbs7_SRLI, i.imm_6_2 }
			 : { msbs6_SRLI, shamt6 } );
      let rd_rs1 = get_creg(i.rs1_C);

      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         rd_rs1,
         f3_SRLI,
         rd_rs1,
         op_OP_IMM
      )) : tagged Invalid;
   end
endfunction
`endif

`ifdef RV_32_64
// C.SRAI: expands to SRAI
function Maybe#(InstrBits) decode_C_SRAI (InstrCBits  instr_C, Bit#(2)  xl);
   begin
      // InstrBits fields: CB-type
      let i = `PAT(parse_instr_C(instr_C, CB), Instr_CB);
      Bit#(1) shamt6_5 = i.imm_12_10 [2];
      Bit#(2) funct2   = i.imm_12_10 [1:0];
      Bit#(6) shamt6   = { shamt6_5, i.imm_6_2 };

      let is_legal = ((i.op == opcode_C1)
            && (i.funct3 == f3_C_SRAI)
            && (funct2 == f2_C_SRAI)
            && (shamt6 != 0)
            && ((xl == misa_mxl_32) ? (shamt6_5 == 0) : True));

      Bit#(12) imm12 = (  (xl == misa_mxl_32)
			 ? { msbs7_SRAI, i.imm_6_2 }
			 : { msbs6_SRAI, shamt6 } );

      let rd_rs1 = get_creg(i.rs1_C);
      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         rd_rs1,
         f3_SRAI,
         rd_rs1,
         op_OP_IMM
      )) : tagged Invalid;
   end
endfunction
`endif

// C.ANDI: expands to ANDI
function Maybe#(InstrBits) decode_C_ANDI (InstrCBits  instr_C);
   begin
      // InstrBits fields: CB-type
      let i = `PAT(parse_instr_C(instr_C, CB), Instr_CB);
      Bit#(12) imm12   = signExtend({ i.imm_12_10 [2], i.imm_6_2 });

      Bit#(2) funct2 = i.imm_12_10 [1:0];

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_ANDI)
		       && (funct2 == f2_C_ANDI));

      let rd_rs1 = get_creg(i.rs1_C);

      return is_legal ? tagged Valid(encode_instr_I(
         imm12,
         rd_rs1,
         f3_ANDI,
         rd_rs1,
         op_OP_IMM
      )) : tagged Invalid;
   end
endfunction

// ================================================================
// 'C' Extension Integer Register-Register Operations

// C.MV: expands to ADD
function Maybe#(InstrBits) decode_C_MV (InstrCBits  instr_bits);
   begin
      let i = `PAT(parse_instr_C(instr_bits, CR), Instr_CR);

      let is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_MV)
		       && (i.rd_rs1 != 0)
		       && (i.rs2 != 0));

      return is_legal ? tagged Valid(encode_instr_R(
         f7_ADD, 
         i.rs2, 
         reg_zero, 
         f3_ADD, 
         i.rd_rs1, 
         op_OP
      )) : tagged Invalid;
   end
endfunction

// C.ADD: expands to ADD
function Maybe#(InstrBits) decode_C_ADD (InstrCBits  instr_bits);
   begin
      let i = `PAT(parse_instr_C(instr_bits, CR), Instr_CR);

      let is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_ADD)
		       && (i.rd_rs1 != 0)
		       && (i.rs2 != 0));

      return is_legal ? tagged Valid(encode_instr_R(
         f7_ADD, 
         i.rs2, 
         i.rd_rs1, 
         f3_ADD, 
         i.rd_rs1, 
         op_OP
      )) : tagged Invalid;
   end
endfunction

// C.AND: expands to AND
function Maybe#(InstrBits) decode_C_AND (InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = `PAT(parse_instr_C(instr_C, CA), Instr_CA);
      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_AND)
		       && (i.funct2 == f2_C_AND));

      return is_legal ? tagged Valid(encode_instr_R(
         f7_AND, 
         get_creg(i.rs2_C), 
         get_creg(i.rd_rs1_C), 
         f3_AND, 
         get_creg(i.rd_rs1_C), 
         op_OP
      )) : tagged Invalid;
   end
endfunction

// C.OR: expands to OR
function Maybe#(InstrBits) decode_C_OR (InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = `PAT(parse_instr_C(instr_C, CA), Instr_CA);

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_OR)
		       && (i.funct2 == f2_C_OR));

      return is_legal ? tagged Valid(encode_instr_R(
         f7_OR, 
         get_creg(i.rs2_C), 
         get_creg(i.rd_rs1_C), 
         f3_OR, 
         get_creg(i.rd_rs1_C), 
         op_OP
      )) : tagged Invalid;
   end
endfunction

// C.XOR: expands to XOR
function Maybe#(InstrBits) decode_C_XOR (InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = `PAT(parse_instr_C(instr_C, CA), Instr_CA);

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_XOR)
		       && (i.funct2 == f2_C_XOR));

      return is_legal ? tagged Valid(encode_instr_R(
         f7_XOR, 
         get_creg(i.rs2_C), 
         get_creg(i.rd_rs1_C), 
         f3_XOR, 
         get_creg(i.rd_rs1_C), 
         op_OP
      )) : tagged Invalid;
   end
endfunction

// C.SUB: expands to SUB
function Maybe#(InstrBits) decode_C_SUB (InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = `PAT(parse_instr_C(instr_C, CA), Instr_CA);
      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_SUB)
		       && (i.funct2 == f2_C_SUB));

      return is_legal ? tagged Valid(encode_instr_R(
         f7_SUB, 
         get_creg(i.rs2_C), 
         get_creg(i.rd_rs1_C), 
         f3_SUB, 
         get_creg(i.rd_rs1_C), 
         op_OP
      )) : tagged Invalid;
   end
endfunction

`ifdef RV_64_128
function Maybe#(InstrBits) decode_C_ADDW(InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = `PAT(parse_instr_C(instr_C, CA), Instr_CA);

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_ADDW)
		       && (i.funct2 == f2_C_ADDW));

      return is_legal ? tagged Valid(encode_instr_R(
         f7_ADDW, 
         get_creg(i.rs2_C), 
         get_creg(i.rd_rs1_C), 
         f3_ADDW, 
         get_creg(i.rd_rs1_C), 
         op_OP_32
      )) : tagged Invalid;
   end
endfunction
`endif

`ifdef RV_64_128
function Maybe#(InstrBits) decode_C_SUBW(InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = `PAT(parse_instr_C(instr_C, CA), Instr_CA);

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_SUBW)
		       && (i.funct2 == f2_C_SUBW));

      return is_legal ? tagged Valid(encode_instr_R(
         f7_SUBW, 
         get_creg(i.rs2_C), 
         get_creg(i.rd_rs1_C), 
         f3_SUBW, 
         get_creg(i.rd_rs1_C), 
         op_OP_32
      )) : tagged Invalid;
   end
endfunction
`endif

// ================================================================
// 'C' Extension EBREAK

// C.EBREAK: expands to EBREAK
function Maybe#(InstrBits) decode_C_EBREAK (InstrCBits  instr_bits);
   begin
      let i = `PAT(parse_instr_C(instr_bits, CR), Instr_CR);

      let is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_EBREAK)
		       && (i.rd_rs1 == 0)
		       && (i.rs2 == 0));

      return is_legal ? tagged Valid(encode_instr_I(
         f12_EBREAK,
         i.rd_rs1,
         f3_PRIV,
         i.rd_rs1,
         op_SYSTEM
      )) : tagged Invalid;
   end
endfunction

// ================================================================

endpackage
