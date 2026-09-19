// Ported from pipeline_ref/Snakefile rule `produce_insertion_counts` (lines
// 623-641). Aggregates every sample's unstranded_unnormalized bedgraph line
// count into one summary TSV.
process PRODUCE_INSERTION_COUNTS {

    input:
    path bedgraphs

    output:
    path "2_insertion_summary.tsv", emit: tsv

    script:
    // Original also piped through `sed 's|05_sitescall/||'` to strip that
    // directory prefix from wc -l's filename column - dropped here since
    // Nextflow stages inputs flat in the task work dir, so there's no
    // directory prefix to strip (not a logic change, just no-op removal).
    """
    wc -l *-unstranded_unnormalized.bg | cut -d '.' -f 1 | grep -v total | sed 's/^[ \\t]*//' > 2_insertion_summary.tsv
    """
}
