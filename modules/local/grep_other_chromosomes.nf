// Ported from pipeline_ref/Snakefile rule `grep_other_chromosomes` (lines
// 372-399). pipeline_ref trims this to per-contig read counts only - the
// KAN/plasmid/locus sam-splitting outputs were dropped along with the
// Keio-sanity subpipeline that was their only consumer.
process GREP_OTHER_CHROMOSOMES {
    tag "${meta.id}"

    input:
    tuple val(meta), path(dedup_bam)

    output:
    tuple val(meta), path("${meta.id}-chrcount.tsv"), emit: chr_count

    script:
    """
    samtools index ${dedup_bam}
    samtools idxstats ${dedup_bam} > ${meta.id}-chrcount.tsv
    """
}
