// Ported from nfcore_HTTM/modules/bam2sam.nf (originally: pipeline/Snakefile rule
// `bam2sam`). Converts both the markeddup and dedup BAMs to SAM - both site-calling
// branches downstream (SAM2SITES, SAM2SITES_NOTDEDUP) read a SAM, not a BAM.
process BAM2SAM {
    tag "${meta.id}"

    input:
    tuple val(meta), path(markeddup), path(dedup)

    output:
    tuple val(meta), path("${meta.id}-markeddup.sam"), emit: markeddup
    tuple val(meta), path("${meta.id}-dedup.sam"), emit: dedup

    script:
    """
    samtools view --threads ${task.cpus} -S ${markeddup} -o ${meta.id}-markeddup.sam
    samtools view --threads ${task.cpus} -S ${dedup} -o ${meta.id}-dedup.sam
    """
}
