from tqdm import tqdm
import pandas as pd
from collections import defaultdict
from fire import Fire
import pickle
from glob import glob

MAX_DIST=101

def read_data(filenames_pattern, outfile):
    print(filenames_pattern)
    files = glob(filenames_pattern)
    # -- get names of files
    names = set()
    for filename in tqdm(files, desc="Reading"):
        name = filename
        for ending in [".annotation.txt", ".ascii.txt", ".raw.txt", ".tok.txt"]:
            if filename.endswith(ending):
                name = filename[:-len(ending)]
        if name in names:
            continue
        names.add(name)
    names = sorted(names)
    # -- get the pairs
    idx_queries = []
    queries = []
    idx_targets = []
    targets = []
    labels = []
    filenames = []
    for name in tqdm(names):
        tqdm.write(name)
        # -- get annotations
        annotations = defaultdict(list)
        with open(name + ".annotation.txt", 'rt') as fin:
            lines = fin.readlines()
        for line in lines:
            idx_1, idx_2, _ = line.strip().split()
            annotations[int(idx_1)].append(int(idx_2))
        # -- get messages
        with open(name + ".raw.txt", 'rt') as fin:
            lines = fin.readlines()
        count = 0
        for query in sorted(list(annotations.keys())):
            for target in range(query, max(-1, query - MAX_DIST), -1):
                idx_queries.append(int(query))
                queries.append(lines[int(query)])
                idx_targets.append(int(target))
                targets.append(lines[int(target)])
                labels.append(target in annotations[int(query)])
                filenames.append(name + ".annotation.txt")
    df = pd.DataFrame({
        "filename": filenames,
        "idx_query": idx_queries,
        "idx_target": idx_targets,
        "query": queries,
        "target": targets,
        "label": labels
    })
    print(df.head()[["query", "target"]])
    print(df.head()[["filename", "idx_query", "idx_target", "label"]])
    pickle.dump(df, open(outfile, 'wb'))
    print(f"{len(df)} rows saved to {outfile}")


if __name__ == '__main__':
    Fire(read_data)