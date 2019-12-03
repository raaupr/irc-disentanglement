from fire import Fire
import argparse
import sys

def read_data(filenames, is_test=False):
        instances = []
        done = set()
        for filename in filenames:
            name = filename
            for ending in [".annotation.txt", ".ascii.txt", ".raw.txt", ".tok.txt"]:
                if filename.endswith(ending):
                    name = filename[:-len(ending)]
            if name in done:
                continue
            done.add(name)

            links = {}
            for line in open(name + ".annotation.txt"):
                print(f'{name + ".annotation.txt"}:{line.strip()}')

def main(raw_args=None):
    parser = argparse.ArgumentParser(description='Input to file.')
    # Data arguments
    parser.add_argument('train', nargs="+", help="Training files, e.g. train/*annotation.txt")
    args = parser.parse_args(raw_args)

    train = read_data(args.train)

if __name__ == "__main__":
    main(sys.argv[1:])