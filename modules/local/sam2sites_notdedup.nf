// Ported from nfcore_HTTM/modules/sam2sites_notdedup.nf (originally: pipeline/Snakefile
// rule `sam2sites_notdedup`): the not-deduplicated sibling of SAM2SITES, run on the
// full markeddup SAM (duplicates still present) rather than the dedup one. Its
// unstranded_unnormalized output is a QC-comparison leaf on its own, not consumed by
// the essentiality/intersect path. Wraps the same bin/sam2sites.py as SAM2SITES.
process SAM2SITES_NOTDEDUP {
    tag "${meta.id}"

    input:
    tuple val(meta), path(sam)

    output:
    tuple val(meta), path("${meta.id}_notdedup.bed"), emit: bed
    tuple val(meta), path("${meta.id}-stranded_notdedup.bg"), emit: stranded
    tuple val(meta), path("${meta.id}-unstranded_notdedup.bg"), emit: unstranded
    tuple val(meta), path("${meta.id}-stranded_unnormalized_notdedup.bg"), emit: stranded_unnormalized
    tuple val(meta), path("${meta.id}-unstranded_unnormalized_notdedup.bg"), emit: unstranded_unnormalized

    script:
    """
    sam2sites.py \
        --sam ${sam} \
        --norm-value ${params.sam2sites_params.norm_value} \
        --read-len-threshold ${params.sam2sites_params.read_len_threshold} \
        --score-threshold ${params.sam2sites_params.score_threshold} \
        --pos-offset-fwd ${params.sam2sites_params.pos_offset_fwd} \
        --pos-offset-rev ${params.sam2sites_params.pos_offset_rev} \
        --bed-output ${meta.id}_notdedup.bed \
        --normalized-output ${meta.id}-stranded_notdedup.bg \
        --unstranded-output ${meta.id}-unstranded_notdedup.bg \
        --unnormalized-output ${meta.id}-stranded_unnormalized_notdedup.bg \
        --unstranded-unnormalized-output ${meta.id}-unstranded_unnormalized_notdedup.bg
    """
}
