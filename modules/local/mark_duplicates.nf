// Ported from nfcore_HTTM/modules/mark_duplicates.nf (originally: pipeline/Snakefile
// rule `mark_duplicates`).
process MARK_DUPLICATES {
    tag "${meta.id}"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}-markeddup.bam"), emit: markeddup
    path "${meta.id}-markeddup_metrics.txt"
    tuple val(meta), path("${meta.id}-dedup.bam"), emit: dedup

    script:
    """
    samtools markdup -@ ${task.cpus} -s -O bam ${bam} ${meta.id}-markeddup.bam 2> ${meta.id}-markeddup_metrics.txt
    samtools view -h -b -@ ${task.cpus} -F 0x400 ${meta.id}-markeddup.bam > ${meta.id}-dedup.bam
    """
}
