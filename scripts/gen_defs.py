#!/usr/bin/env python

if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('-a', '--arch', choices=('RV32', 'RV64', 'RV128'), default='RV64')
    ap.add_argument('-f', '--float', choices=('N', 'F', 'D'))
    args = ap.parse_args()

    defs = []
    defs.append(args.arch)
    if args.arch == 'RV32':
        defs.append('RV_32')
        defs.append('RV_32_64')
    elif args.arch == 'RV64':
        defs.append('RV_64')
        defs.append('RV_32_64')
        defs.append('RV_64_128')
    elif args.arch == 'RV128':
        defs.append('RV_128')
        defs.append('RV_64_128')

    if args.float in 'FD':
        defs += [i+'_F' for i in defs]

    if args.float == 'D':
        defs += [i+'_D' for i in defs]

    print (' '.join(['-D '+i for i in defs]), end='')
