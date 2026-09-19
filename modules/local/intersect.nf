// Ported from pipeline_ref/Snakefile rule `intersect` (lines 495-516).
process INTERSECT {
    tag "${meta.id}"

    input:
    tuple val(meta), path(sample)
    path features

    output:
    tuple val(meta), path("${meta.id}-intersect.bed"), emit: bed
    tuple val("${task.process}"), val('bedtools'), eval('bedtools --version | sed "s/bedtools //"'), emit: versions, topic: versions

    script:
    """
    bedtools intersect -a ${features} -b ${sample} -wo > ${meta.id}-intersect.bed
    """
}
