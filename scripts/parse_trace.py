#!/usr/bin/env python
from capstone import *

te_op_begin_group     = 1
te_op_end_group       = 2
te_op_incr_pc         = 3
te_op_full_reg        = 4
te_op_incr_reg        = 5
te_op_incr_reg_OR     = 6
te_op_addl_state      = 7
te_op_mem_req         = 8
te_op_mem_rsp         = 9
te_op_hart_reset      = 10
te_op_state_init      = 11
te_op_16b_instr       = 16
te_op_32b_instr       = 17

te_op_addl_state_priv     = 1
te_op_addl_state_paddr    = 2
te_op_addl_state_eaddr    = 3
te_op_addl_state_data8    = 4
te_op_addl_state_data16   = 5
te_op_addl_state_data32   = 6
te_op_addl_state_data64   = 7
te_op_addl_state_mtime    = 8
te_op_addl_state_pc_paddr = 9
te_op_addl_state_pc       = 10


def rv_dis_code(rvdis, instr, pc):
    for i in rvdis.disasm(instr, pc):
        print (f"{i.address:08x} {i.mnemonic.decode()} {i.op_str.decode()}")

def parse_trace(fname, cfg):
    fp = open(fname, 'rb')

    arch = cfg.arch
    if arch == 'rv64':
        rvdis = Cs(CS_ARCH_RISCV, CS_MODE_RISCV64)
    elif arch == 'rv32':
        rvdis = Cs(CS_ARCH_RISCV, CS_MODE_RISCV32)
    else:
        raise

    cur_pc = None
    next_pc = None
    state = 'init'
    while True:
        pack = {}
        byte = fp.read(1)
        if byte is None:
            break
        b = int.from_bytes(byte)
        if state == 'init':
            assert b == te_op_begin_group, b
            state = 'begin_group'
        elif state == 'begin_group':
            if b == te_op_hart_reset:
                state = 'hart_reset'
            elif b == te_op_addl_state:
                state = 'addl_state'
            elif b == te_op_32b_instr:
                state = '32b_instr'
            elif b == te_op_full_reg:
                state = 'full_reg'
            else:
                raise Exception(f'state {b} not recognized')
            
        elif state == 'hart_reset':
            state = 'init'
            assert b == te_op_end_group, b
            
        elif state == 'addl_state':
            addl_s = b

            if addl_s == te_op_addl_state_pc:
                state = 'begin_group'
                if arch == 'rv64':
                    cur_pc = int.from_bytes(fp.read(8), 'little')
                    next_pc = int.from_bytes(fp.read(8), 'little')
                elif arch == 'rv32':
                    cur_pc = int.from_bytes(fp.read(4), 'little')
                    next_pc = int.from_bytes(fp.read(4), 'little')
                else:
                    raise

            else:
                raise Exception(f'addl_state {b} not recognized')

        elif state == '32b_instr':
            state = 'begin_group'
            instr = byte + fp.read(3)
            rv_dis_code(rvdis, instr, cur_pc)

        elif state == 'full_reg':
            reg_num = int.from_bytes(byte + fp.read(1), 'little')
            if reg_num >= 0x1000 and reg_num < 0x1020:
                reg = ('gpr', reg_num - 0x1000)
            else:
                raise
            
            if arch == 'rv64':
                data = int.from_bytes(fp.read(8), 'little')
            else:
                data = int.from_bytes(fp.read(4), 'little')

            print (f"\t x{reg[1]} = 0x{data:x}")

if __name__ == "__main__":
    from argparse import ArgumentParser
    ap = ArgumentParser()
    ap.add_argument('src')
    ap.add_argument('-a', '--arch', choices=('rv64', 'rv32'), default='rv64')
    args = ap.parse_args()
    parse_trace(args.src, args)