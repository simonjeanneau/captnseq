// Ported from nfcore_HTTM/modules/sam2sites.nf (originally: pipeline/Snakefile rule
// `sam2sites`): the main, deduplicated-reads branch of insertion-site calling - feeds
// intersect/sites2genes/statisti_call (essentiality) and produce_insertion_counts.
// Wraps bin/sam2sites.py (CLI port of pipeline/scripts/sam2sites.py).
process SAM2SITES {
    tag "${meta.id}"

    input:
    tuple val(meta), path(sam)

    output:
    tuple val(meta), path("${meta.id}.bed"), emit: bed
    tuple val(meta), path("${meta.id}-stranded.bg"), emit: stranded
    tuple val(meta), path("${meta.id}-unstranded.bg"), emit: unstranded
    tuple val(meta), path("${meta.id}-stranded_unnormalized.bg"), emit: stranded_unnormalized
    tuple val(meta), path("${meta.id}-unstranded_unnormalized.bg"), emit: unstranded_unnormalized

    script:
    """
    sam2sites.py \
        --sam ${sam} \
        --norm-value ${params.sam2sites_params.norm_value} \
        --read-len-threshold ${params.sam2sites_params.read_len_threshold} \
        --score-threshold ${params.sam2sites_params.score_threshold} \
        --pos-offset-fwd ${params.sam2sites_params.pos_offset_fwd} \
        --pos-offset-rev ${params.sam2sites_params.pos_offset_rev} \
        --bed-output ${meta.id}.bed \
        --normalized-output ${meta.id}-stranded.bg \
        --unstranded-output ${meta.id}-unstranded.bg \
        --unnormalized-output ${meta.id}-stranded_unnormalized.bg \
        --unstranded-unnormalized-output ${meta.id}-unstranded_unnormalized.bg
    """
}
