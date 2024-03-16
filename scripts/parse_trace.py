#!/usr/bin/env python
from capstone import *
from pprint import pprint

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


gpr_mapping = [
    'zero',
    'ra',
    'sp',
    'gp',
    'tp',
    't0',
    't1',
    't2',
    's0',
    's1',
    'a0',
    'a1',
    'a2',
    'a3',
    'a4',
    'a5',
    'a6',
    'a7',
    's2',
    's3',
    's4',
    's5',
    's6',
    's7',
    's8',
    's9',
    's10',
    's11',
    't3',
    't4',
    't5',
    't6'
]

csr_mapping = {
    0x001: 'fflags',
    0x002: 'frm',
    0x003: 'fcsr',

    0x100: 'sstatus',
    0x104: 'sie',
    0x105: 'stvec',
    0x106: 'scounteren',

    0x10a: 'senvcfg',

    0x140: 'sscratch',
    0x141: 'sepc',
    0x142: 'scause',
    0x143: 'stval',
    0x144: 'sip',

    0x180: 'satp',
    0x5a8: 'scontext',

    0x300: 'mstatus',
    0x301: 'misa',
    0x302: 'medeleg',
    0x303: 'mideleg',
    0x304: 'mie',
    0x305: 'mtvec',
    0x306: 'mcounteren',
    0x310: 'mstatush',

    0x340: 'mscratch',
    0x341: 'mepc',
    0x342: 'mcause',
    0x343: 'mtval',
    0x344: 'mip',
    
    0x34a: 'mtinst',
    0x35b: 'mtval2',

    0x3b0: 'pmpaddr0',

    0x7a0: 'tselect',
    0x7a1: 'tdata1',
    0x7a2: 'tdata2',
    0x7a3: 'tdata3',
    0x7a8: 'mcontext',
}

priv_mapping = {
    0: 'U',
    1: 'S',
    3: 'M',
}

def read1(fp):
    byte = fp.read(1)
    if byte is None:
        return
    return int.from_bytes(byte)

rvdis = None

def rv_dis_instr(instr, pc):
    if len(instr) == 2:
        return {
            'addr': pc,
            'size': 2,
            'op_str': '',
            'mnemonic': instr,
    }

    assert len(instr) == 4

    for i in rvdis.disasm(instr, pc):
        return {
            'addr': pc,
            'size': 4,
            'op_str': i.op_str.decode(),
            'mnemonic': i.mnemonic.decode(),
        }
    
def print_packet(p):
    if p['op'] == 'reset':
        print ("RESET")

    elif p['op'] == 'instr':
        dis = p['dis']
        instr = p['instr']
        print (f"{dis['addr']:08x}:\t{dis['mnemonic']} {dis['op_str']}")
        for (reg_type, reg_no), val in p.get('regs', []):
            if reg_type == 'gpr':
                print (f"\t\t{gpr_mapping[reg_no]} = 0x{val:x}")
            elif reg_type == 'fpr':
                print (f"\t\tf{reg_no:02} = 0x{val:x}")
            elif reg_type == 'csr':
                print (f"\t\t{csr_mapping[reg_no]} = 0x{val:x}")
        if 'mem_eaddr' in p:
            eaddr = p['mem_eaddr']
            if 'mem_data' in p:
                print (f"\t\tM[{eaddr:x}] = 0x{p['mem_data']:x}")
            else:
                print (f"\t\tM[{eaddr:x}]")
        if 'priv' in p:
            print (f"\t\tPriv {p['priv']}")

    else:
        raise

def read_addr(fp, arch):
    if arch == 'rv64':
        return int.from_bytes(fp.read(8), 'little')
    elif arch == 'rv32':
        return int.from_bytes(fp.read(4), 'little')
    raise

def parse_trace(fp, cfg):
    arch = cfg.arch
    state = 'end_group'
    pack = {'op': None, 'arch': arch}
    while True:
        if state == 'end_group':
            if pack['op']:
                print_packet(pack)

            if not (b := read1(fp)):
                break
            assert b == te_op_begin_group, b
            state = 'begin_group'
            pack = {'op': None, 'arch': arch}

        elif state == 'begin_group':
            if not (b := read1(fp)):
                break

            if b == te_op_end_group:
                state = 'end_group'
            elif b == te_op_full_reg:
                state = 'full_reg'
            elif b == te_op_addl_state:
                state = 'addl_state'
            elif b == te_op_hart_reset:
                state = 'hart_reset'
            elif b == te_op_state_init:
                raise

            elif b == te_op_16b_instr:
                state = '16b_instr'
            elif b == te_op_32b_instr:
                state = '32b_instr'

            else:
                raise Exception(f'state {b} not recognized')
            
        elif state == 'hart_reset':
            pack['op'] = 'reset'
            state = 'end_group'
            assert read1(fp) == te_op_end_group
            
        elif state == 'addl_state':
            addl_s = read1(fp)

            if addl_s == te_op_addl_state_priv:
                state = 'begin_group'
                pack['priv'] = priv_mapping[read1(fp)]

            elif addl_s == te_op_addl_state_eaddr:
                state = 'begin_group'
                pack['mem_eaddr'] = read_addr(fp, arch)
            elif addl_s == te_op_addl_state_data8:
                state = 'begin_group'
                pack['mem_data'] = int.from_bytes(fp.read(1), 'little')

            elif addl_s == te_op_addl_state_data16:
                state = 'begin_group'
                pack['mem_data'] = int.from_bytes(fp.read(2), 'little')

            elif addl_s == te_op_addl_state_data32:
                state = 'begin_group'
                pack['mem_data'] = int.from_bytes(fp.read(4), 'little')

            elif addl_s == te_op_addl_state_data64:
                state = 'begin_group'
                pack['mem_data'] = int.from_bytes(fp.read(8), 'little')

            elif addl_s == te_op_addl_state_pc:
                state = 'begin_group'
                cur_pc = read_addr(fp, arch)
                next_pc = read_addr(fp, arch)
                pack['pc'] = cur_pc
                pack['next_pc'] = next_pc

            else:
                raise Exception(f'addl_state {addl_s} not recognized')

        elif state == 'full_reg':
            state = 'begin_group'
            reg_num = int.from_bytes(fp.read(2), 'little')
            if reg_num >= 0x1000 and reg_num < 0x1020:
                reg = ('gpr', reg_num - 0x1000)
            elif reg_num < 0x1000:
                reg = ('csr', reg_num)
            elif reg_num >= 0x1020:
                reg = ('fpr', reg_num - 0x1020)
            else:
                print (reg_num)
                raise
            
            if arch == 'rv64':
                val = int.from_bytes(fp.read(8), 'little')
            else:
                val = int.from_bytes(fp.read(4), 'little')

            if 'regs' not in pack:
                pack['regs'] = []
            pack['regs'].append((reg, val))

        elif state == '16b_instr':
            state = 'begin_group'
            instr_bytes = fp.read(2)
            pack.update({
                'op': 'instr',
                'instr': int.from_bytes(instr_bytes, 'little'),
                'dis': rv_dis_instr(instr_bytes, pack['pc']),
            })

        elif state == '32b_instr':
            state = 'begin_group'
            instr_bytes = fp.read(4)
            pack.update({
                'op': 'instr',
                'instr': int.from_bytes(instr_bytes, 'little'),
                'dis': rv_dis_instr(instr_bytes, pack['pc']),
            })

if __name__ == "__main__":
    from argparse import ArgumentParser
    ap = ArgumentParser()
    ap.add_argument('srcs', nargs='+')
    ap.add_argument('-a', '--arch', choices=('rv64', 'rv32'), default='rv64')
    args = ap.parse_args()

    arch = args.arch
    if arch == 'rv64':
        rvdis = Cs(CS_ARCH_RISCV, CS_MODE_RISCV64)
    elif arch == 'rv32':
        rvdis = Cs(CS_ARCH_RISCV, CS_MODE_RISCV32)
    else:
        raise

    for src in args.srcs:
        print (f"parsing {src}")
        with open(src, 'rb') as fp:
            parse_trace(fp, args)