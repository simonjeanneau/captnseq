// Ported from nfcore_HTTM/modules/flagstat.nf (originally: pipeline/Snakefile rule
// `flagstat`). Input is the markeddup BAM (not the dedup one), matching the Snakefile.
process FLAGSTAT {
    tag "${meta.id}"

    input:
    tuple val(meta), path(bam)

    output:
    path "${meta.id}-flagstat.txt", emit: flagstat

    script:
    """
    samtools flagstat -@ ${task.cpus} ${bam} > ${meta.id}-flagstat.txt
    """
}
