#!/usr/bin/env python
# coding: utf-8
# Ported from nfcore_HTTM/pipeline_ref/scripts/sites2genes.py (originally a
# Snakemake `script:` rule reading the injected `snakemake` object). Logic
# below is byte-identical to the original compute_gene_insertions() - only
# the entrypoint changed, same pattern as bin/sam2sites.py: Nextflow has no
# injected snakemake object, so this uses a plain argparse CLI instead.
#
# 20260213 paramétrisation du trim des région informatives via config file

"""
Usage : python sites2genes.py --features CDS.bed --sample intersect.bed --length-pc-start 0 --length-pc-stop 100 --output genes_insertions.tsv
"""

import argparse
import pandas as pd


def compute_gene_insertions(features_path, sample_path, length_pc_start, length_pc_stop, output_path):
    # Read files
    gene_df = pd.read_csv(
        str(features_path),
        dtype={
            "chr_name": str,
            "start": "Int64",
            "end": "Int64",
            "name": str,
            "score": "Int64",
            "strand": str
        },
        sep="\t",
        header=None,
        names=["chr_name", "start", "end", "name", "score", "strand"],
    )

    intersect_df = pd.read_csv(
        str(sample_path),
        dtype={
            "chr_name_gene": str,
            "start_gene": "Int64",
            "end_gene": "Int64",
            "name_gene": str,
            "score_gene": "Int64",
            "strand_gene": str,
            "chr_name_insertion": str,
            "start_insertion": "Int64",
            "end_insertion": "Int64",
            "score_insertion": "Int64"
        },
        sep="\t",
        header=None,
        usecols=range(10),
        names=["chr_name_gene", "start_gene", "end_gene", "name_gene", "score_gene", "strand_gene", "chr_name_insertion", "start_insertion", "end_insertion", "score_insertion"],
    )

    # filter insertions outside of genes (due to insertion duplication and excluding length_pc_start length_pc_end)
    intersect_df.replace({'strand_gene': {"+": "1", "-": "-1"}}, inplace=True)
    gene_df.replace({'strand': {"+": "1", "-": "-1"}}, inplace=True)

    intersect_df = intersect_df.loc[
        (
            (intersect_df['strand_gene'] == "1") &
            ((intersect_df['start_insertion'] - 5) >= (intersect_df['start_gene'] + ((intersect_df['end_gene'] - intersect_df['start_gene']) * length_pc_start / 100.0))) &
            ((intersect_df['start_insertion'] + 5) <= (intersect_df['end_gene'] - 1 - ((intersect_df['end_gene'] - intersect_df['start_gene']) * (100 - length_pc_stop) / 100.0)))
        )
        |
        (
            (intersect_df['strand_gene'] == "-1") &
            ((intersect_df['start_insertion'] + 5) <= (intersect_df['end_gene'] - 1 - ((intersect_df['end_gene'] - intersect_df['start_gene']) * length_pc_start / 100.0))) &
            ((intersect_df['start_insertion'] - 5) >= (intersect_df['start_gene'] + ((intersect_df['end_gene'] - intersect_df['start_gene']) * (100 - length_pc_stop) / 100.0)))
        )
    ]

    # make columns required for biotradis toolkit (almost, usually no chr_name)
    gene_df["locus_tag"] = gene_df["name"]
    gene_df["gene_name"] = gene_df["name"]
    gene_df["ncrna"] = 0
    gene_df["read_count"] = 0
    gene_df["ins_index"] = 0.0
    gene_df["gene_length"] = gene_df["end"] - gene_df["start"]
    gene_df["ins_count"] = 0
    gene_df["fcn"] = "NA"
    gene_df = gene_df.set_index('name')

    # Compute insertion index and read_count
    # Perform groupby and specify the aggregation dictionary
    intersect_df = intersect_df.groupby('name_gene', sort=False).agg({'score_insertion': ['sum', 'mean', 'count']})
    # This creates a MultiIndex in columns, so you need to flatten these for easier access
    intersect_df.columns = ['_'.join(col).strip() for col in intersect_df.columns.values]
    for index, row in intersect_df.iterrows():
        gene_df.loc[index, "read_count"] = row['score_insertion_sum']
        gene_df.loc[index, "ins_count"] = row['score_insertion_count']
    gene_df["ins_index"] = gene_df["ins_count"] / gene_df["gene_length"]
    gene_df[["chr_name", "locus_tag", "gene_name", "ncrna", "start", "end", "strand", "read_count", "ins_index", "gene_length", "ins_count", "fcn"]].to_csv(
        str(output_path), header=True, index=False, sep="\t"
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--features", required=True)
    parser.add_argument("--sample", required=True)
    parser.add_argument("--length-pc-start", type=float, required=True)
    parser.add_argument("--length-pc-stop", type=float, required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    compute_gene_insertions(
        features_path=args.features,
        sample_path=args.sample,
        length_pc_start=args.length_pc_start,
        length_pc_stop=args.length_pc_stop,
        output_path=args.output,
    )


if __name__ == "__main__":
    main()
