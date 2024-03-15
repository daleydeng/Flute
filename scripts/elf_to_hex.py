#!/usr/bin/env python
import sys
from pprint import pprint
from elftools.elf.elffile import ELFFile
from elftools.elf.constants import SH_FLAGS

BASE_ADDR = 0x80000000
MIN_MEM_ADDR_256MB = 0x80000000
MAX_MEM_ADDR_256MB = MIN_MEM_ADDR_256MB + 0x10000000

DFLT_SYMS = {
    'start': '_start',
    'exit': 'exit',
    'tohost': 'tohost',
}

def load_elf(fname, syms={}):
    syms = {**DFLT_SYMS, **syms};
    start_sym = syms['start']
    exit_sym = syms['exit']
    tohost_sym = syms['tohost']

    fp = open(fname, 'rb')
    elf = ELFFile(fp)
    bitwidth = elf.elfclass
    assert elf.get_machine_arch() == 'RISC-V'
    assert elf.structs.little_endian
    assert elf.structs.e_type == 'ET_EXEC'

    min_addr = None
    max_addr = None
    pc_start = None
    pc_exit = None
    tohost_addr = None

    out_data = []

    for sec in elf.iter_sections():
        if sec.is_null():
            continue

        if VERBOSE:
            print(f"Section {sec.name:24}: ", end='')
        sh_type = sec.header['sh_type']
        sh_flags = sec.header['sh_flags']
        is_sec_code_data = sh_type in (
            'SHT_PROGBITS',
            'SHT_NOBITS',
            'SHT_INIT_ARRAY',
            'SHT_FINI_ARRAY',
        ) and bool(
            sh_flags & SH_FLAGS.SHF_WRITE
            or sh_flags & SH_FLAGS.SHF_ALLOC
            or sh_flags & SH_FLAGS.SHF_EXECINSTR
        )
        is_sec_symtab = sh_type == 'SHT_SYMTAB'
        if (not is_sec_code_data and not is_sec_symtab):
            if VERBOSE:
                print ("Ignored")
            continue

        data = sec.data()
        if is_sec_code_data:
            sh_addr = sec.header['sh_addr']
            if min_addr is None or sh_addr < min_addr:
                min_addr = sh_addr
            end = sh_addr + len(data) - 1
            if max_addr is None or end > max_addr:
                max_addr = end

            if VERBOSE:
                print(f"addr [0x{sh_addr:08x}, 0x{max_addr+1:08x}) size 0x{len(data):4x}(={len(data)}) bytes")
            out_data.append((sh_addr, data))
        
        elif is_sec_symtab:
            if VERBOSE:
                print (f"searching {start_sym} {exit_sym} {tohost_sym}") 
            for sym in sec.iter_symbols():
                name, addr = sym.name, sym.entry['st_value']
                if name == start_sym:
                    pc_start = addr
                elif name == exit_sym:
                    pc_exit = addr
                elif name == tohost_sym:
                    tohost_addr = addr

    return {
        'range': [min_addr, max_addr],
        'syms': {
            'pc_start': pc_start,
            'pc_exit': pc_exit, 
            'tohost_addr': tohost_addr,
        },
        'data': out_data,
    }

def align(v, div):
    return v // div * div

def write_mem_hex(elf, start_addr):
    end_addr = elf['range'][-1]

    mem_word_size = 32

    a1 = align(start_addr, mem_word_size)
    a2 = align(end_addr + mem_word_size - 1, mem_word_size)

    print(f"@{(a1 - BASE_ADDR)//32:07x}    // raw_mem addr;  byte addr: {a1 - BASE_ADDR:08x}")

    canvas = bytearray(a2 - BASE_ADDR)
    for addr, data in elf['data']:
        off = addr - BASE_ADDR
        canvas[off:off + len(data)] = data

    for addr in range(a1, a2, mem_word_size):
        for j in range(mem_word_size-1, -1, -1):
            print(f"{canvas[addr - BASE_ADDR + j]:02x}",end='')
        print(f"    // raw_mem addr {(addr - BASE_ADDR)//mem_word_size:08x};  byte addr {addr - BASE_ADDR:08x}")

    if addr < MAX_MEM_ADDR_256MB - mem_word_size:
        addr = MAX_MEM_ADDR_256MB - mem_word_size

    print (f"@{(addr - BASE_ADDR)//mem_word_size:07x}    // last raw_mem addr;  byte addr: {addr - BASE_ADDR:08x}")
    for j in range(mem_word_size-1, -1, -1):
        print(f"{0:02x}", end='')
    print(f"    // raw_mem addr {(addr - BASE_ADDR)//mem_word_size:08x};  byte addr {addr - BASE_ADDR:08x}")

if __name__ == "__main__":
    from argparse import ArgumentParser
    parser = ArgumentParser(
        prog='elf_to_hex.py',
        description=f'''
Usage:
    elf_to_hex.py  --help -h
    elf_to_hex.py  <ELF filename>  <mem hex filename>
Reads ELF file and writes a Verilog Hex Memory image file
ELF file should have addresses within this range:
              [0x{MIN_MEM_ADDR_256MB:8x}, 0x{MAX_MEM_ADDR_256MB:8x})
'''
    )
    parser.add_argument('-v', '--verbose', action='store_true')
    parser.add_argument('elf')
    args = parser.parse_args()
    VERBOSE = args.verbose

    elf = load_elf(args.elf)
    write_mem_hex(elf, BASE_ADDR)