// Ported from nfcore_HTTM/modules/samtools_sort.nf (originally the samtools half +
// min_mapped_reads guard of pipeline/Snakefile rule `map_reads`).
process SAMTOOLS_SORT {
    tag "${meta.id}"

    input:
    tuple val(meta), path(sam)

    output:
    tuple val(meta), path("${meta.id}.bam"), emit: bam
    tuple val("${task.process}"), val('samtools'), eval('samtools --version | head -1 | sed "s/samtools //"'), emit: versions, topic: versions

    script:
    """
    samtools view -bh -q ${params.mapQ_threshold} -@ ${task.cpus} ${sam} | \
        samtools sort -n -m 512M -@ ${task.cpus} - | \
        samtools fixmate -m - - | \
        samtools sort -m 512M -@ ${task.cpus} -O BAM -o ${meta.id}.bam -

    n_mapped=\$(samtools view -c -F 4 ${meta.id}.bam)
    if [ "\$n_mapped" -lt ${params.min_mapped_reads} ]; then
        echo "map_reads: only \$n_mapped mapped reads for ${meta.id} (minimum ${params.min_mapped_reads}) - refusing to treat this as a successful output" >&2
        exit 1
    fi
    """
}
