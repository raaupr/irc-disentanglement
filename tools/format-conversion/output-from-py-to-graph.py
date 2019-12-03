#!/usr/bin/env python3

from __future__ import print_function

import argparse
import logging
import sys

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Convert the output from a run of the python system into content that can be evaluated.')
    args = parser.parse_args()

    done_training = False
    for line in sys.stdin:
        if line.startswith("data/") or line.startswith("../data/"):
            line = line.split('/')[-1].strip()
            #parts = line.split()
            #print('>', parts)
            #print("{}:{}".format(parts[0], ' '.join(parts[1:])))
            print(line)
