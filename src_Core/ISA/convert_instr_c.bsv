package convert_instr_c;
// ================================================================
// convert_instr_C() is a function that decodes and expands a 16-bit
// "compressed" RISC-V instruction ('C' extension) into its full
// 32-bit equivalent.
// ================================================================

export convert_instr_C;

import isa_decls   :: *;

`define check(val) \
   case (val) matches \
      {.valid, .instr}: if (!illegal && !found && valid) begin \
         found = True; \
         out = instr; \
      end \
   endcase

`define check_n(val, n) \
   case (val) matches \
      {.valid, .instr}: if (!illegal && !found && valid && xl == n) begin \
         found = True; \
         out = instr; \
      end \
   endcase

`define check_n2(val, n1, n2) \
   case (val) matches \
      {.valid, .instr}: if (!illegal && !found && valid && (xl == n1 || xl == n2)) begin \
         found = True; \
         out = instr; \
      end \
   endcase

`define check_nf(val, n) \
   case (val) matches \
      {.valid, .instr}: if (!illegal && !found && valid && xl == n && misa.f == 1) begin \
         found = True; \
         out = instr; \
      end \
   endcase

`define check_n2f(val, n1, n2) \
   case (val) matches \
      {.valid, .instr}: if (!illegal && !found && valid && (xl == n1 || xl == n2) && misa.f == 1) begin \
         found = True; \
         out = instr; \
      end \
   endcase

`define check_nd(val, n) \
   case (val) matches \
      {.valid, .instr}: if (!illegal && !found && valid && xl == n && misa.d == 1) begin \
         found = True; \
         out = instr; \
      end \
   endcase

`define check_n2d(val, n1, n2) \
   case (val) matches \
      {.valid, .instr}: if (!illegal && !found && valid && (xl == n1 || xl == n2) && misa.d == 1) begin \
         found = True; \
         out = instr; \
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
function Tuple2#(Bool, InstrBits) decode_C_LWSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(8) offset = { i.imm_6_2[1:0], i.imm_12, i.imm_6_2[4:2], 2'b0};

      let is_legal = ((i.op == opcode_C2)
		       && (i.rd_rs1 != 0)
		       && (i.funct3 == f3_C_LWSP));

      let instr = mkInstr_I (zeroExtend (offset),  /*rs1*/reg_sp,  f3_LW,  i.rd_rs1,  op_LOAD);

      return tuple2 (is_legal, instr);
   end
endfunction

`ifdef RV_64_128
// LDSP: expands into LD
function Tuple2#(Bool, InstrBits) decode_C_LDSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(9) offset = { i.imm_6_2[2:0], i.imm_12, i.imm_6_2[4:3], 3'b0 };

      let is_legal = ((i.op == opcode_C2)
		       && (i.rd_rs1 != 0)
		       && (i.funct3 == f3_C_LDSP));

      let instr = mkInstr_I (zeroExtend (offset),  /*rs1*/reg_sp,  f3_LD,  i.rd_rs1,  op_LOAD);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV128
// LQSP: expands into LQ
function Tuple2#(Bool, InstrBits) decode_C_LQSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(10) offset = { i.imm_6_2 [3:0], i.imm_12, i.imm_6_2 [4], 4'b0 };

      let is_legal = ((i.op == opcode_C2)
		       && (i.rd_rs1 != 0)
		       && (i.funct3 == f3_C_LQSP));

      let     instr = mkInstr_I (zeroExtend (offset),  /*rs1*/reg_sp,  f3_LQ,  i.rd_rs1,  op_LOAD);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV_32_F
// FLWSP: expands into FLW
function Tuple2#(Bool, InstrBits) decode_C_FLWSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(8) offset = { i.imm_6_2 [1:0], i.imm_12, i.imm_6_2 [4:2], 2'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_FLWSP;
      let     instr = mkInstr_I (zeroExtend (offset),  /*rs1*/reg_sp,  f3_FLW,  /*rd*/i.rd_rs1,  op_LOAD_FP);
      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV_64_128_D
// FLDSP: expands into FLD
function Tuple2#(Bool, InstrBits) decode_C_FLDSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: I-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(9) offset = { i.imm_6_2[2:0], i.imm_12, i.imm_6_2[4:3], 3'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_FLDSP;

      let     instr = mkInstr_I (zeroExtend (offset),  /*rs1*/reg_sp,  f3_FLD,  i.rd_rs1,  op_LOAD_FP);
      return tuple2 (is_legal, instr);
   end
endfunction
`endif

// ================================================================
// 'C' Extension Stack-Pointer-Based Stores

// SWSP: expands to SW
function Tuple2#(Bool, InstrBits) decode_C_SWSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = parse_instr_C(instr_C, InstrCFmtCSS).ast.CSS;
      Bit#(8) offset = { i.imm_12_7 [1:0], i.imm_12_7 [5:2], 2'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_SWSP;
      let instr = mkInstr_S_type (zeroExtend (offset), i.rs2, /*rs1*/reg_sp, f3_SW, op_STORE);

      return tuple2 (is_legal, instr);
   end
endfunction

`ifdef RV_64_128
// SDSP: expands to SD
function Tuple2#(Bool, InstrBits) decode_C_SDSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = parse_instr_C(instr_C, InstrCFmtCSS).ast.CSS;
      Bit#(9) offset = { i.imm_12_7[2:0], i.imm_12_7[5:3], 3'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_SDSP;

      let instr = mkInstr_S_type (zeroExtend (offset), i.rs2, /*rs1*/reg_sp, f3_SD, op_STORE);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV128
// SQSP: expands to SQ
function Tuple2#(Bool, InstrBits) decode_C_SQSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = parse_instr_C(instr_C, InstrCFmtCSS).ast.CSS;
      Bit#(10) offset = { i.imm_12_7[3:0], i.imm_12_7[5:4], 4'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_SQSP;

      let instr = mkInstr_S_type (zeroExtend (offset), i.rs2, /*rs1*/reg_sp, f3_SQ, op_STORE);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV_32_F
// FSWSP: expands to FSW
function Tuple2#(Bool, InstrBits) decode_C_FSWSP(InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = parse_instr_C(instr_C, InstrCFmtCSS).ast.CSS;
      Bit#(8) offset = { i.imm_12_7 [1:0], i.imm_12_7 [5:2], 2'b0 };

      let is_legal = op == opcode_C2 && funct3 == f3_C_FSWSP;
      let instr = mkInstr_S_type (zeroExtend (offset), i.rs2, /*rs1*/reg_sp, f3_FSW, op_STORE_FP);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV_32_64_D
// FSDSP: expands to FSD
function Tuple2#(Bool, InstrBits) decode_C_FSDSP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CSS-type
      let i = parse_instr_C(instr_C, InstrCFmtCSS).ast.CSS;
      Bit#(9) offset = { i.imm_12_7 [2:0], i.imm_12_7 [5:3], 3'b0 };

      let is_legal = i.op == opcode_C2 && i.funct3 == f3_C_FSDSP;
      let instr = mkInstr_S_type (zeroExtend (offset), i.rs2, /*rs1*/reg_sp, f3_FSD, op_STORE_FP);
      return tuple2 (is_legal, instr);
   end
endfunction
`endif

// ================================================================
// 'C' Extension Register-Based Loads

// C_LW: expands to LW
function Tuple2#(Bool, InstrBits) decode_C_LW (InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = parse_instr_C(instr_C, InstrCFmtCL).ast.CL;
      Bit#(7) offset = { i.imm_6_5 [0], i.imm_12_10, i.imm_6_5 [1], 2'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_LW;

      let instr = mkInstr_I (zeroExtend (offset),  get_creg(i.rs1_C),  
         f3_LW,  get_creg(i.rd_C),  op_LOAD);

      return tuple2 (is_legal, instr);
   end
endfunction

`ifdef RV_64_128
// C_LD: expands to LD
function Tuple2#(Bool, InstrBits) decode_C_LD (InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = parse_instr_C(instr_C, InstrCFmtCL).ast.CL;
      Bit#(8) offset = { i.imm_6_5, i.imm_12_10, 3'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_LD;
      let instr = mkInstr_I (zeroExtend(offset),  get_creg(i.rs1_C), 
          f3_LD,  get_creg(i.rd_C),  op_LOAD);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV128
// C_LQ: expands to LQ
function Tuple2#(Bool, InstrBits) decode_C_LQ (InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = parse_instr_C(instr_C, InstrCFmtCL).ast.CL;
      Bit#(9) offset = { i.imm_12_10 [0], i.imm_6_5, i.imm_12_10 [2], i.imm_12_10 [1], 4'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_LQ;
      let instr = mkInstr_I (zeroExtend(offset),  get_creg(i.rs1_C), 
          f3_LQ,  get_creg(i.rd_C),  op_LOAD);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV_32_F
// C_FLW: expands to FLW
function Tuple2#(Bool, InstrBits) decode_C_FLW(InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = parse_instr_C(instr_C, InstrCFmtCL).ast.CL;
      Bit#(7) offset = { i.imm_6_5[0], i.imm_12_10, i.imm_6_5[1], 2'b0 };

      let is_legal =i.op == opcode_C0 && i.funct3 == f3_C_FLW;
      let instr = mkInstr_I (zeroExtend (offset),  get_creg(i.rs1_C),  
         f3_FLW,  get_creg(i.rd_C),  op_LOAD_FP);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV_32_64_D
// C_FLD: expands to FLD
function Tuple2#(Bool, InstrBits) decode_C_FLD (InstrCBits  instr_C);
   begin
      // InstrBits fields: CL-type
      let i = parse_instr_C(instr_C, InstrCFmtCL).ast.CL;
      Bit#(8) offset = { i.imm_6_5, i.imm_12_10, 3'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_FLD;
      let instr = mkInstr_I (zeroExtend (offset),  get_creg(i.rs1_C),  
         f3_FLD,  get_creg(i.rd_C),  op_LOAD_FP);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

// ================================================================
// 'C' Extension Register-Based Stores

// C_SW: expands to SW
function Tuple2#(Bool, InstrBits) decode_C_SW (InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = parse_instr_C(instr_C, InstrCFmtCS).ast.CS;
      Bit#(7) offset = { i.imm_6_5[0], i.imm_12_10, i.imm_6_5[1], 2'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_SW;
      let instr = mkInstr_S_type (zeroExtend (offset), get_creg(i.rs2_C), 
         get_creg(i.rs1_C), f3_SW, op_STORE);
      
      return tuple2 (is_legal, instr);
   end
endfunction

`ifdef RV_64_128
// C_SD: expands to SD
function Tuple2#(Bool, InstrBits) decode_C_SD (InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = parse_instr_C(instr_C, InstrCFmtCS).ast.CS;
      Bit#(8) offset = { i.imm_6_5, i.imm_12_10, 3'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_SD;
      let instr = mkInstr_S_type (zeroExtend (offset), get_creg(i.rs2_C), 
         get_creg(i.rs1_C), f3_SD, op_STORE);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV128
// C_SQ: expands to SQ
function Tuple2#(Bool, InstrBits) decode_C_SQ (InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = parse_instr_C(instr_C, InstrCFmtCS).ast.CS;
      Bit#(9) offset = { i.imm_12_10[0], i.imm_6_5, i.imm_12_10[2], i.imm_12_10[1], 4'b0 };

      let is_legal = op == opcode_C0 && funct3 == f3_C_SQ;
      let instr = mkInstr_S_type (zeroExtend (offset), get_creg(i.rs2_C), 
         get_creg(i.rs1_C), f3_SQ, op_STORE);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV_32_F
// C_FSW: expands to FSW
function Tuple2#(Bool, InstrBits) decode_C_FSW(InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = parse_instr_C(instr_C, InstrCFmtCS).ast.CS;
      match { .funct3, .i.imm_12_10, .rs1, .i.imm_6_5, .rs2, .op } = fv_ifields_CS_type (instr_C);
      Bit#(7) offset = { i.imm_6_5 [0], i.imm_12_10, i.imm_6_5 [1], 2'b0 };

      Bool is_legal = op == opcode_C0 && funct3 == f3_C_FSW;

      let instr = mkInstr_S_type (zeroExtend (offset), rs2, rs1, f3_FSW, op_STORE_FP);
      
      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV_32_64_F
// C_FSD: expands to FSD
function Tuple2#(Bool, InstrBits) decode_C_FSD(InstrCBits  instr_C);
   begin
      // InstrBits fields: CS-type
      let i = parse_instr_C(instr_C, InstrCFmtCS).ast.CS;
      Bit#(8) offset = { i.imm_6_5, i.imm_12_10, 3'b0 };

      let is_legal = i.op == opcode_C0 && i.funct3 == f3_C_FSD;
      let instr = mkInstr_S_type (zeroExtend (offset), get_creg(i.rs2_C),
         get_creg(i.rs1_C), f3_FSD, op_STORE_FP);
      
      return tuple2 (is_legal, instr);
   end
endfunction
`endif

// ================================================================
// 'C' Extension Control Transfer
// C.J, C.JAL, C.JR, C.JALR, C.BEQZ, C.BNEZ

// C.J: expands to JAL
function Tuple2#(Bool, InstrBits) decode_C_J(InstrCBits  instr_C);
   begin
      // InstrBits fields: CJ-type
      let i = parse_instr_C(instr_C, InstrCFmtCJ).ast.CJ;
      Bit#(12) offset = {
         i.imm_12_2 [10],
         i.imm_12_2 [6],
         i.imm_12_2 [8:7],
         i.imm_12_2 [4],
         i.imm_12_2 [5],
         i.imm_12_2 [0],
         i.imm_12_2 [9],
         i.imm_12_2 [3:1],
      1'b0};

      let is_legal = i.op == opcode_C1 && i.funct3 == f3_C_J;

      Bit#(21) imm21 = signExtend (offset);
      let instr = mkInstr_J_type (imm21, /*rd*/ reg_zero, op_JAL);
      
      return tuple2 (is_legal, instr);
   end
endfunction

`ifdef RV_32
// C.JAL: expands to JAL
function Tuple2#(Bool, InstrBits) decode_C_JAL (InstrCBits  instr_C);
   begin
      // InstrBits fields: CJ-type
      let i = parse_instr_C(instr_C, InstrCFmtCJ).ast.CJ;
      Bit#(12) offset = {
         i.imm_12_2 [10],
         i.imm_12_2 [6],
         i.imm_12_2 [8:7],
         i.imm_12_2 [4],
         i.imm_12_2 [5],
         i.imm_12_2 [0],
         i.imm_12_2 [9],
         i.imm_12_2 [3:1],
         1'b0};

      let is_legal = i.op == opcode_C1 && i.funct3 == f3_C_JAL;
      Bit#(21) imm21 = signExtend (offset);
      let       instr = mkInstr_J_type  (imm21,  /*rd*/ reg_ra,  op_JAL);
      
      return tuple2 (is_legal, instr);
   end
endfunction
`endif

// C.JR: expands to JALR
function Tuple2#(Bool, InstrBits) decode_C_JR (InstrCBits  instr_bits);
   begin
      let i = parse_instr_C(instr_bits, InstrCFmtCR).ast.CR;

      Bool is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_JR)
		       && (i.rd_rs1 != 0)
		       && (i.rs2 == 0));

      return tuple2 (is_legal, mkInstr_I(0, /*rs1*/i.rd_rs1, f3_JALR, reg_zero, op_JALR));
   end
endfunction

// C.JALR: expands to JALR
function Tuple2#(Bool, InstrBits) decode_C_JALR (InstrCBits  instr_bits);
   begin
      let i = parse_instr_C(instr_bits, InstrCFmtCR).ast.CR;

      Bool is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_JALR)
		       && (i.rd_rs1 != 0)
		       && (i.rs2 == 0));

      return tuple2 (is_legal, mkInstr_I(/*imm12*/ 0, /*rs1*/i.rd_rs1, f3_JALR, reg_ra, op_JALR));
   end
endfunction

// C.BEQZ: expands to BEQ
function Tuple2#(Bool, InstrBits) decode_C_BEQZ (InstrCBits  instr_C);
   begin
      // InstrBits fields: CB-type
      let i = parse_instr_C(instr_C, InstrCFmtCB).ast.CB;
      Bit#(9) offset = { i.imm_12_10[2], i.imm_6_2[4:3], i.imm_6_2[0], 
                        i.imm_12_10[1:0], i.imm_6_2[2:1], 1'b0 };
      
      let is_legal = i.op == opcode_C1 && i.funct3 == f3_C_BEQZ;

      Bit#(13) imm13 = signExtend (offset);
      let instr = mkInstr_B_type (imm13, /*rs2*/reg_zero, get_creg(i.rs1_C),
         f3_BEQ, op_BRANCH);

      return tuple2 (is_legal, instr);
   end
endfunction

// C.BNEZ: expands to BNE
function Tuple2#(Bool, InstrBits) decode_C_BNEZ (InstrCBits  instr_C);
   begin
      // InstrBits fields: CB-type
      let i = parse_instr_C(instr_C, InstrCFmtCB).ast.CB;
      Bit#(9) offset = { i.imm_12_10[2], i.imm_6_2[4:3], i.imm_6_2[0], 
         i.imm_12_10[1:0], i.imm_6_2 [2:1], 1'b0 };
      
      let is_legal = i.op == opcode_C1 && i.funct3 == f3_C_BNEZ;

      RegIdx   rs2   = reg_zero;
      Bit#(13) imm13 = signExtend (offset);
      let instr = mkInstr_B_type (imm13, /*rs2*/reg_zero, get_creg(i.rs1_C),
         f3_BNE, op_BRANCH);

      return tuple2 (is_legal, instr);
   end
endfunction

// ================================================================
// 'C' Extension Integer Constant-Generation

// C.LI: expands to ADDI
function Tuple2#(Bool, InstrBits) decode_C_LI (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(6) imm6 = { i.imm_12, i.imm_6_2 };

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_LI)
		       && (i.rd_rs1 != 0));

      Bit#(12) imm12 = signExtend (imm6);
      let       instr = mkInstr_I (imm12, /*rs1*/reg_zero, f3_ADDI, i.rd_rs1, op_OP_IMM);

      return tuple2 (is_legal, instr);
   end
endfunction

// C.LUI: expands to LUI
function Tuple2#(Bool, InstrBits) decode_C_LUI (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(6) nzimm6 = { i.imm_12, i.imm_6_2 };

      Bool is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_LUI)
		       && (i.rd_rs1 != 0)
		       && (i.rd_rs1 != 2)
		       && (nzimm6 != 0));

      Bit#(20) imm20 = signExtend (nzimm6);
      let instr = mkInstr_U_type (imm20, i.rd_rs1, op_LUI);

      return tuple2 (is_legal, instr);
   end
endfunction

// ================================================================
// 'C' Extension Integer Register-Immediate Operations

// C.ADDI: expands to ADDI
function Tuple2#(Bool, InstrBits) decode_C_ADDI (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(6) nzimm6 = { i.imm_12, i.imm_6_2 };

      Bool is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_ADDI)
		       && (i.rd_rs1 != 0)
		       && (nzimm6 != 0));

      Bit#(12) imm12 = signExtend (nzimm6);
      let       instr = mkInstr_I (imm12, /*rs1*/i.rd_rs1, f3_ADDI, /*rd*/i.rd_rs1, op_OP_IMM);

      return tuple2 (is_legal, instr);
   end
endfunction

// C.NOP: expands to ADDI
function Tuple2#(Bool, InstrBits) decode_C_NOP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(6) nzimm6 = { i.imm_12, i.imm_6_2 };

      Bool is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_NOP)
		       && (i.rd_rs1 == 0)
		       && (nzimm6 == 0));

      Bit#(12) imm12 = signExtend (nzimm6);
      let       instr = mkInstr_I (imm12, /*rs1*/i.rd_rs1, f3_ADDI, /*rd*/i.rd_rs1, op_OP_IMM);

      return tuple2 (is_legal, instr);
   end
endfunction

`ifdef RV_64_128
// C.ADDIW: expands to ADDIW
function Tuple2#(Bool, InstrBits) decode_C_ADDIW (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(6) imm6 = { i.imm_12, i.imm_6_2 };

      Bool is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_ADDIW)
		       && (i.rd_rs1 != 0));

      Bit#(12) imm12 = signExtend (imm6);
      let       instr = mkInstr_I (imm12, /*rs1*/ i.rd_rs1, f3_ADDIW, /*rd*/ i.rd_rs1, op_OP_IMM_32);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

// C.ADDI16SP: expands to ADDI
function Tuple2#(Bool, InstrBits) decode_C_ADDI16SP (InstrCBits  instr_C);
   begin
      // InstrBits fields: CI-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(10) nzimm10 = { i.imm_12, i.imm_6_2[2:1], i.imm_6_2[3], i.imm_6_2[0], i.imm_6_2[4], 4'b0 };

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_ADDI16SP)
		       && (i.rd_rs1 == reg_sp)
		       && (nzimm10 != 0));

      Bit#(12) imm12 = signExtend (nzimm10);
      let       instr = mkInstr_I (imm12, i.rd_rs1, f3_ADDI, i.rd_rs1, op_OP_IMM);

      return tuple2 (is_legal, instr);
   end
endfunction

// C.ADDI4SPN: expands to ADDI
function Tuple2#(Bool, InstrBits) decode_C_ADDI4SPN (InstrCBits  instr_C);
   begin
      // InstrBits fields: CIW-type
      let i = parse_instr_C(instr_C, InstrCFmtCIW).ast.CIW;
      Bit#(10) nzimm10 = { i.imm_12_5 [5:2], i.imm_12_5 [7:6], i.imm_12_5 [0], i.imm_12_5 [1], 2'b0 };

      let is_legal = ((i.op == opcode_C0)
		       && (i.funct3 == f3_C_ADDI4SPN)
		       && (nzimm10 != 0));

      Bit#(12) imm12 = zeroExtend (nzimm10);
      let instr = mkInstr_I (imm12, /*rs1*/reg_sp, f3_ADDI, get_creg(i.rd_C), op_OP_IMM);

      return tuple2 (is_legal, instr);
   end
endfunction

// C.SLLI: expands to SLLI
function Tuple2#(Bool, InstrBits) decode_C_SLLI (InstrCBits  instr_C, Bit#(2)  xl);
   begin
      // InstrBits fields: CI-type
      let i = parse_instr_C(instr_C, InstrCFmtCI).ast.CI;
      Bit#(6) shamt6 = { i.imm_12, i.imm_6_2 };

      let is_legal = ((i.op == opcode_C2)
		       && (i.funct3 == f3_C_SLLI)
		       && (i.rd_rs1 != 0)
             && (shamt6 != 0)
		       && ((xl == misa_mxl_32) ? (i.imm_12 == 0) : True));

      Bit#(12) imm12 = (  (xl == misa_mxl_32)
			 ? { msbs7_SLLI, i.imm_6_2 }
			 : { msbs6_SLLI, shamt6 } );
      let instr = mkInstr_I (imm12, i.rd_rs1, f3_SLLI, i.rd_rs1, op_OP_IMM);

      return tuple2 (is_legal, instr);
   end
endfunction

`ifdef RV_32_64
// C.SRLI: expands to SRLI
function Tuple2#(Bool, InstrBits) decode_C_SRLI(InstrCBits  instr_C, Bit#(2)  xl);
   begin
      // InstrBits fields: CB-type
      let i = parse_instr_C(instr_C, InstrCFmtCB).ast.CB;      
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
      let instr = mkInstr_I (imm12, /*rs1*/rd_rs1, f3_SRLI, /*rd*/rd_rs1, op_OP_IMM);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

`ifdef RV_32_64
// C.SRAI: expands to SRAI
function Tuple2#(Bool, InstrBits) decode_C_SRAI (InstrCBits  instr_C, Bit#(2)  xl);
   begin
      // InstrBits fields: CB-type
      let i = parse_instr_C(instr_C, InstrCFmtCB).ast.CB;
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
      let instr = mkInstr_I (imm12, /*rs1*/rd_rs1, f3_SRAI, /*rd*/rd_rs1, op_OP_IMM);

      return tuple2 (is_legal, instr);
   end
endfunction
`endif

// C.ANDI: expands to ANDI
function Tuple2#(Bool, InstrBits) decode_C_ANDI (InstrCBits  instr_C);
   begin
      // InstrBits fields: CB-type
      let i = parse_instr_C(instr_C, InstrCFmtCB).ast.CB;
      Bit#(1) imm6_5 = i.imm_12_10 [2];
      Bit#(6) imm6   = { imm6_5, i.imm_6_2 };
      Bit#(2) funct2 = i.imm_12_10 [1:0];

      Bool is_legal = ((i.op == opcode_C1)
		       && (i.funct3 == f3_C_ANDI)
		       && (funct2 == f2_C_ANDI));

      Bit#(12) imm12 = signExtend (imm6);
      let rd_rs1 = get_creg(i.rs1_C);
      let instr = mkInstr_I (imm12, /*rs1*/ rd_rs1, f3_ANDI, /*rd*/rd_rs1, op_OP_IMM);

      return tuple2 (is_legal, instr);
   end
endfunction

// ================================================================
// 'C' Extension Integer Register-Register Operations

// C.MV: expands to ADD
function Tuple2#(Bool, InstrBits) decode_C_MV (InstrCBits  instr_bits);
   begin
      let i = parse_instr_C(instr_bits, InstrCFmtCR).ast.CR;

      let is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_MV)
		       && (i.rd_rs1 != 0)
		       && (i.rs2 != 0));

      return tuple2 (is_legal, {f7_ADD, i.rs2, reg_zero, f3_ADD, i.rd_rs1, op_OP});
   end
endfunction

// C.ADD: expands to ADD
function Tuple2#(Bool, InstrBits) decode_C_ADD (InstrCBits  instr_bits);
   begin
      let i = parse_instr_C(instr_bits, InstrCFmtCR).ast.CR;

      Bool is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_ADD)
		       && (i.rd_rs1 != 0)
		       && (i.rs2 != 0));

      return tuple2 (is_legal, {f7_ADD, i.rs2, i.rd_rs1, f3_ADD, i.rd_rs1, op_OP});
   end
endfunction

// C.AND: expands to AND
function Tuple2#(Bool, InstrBits) decode_C_AND (InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = parse_instr_C(instr_C, InstrCFmtCA).ast.CA;
      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_AND)
		       && (i.funct2 == f2_C_AND));

      return tuple2 (is_legal, {
         f7_AND, get_creg(i.rs2_C), get_creg(i.rd_rs1_C), f3_AND, 
         get_creg(i.rd_rs1_C), op_OP});
   end
endfunction

// C.OR: expands to OR
function Tuple2#(Bool, InstrBits) decode_C_OR (InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = parse_instr_C(instr_C, InstrCFmtCA).ast.CA;

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_OR)
		       && (i.funct2 == f2_C_OR));

      return tuple2 (is_legal, {
         f7_OR, get_creg(i.rs2_C), get_creg(i.rd_rs1_C), f3_OR, 
         get_creg(i.rd_rs1_C), op_OP});
   end
endfunction

// C.XOR: expands to XOR
function Tuple2#(Bool, InstrBits) decode_C_XOR (InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = parse_instr_C(instr_C, InstrCFmtCA).ast.CA;

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_XOR)
		       && (i.funct2 == f2_C_XOR));

      return tuple2 (is_legal, {
         f7_XOR, get_creg(i.rs2_C), get_creg(i.rd_rs1_C), f3_XOR, 
         get_creg(i.rd_rs1_C), op_OP});
   end
endfunction

// C.SUB: expands to SUB
function Tuple2#(Bool, InstrBits) decode_C_SUB (InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = parse_instr_C(instr_C, InstrCFmtCA).ast.CA;
      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_SUB)
		       && (i.funct2 == f2_C_SUB));

      return tuple2 (is_legal, {
         f7_SUB, get_creg(i.rs2_C), get_creg(i.rd_rs1_C), f3_SUB, 
         get_creg(i.rd_rs1_C), op_OP});
   end
endfunction

`ifdef RV_64_128
function Tuple2#(Bool, InstrBits) decode_C_ADDW(InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = parse_instr_C(instr_C, InstrCFmtCA).ast.CA;

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_ADDW)
		       && (i.funct2 == f2_C_ADDW));

      return tuple2 (is_legal, {
         f7_ADDW, get_creg(i.rs2_C), get_creg(i.rd_rs1_C), f3_ADDW, 
         get_creg(i.rd_rs1_C), op_OP_32});
   end
endfunction
`endif

`ifdef RV_64_128
function Tuple2#(Bool, InstrBits) decode_C_SUBW(InstrCBits  instr_C);
   begin
      // InstrBits fields: CA-type
      let i = parse_instr_C(instr_C, InstrCFmtCA).ast.CA;

      let is_legal = ((i.op == opcode_C1)
		       && (i.funct6 == f6_C_SUBW)
		       && (i.funct2 == f2_C_SUBW));

      return tuple2 (is_legal, {
         f7_SUBW, get_creg(i.rs2_C), get_creg(i.rd_rs1_C), f3_SUBW, 
         get_creg(i.rd_rs1_C), op_OP_32});
   end
endfunction
`endif

// ================================================================
// 'C' Extension EBREAK

// C.EBREAK: expands to EBREAK
function Tuple2#(Bool, InstrBits) decode_C_EBREAK (InstrCBits  instr_bits);
   begin
      let i = parse_instr_C(instr_bits, InstrCFmtCR).ast.CR;

      let is_legal = ((i.op == opcode_C2)
		       && (i.funct4 == f4_C_EBREAK)
		       && (i.rd_rs1 == 0)
		       && (i.rs2 == 0));

      return tuple2 (is_legal, {f12_EBREAK, i.rd_rs1, f3_PRIV,  i.rd_rs1, op_SYSTEM});
   end
endfunction

// ================================================================

endpackage
