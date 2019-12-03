#!/usr/bin/env python3

from __future__ import print_function

import argparse
import sys

def get_pairs(filename, storage):
    for line in open(filename):
        line = line.strip()
        if ':' in line:
            filename = line.split(':')[0].split('/')[-1]
            line = line.split(":")[1]
        else:
            filename = filename.split('/')[-1]

        nums = [int(n) for n in line.split() if n != '-']
        source = max(nums)
        nums.remove(source)
        if len(nums) == 0 or (nums[0] == source and len(nums) == 1):
            storage.setdefault(filename, set()).add((source, source))
        else:
            for num in nums:
                storage.setdefault(filename, set()).add((source, num))

def print_results(name, total_gold, total_auto, matched):
    p = 0.0
    if total_auto > 0:
        p = 100 * matched / total_auto
    r = 0.0
    if total_gold > 0:
        r = 100 * matched / total_gold
    f = 0.0
    if matched > 0:
        f = 2 * p * r / (p + r)
    print("g/a/m{}:".format(name), total_gold, total_auto, matched)
    print("p/r/f{}: {:.3} {:.3} {:.3}".format(name, p, r, f))
    return p,r,f

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Evaluate conversation graph output.')
    parser.add_argument('--gold', help='Files containing annotations', nargs="+", required=True)
    parser.add_argument('--auto', help='Files containing system output', nargs="+", required=True)
    args = parser.parse_args()

    assert args.gold is not None and args.auto is not None

    # Read
    gold = {}
    for filename in args.gold:
        get_pairs(filename, gold)

    auto = {}
    for filename in args.auto:
        get_pairs(filename, auto)

    # Calculate
    total_gold = 0
    for filename in gold:
        total_gold += len(gold[filename])

    total_auto = 0
    for filename in auto:
        total_auto += len(auto[filename])

    matched = 0
    for filename in gold:
        if filename in auto:
            for pair in gold[filename]:
                if pair in auto[filename]:
                    matched += 1

    auto_srcs = set()
    for filename in auto:
        for pair in auto[filename]:
            auto_srcs.add((filename, pair[0]))                   

    with open('graph-eval.log', 'wt') as fout:
        for filename in gold:
            if filename in auto:
                for pair in gold[filename]:
                    if pair in auto[filename]:
                        fout.write(f'{filename}:{pair[0]} {pair[1]} - match\n')
                    elif (filename, pair[0]) not in auto_srcs:
                        fout.write(f'{filename}:{pair[0]} {pair[1]} - not found\n')
                    else:
                        fout.write(f"{filename}:{pair[0]} {pair[1]} - doesn't match\n")

    print_results("", total_gold, total_auto, matched)