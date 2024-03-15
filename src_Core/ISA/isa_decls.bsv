package isa_decls;

`ifdef RV32
typedef 32 XLEN;
`elsif RV64
typedef 64 XLEN;
`endif

typedef TMul#(2, XLEN)  XLEN_2;
typedef TSub#(XLEN, 2)  XLEN_MINUS_2;
Integer xlen = valueOf (XLEN);

typedef enum { RV32, RV64 } RVVersion deriving (Eq, Bits);
RVVersion rv_version = xlen == 32 ? RV32 : RV64;

typedef  8 BitsPerByte;
typedef  Bit#(BitsPerByte) Byte;
Integer  bits_per_byte = valueOf(BitsPerByte);

typedef  XLEN BitsPerWordXL;
typedef  Bit#(BitsPerWordXL)  WordXL;

typedef  TDiv#(BitsPerWordXL, BitsPerByte) BytesPerWordXL;
Integer  bytes_per_wordxl = valueOf(BytesPerWordXL);

typedef  TLog#(BytesPerWordXL)              Bits_per_Byte_in_WordXL;
typedef  Bit#(Bits_per_Byte_in_WordXL)        Byte_in_WordXL;
Integer  bits_per_byte_in_wordxl = valueOf (Bits_per_Byte_in_WordXL);

typedef  Int#(XLEN)  IntXL;     // Signed register data
typedef  WordXL       Addr;

// ================================================================
// FLEN and related constants, for floating point data
// Can have one or two fpu sizes (should they be merged sooner than later ?).

// ISA_D => ISA_F (ISA_D implies ISA_F)
// The combination ISA_D and !ISA_F is not permitted

`ifdef ISA_F

`ifdef ISA_D
typedef 64 FLEN;
Bool has_fpu_32 = False;
Bool has_fpu_64 = True;
`else
typedef 32 FLEN;
Bool has_fpu_32 = True;
Bool has_fpu_64 = False;
`endif // ISA_D

typedef  Bit#(FLEN)  WordFL;    // Floating point data
typedef  TDiv#(FLEN, BitsPerByte) BytesPerWordFL;

`endif // ISA_F

// ================================================================
// Tokens are used for signalling/synchronization, and have no payload
typedef Bit#(0) Token;

// ================================================================
// Instruction fields
// This is used for encoding Tandem Verifier traces
typedef enum {ISIZE16, ISIZE32} ISize deriving (Bits, Eq, FShow);

typedef 32 INST_LEN;
typedef  Bit#(INST_LEN)  InstrBits;
typedef  Bit#(7)   Opcode;
typedef  Bit#(5)   RegIdx;       // 32 registers, 0..31
typedef  Bit#(12)  CSRAddr;

typedef  32         NumRegs;
Integer  num_regs = valueOf(NumRegs);

InstrBits illegal_instr = 32'h0000_0000;

function  Opcode    instr_opcode   (InstrBits x); return x [6:0]; endfunction
function  Bit#(2)   instr_funct2   (InstrBits x); return x [26:25]; endfunction
function  Bit#(3)   instr_funct3   (InstrBits x); return x [14:12]; endfunction
function  Bit#(5)   instr_funct5   (InstrBits x); return x [31:27]; endfunction
function  Bit#(7)   instr_funct7   (InstrBits x); return x [31:25]; endfunction
function  Bit#(10)  instr_funct10  (InstrBits x); return { x [31:25], x [14:12] }; endfunction
function  Bit#(2)   instr_fmt      (InstrBits x); return x [26:25]; endfunction

function  RegIdx    instr_rd       (InstrBits x); return x [11:7]; endfunction
function  RegIdx    instr_rs1      (InstrBits x); return x [19:15]; endfunction
function  RegIdx    instr_rs2      (InstrBits x); return x [24:20]; endfunction
function  RegIdx    instr_rs3      (InstrBits x); return x [31:27]; endfunction
function  CSRAddr    instr_csr      (InstrBits x); return x [31:20]; endfunction
function  Bit#(12)  instr_I_imm12  (InstrBits x); return x [31:20]; endfunction
function  Bit#(12)  instr_S_imm12  (InstrBits x); return { x [31:25], x [11:7] }; endfunction
function  Bit#(20)  instr_U_imm20  (InstrBits x); return x [31:12]; endfunction

function  Bit#(13)  instr_B_imm13 (InstrBits x); 
   return { x [31], x [7], x [30:25], x [11:8], 1'b0 };
endfunction

function  Bit#(21)  instr_J_imm21 (InstrBits x);
   return { x [31], x [19:12], x [20], x [30:21], 1'b0 };
endfunction

// For FENCE decode
function  Bit#(4)   instr_pred (InstrBits x); return x [27:24]; endfunction
function  Bit#(4)   instr_succ (InstrBits x); return x [23:20]; endfunction

// For AMO decode
function  Bit#(2)   instr_aqrl (InstrBits x); return x [26:25]; endfunction

// ----------------
// Decoded instructions
typedef enum {
   InstrFmtIllegal,
   InstrFmtR,
   InstrFmtI
} InstrFmt deriving (Bits, Eq, FShow);

typedef struct {
   InstrFmt fmt;
   union tagged {
      InstrBits Raw;
      struct {
         Bit#(7) funct7;
         Bit#(5) rs2;
         Bit#(5) rs1;
         Bit#(3) funct3;
         Bit#(5) rd;
         Bit#(7) opcode;
      }  R;
      struct {
         Bit#(12) imm12;
         Bit#(5) rs1;
         Bit#(3) funct3;
         Bit#(5) rd;
         Bit#(7) opcode;
      } I;
   } ast;
} Instruction deriving (Bits, FShow);

function Instruction decode_instruction(InstrBits bits);
   return case (bits[6:0])
      'b0110011: Instruction {fmt: InstrFmtR, ast: tagged R(unpack(bits))};
      'b0010011: Instruction {fmt: InstrFmtI, ast: tagged I(unpack(bits))};
      default: Instruction {fmt: InstrFmtIllegal, ast: tagged Raw(bits)};
   endcase;
endfunction


typedef struct {
   Opcode    opcode;

   RegIdx   rd;
   RegIdx   rs1;
   RegIdx   rs2;
   RegIdx   rs3;
   CSRAddr   csr;

   Bit#(3)  funct3;
   Bit#(5)  funct5;
   Bit#(7)  funct7;
   Bit#(10) funct10;

   Bit#(12) imm12_I;
   Bit#(12) imm12_S;
   Bit#(13) imm13_B;
   Bit#(20) imm20_U;
   Bit#(21) imm13_J;

   Bit#(4)  pred;
   Bit#(4)  succ;

   Bit#(2)  aqrl;
   } DecodedInstr
deriving (FShow, Bits);

function DecodedInstr decode_instr (InstrBits instr);
   return DecodedInstr {
      opcode:    instr_opcode   (instr),
      rd:        instr_rd       (instr),
      rs1:       instr_rs1      (instr),
      rs2:       instr_rs2      (instr),
      rs3:       instr_rs3      (instr),
      csr:       instr_csr      (instr),

      funct3:    instr_funct3   (instr),
      funct5:    instr_funct5   (instr),
      funct7:    instr_funct7   (instr),
      funct10:   instr_funct10  (instr),

      imm12_I:   instr_I_imm12  (instr),
      imm12_S:   instr_S_imm12  (instr),
      imm13_B:  instr_B_imm13 (instr),
      imm20_U:   instr_U_imm20  (instr),
      imm13_J:  instr_J_imm21 (instr),

      pred:      instr_pred     (instr),
      succ:      instr_succ     (instr),

      aqrl:      instr_aqrl     (instr)
      };
endfunction

// ================================================================
// Instruction constructors
// Used in 'C' decode to construct equivalent 32-bit instructions

// // R-type
// function InstrBits  mkInstr_R_type (Bit#(7) funct7, RegIdx rs2, RegIdx rs1, Bit#(3) funct3, RegIdx rd, Bit#(7) opcode);
//    let instr = { funct7, rs2, rs1, funct3, rd, opcode };
//    return instr;
// endfunction

// I-type
function InstrBits  mkInstr_I_type (Bit#(12) imm12, RegIdx rs1, Bit#(3) funct3, RegIdx rd, Bit#(7) opcode);
   let instr = { imm12, rs1, funct3, rd, opcode };
   return instr;
endfunction

// S-type

function InstrBits  mkInstr_S_type (Bit#(12) imm12, RegIdx rs2, RegIdx rs1, Bit#(3) funct3, Bit#(7) opcode);
   let instr = { imm12 [11:5], rs2, rs1, funct3, imm12 [4:0], opcode };
   return instr;
endfunction

// B-type
function InstrBits  mkInstr_B_type (Bit#(13) imm13, RegIdx rs2, RegIdx rs1, Bit#(3) funct3, Bit#(7) opcode);
   let instr = { imm13 [12], imm13 [10:5], rs2, rs1, funct3, imm13 [4:1], imm13 [11], opcode };
   return instr;
endfunction

// U-type
function InstrBits  mkInstr_U_type (Bit#(20) imm20, RegIdx rd, Bit#(7) opcode);
   let instr = { imm20, rd, opcode };
   return instr;
endfunction

// J-type
function InstrBits  mkInstr_J_type (Bit#(21) imm21, RegIdx rd, Bit#(7) opcode);
   let instr = { imm21 [20], imm21 [10:1], imm21 [11], imm21 [19:12], rd, opcode };
   return instr;
endfunction

RegIdx x0  =  0;    RegIdx x1  =  1;    RegIdx x2  =  2;    RegIdx x3  =  3;
RegIdx x4  =  4;    RegIdx x5  =  5;    RegIdx x6  =  6;    RegIdx x7  =  7;
RegIdx x8  =  8;    RegIdx x9  =  9;    RegIdx x10 = 10;    RegIdx x11 = 11;
RegIdx x12 = 12;    RegIdx x13 = 13;    RegIdx x14 = 14;    RegIdx x15 = 15;
RegIdx x16 = 16;    RegIdx x17 = 17;    RegIdx x18 = 18;    RegIdx x19 = 19;
RegIdx x20 = 20;    RegIdx x21 = 21;    RegIdx x22 = 22;    RegIdx x23 = 23;
RegIdx x24 = 24;    RegIdx x25 = 25;    RegIdx x26 = 26;    RegIdx x27 = 27;
RegIdx x28 = 28;    RegIdx x29 = 29;    RegIdx x30 = 30;    RegIdx x31 = 31;

// Register names used in calling convention
RegIdx reg_zero =  0;
RegIdx reg_ra   =  1;
RegIdx reg_sp   =  2;
RegIdx reg_gp   =  3;
RegIdx reg_tp   =  4;

RegIdx reg_t0   =  5; RegIdx reg_t1  =  6; RegIdx reg_t2 =  7;
RegIdx reg_fp   =  8;
RegIdx reg_s0   =  8; RegIdx reg_s1  =  9;

RegIdx reg_a0   = 10; RegIdx reg_a1  = 11;
RegIdx reg_v0   = 10; RegIdx reg_v1  = 11;

RegIdx reg_a2   = 12; RegIdx reg_a3  = 13; RegIdx reg_a4 = 14; RegIdx reg_a5 = 15;
RegIdx reg_a6   = 16; RegIdx reg_a7  = 17;

RegIdx reg_s2   = 18; RegIdx reg_s3  = 19; RegIdx reg_s4 = 20; RegIdx reg_s5 = 21;
RegIdx reg_s6   = 22; RegIdx reg_s7  = 23; RegIdx reg_s8 = 24; RegIdx reg_s9 = 25;
RegIdx reg_s10  = 26; RegIdx reg_s11 = 27;

RegIdx reg_t3   = 28; RegIdx reg_t4  = 29; RegIdx reg_t5 = 30; RegIdx reg_t6 = 31;

// ----------------
// Is 'r' a standard register for PC save/restore on call/return?
// This function is used in branch-predictors for managing the return-address stack.

function Bool is_reg_link (RegIdx  r);
   return (r == reg_ra) || (r == reg_t0);
endfunction

// Kinds of memory access (excluding AMOs)
typedef enum { Access_RWX_R, Access_RWX_W, Access_RWX_X } Access_RWX
deriving (Eq, Bits, FShow);

typedef enum {BITS8, BITS16, BITS32, BITS64    // Even in RV32, to allow for Double (floating point)
} MemDataSize
deriving (Eq, Bits, FShow);

typedef Bit#(2) MemReqSize;

MemReqSize f3_SIZE_B = 2'b00;
MemReqSize f3_SIZE_H = 2'b01;
MemReqSize f3_SIZE_W = 2'b10;
MemReqSize f3_SIZE_D = 2'b11;

Opcode op_LOAD = 7'b00_000_11;
Bit#(3) f3_LB  = 3'b000;
Bit#(3) f3_LH  = 3'b001;
Bit#(3) f3_LW  = 3'b010;
Bit#(3) f3_LD  = 3'b011;
Bit#(3) f3_LBU = 3'b100;
Bit#(3) f3_LHU = 3'b101;
Bit#(3) f3_LWU = 3'b110;

Opcode op_STORE = 7'b01_000_11;
Bit#(3) f3_SB  = 3'b000;
Bit#(3) f3_SH  = 3'b001;
Bit#(3) f3_SW  = 3'b010;
Bit#(3) f3_SD  = 3'b011;

Opcode op_MISC_MEM = 7'b00_011_11;
Bit#(3) f3_FENCE   = 3'b000;
Bit#(3) f3_FENCE_I = 3'b001;

typedef struct {
   // Predecessors
   Bool pi;    // IO reads
   Bool po;    // IO writes
   Bool pr;    // Mem reads
   Bool pw;    // Mem writes
   // Successors
   Bool si;
   Bool so;
   Bool sr;
   Bool sw;
 } FenceOrdering
deriving (FShow);

instance Bits#(FenceOrdering, 8);
   function Bit#(8) pack (FenceOrdering fo);
      return {
         pack (fo.pi),
	      pack (fo.po),
	      pack (fo.pr),
	      pack (fo.pw),
	      pack (fo.si),
	      pack (fo.so),
	      pack (fo.sr),
	      pack (fo.sw) };
   endfunction
   function FenceOrdering unpack (Bit#(8) b8);
      return FenceOrdering {
         pi: unpack (b8 [7]),
			po: unpack (b8 [6]),
			pr: unpack (b8 [5]),
		   pw: unpack (b8 [4]),
	      si: unpack (b8 [3]),
        	so: unpack (b8 [2]),
			sr: unpack (b8 [1]),
			sw: unpack (b8 [0]) };
   endfunction
endinstance

function Bit#(4) instr_to_fence_fm (Bit#(32) instr); return instr [31:28]; endfunction

Bit#(4) fence_fm_none = 4'b0000;
Bit#(4) fence_fm_TSO  = 4'b1000;

// ================================================================
// Atomic Memory Operation Instructions

Opcode op_AMO = 7'b01_011_11;

// NOTE: bit [4] for aq, and [3] for rl, are here set to zero
Bit#(3)    f3_AMO_W     = 3'b010;
Bit#(3)    f3_AMO_D     = 3'b011;
Bit#(5)    f5_AMO_LR     = 5'b00010;
Bit#(5)    f5_AMO_SC     = 5'b00011;
Bit#(5)    f5_AMO_ADD    = 5'b00000;
Bit#(5)    f5_AMO_SWAP   = 5'b00001;
Bit#(5)    f5_AMO_XOR    = 5'b00100;
Bit#(5)    f5_AMO_AND    = 5'b01100;
Bit#(5)    f5_AMO_OR     = 5'b01000;
Bit#(5)    f5_AMO_MIN    = 5'b10000;
Bit#(5)    f5_AMO_MAX    = 5'b10100;
Bit#(5)    f5_AMO_MINU   = 5'b11000;
Bit#(5)    f5_AMO_MAXU   = 5'b11100;

function Fmt fshow_f5_AMO_op (Bit#(5) op);
   Fmt fmt = case (op)
		f5_AMO_LR: $format ("LR");
		f5_AMO_SC: $format ("SC");
		f5_AMO_ADD: $format ("ADD");
		f5_AMO_SWAP: $format ("SWAP");
		f5_AMO_XOR: $format ("XOR");
		f5_AMO_AND: $format ("AND");
		f5_AMO_OR: $format ("OR");
		f5_AMO_MIN: $format ("MIN");
		f5_AMO_MAX: $format ("MAX");
		f5_AMO_MINU: $format ("MINU");
		f5_AMO_MAXU: $format ("MAXU");
	     endcase;
   return fmt;
endfunction

Bit#(10) f10_LR_W       = 10'b00010_00_010;
Bit#(10) f10_SC_W       = 10'b00011_00_010;
Bit#(10) f10_AMOADD_W   = 10'b00000_00_010;
Bit#(10) f10_AMOSWAP_W  = 10'b00001_00_010;
Bit#(10) f10_AMOXOR_W   = 10'b00100_00_010;
Bit#(10) f10_AMOAND_W   = 10'b01100_00_010;
Bit#(10) f10_AMOOR_W    = 10'b01000_00_010;
Bit#(10) f10_AMOMIN_W   = 10'b10000_00_010;
Bit#(10) f10_AMOMAX_W   = 10'b10100_00_010;
Bit#(10) f10_AMOMINU_W  = 10'b11000_00_010;
Bit#(10) f10_AMOMAXU_W  = 10'b11100_00_010;

Bit#(10) f10_LR_D       = 10'b00010_00_011;
Bit#(10) f10_SC_D       = 10'b00011_00_011;
Bit#(10) f10_AMOADD_D   = 10'b00000_00_011;
Bit#(10) f10_AMOSWAP_D  = 10'b00001_00_011;
Bit#(10) f10_AMOXOR_D   = 10'b00100_00_011;
Bit#(10) f10_AMOAND_D   = 10'b01100_00_011;
Bit#(10) f10_AMOOR_D    = 10'b01000_00_011;
Bit#(10) f10_AMOMIN_D   = 10'b10000_00_011;
Bit#(10) f10_AMOMAX_D   = 10'b10100_00_011;
Bit#(10) f10_AMOMINU_D  = 10'b11000_00_011;
Bit#(10) f10_AMOMAXU_D  = 10'b11100_00_011;

// ================================================================
// Integer Register-Immediate Instructions

Opcode op_OP_IMM = 7'b00_100_11;

Bit#(3) f3_ADDI  = 3'b000;
Bit#(3) f3_SLLI  = 3'b001;
Bit#(3) f3_SLTI  = 3'b010;
Bit#(3) f3_SLTIU = 3'b011;
Bit#(3) f3_XORI  = 3'b100;
Bit#(3) f3_SRxI  = 3'b101; Bit#(3) f3_SRLI  = 3'b101; Bit#(3) f3_SRAI  = 3'b101;
Bit#(3) f3_ORI   = 3'b110;
Bit#(3) f3_ANDI  = 3'b111;

// ================================================================
// Integer Register-Immediate 32b Instructions for RV64

Opcode op_OP_IMM_32 = 7'b00_110_11;

Bit#(3) f3_ADDIW = 3'b000;
Bit#(3) f3_SLLIW = 3'b001;
Bit#(3) f3_SRxIW = 3'b101; Bit#(3) f3_SRLIW = 3'b101; Bit#(3) f3_SRAIW = 3'b101;

// OP_IMM.SLLI/SRLI/SRAI for RV32
Bit#(7)  msbs7_SLLI = 7'b_000_0000;
Bit#(7)  msbs7_SRLI = 7'b_000_0000;
Bit#(7)  msbs7_SRAI = 7'b_010_0000;

// OP_IMM.SLLI/SRLI/SRAI for RV64
Bit#(6)  msbs6_SLLI = 6'b_00_0000;
Bit#(6)  msbs6_SRLI = 6'b_00_0000;
Bit#(6)  msbs6_SRAI = 6'b_01_0000;

// ================================================================
// Integer Register-Register Instructions

Opcode op_OP = 7'b0110011;

Bit#(7) f7_ADD  = 7'b_000_0000;
Bit#(7) f7_SUB  = 7'b_010_0000;   
Bit#(7) f7_XOR  = 7'b_000_0000;    
Bit#(7) f7_OR   = 7'b_000_0000;    
Bit#(7) f7_AND  = 7'b_000_0000;
Bit#(7) f7_SLT = 7'b_000_0000; 
Bit#(7) f7_SLTU = 7'b_000_0000;

Bit#(3) f3_ADD = 3'b_000;
Bit#(3) f3_SUB = 3'b_000;
Bit#(3) f3_XOR = 3'b_100;
Bit#(3) f3_OR  = 3'b_110;
Bit#(3) f3_AND = 3'b_111;
Bit#(3) f3_SLT = 3'b_010;
Bit#(3) f3_SLTU =3'b_011;

// ----------------
// MUL/DIV/REM family

Bit#(7) f7_MUL_DIV_REM = 7'b000_0001;

function Bool f7_is_OP_MUL_DIV_REM (Bit#(7) f7);
   return (f7 == f7_MUL_DIV_REM);
endfunction

Bit#(3) f3_MUL    = 3'b000;
Bit#(3) f3_MULH   = 3'b001;
Bit#(3) f3_MULHSU = 3'b010;
Bit#(3) f3_MULHU  = 3'b011;
Bit#(3) f3_DIV    = 3'b100;
Bit#(3) f3_DIVU   = 3'b101;
Bit#(3) f3_REM    = 3'b110;
Bit#(3) f3_REMU   = 3'b111;

Bit#(10) f10_MUL    = 10'b000_0001_000;
Bit#(10) f10_MULH   = 10'b000_0001_001;
Bit#(10) f10_MULHSU = 10'b000_0001_010;
Bit#(10) f10_MULHU  = 10'b000_0001_011;
Bit#(10) f10_DIV    = 10'b000_0001_100;
Bit#(10) f10_DIVU   = 10'b000_0001_101;
Bit#(10) f10_REM    = 10'b000_0001_110;
Bit#(10) f10_REMU   = 10'b000_0001_111;

// ================================================================
// Integer Register-Register 32b Instructions for RV64

Opcode op_OP_32 = 7'b01_110_11;

Bit#(10) f10_ADDW   = 10'b000_0000_000;
Bit#(10) f10_SUBW   = 10'b010_0000_000;
Bit#(10) f10_SLLW   = 10'b000_0000_001;
Bit#(10) f10_SRLW   = 10'b000_0000_101;
Bit#(10) f10_SRAW   = 10'b010_0000_101;

Bit#(7) funct7_ADDW = 7'b_000_0000;    Bit#(3) funct3_ADDW  = 3'b_000;
Bit#(7) funct7_SUBW = 7'b_010_0000;    Bit#(3) funct3_SUBW  = 3'b_000;

Bit#(10) f10_MULW   = 10'b000_0001_000;
Bit#(10) f10_DIVW   = 10'b000_0001_100;
Bit#(10) f10_DIVUW  = 10'b000_0001_101;
Bit#(10) f10_REMW   = 10'b000_0001_110;
Bit#(10) f10_REMUW  = 10'b000_0001_111;

function Bool is_OP_32_MUL_DIV_REM (Bit#(10) f10);
   return ((f10 == f10_MULW)
	   || (f10 == f10_DIVW)
	   || (f10 == f10_DIVUW)
	   || (f10 == f10_REMW)
	   || (f10 == f10_REMUW));
endfunction

// ================================================================
// LUI, AUIPC

Opcode op_LUI   = 7'b01_101_11;
Opcode op_AUIPC = 7'b00_101_11;

// ================================================================
// Control transfer

Opcode  op_BRANCH = 7'b11_000_11;

Bit#(3) f3_BEQ   = 3'b000;
Bit#(3) f3_BNE   = 3'b001;
Bit#(3) f3_BLT   = 3'b100;
Bit#(3) f3_BGE   = 3'b101;
Bit#(3) f3_BLTU  = 3'b110;
Bit#(3) f3_BGEU  = 3'b111;

Opcode op_JAL  = 7'b11_011_11;

Opcode op_JALR = 7'b11_001_11;
Bit#(3) funct3_JALR = 3'b000;

`ifdef ISA_F
// ================================================================
// Floating Point Instructions

// ----------------------------------------------------------------
// TODO: the following are FPU implementation choices; shouldn't be in isa_decls
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

Bit#(7) f7_FSGNJ_S     = 7'h10;                                    Bit#(3) funct3_FSGNJ_S  = 3'b000;
Bit#(7) f7_FSGNJN_S    = 7'h10;                                    Bit#(3) funct3_FSGNJN_S = 3'b001;
Bit#(7) f7_FSGNJX_S    = 7'h10;                                    Bit#(3) funct3_FSGNJX_S = 3'b010;

Bit#(7) f7_FMIN_S      = 7'h14;                                    Bit#(3) funct3_FMIN_S   = 3'b000;
Bit#(7) f7_FMAX_S      = 7'h14;                                    Bit#(3) funct3_FMAX_S   = 3'b001;

Bit#(7) f7_FCVT_W_S    = 7'h60; Bit#(5) rs2_FCVT_W_S  = 5'b00000;
Bit#(7) f7_FCVT_WU_S   = 7'h60; Bit#(5) rs2_FCVT_WU_S = 5'b00001;
Bit#(7) f7_FMV_X_W     = 7'h70; Bit#(5) rs2_FMV_X_W   = 5'b00000; Bit#(3) funct3_FMV_X_W  = 3'b000;

Bit#(7) f7_FCMP_S      = 7'h50;
Bit#(7) f7_FEQ_S       = 7'h50;                                    Bit#(3) funct3_FEQ_S    = 3'b010;
Bit#(7) f7_FLT_S       = 7'h50;                                    Bit#(3) funct3_FLT_S    = 3'b001;
Bit#(7) f7_FLE_S       = 7'h50;                                    Bit#(3) funct3_FLE_S    = 3'b000;

Bit#(7) f7_FCLASS_S    = 7'h70; Bit#(5) rs2_FCLASS_S  = 5'b00000; Bit#(3) funct3_FCLASS_S = 3'b001;
Bit#(7) f7_FCVT_S_W    = 7'h68; Bit#(5) rs2_FCVT_S_W  = 5'b00000;
Bit#(7) f7_FCVT_S_WU   = 7'h68; Bit#(5) rs2_FCVT_S_WU = 5'b00001;
Bit#(7) f7_FMV_W_X     = 7'h78; Bit#(5) rs2_FMV_W_X   = 5'b00000; Bit#(3) funct3_FMV_W_X  = 3'b000;

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

Bit#(7) f7_FSGNJ_D     = 7'h11;                                    Bit#(3) funct3_FSGNJ_D  = 3'b000;
Bit#(7) f7_FSGNJN_D    = 7'h11;                                    Bit#(3) funct3_FSGNJN_D = 3'b001;
Bit#(7) f7_FSGNJX_D    = 7'h11;                                    Bit#(3) funct3_FSGNJX_D = 3'b010;

Bit#(7) f7_FMIN_D      = 7'h15;                                    Bit#(3) funct3_FMIN_D   = 3'b000;
Bit#(7) f7_FMAX_D      = 7'h15;                                    Bit#(3) funct3_FMAX_D   = 3'b001;

Bit#(7) f7_FCVT_S_D    = 7'h20; Bit#(5) rs2_FCVT_S_D = 5'b00001;
Bit#(7) f7_FCVT_D_S    = 7'h21; Bit#(5) rs2_FCVT_D_S = 5'b00000;

Bit#(7) f7_FCMP_D      = 7'h51;
Bit#(7) f7_FEQ_D       = 7'h51;                                    Bit#(3) funct3_FEQ_D    = 3'b010;
Bit#(7) f7_FLT_D       = 7'h51;                                    Bit#(3) funct3_FLT_D    = 3'b001;
Bit#(7) f7_FLE_D       = 7'h51;                                    Bit#(3) funct3_FLE_D    = 3'b000;

Bit#(7) f7_FCLASS_D    = 7'h71; Bit#(5) rs2_FCLASS_D  = 5'b00000; Bit#(3) funct3_FCLASS_D = 3'b001;
Bit#(7) f7_FCVT_W_D    = 7'h61; Bit#(5) rs2_FCVT_W_D  = 5'b00000;
Bit#(7) f7_FCVT_WU_D   = 7'h61; Bit#(5) rs2_FCVT_WU_D = 5'b00001;
Bit#(7) f7_FCVT_D_W    = 7'h69; Bit#(5) rs2_FCVT_D_W  = 5'b00000;
Bit#(7) f7_FCVT_D_WU   = 7'h69; Bit#(5) rs2_FCVT_D_WU = 5'b00001;

// ----------------
// RV64D

Bit#(7) f7_FCVT_L_D    = 7'h61; Bit#(5) rs2_FCVT_L_D  = 5'b00010;
Bit#(7) f7_FCVT_LU_D   = 7'h61; Bit#(5) rs2_FCVT_LU_D = 5'b00011;
Bit#(7) f7_FMV_X_D     = 7'h71; Bit#(5) rs2_FMV_X_D   = 5'b00000; Bit#(3) funct3_FMV_X_D = 3'b000;
Bit#(7) f7_FCVT_D_L    = 7'h69; Bit#(5) rs2_FCVT_D_L  = 5'b00010;
Bit#(7) f7_FCVT_D_LU   = 7'h69; Bit#(5) rs2_FCVT_D_LU = 5'b00011;
Bit#(7) f7_FMV_D_X     = 7'h79; Bit#(5) rs2_FMV_D_X   = 5'b00000; Bit#(3) funct3_FMV_D_X = 3'b000;

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
	  || ((funct7== f7_FSGNJ_S)                              && (rm == funct3_FSGNJ_S))
	  || ((funct7== f7_FSGNJN_S)                             && (rm == funct3_FSGNJN_S))
	  || ((funct7== f7_FSGNJX_S)                             && (rm == funct3_FSGNJX_S))
	  || ((funct7== f7_FMIN_S)                               && (rm == funct3_FMIN_S))
	  || ((funct7== f7_FMAX_S)                               && (rm == funct3_FMAX_S))
	  || ((funct7== f7_FCVT_W_S)  && (rs2 == rs2_FCVT_W_S))
	  || ((funct7== f7_FCVT_WU_S) && (rs2 == rs2_FCVT_WU_S))
	  || ((funct7== f7_FMV_X_W)   && (rs2 == rs2_FMV_X_W)    && (rm == funct3_FMV_X_W))
	  || ((funct7== f7_FEQ_S)     &&                            (rm == funct3_FEQ_S))
	  || ((funct7== f7_FLT_S)     &&                            (rm == funct3_FLT_S))
	  || ((funct7== f7_FLE_S)     &&                            (rm == funct3_FLE_S))
	  || ((funct7== f7_FCLASS_S)  && (rs2 == rs2_FCLASS_S)   && (rm == funct3_FCLASS_S))
	  || ((funct7== f7_FCVT_S_W)  && (rs2 == rs2_FCVT_S_W))
	  || ((funct7== f7_FCVT_S_WU) && (rs2 == rs2_FCVT_S_WU))
	  || ((funct7== f7_FMV_W_X)   && (rs2 == rs2_FMV_W_X)    && (rm == funct3_FMV_W_X))
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
	  || ((funct7== f7_FSGNJ_D)                              && (rm == funct3_FSGNJ_D))
	  || ((funct7== f7_FSGNJN_D)                             && (rm == funct3_FSGNJN_D))
	  || ((funct7== f7_FSGNJX_D)                             && (rm == funct3_FSGNJX_D))
	  || ((funct7== f7_FMIN_D)                               && (rm == funct3_FMIN_D))
	  || ((funct7== f7_FMAX_D)                               && (rm == funct3_FMAX_D))
	  || ((funct7== f7_FCVT_S_D)  && (rs2 == rs2_FCVT_S_D))
	  || ((funct7== f7_FCVT_D_S)  && (rs2 == rs2_FCVT_D_S))
	  || ((funct7== f7_FEQ_D)                                && (rm == funct3_FEQ_D))
	  || ((funct7== f7_FLT_D)                                && (rm == funct3_FLT_D))
	  || ((funct7== f7_FLE_D)                                && (rm == funct3_FLE_D))
	  || ((funct7== f7_FCLASS_D)  && (rs2 == rs2_FCLASS_D))  && (rm == funct3_FCLASS_D)
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
	  || ((funct7== f7_FMV_X_D)   && (rs2 == rs2_FMV_X_D))   && (rm == funct3_FMV_X_D)
	  || ((funct7== f7_FCVT_D_L)  && (rs2 == rs2_FCVT_D_L))
	  || ((funct7== f7_FCVT_D_LU) && (rs2 == rs2_FCVT_D_LU))
	  || ((funct7== f7_FMV_D_X)   && (rs2 == rs2_FMV_D_X))   && (rm == funct3_FMV_D_X)
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

// ================================================================
// System Instructions
Opcode op_SYSTEM = 7'b11_100_11;

// sub-opcodes: (in funct3 field)
Bit#(3)   f3_PRIV           = 3'b000;
Bit#(3)   f3_CSRRW          = 3'b001;
Bit#(3)   f3_CSRRS          = 3'b010;
Bit#(3)   f3_CSRRC          = 3'b011;
Bit#(3)   f3_SYSTEM_ILLEGAL = 3'b100;
Bit#(3)   f3_CSRRWI         = 3'b101;
Bit#(3)   f3_CSRRSI         = 3'b110;
Bit#(3)   f3_CSRRCI         = 3'b111;

// sub-sub-opcodes for f3_PRIV

Bit#(12) f12_ECALL     = 12'b_0000_0000_0000;
Bit#(12) f12_EBREAK    = 12'b_0000_0000_0001;

Bit#(12) f12_URET      = 12'b_0000_0000_0010;
Bit#(12) f12_SRET      = 12'b_0001_0000_0010;
Bit#(12) f12_HRET      = 12'b_0010_0000_0010;
Bit#(12) f12_MRET      = 12'b_0011_0000_0010;
Bit#(12) f12_WFI       = 12'b_0001_0000_0101;

// v1.10 sub-sub-opcode for SFENCE_VMA
Bit#(7)  f7_SFENCE_VMA = 7'b_0001_001;

InstrBits break_instr = { f12_EBREAK, 5'b00000, 3'b000, 5'b00000, op_SYSTEM };

function Bool is_instr_csrrx (InstrBits  instr);
   let decoded_instr = decode_instr (instr);
   let opcode        = decoded_instr.opcode;
   let funct3        = decoded_instr.funct3;
   let csr           = decoded_instr.csr;
   return ((opcode == op_SYSTEM) && f3_is_CSRR_any (funct3));
endfunction

function Bool f3_is_CSRR_any (Bit#(3) f3);
   return (f3_is_CSRR_W (f3) || f3_is_CSRR_S_or_C (f3));
endfunction

function Bool f3_is_CSRR_W (Bit#(3) f3);
   return ((f3 == f3_CSRRW) || (f3 == f3_CSRRWI));
endfunction

function Bool f3_is_CSRR_S_or_C (Bit#(3) f3);
   return ((f3 == f3_CSRRS) || (f3 == f3_CSRRSI) ||
	   (f3 == f3_CSRRC) || (f3 == f3_CSRRCI));
endfunction

// ================================================================
// Privilege Modes

typedef 4 NumPrivModes;

typedef Bit#(2) PrivMode;

PrivMode         u_Priv_Mode = 2'b00;
PrivMode         s_Priv_Mode = 2'b01;
PrivMode  reserved_Priv_Mode = 2'b10;
PrivMode         m_Priv_Mode = 2'b11;

function Fmt fshow_Priv_Mode (PrivMode pm);
   return case (pm)
	     u_Priv_Mode: $format ("U");
	     s_Priv_Mode: $format ("S");
	     m_Priv_Mode: $format ("M");
	     default: $format ("RESERVED");
	  endcase;
endfunction

// ================================================================
// Control/Status registers

function Bool fn_csr_addr_can_write (CSRAddr csr_addr);
   return (csr_addr [11:10] != 2'b11);
endfunction

function Bool fn_csr_addr_priv_ok (CSRAddr csr_addr, PrivMode priv_mode);
   return (priv_mode >= csr_addr [9:8]);
endfunction

// ----------------
// User-level CSR addresses

CSRAddr   csr_addr_ustatus        = 12'h000;    // User status
CSRAddr   csr_addr_uie            = 12'h004;    // User interrupt-enable
CSRAddr   csr_addr_utvec          = 12'h005;    // User trap handler base address

CSRAddr   csr_addr_uscratch       = 12'h040;    // Scratch register for trap handlers
CSRAddr   csr_addr_uepc           = 12'h041;    // User exception program counter
CSRAddr   csr_addr_ucause         = 12'h042;    // User trap cause
CSRAddr   csr_addr_utval          = 12'h043;    // User bad address or instruction
CSRAddr   csr_addr_uip            = 12'h044;    // User interrupt pending

CSRAddr   csr_addr_fflags         = 12'h001;    // Floating-point accrued exceptions
CSRAddr   csr_addr_frm            = 12'h002;    // Floating-point Dynamic Rounding Mode
CSRAddr   csr_addr_fcsr           = 12'h003;    // Floating-point Control and Status Register (frm + fflags)

CSRAddr   csr_addr_cycle          = 12'hC00;    // Cycle counter for RDCYCLE
CSRAddr   csr_addr_time           = 12'hC01;    // Timer for RDTIME
CSRAddr   csr_addr_instret        = 12'hC02;    // Instructions retired counter for RDINSTRET

CSRAddr   csr_addr_hpmcounter3    = 12'hC03;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter4    = 12'hC04;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter5    = 12'hC05;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter6    = 12'hC06;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter7    = 12'hC07;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter8    = 12'hC08;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter9    = 12'hC09;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter10   = 12'hC0A;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter11   = 12'hC0B;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter12   = 12'hC0C;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter13   = 12'hC0D;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter14   = 12'hC0E;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter15   = 12'hC0F;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter16   = 12'hC10;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter17   = 12'hC11;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter18   = 12'hC12;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter19   = 12'hC13;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter20   = 12'hC14;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter21   = 12'hC15;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter22   = 12'hC16;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter23   = 12'hC17;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter24   = 12'hC18;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter25   = 12'hC19;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter26   = 12'hC1A;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter27   = 12'hC1B;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter28   = 12'hC1C;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter29   = 12'hC1D;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter30   = 12'hC1E;    // Performance-monitoring counter
CSRAddr   csr_addr_hpmcounter31   = 12'hC1F;    // Performance-monitoring counter

CSRAddr   csr_addr_cycleh         = 12'hC80;    // Upper 32 bits of csr_cycle (RV32I only)
CSRAddr   csr_addr_timeh          = 12'hC81;    // Upper 32 bits of csr_time (RV32I only)
CSRAddr   csr_addr_instreth       = 12'hC82;    // Upper 32 bits of csr_instret (RV32I only)

CSRAddr   csr_addr_hpmcounter3h   = 12'hC83;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter4h   = 12'hC84;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter5h   = 12'hC85;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter6h   = 12'hC86;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter7h   = 12'hC87;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter8h   = 12'hC88;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter9h   = 12'hC89;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter10h  = 12'hC8A;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter11h  = 12'hC8B;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter12h  = 12'hC8C;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter13h  = 12'hC8D;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter14h  = 12'hC8E;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter15h  = 12'hC8F;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter16h  = 12'hC90;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter17h  = 12'hC91;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter18h  = 12'hC92;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter19h  = 12'hC93;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter20h  = 12'hC94;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter21h  = 12'hC95;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter22h  = 12'hC96;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter23h  = 12'hC97;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter24h  = 12'hC98;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter25h  = 12'hC99;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter26h  = 12'hC9A;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter27h  = 12'hC9B;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter28h  = 12'hC9C;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter29h  = 12'hC9D;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter30h  = 12'hC9E;    // Upper 32 bits of performance-monitoring counter
CSRAddr   csr_addr_hpmcounter31h  = 12'hC9F;    // Upper 32 bits of performance-monitoring counter

// Information from the CSR on a new trap. 
typedef struct {
   Addr        pc;
   WordXL      mstatus;
   WordXL      mcause;
   PrivMode   priv;
} Trap_Info deriving (Bits, Eq, FShow);

`include "isa_decls_cext.bsvi"
`include "isa_decls_priv_supervisor.bsvi"
`include "isa_decls_priv_machine.bsvi"

`ifdef INCLUDE_PC_TRACE
typedef struct {
   Bit#(64)  cycle;
   Bit#(64)  instret;
   Bit#(64)  pc;
} PC_Trace deriving (Bits, FShow);
`endif

endpackage
