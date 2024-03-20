#!/usr/bin/env python

def add_def(defs, d):
    defs += [f"-Xcpp '-D {d}'"]
    return d

if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('-a', '--arch', choices=('RV32', 'RV64', 'RV128'), default='RV32')
    ap.add_argument('-e', '--ext', default='I')
    ap.add_argument('--satp', choices=('BARE', 'SV32', 'SV39', 'SV48'), default='BARE')
    ap.add_argument('-D', '--defs', action='append')
    args = ap.parse_args()


    ext = args.ext
    if 'D' in ext:
        assert 'F' in ext

    defs = []
    archs = []

    add_def(defs, f'ARCH={args.arch.lower()}')

    add_def(defs, args.arch)
    if args.arch == 'RV32':
        archs.append(add_def(defs, 'RV_32'))
        archs.append(add_def(defs, 'RV_32_64'))
    elif args.arch == 'RV64':
        archs.append(add_def(defs, 'RV_64'))
        archs.append(add_def(defs, 'RV_32_64'))
        archs.append(add_def(defs, 'RV_64_128'))
    elif args.arch == 'RV128':
        archs.append(add_def(defs, 'RV_128'))
        archs.append(add_def(defs, 'RV_64_128'))

    for e in 'ACDFIM':
        if e in ext or e == 'I':
            for a in archs:
                add_def(defs, f'{a}_{e}')
            add_def(defs, f'ISA_{e}')
    
    add_def(defs, 'ISA_PRIV_M')
    if 'U' in ext:
        add_def(defs, 'ISA_PRIV_S')
    if 'U' in ext:
        add_def(defs, 'ISA_PRIV_U')

    add_def(defs, args.satp)
    add_def(defs, f'SATP_MODE={args.satp.lower()}')

    for i in args.defs:
        add_def(defs, i)

    print (' '.join(defs), end='')
