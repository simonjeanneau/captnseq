// Ported from pipeline_ref/Snakefile rule `sites2genes` (lines 542-567), a
// Snakemake `script:` rule wrapping pipeline_ref/scripts/sites2genes.py.
// Wraps bin/sites2genes.py (CLI port of that script).
process SITES2GENES {
    tag "${meta.id}"

    input:
    tuple val(meta), path(sample)
    path features

    output:
    tuple val(meta), path("${meta.id}-genes_insertions.tsv"), emit: tsv

    script:
    """
    sites2genes.py \
        --features ${features} \
        --sample ${sample} \
        --length-pc-start ${params.sites2genes_params.length_pc_start} \
        --length-pc-stop ${params.sites2genes_params.length_pc_stop} \
        --output ${meta.id}-genes_insertions.tsv
    """
}
