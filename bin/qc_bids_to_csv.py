# ------------------------------------------------------------------------------
# options
# ------------------------------------------------------------------------------
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--in_dir", help="subject id", required=True, type=str)
parser.add_argument("-o", "--out_dir", help="session/wave/time", required=True, type=str)
parser.add_argument(
    "--overwrite",
    help="flag to overwrite files",
    required=False,
    default=False,
    type=bool,
)
args = parser.parse_args()

# ------------------------------------------------------------------------------
# modules
# ------------------------------------------------------------------------------
import pandas as pd
import os
from glob import glob

# ------------------------------------------------------------------------------
# paths
# ------------------------------------------------------------------------------
in_dir=args.in_dir
out_dir=args.out_dir
in_paths = glob(f"{in_dir}/*.json")

# ------------------------------------------------------------------------------
# check paths
# ------------------------------------------------------------------------------
if len(in_paths) == 0:
    raise Exception(f"no json files found in {in_dir}")

# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
def json_to_csv(in_path, out_path):
    """
    Read json file as pandas dataframe
    """
    if not os.path.exists(in_path):
        raise Exception("file does not exist (in_path: %s)" % in_path)

    if os.path.exists(out_path) and args.overwrite == 0:
        raise Exception(
            "file already exists and overwrite set to 0 (out_path: %s)" % out_path
        )

    out_dir = os.path.dirname(out_path)
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    df = pd.read_json(in_path, orient="index")
    # data wrangling
    df.reset_index(inplace=True)
    df = df.rename(columns={"index": "key", 0: "value"})
    df = df.explode("value")
    df["key_idx"] = df.groupby("key").cumcount() + 1
    df.loc[df["key_idx"] > 1, "key"] = (
        df.loc[df["key_idx"] > 1, "key"]
        + "_"
        + df.loc[df["key_idx"] > 1, "key_idx"].astype(str)
    )
    df = df.drop(["key_idx"], axis=1)
    df = df.transpose()
    df.columns = df.iloc[0]
    df = df.drop(df.index[0])

    # save
    df.to_csv(out_path, index=False)

# ------------------------------------------------------------------------------
# loop
# ------------------------------------------------------------------------------
for in_path in in_paths:
    out_file = os.path.basename(in_path).replace(".json", ".csv")
    out_path = os.path.join(out_dir, out_file)
    try:
        print("in_path: %s" % in_path)
        json_to_csv(in_path, out_path)
    except Exception as e:
        print(e)

